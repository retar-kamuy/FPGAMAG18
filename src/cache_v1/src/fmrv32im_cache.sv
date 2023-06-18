module fmrv32im_cache #(
  parameter INTEL     = 0,
  parameter OSRAM     = 0,
  parameter MEM_FILE  = ""
) (
  input                 RST_N               ,
  input                 CLK                 ,
  // Instruction Memory
  output                I_MEM_WAIT          ,
  input                 I_MEM_ENA           ,
  input         [31:0]  I_MEM_ADDR          ,
  output        [31:0]  I_MEM_RDATA         ,
  output                I_MEM_BADMEM_EXCPT  ,
  // Data Memory
  output                D_MEM_WAIT          ,
  input                 D_MEM_ENA           ,
  input         [3:0]   D_MEM_WSTB          ,
  input         [31:0]  D_MEM_ADDR          ,
  input         [31:0]  D_MEM_WDATA         ,
  output logic  [31:0]  D_MEM_RDATA         ,
  output                D_MEM_BADMEM_EXCPT  ,
  // Local Control for AXI4 Master
  output                WR_REQ_START        ,
  output        [31:0]  WR_REQ_ADDR         ,
  output        [15:0]  WR_REQ_LEN          ,
  input                 WR_REQ_READY        ,
  input         [9:0]   WR_REQ_MEM_ADDR     ,
  output logic  [31:0]  WR_REQ_MEM_WDATA    ,
  output                RD_REQ_START        ,
  output        [31:0]  RD_REQ_ADDR         ,
  output        [15:0]  RD_REQ_LEN          ,
  input                 RD_REQ_READY        ,
  input                 RD_REQ_MEM_WE       ,
  input         [9:0]   RD_REQ_MEM_ADDR     ,
  input         [31:0]  RD_REQ_MEM_RDATA
);

  enum logic [2:0] {
    S_IDLE    = 0,
    S_W_REQ   = 1,
    S_W_WAIT  = 2,
    S_R_REQ   = 3,
    S_R_WAIT  = 4
  } state;

  // メモリマップ判定
  logic isel_ram, isel_illegal;
  assign isel_ram     = (I_MEM_ENA & (I_MEM_ADDR[31:30] == 2'b00));
  assign isel_illegal = (I_MEM_ENA & (I_MEM_ADDR[31:30] != 2'b00));

  logic dsel_ram, dsel_illegal;
  assign dsel_ram     = (D_MEM_ENA & (D_MEM_ADDR[31:30] == 2'b00));
  assign dsel_illegal = (D_MEM_ENA & (D_MEM_ADDR[31:30] != 2'b00));

  // I-Cache, D-Cache
  logic [31:0] imem [0:1023];
  logic [31:0] dmem [0:1023];

  logic [31:0] i_base, d_base;

  // キャッシュ判定
  logic I_MEM_miss, D_MEM_miss;
  logic i_valid, d_valid;

  generate 
    if(OSRAM == 0) begin
      assign I_MEM_miss = I_MEM_ENA & isel_ram &
                          ~(|(I_MEM_ADDR[29:12] == i_base[29:12]));
      assign D_MEM_miss = D_MEM_ENA & dsel_ram &
                          ~(|(D_MEM_ADDR[29:12] == d_base[29:12]));
    end else begin
      assign I_MEM_miss = I_MEM_ENA & isel_ram &
                          ~(|(I_MEM_ADDR[29:12] == i_base[29:12])) | ~i_valid;
      assign D_MEM_miss = D_MEM_ENA & dsel_ram &
                          ~(|(D_MEM_ADDR[29:12] == d_base[29:12])) | ~d_valid;
    end
  endgenerate

  assign I_MEM_WAIT = I_MEM_miss;
  assign D_MEM_WAIT = D_MEM_miss;
  assign I_MEM_BADMEM_EXCPT = isel_illegal & ~I_MEM_miss;
  assign D_MEM_BADMEM_EXCPT = dsel_illegal & ~D_MEM_miss;

  logic [15:0] leng;
  logic channel;
  logic [31:0] req_base;

  // 簡易キャッシュ管理
  always @(posedge CLK or negedge RST_N) begin
    if(~RST_N) begin
      state    <= S_IDLE;
      channel  <= 0;
      leng     <= 0;
      req_base <= 0;
      i_base   <= 0;
      d_base   <= 0;
      i_valid  <= 0;
      d_valid  <= 0;
    end else begin
      case(state)
        S_IDLE:
          if(I_MEM_miss) begin
            if(RD_REQ_READY) begin
              state    <= S_R_REQ;
              channel  <= 1'b0;
              leng     <= 16'd4096;
              req_base <= {I_MEM_ADDR[31:12], 12'd0};
            end
          end else if(D_MEM_miss) begin
            if(WR_REQ_READY & d_valid) begin
              state    <= S_W_REQ;
              channel  <= 1'b1;
              leng     <= 16'd4096;
              req_base <= {d_base[31:12], 12'd0};
            end else if(RD_REQ_READY & ~d_valid) begin
              state    <= S_R_REQ;
              channel  <= 1'b1;
              leng     <= 16'd4096;
              req_base <= {D_MEM_ADDR[31:12], 12'd0};
            end
          end
        S_W_REQ:
          state <= S_W_WAIT;
        S_W_WAIT:
          if(WR_REQ_READY) begin
            state    <= S_R_REQ;
            channel  <= 1'b1;
            leng     <= 16'd4096;
            req_base <= {D_MEM_ADDR[31:12], 12'd0};
          end
        S_R_REQ:
          state <= S_R_WAIT;
        S_R_WAIT:
          if(RD_REQ_READY) begin
            state <= S_IDLE;
            if(channel) begin
              d_base <= req_base;
              d_valid <= 1;
            end else begin
              i_base <= req_base;
              i_valid <= 1;
            end
          end
      endcase
    end
  end

  assign WR_REQ_START = (state == S_W_REQ);
  assign WR_REQ_ADDR  = req_base;
  assign WR_REQ_LEN   = leng;
  assign RD_REQ_START = (state == S_R_REQ);
  assign RD_REQ_ADDR  = req_base;
  assign RD_REQ_LEN   = leng;

  logic [9:0] mem_addr;
  assign mem_addr = WR_REQ_MEM_ADDR | RD_REQ_MEM_ADDR;

  generate
    if(INTEL == 0) begin
      // for non Verndor Lock
      // I-Cache Memory
      logic [31:0] I_MEM_rdata_out;

      always @(posedge CLK)
        if(!channel & RD_REQ_MEM_WE)
          imem[mem_addr] <= RD_REQ_MEM_RDATA;
        else begin
          if(~D_MEM_miss & D_MEM_WSTB[0]) imem[D_MEM_ADDR[11:2]][7:0]   <= D_MEM_WDATA[7:0];
          if(~D_MEM_miss & D_MEM_WSTB[1]) imem[D_MEM_ADDR[11:2]][15:8]  <= D_MEM_WDATA[15:8];
          if(~D_MEM_miss & D_MEM_WSTB[2]) imem[D_MEM_ADDR[11:2]][23:16] <= D_MEM_WDATA[23:16];
          if(~D_MEM_miss & D_MEM_WSTB[3]) imem[D_MEM_ADDR[11:2]][31:24] <= D_MEM_WDATA[31:24];
        end

      always @(posedge CLK or negedge RST_N)
        if (~RST_N)
          I_MEM_rdata_out <= 32'd0;
        else
          I_MEM_rdata_out <= imem[I_MEM_ADDR[11:2]];

      assign I_MEM_RDATA = I_MEM_rdata_out;

      // D-Cache Memory
      always @(posedge CLK)
        if(channel & RD_REQ_MEM_WE)
          dmem[mem_addr] <= RD_REQ_MEM_RDATA;
        else begin
          if(~D_MEM_miss & D_MEM_WSTB[0]) dmem[D_MEM_ADDR[11:2]][7:0]   <= D_MEM_WDATA[7:0];
          if(~D_MEM_miss & D_MEM_WSTB[1]) dmem[D_MEM_ADDR[11:2]][15:8]  <= D_MEM_WDATA[15:8];
          if(~D_MEM_miss & D_MEM_WSTB[2]) dmem[D_MEM_ADDR[11:2]][23:16] <= D_MEM_WDATA[23:16];
          if(~D_MEM_miss & D_MEM_WSTB[3]) dmem[D_MEM_ADDR[11:2]][31:24] <= D_MEM_WDATA[31:24];
        end

      always @(posedge CLK or negedge RST_N)
        if (~RST_N) begin
          WR_REQ_MEM_WDATA <= 32'd0;
          D_MEM_RDATA <= 32'd0;
        end else begin
          WR_REQ_MEM_WDATA <= dmem[mem_addr];
          D_MEM_RDATA <= dmem[D_MEM_ADDR[11:2]];
        end

      // initial $readmemh(MEM_FILE, imem, 0, 1023);
      // initial $readmemh(MEM_FILE, dmem, 0, 1023);
    end else begin
      // for Intel FPGA
      fmrv32im_intel_cram #(
        .MEM_FILE   (MEM_FILE                 )
      ) u_icache_cram (
        .clock_a    (CLK                      ),
        .address_a  (mem_addr                 ),
        .wren_a     (!channel & RD_REQ_MEM_WE ),
        .data_a     (RD_REQ_MEM_RDATA         ),
        .q_a        (                         ),
        .clock_b    (CLK                      ),
        .address_b  (I_MEM_ADDR[11:2]         ),
        .byteena_b  (4'd0                     ),
        .data_b     (32'd0                    ),
        .wren_b     (1'd0                     ),
        .q_b        (I_MEM_RDATA              )
      );

      fmrv32im_intel_cram #(
        .MEM_FILE   (MEM_FILE                 )
      ) u_dcache_cram (
        .clock_a    (CLK                      ),
        .address_a  (mem_addr                 ),
        .wren_a     (channel & RD_REQ_MEM_WE  ),
        .data_a     (RD_REQ_MEM_RDATA         ),
        .q_a        (WR_REQ_MEM_WDATA         ),
        .clock_b    (CLK                      ),
        .address_b  (D_MEM_ADDR[11:2]         ),
        .byteena_b  (D_MEM_WSTB               ),
        .data_b     (D_MEM_WDATA              ),
        .wren_b     (D_MEM_WSTB[3] | D_MEM_WSTB[2] | D_MEM_WSTB[1] | D_MEM_WSTB[0] ),
        .q_b        (D_MEM_RDATA              )
      );
    end
  endgenerate

`ifdef verilator
  //-------------------------------------------------------------
  // set_imem: Write byte into memory
  //-------------------------------------------------------------
  export "DPI-C" task set_imem;
  task set_imem(string path);
    $info("readmemh path: %s\n", path);
    $readmemh(path, imem, 0, 1023);
  endtask
  //-------------------------------------------------------------
  // set_dmem: Write byte into memory
  //-------------------------------------------------------------
  export "DPI-C" task set_dmem;
  task set_dmem(string path);
    $info("readmemh path: %s\n", path);
    $readmemh(path, dmem, 0, 1023);
  endtask
`endif  // verilator

endmodule
