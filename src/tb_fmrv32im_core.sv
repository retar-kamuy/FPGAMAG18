`timescale 1ns / 1ps
`include "vunit_defines.svh"

module tb_fmrv32im_core;
   reg RST_N;
   reg CLK;

   reg [31:0] INTERRUPT;

   // Write Address Channel
   wire [15:0] IM_AXI_AWADDR;
   wire [3:0]  IM_AXI_AWCACHE;
   wire [2:0]  IM_AXI_AWPROT;
   wire        IM_AXI_AWVALID;
   wire        IM_AXI_AWREADY;

   // Write Data Channel
   wire [31:0] IM_AXI_WDATA;
   wire [3:0]  IM_AXI_WSTRB;
   wire        IM_AXI_WVALID;
   wire        IM_AXI_WREADY;

   // Write Response Channel
   wire        IM_AXI_BVALID;
   wire        IM_AXI_BREADY;
   wire [1:0]  IM_AXI_BRESP;

   // Read Address Channel
   wire [15:0] IM_AXI_ARADDR;
   wire [3:0]  IM_AXI_ARCACHE;
   wire [2:0]  IM_AXI_ARPROT;
   wire        IM_AXI_ARVALID;
   wire        IM_AXI_ARREADY;

   // Read Data Channel
   wire [31:0] IM_AXI_RDATA;
   wire [1:0]  IM_AXI_RRESP;
   wire        IM_AXI_RVALID;
   wire        IM_AXI_RREADY;

   // --------------------------------------------------
   // AXI4 Interface(Master)
   // --------------------------------------------------

   // Master Write Address
   wire [0:0]  MM_AXI_AWID;
   wire [31:0] MM_AXI_AWADDR;
   wire [7:0]  MM_AXI_AWLEN;
   wire [2:0]  MM_AXI_AWSIZE;
   wire [1:0]  MM_AXI_AWBURST;
   wire        MM_AXI_AWLOCK;
   wire [3:0]  MM_AXI_AWCACHE;
   wire [2:0]  MM_AXI_AWPROT;
   wire [3:0]  MM_AXI_AWQOS;
   wire [0:0]  MM_AXI_AWUSER;
   wire        MM_AXI_AWVALID;
   wire        MM_AXI_AWREADY;

   // Master Write Data
   wire [31:0] MM_AXI_WDATA;
   wire [3:0]  MM_AXI_WSTRB;
   wire        MM_AXI_WLAST;
   wire [0:0]  MM_AXI_WUSER;
   wire        MM_AXI_WVALID;
   wire        MM_AXI_WREADY;

   // Master Write Response
   wire [0:0]  MM_AXI_BID;
   wire [1:0]  MM_AXI_BRESP;
   wire [0:0]  MM_AXI_BUSER;
   wire        MM_AXI_BVALID;
   wire        MM_AXI_BREADY;

   // Master Read Address
   wire [0:0]  MM_AXI_ARID;
   wire [31:0] MM_AXI_ARADDR;
   wire [7:0]  MM_AXI_ARLEN;
   wire [2:0]  MM_AXI_ARSIZE;
   wire [1:0]  MM_AXI_ARBURST;
   wire [1:0]  MM_AXI_ARLOCK;
   wire [3:0]  MM_AXI_ARCACHE;
   wire [2:0]  MM_AXI_ARPROT;
   wire [3:0]  MM_AXI_ARQOS;
   wire [0:0]  MM_AXI_ARUSER;
   wire        MM_AXI_ARVALID;
   wire        MM_AXI_ARREADY;

   // Master Read Data
   wire [0:0]  MM_AXI_RID;
   wire [31:0] MM_AXI_RDATA;
   wire [1:0]  MM_AXI_RRESP;
   wire        MM_AXI_RLAST;
   wire [0:0]  MM_AXI_RUSER;
   wire        MM_AXI_RVALID;
   wire        MM_AXI_RREADY;

   logic [31:0] rslt;

   // Clock
   localparam CLK100M = 10;
   always begin
      #(CLK100M/2) CLK <= ~CLK;
   end

   task load_elf(input string path);
      $info("Load ELF: Simulatin Start %s\n", path);
      $readmemh(path, u_fmrv32im_core.u_fmrv32im_cache.imem, 0, 1023);
      $readmemh(path, u_fmrv32im_core.u_fmrv32im_cache.dmem, 0, 1023);

      @(posedge CLK);
      $info("Process Start");
   endtask

   // Sinario
   `TEST_SUITE begin
      `TEST_SUITE_SETUP begin
         $info("Running test suite setup code");
         RST_N = 1'b0;
         CLK   = 1'b0;

         INTERRUPT = 0;
      end

      `TEST_CASE_SETUP begin
         $info("Running test case setup code");
         @(posedge CLK);
         RST_N = 1'b1;
         $info("Simulation Start");
      end

      `TEST_CASE("rv32ui-p-add") load_elf("rv32ui-p-add.hex");
      `TEST_CASE("rv32ui-p-addi") load_elf("rv32ui-p-addi.hex");
      `TEST_CASE("rv32ui-p-and") load_elf("rv32ui-p-and.hex");
      `TEST_CASE("rv32ui-p-andi") load_elf("rv32ui-p-andi.hex");
      `TEST_CASE("rv32ui-p-auipc") load_elf("rv32ui-p-auipc.hex");
      `TEST_CASE("rv32ui-p-beq") load_elf("rv32ui-p-beq.hex");
      `TEST_CASE("rv32ui-p-bge") load_elf("rv32ui-p-bge.hex");
      `TEST_CASE("rv32ui-p-bgeu") load_elf("rv32ui-p-bgeu.hex");
      `TEST_CASE("rv32ui-p-blt") load_elf("rv32ui-p-blt.hex");
      `TEST_CASE("rv32ui-p-bltu") load_elf("rv32ui-p-bltu.hex");
      `TEST_CASE("rv32ui-p-bne") load_elf("rv32ui-p-bne.hex");
      `TEST_CASE("rv32ui-p-fence_i") load_elf("rv32ui-p-fence_i.hex");
      `TEST_CASE("rv32ui-p-jal") load_elf("rv32ui-p-jal.hex");
      `TEST_CASE("rv32ui-p-jalr") load_elf("rv32ui-p-jalr.hex");
      `TEST_CASE("rv32ui-p-lb") load_elf("rv32ui-p-lb.hex");
      `TEST_CASE("rv32ui-p-lbu") load_elf("rv32ui-p-lbu.hex");
      `TEST_CASE("rv32ui-p-lh") load_elf("rv32ui-p-lh.hex");
      `TEST_CASE("rv32ui-p-lhu") load_elf("rv32ui-p-lhu.hex");
      `TEST_CASE("rv32ui-p-lui") load_elf("rv32ui-p-lui.hex");
      `TEST_CASE("rv32ui-p-lw") load_elf("rv32ui-p-lw.hex");
      `TEST_CASE("rv32ui-p-or") load_elf("rv32ui-p-or.hex");
      `TEST_CASE("rv32ui-p-ori") load_elf("rv32ui-p-ori.hex");
      `TEST_CASE("rv32ui-p-sb") load_elf("rv32ui-p-sb.hex");
      `TEST_CASE("rv32ui-p-sh") load_elf("rv32ui-p-sh.hex");
      `TEST_CASE("rv32ui-p-simple") load_elf("rv32ui-p-simple.hex");
      `TEST_CASE("rv32ui-p-sll") load_elf("rv32ui-p-sll.hex");
      `TEST_CASE("rv32ui-p-slli") load_elf("rv32ui-p-slli.hex");
      `TEST_CASE("rv32ui-p-slt") load_elf("rv32ui-p-slt.hex");
      `TEST_CASE("rv32ui-p-slti") load_elf("rv32ui-p-slti.hex");
      `TEST_CASE("rv32ui-p-sltiu") load_elf("rv32ui-p-sltiu.hex");
      `TEST_CASE("rv32ui-p-sltu") load_elf("rv32ui-p-sltu.hex");
      `TEST_CASE("rv32ui-p-sra") load_elf("rv32ui-p-sra.hex");
      `TEST_CASE("rv32ui-p-srai") load_elf("rv32ui-p-srai.hex");
      `TEST_CASE("rv32ui-p-srl") load_elf("rv32ui-p-srl.hex");
      `TEST_CASE("rv32ui-p-srli") load_elf("rv32ui-p-srli.hex");
      `TEST_CASE("rv32ui-p-sub") load_elf("rv32ui-p-sub.hex");
      `TEST_CASE("rv32ui-p-sw") load_elf("rv32ui-p-sw.hex");
      `TEST_CASE("rv32ui-p-xor") load_elf("rv32ui-p-xor.hex");
      `TEST_CASE("rv32ui-p-xori") load_elf("rv32ui-p-xori.hex");
      `TEST_CASE("rv32um-p-div") load_elf("rv32um-p-div.hex");
      `TEST_CASE("rv32um-p-divu") load_elf("rv32um-p-divu.hex");
      `TEST_CASE("rv32um-p-mul") load_elf("rv32um-p-mul.hex");
      `TEST_CASE("rv32um-p-mulh") load_elf("rv32um-p-mulh.hex");
      `TEST_CASE("rv32um-p-mulhsu") load_elf("rv32um-p-mulhsu.hex");
      `TEST_CASE("rv32um-p-mulhu") load_elf("rv32um-p-mulhu.hex");
      `TEST_CASE("rv32um-p-rem") load_elf("rv32um-p-rem.hex");
      `TEST_CASE("rv32um-p-remu") load_elf("rv32um-p-remu.hex");

      `TEST_CASE_CLEANUP begin
         wait(
            (u_fmrv32im_core.dbus_addr == 32'h0000_0800) &
	         (u_fmrv32im_core.dbus_wstb == 4'hF)
         );
         rslt <= u_fmrv32im_core.dbus_wdata;
         repeat(10) @(posedge CLK);
      end

      `TEST_SUITE_CLEANUP begin
         $info("Simulatin Finish");
         assert(rslt === 32'd1) begin
            $info("Success Result: %8x\n", rslt);
         end
            else begin
               $fatal("Error Result: %8x\n", rslt);
            end
      end
   end

   fmrv32im_core u_fmrv32im_core (
      .RST_N          (RST_N),
      .CLK            (CLK),

      .INTERRUPT      (INTERRUPT),

      // ------------------------------------------------------------
      // Master Write Address
      .MM_AXI_AWID    (MM_AXI_AWID),
      .MM_AXI_AWADDR  (MM_AXI_AWADDR),
      .MM_AXI_AWLEN   (MM_AXI_AWLEN),
      .MM_AXI_AWSIZE  (MM_AXI_AWSIZE),
      .MM_AXI_AWBURST (MM_AXI_AWBURST),
      .MM_AXI_AWLOCK  (MM_AXI_AWLOCK),
      .MM_AXI_AWCACHE (MM_AXI_AWCACHE),
      .MM_AXI_AWPROT  (MM_AXI_AWPROT),
      .MM_AXI_AWQOS   (MM_AXI_AWQOS),
      .MM_AXI_AWUSER  (MM_AXI_AWUSER),
      .MM_AXI_AWVALID (MM_AXI_AWVALID),
      .MM_AXI_AWREADY (MM_AXI_AWREADY),

      // Master Write Data
      .MM_AXI_WDATA   (MM_AXI_WDATA),
      .MM_AXI_WSTRB   (MM_AXI_WSTRB),
      .MM_AXI_WLAST   (MM_AXI_WLAST),
      .MM_AXI_WUSER   (MM_AXI_WUSER),
      .MM_AXI_WVALID  (MM_AXI_WVALID),
      .MM_AXI_WREADY  (MM_AXI_WREADY),

      // Master Write Response
      .MM_AXI_BID     (MM_AXI_BID),
      .MM_AXI_BRESP   (MM_AXI_BRESP),
      .MM_AXI_BUSER   (MM_AXI_BUSER),
      .MM_AXI_BVALID  (MM_AXI_BVALID),
      .MM_AXI_BREADY  (MM_AXI_BREADY),

      // Master Read Address
      .MM_AXI_ARID    (MM_AXI_ARID),
      .MM_AXI_ARADDR  (MM_AXI_ARADDR),
      .MM_AXI_ARLEN   (MM_AXI_ARLEN),
      .MM_AXI_ARSIZE  (MM_AXI_ARSIZE),
      .MM_AXI_ARBURST (MM_AXI_ARBURST),
      .MM_AXI_ARLOCK  (MM_AXI_ARLOCK),
      .MM_AXI_ARCACHE (MM_AXI_ARCACHE),
      .MM_AXI_ARPROT  (MM_AXI_ARPROT),
      .MM_AXI_ARQOS   (MM_AXI_ARQOS),
      .MM_AXI_ARUSER  (MM_AXI_ARUSER),
      .MM_AXI_ARVALID (MM_AXI_ARVALID),
      .MM_AXI_ARREADY (MM_AXI_ARREADY),

      // Master Read Data
      .MM_AXI_RID     (MM_AXI_RID),
      .MM_AXI_RDATA   (MM_AXI_RDATA),
      .MM_AXI_RRESP   (MM_AXI_RRESP),
      .MM_AXI_RLAST   (MM_AXI_RLAST),
      .MM_AXI_RUSER   (MM_AXI_RUSER),
      .MM_AXI_RVALID  (MM_AXI_RVALID),
      .MM_AXI_RREADY  (MM_AXI_RREADY),

      // ------------------------------------------------------------
      // Write Address Channel
      .IM_AXI_AWADDR  (IM_AXI_AWADDR),
      .IM_AXI_AWCACHE (IM_AXI_AWCACHE),
      .IM_AXI_AWPROT  (IM_AXI_AWPROT),
      .IM_AXI_AWVALID (IM_AXI_AWVALID),
      .IM_AXI_AWREADY (IM_AXI_AWREADY),

      // Write Data Channel
      .IM_AXI_WDATA   (IM_AXI_WDATA),
      .IM_AXI_WSTRB   (IM_AXI_WSTRB),
      .IM_AXI_WVALID  (IM_AXI_WVALID),
      .IM_AXI_WREADY  (IM_AXI_WREADY),

      // Write Response Channel
      .IM_AXI_BVALID  (IM_AXI_BVALID),
      .IM_AXI_BREADY  (IM_AXI_BREADY),
      .IM_AXI_BRESP   (IM_AXI_BRESP),

      // Read Address Channel
      .IM_AXI_ARADDR  (IM_AXI_ARADDR),
      .IM_AXI_ARCACHE (IM_AXI_ARCACHE),
      .IM_AXI_ARPROT  (IM_AXI_ARPROT),
      .IM_AXI_ARVALID (IM_AXI_ARVALID),
      .IM_AXI_ARREADY (IM_AXI_ARREADY),

      // Read Data Channel
      .IM_AXI_RDATA   (IM_AXI_RDATA),
      .IM_AXI_RRESP   (IM_AXI_RRESP),
      .IM_AXI_RVALID  (IM_AXI_RVALID),
      .IM_AXI_RREADY  (IM_AXI_RREADY)
   );


   tb_axi_slave_model u_axi_slave
     (
      // Reset, Clock
      .ARESETN       ( RST_N          ),
      .ACLK          ( CLK            ),

      // Master Write Address
      .M_AXI_AWID    ( MM_AXI_AWID    ),
      .M_AXI_AWADDR  ( MM_AXI_AWADDR  ),
      .M_AXI_AWLEN   ( MM_AXI_AWLEN   ),
      .M_AXI_AWSIZE  ( MM_AXI_AWSIZE  ),
      .M_AXI_AWBURST ( MM_AXI_AWBURST ),
      .M_AXI_AWLOCK  ( MM_AXI_AWLOCK  ),
      .M_AXI_AWCACHE ( MM_AXI_AWCACHE ),
      .M_AXI_AWPROT  ( MM_AXI_AWPROT  ),
      .M_AXI_AWQOS   ( MM_AXI_AWQOS   ),
      .M_AXI_AWUSER  ( MM_AXI_AWUSER  ),
      .M_AXI_AWVALID ( MM_AXI_AWVALID ),
      .M_AXI_AWREADY ( MM_AXI_AWREADY ),

      // Master Write Data
      .M_AXI_WDATA   ( MM_AXI_WDATA   ),
      .M_AXI_WSTRB   ( MM_AXI_WSTRB   ),
      .M_AXI_WLAST   ( MM_AXI_WLAST   ),
      .M_AXI_WUSER   ( MM_AXI_WUSER   ),
      .M_AXI_WVALID  ( MM_AXI_WVALID  ),
      .M_AXI_WREADY  ( MM_AXI_WREADY  ),

      // Master Write Response
      .M_AXI_BID     ( MM_AXI_BID     ),
      .M_AXI_BRESP   ( MM_AXI_BRESP   ),
      .M_AXI_BUSER   ( MM_AXI_BUSER   ),
      .M_AXI_BVALID  ( MM_AXI_BVALID  ),
      .M_AXI_BREADY  ( MM_AXI_BREADY  ),

      // Master Read Address
      .M_AXI_ARID    ( MM_AXI_ARID    ),
      .M_AXI_ARADDR  ( MM_AXI_ARADDR  ),
      .M_AXI_ARLEN   ( MM_AXI_ARLEN   ),
      .M_AXI_ARSIZE  ( MM_AXI_ARSIZE  ),
      .M_AXI_ARBURST ( MM_AXI_ARBURST ),
      // .M_AXI_ARLOCK(),
      .M_AXI_ARLOCK  ( MM_AXI_ARLOCK  ),
      .M_AXI_ARCACHE ( MM_AXI_ARCACHE ),
      .M_AXI_ARPROT  ( MM_AXI_ARPROT  ),
      .M_AXI_ARQOS   ( MM_AXI_ARQOS   ),
      .M_AXI_ARUSER  ( MM_AXI_ARUSER  ),
      .M_AXI_ARVALID ( MM_AXI_ARVALID ),
      .M_AXI_ARREADY ( MM_AXI_ARREADY ),

      // Master Read Data
      .M_AXI_RID     ( MM_AXI_RID     ),
      .M_AXI_RDATA   ( MM_AXI_RDATA   ),
      .M_AXI_RRESP   ( MM_AXI_RRESP   ),
      .M_AXI_RLAST   ( MM_AXI_RLAST   ),
      .M_AXI_RUSER   ( MM_AXI_RUSER   ),
      .M_AXI_RVALID  ( MM_AXI_RVALID  ),
      .M_AXI_RREADY  ( MM_AXI_RREADY  )
      );

   tb_axil_slave_model u_axil_slave
     (
      // Reset, Clock
      .ARESETN       ( RST_N          ),
      .ACLK          ( CLK            ),

      // Master Write Address
      .M_AXI_AWADDR  ( IM_AXI_AWADDR  ),
      .M_AXI_AWCACHE ( IM_AXI_AWCACHE ),
      .M_AXI_AWPROT  ( IM_AXI_AWPROT  ),
      .M_AXI_AWVALID ( IM_AXI_AWVALID ),
      .M_AXI_AWREADY ( IM_AXI_AWREADY ),

      // Master Write Data
      .M_AXI_WDATA   ( IM_AXI_WDATA   ),
      .M_AXI_WSTRB   ( IM_AXI_WSTRB   ),
      .M_AXI_WVALID  ( IM_AXI_WVALID  ),
      .M_AXI_WREADY  ( IM_AXI_WREADY  ),

      // Master Write Response
      .M_AXI_BRESP   ( IM_AXI_BRESP   ),
      .M_AXI_BVALID  ( IM_AXI_BVALID  ),
      .M_AXI_BREADY  ( IM_AXI_BREADY  ),

      // Master Read Address
      .M_AXI_ARADDR  ( IM_AXI_ARADDR  ),
      .M_AXI_ARCACHE ( IM_AXI_ARCACHE ),
      .M_AXI_ARPROT  ( IM_AXI_ARPROT  ),
      .M_AXI_ARVALID ( IM_AXI_ARVALID ),
      .M_AXI_ARREADY ( IM_AXI_ARREADY ),

      // Master Read Data
      .M_AXI_RDATA   ( IM_AXI_RDATA   ),
      .M_AXI_RRESP   ( IM_AXI_RRESP   ),
      .M_AXI_RVALID  ( IM_AXI_RVALID  ),
      .M_AXI_RREADY  ( IM_AXI_RREADY  )
      );

endmodule // tb_fmrv32im_core
