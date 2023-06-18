`timescale 1ns / 1ps

module tb_top (input clk, output logic [31:0] rslt);
  logic         rst_n   ;
  // logic         clk = 0 ;
  logic         RXD     ;
  logic         TXD     ;
  logic [31:0]  GPIO_I  ;
  logic [31:0]  GPIO_O  ;
  logic [31:0]  GPIO_OT ;

  // --------------------------------------------------
  // AXI4 Interface(Master)
  // --------------------------------------------------
  // Master Write Address
  logic [0:0]   MM_AXI_AWID     ;
  logic [31:0]  MM_AXI_AWADDR   ;
  logic [7:0]   MM_AXI_AWLEN    ;
  logic [2:0]   MM_AXI_AWSIZE   ;
  logic [1:0]   MM_AXI_AWBURST  ;
  logic         MM_AXI_AWLOCK   ;
  logic [3:0]   MM_AXI_AWCACHE  ;
  logic [2:0]   MM_AXI_AWPROT   ;
  logic [3:0]   MM_AXI_AWQOS    ;
  logic [0:0]   MM_AXI_AWUSER   ;
  logic         MM_AXI_AWVALID  ;
  logic         MM_AXI_AWREADY  ;
  // Master Write Data
  logic [31:0]  MM_AXI_WDATA    ;
  logic [3:0]   MM_AXI_WSTRB    ;
  logic         MM_AXI_WLAST    ;
  logic [0:0]   MM_AXI_WUSER    ;
  logic         MM_AXI_WVALID   ;
  logic         MM_AXI_WREADY   ;
  // Master Write Response
  logic [0:0]   MM_AXI_BID      ;
  logic [1:0]   MM_AXI_BRESP    ;
  logic [0:0]   MM_AXI_BUSER    ;
  logic         MM_AXI_BVALID   ;
  logic         MM_AXI_BREADY   ;
  // Master Read Address
  logic [0:0]   MM_AXI_ARID     ;
  logic [31:0]  MM_AXI_ARADDR   ;
  logic [7:0]   MM_AXI_ARLEN    ;
  logic [2:0]   MM_AXI_ARSIZE   ;
  logic [1:0]   MM_AXI_ARBURST  ;
  logic [1:0]   MM_AXI_ARLOCK   ;
  logic [3:0]   MM_AXI_ARCACHE  ;
  logic [2:0]   MM_AXI_ARPROT   ;
  logic [3:0]   MM_AXI_ARQOS    ;
  logic [0:0]   MM_AXI_ARUSER   ;
  logic         MM_AXI_ARVALID  ;
  logic         MM_AXI_ARREADY  ;
  // Master Read Data
  logic [0:0]   MM_AXI_RID      ;
  logic [31:0]  MM_AXI_RDATA    ;
  logic [1:0]   MM_AXI_RRESP    ;
  logic         MM_AXI_RLAST    ;
  logic [0:0]   MM_AXI_RUSER    ;
  logic         MM_AXI_RVALID   ;
  logic         MM_AXI_RREADY   ;

  // logic [31:0]  rslt            ;

  // Clock
  // localparam CLK100M = 10ns;
  // initial begin
  //   clk = 0;
  //   forever
  //     #(CLK100M / 2) clk = ~clk;
  // end

  task load_elf(input string path);
    $info("Load ELF: Simulatin Start %s\n", path);
    $readmemh(path, u_fmrv32im_core.u_fmrv32im_cache.imem, 0, 1023);
    $readmemh(path, u_fmrv32im_core.u_fmrv32im_cache.dmem, 0, 1023);

    @(posedge clk);
    $info("Process Start");
  endtask

  // Sinario
  initial begin
    $info("Running test suite setup code");
    rst_n   = 0;
    RXD     = 0;
    GPIO_I  = 0;

    $info("Running test case setup code");
    repeat(5) @(posedge clk);
    rst_n = 1;
    $info("Simulation Start");

    // load_elf("rv32ui-p-add.hex");
    $info("Load ELF: Simulatin Start %s\n", "rv32ui-p-add.hex");
    $readmemh("env/tests/rv32ui-p-add.hex", u_fmrv32im_core.u_fmrv32im_cache.imem, 0, 1023);
    $readmemh("env/tests/rv32ui-p-add.hex", u_fmrv32im_core.u_fmrv32im_cache.dmem, 0, 1023);

    repeat(5) @(posedge clk);
    $info("Process Start");

    wait(
      (u_fmrv32im_core.dbus_addr === 32'h0000_0800) &
      (u_fmrv32im_core.dbus_wstb === 4'hF)
    );
    rslt = u_fmrv32im_core.dbus_wdata;
    repeat(10) @(posedge clk);

    $info("Simulatin Finish");
    // assert(rslt === 1)
    //   $info("Success Result: %8x\n", rslt);
    // else
    //   $fatal("Error Result: %8x\n", rslt);

    $finish;
  end

  fmrv32im_core u_fmrv32im_core (
    .rst_n                  ,
    .clk                    ,
    // Master Write Address
    .MM_AXI_AWID            ,
    .MM_AXI_AWADDR          ,
    .MM_AXI_AWLEN           ,
    .MM_AXI_AWSIZE          ,
    .MM_AXI_AWBURST         ,
    .MM_AXI_AWLOCK          ,
    .MM_AXI_AWCACHE         ,
    .MM_AXI_AWPROT          ,
    .MM_AXI_AWQOS           ,
    .MM_AXI_AWUSER          ,
    .MM_AXI_AWVALID         ,
    .MM_AXI_AWREADY         ,
    // Master Write Data
    .MM_AXI_WDATA           ,
    .MM_AXI_WSTRB           ,
    .MM_AXI_WLAST           ,
    .MM_AXI_WUSER           ,
    .MM_AXI_WVALID          ,
    .MM_AXI_WREADY          ,
    // Master Write Response
    .MM_AXI_BID             ,
    .MM_AXI_BRESP           ,
    .MM_AXI_BUSER           ,
    .MM_AXI_BVALID          ,
    .MM_AXI_BREADY          ,
    // Master Read Address
    .MM_AXI_ARID            ,
    .MM_AXI_ARADDR          ,
    .MM_AXI_ARLEN           ,
    .MM_AXI_ARSIZE          ,
    .MM_AXI_ARBURST         ,
    .MM_AXI_ARLOCK          ,
    .MM_AXI_ARCACHE         ,
    .MM_AXI_ARPROT          ,
    .MM_AXI_ARQOS           ,
    .MM_AXI_ARUSER          ,
    .MM_AXI_ARVALID         ,
    .MM_AXI_ARREADY         ,
    // Master Read Data
    .MM_AXI_RID             ,
    .MM_AXI_RDATA           ,
    .MM_AXI_RRESP           ,
    .MM_AXI_RLAST           ,
    .MM_AXI_RUSER           ,
    .MM_AXI_RVALID          ,
    .MM_AXI_RREADY          ,
    .RXD                    ,
    .TXD                    ,
    .GPIO_I                 ,
    .GPIO_O                 ,
    .GPIO_OT
  );

  tb_axi_slave_model u_axi_slave (
    // Reset, Clock
    .ARESETN        (rst_n          ),
    .ACLK           (clk            ),
    // Master Write Address
    .M_AXI_AWID     (MM_AXI_AWID    ),
    .M_AXI_AWADDR   (MM_AXI_AWADDR  ),
    .M_AXI_AWLEN    (MM_AXI_AWLEN   ),
    .M_AXI_AWSIZE   (MM_AXI_AWSIZE  ),
    .M_AXI_AWBURST  (MM_AXI_AWBURST ),
    .M_AXI_AWLOCK   (MM_AXI_AWLOCK  ),
    .M_AXI_AWCACHE  (MM_AXI_AWCACHE ),
    .M_AXI_AWPROT   (MM_AXI_AWPROT  ),
    .M_AXI_AWQOS    (MM_AXI_AWQOS   ),
    .M_AXI_AWUSER   (MM_AXI_AWUSER  ),
    .M_AXI_AWVALID  (MM_AXI_AWVALID ),
    .M_AXI_AWREADY  (MM_AXI_AWREADY ),
    // Master Write Data
    .M_AXI_WDATA    (MM_AXI_WDATA   ),
    .M_AXI_WSTRB    (MM_AXI_WSTRB   ),
    .M_AXI_WLAST    (MM_AXI_WLAST   ),
    .M_AXI_WUSER    (MM_AXI_WUSER   ),
    .M_AXI_WVALID   (MM_AXI_WVALID  ),
    .M_AXI_WREADY   (MM_AXI_WREADY  ),
    // Master Write Response
    .M_AXI_BID      (MM_AXI_BID     ),
    .M_AXI_BRESP    (MM_AXI_BRESP   ),
    .M_AXI_BUSER    (MM_AXI_BUSER   ),
    .M_AXI_BVALID   (MM_AXI_BVALID  ),
    .M_AXI_BREADY   (MM_AXI_BREADY  ),
    // Master Read Address
    .M_AXI_ARID     (MM_AXI_ARID    ),
    .M_AXI_ARADDR   (MM_AXI_ARADDR  ),
    .M_AXI_ARLEN    (MM_AXI_ARLEN   ),
    .M_AXI_ARSIZE   (MM_AXI_ARSIZE  ),
    .M_AXI_ARBURST  (MM_AXI_ARBURST ),
    // .M_AXI_ARLOCK(),
    .M_AXI_ARLOCK   (MM_AXI_ARLOCK  ),
    .M_AXI_ARCACHE  (MM_AXI_ARCACHE ),
    .M_AXI_ARPROT   (MM_AXI_ARPROT  ),
    .M_AXI_ARQOS    (MM_AXI_ARQOS   ),
    .M_AXI_ARUSER   (MM_AXI_ARUSER  ),
    .M_AXI_ARVALID  (MM_AXI_ARVALID ),
    .M_AXI_ARREADY  (MM_AXI_ARREADY ),
    // Master Read Data
    .M_AXI_RID      (MM_AXI_RID     ),
    .M_AXI_RDATA    (MM_AXI_RDATA   ),
    .M_AXI_RRESP    (MM_AXI_RRESP   ),
    .M_AXI_RLAST    (MM_AXI_RLAST   ),
    .M_AXI_RUSER    (MM_AXI_RUSER   ),
    .M_AXI_RVALID   (MM_AXI_RVALID  ),
    .M_AXI_RREADY   (MM_AXI_RREADY  )
  );

endmodule
