module fmrv32im_core #(
  parameter MEM_FILE = "../../../../src/imem.hex"
) (
  input rst_n,
  input clk,
  // ------------------------------------------------------------
  // Master Write Address
  output [0:0] MM_AXI_AWID,
  output [31:0] MM_AXI_AWADDR,
  output [7:0] MM_AXI_AWLEN,
  output [2:0] MM_AXI_AWSIZE,
  output [1:0] MM_AXI_AWBURST,
  output MM_AXI_AWLOCK,
  output [3:0] MM_AXI_AWCACHE,
  output [2:0] MM_AXI_AWPROT,
  output [3:0] MM_AXI_AWQOS,
  output [0:0] MM_AXI_AWUSER,
  output MM_AXI_AWVALID,
  input MM_AXI_AWREADY,
  // Master Write Data
  output [31:0] MM_AXI_WDATA,
  output [3:0] MM_AXI_WSTRB,
  output MM_AXI_WLAST,
  output [0:0] MM_AXI_WUSER,
  output MM_AXI_WVALID,
  input MM_AXI_WREADY,
  // Master Write Response
  input [0:0] MM_AXI_BID,
  input [1:0] MM_AXI_BRESP,
  input [0:0] MM_AXI_BUSER,
  input MM_AXI_BVALID,
  output MM_AXI_BREADY,
  // Master Read Address
  output [0:0] MM_AXI_ARID,
  output [31:0] MM_AXI_ARADDR,
  output [7:0] MM_AXI_ARLEN,
  output [2:0] MM_AXI_ARSIZE,
  output [1:0] MM_AXI_ARBURST,
  output [1:0] MM_AXI_ARLOCK,
  output [3:0] MM_AXI_ARCACHE,
  output [2:0] MM_AXI_ARPROT,
  output [3:0] MM_AXI_ARQOS,
  output [0:0] MM_AXI_ARUSER,
  output MM_AXI_ARVALID,
  input MM_AXI_ARREADY,
  // Master Read Data
  input [0:0] MM_AXI_RID,
  input [31:0] MM_AXI_RDATA,
  input [1:0] MM_AXI_RRESP,
  input MM_AXI_RLAST,
  input [0:0] MM_AXI_RUSER,
  input MM_AXI_RVALID,
  output MM_AXI_RREADY,
  // ------------------------------------------------------------
  input           RXD     ,
  output          TXD     ,
  input   [31:0]  GPIO_I  ,
  output  [31:0]  GPIO_O  ,
  output  [31:0]  GPIO_OT
);

  logic TIMER_EXPIRED;

  logic I_MEM_WAIT;
  logic I_MEM_ENA;
  logic [31:0] I_MEM_ADDR;
  logic [31:0] I_MEM_RDATA;
  logic I_MEM_BADMEM_EXCPT;

  logic D_MEM_WAIT;
  logic D_MEM_ENA;
  logic [3:0] D_MEM_WSTB;
  logic [31:0] D_MEM_ADDR;
  logic [31:0] D_MEM_WDATA;
  logic [31:0] D_MEM_RDATA;
  logic D_MEM_BADMEM_EXCPT;

  logic WR_REQ_START;
  logic [31:0] WR_REQ_ADDR;
  logic [15:0] WR_REQ_LEN;
  logic WR_REQ_READY;
  logic [9:0] WR_REQ_MEM_ADDR;
  logic [31:0] WR_REQ_MEM_WDATA;

  logic RD_REQ_START;
  logic [31:0] RD_REQ_ADDR;
  logic [15:0] RD_REQ_LEN;
  logic RD_REQ_READY;
  logic RD_REQ_MEM_WE;
  logic [9:0] RD_REQ_MEM_ADDR;
  logic [31:0] RD_REQ_MEM_RDATA;
  // PLIC
  logic PLIC_BUS_WE;
  logic [3:0] PLIC_BUS_ADDR;
  logic [31:0] PLIC_BUS_WDATA;
  logic [31:0] PLIC_BUS_RDATA;
  // TIMER
  logic TIMER_BUS_WE;
  logic [3:0] TIMER_BUS_ADDR;
  logic [31:0] TIMER_BUS_WDATA;
  logic [31:0] TIMER_BUS_RDATA;

  logic EXT_INTERRUPT;

  fmrv32im #(
    .MADD33_ADDON(0)
  ) u_fmrv32im (
    .RST_N              (rst_n  ),
    .CLK                (clk    ),
    .I_MEM_WAIT                  ,
    .I_MEM_ENA                   ,
    .I_MEM_ADDR                  ,
    .I_MEM_RDATA                 ,
    .I_MEM_BADMEM_EXCPT          ,
    .D_MEM_WAIT                  ,
    .D_MEM_ENA                   ,
    .D_MEM_WSTB                  ,
    .D_MEM_ADDR                  ,
    .D_MEM_WDATA                 ,
    .D_MEM_RDATA                 ,
    .D_MEM_BADMEM_EXCPT          ,
    .EXT_INTERRUPT               ,
    .TIMER_EXPIRED
  );

  // DMEM
  logic         C_MEM_WAIT            ;
  logic         C_MEM_ENA             ;
  logic [3:0]   dbus_wstb             ;
  logic [31:0]  dbus_addr             ;
  logic [31:0]  dbus_wdata            ;
  logic [31:0]  C_MEM_RDATA           ;
  logic         C_MEM_BADMEM_EXCPT    ;
  // Local Inerface
  logic         PERIPHERAL_BUS_WAIT   ;
  logic         PERIPHERAL_BUS_ENA    ;
  logic [3:0]   PERIPHERAL_BUS_WSTB   ;
  logic [31:0]  PERIPHERAL_BUS_ADDR   ;
  logic [31:0]  PERIPHERAL_BUS_WDATA  ;
  logic [31:0]  PERIPHERAL_BUS_RDATA  ;

  fmrv32im_BADMEM_sel u_fmrv32im_BADMEM_sel (
    // Data Memory Bus
    .D_MEM_WAIT                        ,
    .D_MEM_ENA                         ,
    .D_MEM_WSTB                        ,
    .D_MEM_ADDR                        ,
    .D_MEM_WDATA                       ,
    .D_MEM_RDATA                       ,
    .D_MEM_BADMEM_EXCPT                ,
    // DMEM
    .C_MEM_WAIT                        ,
    .C_MEM_ENA                         ,
    .C_MEM_WSTB           (dbus_wstb  ),
    .C_MEM_ADDR           (dbus_addr  ),
    .C_MEM_WDATA          (dbus_wdata ),
    .C_MEM_RDATA                       ,
    .C_MEM_BADMEM_EXCPT                ,
    // Local Inerface
    .PERIPHERAL_BUS_WAIT               ,
    .PERIPHERAL_BUS_ENA                ,
    .PERIPHERAL_BUS_WSTB               ,
    .PERIPHERAL_BUS_ADDR               ,
    .PERIPHERAL_BUS_WDATA              ,
    .PERIPHERAL_BUS_RDATA              ,
    // PLIC
    .PLIC_BUS_WE                       ,
    .PLIC_BUS_ADDR                     ,
    .PLIC_BUS_WDATA                    ,
    .PLIC_BUS_RDATA                    ,
    // TIMER
    .TIMER_BUS_WE                      ,
    .TIMER_BUS_ADDR                    ,
    .TIMER_BUS_WDATA                   ,
    .TIMER_BUS_RDATA
  );

  fmrv32im_cache # (
    .INTEL              (0                  ),
    .OSRAM              (0                  ),
    .MEM_FILE           (MEM_FILE           )
  ) u_fmrv32im_cache (
    .RST_N              (rst_n              ),
    .CLK                (clk                ),
    // Instruction Memory
    .I_MEM_WAIT                              ,
    .I_MEM_ENA                               ,
    .I_MEM_ADDR                              ,
    .I_MEM_RDATA                             ,
    .I_MEM_BADMEM_EXCPT                      ,
    // Data Memory
    .D_MEM_WAIT         (C_MEM_WAIT         ),
    .D_MEM_ENA          (C_MEM_ENA          ),
    .D_MEM_WSTB         (dbus_wstb          ),
    .D_MEM_ADDR         (dbus_addr          ),
    .D_MEM_WDATA        (dbus_wdata         ),
    .D_MEM_RDATA        (C_MEM_RDATA        ),
    .D_MEM_BADMEM_EXCPT (C_MEM_BADMEM_EXCPT ),
    // Local Control for AXI4 Master
    .WR_REQ_START                            ,
    .WR_REQ_ADDR                             ,
    .WR_REQ_LEN                              ,
    .WR_REQ_READY                            ,
    .WR_REQ_MEM_ADDR                         ,
    .WR_REQ_MEM_WDATA                        ,
    .RD_REQ_START                            ,
    .RD_REQ_ADDR                             ,
    .RD_REQ_LEN                              ,
    .RD_REQ_READY                            ,
    .RD_REQ_MEM_WE                           ,
    .RD_REQ_MEM_ADDR                         ,
    .RD_REQ_MEM_RDATA
  );

  logic INTERRUPT;

  fmrv32im_plic u_fmrv32im_plic (
    .RST_N      (rst_n              ),
    .CLK        (clk                ),
    .BUS_WE     (PLIC_BUS_WE        ),
    .BUS_ADDR   (PLIC_BUS_ADDR      ),
    .BUS_WDATA  (PLIC_BUS_WDATA     ),
    .BUS_RDATA  (PLIC_BUS_RDATA     ),
    .INT_IN     ({31'd0, INTERRUPT} ),
    .INT_OUT    (EXT_INTERRUPT      )
  );

  fmrv32im_timer u_fmrv32im_timer (
    .RST_N      (rst_n            ),
    .CLK        (clk              ),
    .BUS_WE     (TIMER_BUS_WE     ),
    .BUS_ADDR   (TIMER_BUS_ADDR   ),
    .BUS_WDATA  (TIMER_BUS_WDATA  ),
    .BUS_RDATA  (TIMER_BUS_RDATA  ),
    .EXPIRED    (TIMER_EXPIRED    )
  );

  fmrv32im_axim u_fmrv32im_axim (
    // Reset, Clock
    .RST_N            (rst_n          ),
    .CLK              (clk            ),
    // Master Write Address
    .M_AXI_AWID       (MM_AXI_AWID    ),
    .M_AXI_AWADDR     (MM_AXI_AWADDR  ),
    .M_AXI_AWLEN      (MM_AXI_AWLEN   ),
    .M_AXI_AWSIZE     (MM_AXI_AWSIZE  ),
    .M_AXI_AWBURST    (MM_AXI_AWBURST ),
    .M_AXI_AWLOCK     (MM_AXI_AWLOCK  ),
    .M_AXI_AWCACHE    (MM_AXI_AWCACHE ),
    .M_AXI_AWPROT     (MM_AXI_AWPROT  ),
    .M_AXI_AWQOS      (MM_AXI_AWQOS   ),
    .M_AXI_AWUSER     (MM_AXI_AWUSER  ),
    .M_AXI_AWVALID    (MM_AXI_AWVALID ),
    .M_AXI_AWREADY    (MM_AXI_AWREADY ),
    // Master Write Data
    .M_AXI_WDATA      (MM_AXI_WDATA   ),
    .M_AXI_WSTRB      (MM_AXI_WSTRB   ),
    .M_AXI_WLAST      (MM_AXI_WLAST   ),
    .M_AXI_WUSER      (MM_AXI_WUSER   ),
    .M_AXI_WVALID     (MM_AXI_WVALID  ),
    .M_AXI_WREADY     (MM_AXI_WREADY  ),
    // Master Write Response
    .M_AXI_BID        (MM_AXI_BID     ),
    .M_AXI_BRESP      (MM_AXI_BRESP   ),
    .M_AXI_BUSER      (MM_AXI_BUSER   ),
    .M_AXI_BVALID     (MM_AXI_BVALID  ),
    .M_AXI_BREADY     (MM_AXI_BREADY  ),
    // Master Read Address
    .M_AXI_ARID       (MM_AXI_ARID    ),
    .M_AXI_ARADDR     (MM_AXI_ARADDR  ),
    .M_AXI_ARLEN      (MM_AXI_ARLEN   ),
    .M_AXI_ARSIZE     (MM_AXI_ARSIZE  ),
    .M_AXI_ARBURST    (MM_AXI_ARBURST ),
    .M_AXI_ARLOCK     (MM_AXI_ARLOCK  ),
    .M_AXI_ARCACHE    (MM_AXI_ARCACHE ),
    .M_AXI_ARPROT     (MM_AXI_ARPROT  ),
    .M_AXI_ARQOS      (MM_AXI_ARQOS   ),
    .M_AXI_ARUSER     (MM_AXI_ARUSER  ),
    .M_AXI_ARVALID    (MM_AXI_ARVALID ),
    .M_AXI_ARREADY    (MM_AXI_ARREADY ),
    // Master Read Data
    .M_AXI_RID        (MM_AXI_RID     ),
    .M_AXI_RDATA      (MM_AXI_RDATA   ),
    .M_AXI_RRESP      (MM_AXI_RRESP   ),
    .M_AXI_RLAST      (MM_AXI_RLAST   ),
    .M_AXI_RUSER      (MM_AXI_RUSER   ),
    .M_AXI_RVALID     (MM_AXI_RVALID  ),
    .M_AXI_RREADY     (MM_AXI_RREADY  ),
    // Local Control
    .WR_REQ_START                      ,
    .WR_REQ_ADDR                       ,
    .WR_REQ_LEN                        ,
    .WR_REQ_READY                      ,
    .WR_REQ_MEM_ADDR                   ,
    .WR_REQ_MEM_WDATA                  ,
    .RD_REQ_START                      ,
    .RD_REQ_ADDR                       ,
    .RD_REQ_LEN                        ,
    .RD_REQ_READY                      ,
    .RD_REQ_MEM_WE                     ,
    .RD_REQ_MEM_ADDR                   ,
    .RD_REQ_MEM_RDATA
  );

  // Write Address Channel
  logic [31:0]  IM_AXI_AWADDR   ;
  logic [3:0]   IM_AXI_AWCACHE  ;
  logic [2:0]   IM_AXI_AWPROT   ;
  logic         IM_AXI_AWVALID  ;
  logic         IM_AXI_AWREADY  ;
  // Write Data Channel
  logic [31:0]  IM_AXI_WDATA    ;
  logic [3:0]   IM_AXI_WSTRB    ;
  logic         IM_AXI_WVALID   ;
  logic         IM_AXI_WREADY   ;
  // Write Response Channel
  logic         IM_AXI_BVALID   ;
  logic         IM_AXI_BREADY   ;
  logic [1:0]   IM_AXI_BRESP    ;
  // Read Address Channel
  logic [31:0]  IM_AXI_ARADDR   ;
  logic [3:0]   IM_AXI_ARCACHE  ;
  logic [2:0]   IM_AXI_ARPROT   ;
  logic         IM_AXI_ARVALID  ;
  logic         IM_AXI_ARREADY  ;
  // Read Data Channel
  logic [31:0]  IM_AXI_RDATA    ;
  logic [1:0]   IM_AXI_RRESP    ;
  logic         IM_AXI_RVALID   ;
  logic         IM_AXI_RREADY   ;

  fmrv32im_axilm u_fmrv32im_axilm (
    // AXI4 Lite Interface
    .RST_N          (rst_n                ),
    .CLK            (clk                  ),
    // Write Address Channel
    .M_AXI_AWADDR   (IM_AXI_AWADDR        ),
    .M_AXI_AWCACHE  (IM_AXI_AWCACHE       ),
    .M_AXI_AWPROT   (IM_AXI_AWPROT        ),
    .M_AXI_AWVALID  (IM_AXI_AWVALID       ),
    .M_AXI_AWREADY  (IM_AXI_AWREADY       ),
    // Write Data Channel
    .M_AXI_WDATA    (IM_AXI_WDATA         ),
    .M_AXI_WSTRB    (IM_AXI_WSTRB         ),
    .M_AXI_WVALID   (IM_AXI_WVALID        ),
    .M_AXI_WREADY   (IM_AXI_WREADY        ),
    // Write Response Channel
    .M_AXI_BVALID   (IM_AXI_BVALID        ),
    .M_AXI_BREADY   (IM_AXI_BREADY        ),
    .M_AXI_BRESP    (IM_AXI_BRESP         ),
    // Read Address Channel
    .M_AXI_ARADDR   (IM_AXI_ARADDR        ),
    .M_AXI_ARCACHE  (IM_AXI_ARCACHE       ),
    .M_AXI_ARPROT   (IM_AXI_ARPROT        ),
    .M_AXI_ARVALID  (IM_AXI_ARVALID       ),
    .M_AXI_ARREADY  (IM_AXI_ARREADY       ),
    // Read Data Channel
    .M_AXI_RDATA    (IM_AXI_RDATA         ),
    .M_AXI_RRESP    (IM_AXI_RRESP         ),
    .M_AXI_RVALID   (IM_AXI_RVALID        ),
    .M_AXI_RREADY   (IM_AXI_RREADY        ),
    // Local Inerface
    .BUS_WAIT       (PERIPHERAL_BUS_WAIT  ),
    .BUS_ENA        (PERIPHERAL_BUS_ENA   ),
    .BUS_WSTB       (PERIPHERAL_BUS_WSTB  ),
    .BUS_ADDR       (PERIPHERAL_BUS_ADDR  ),
    .BUS_WDATA      (PERIPHERAL_BUS_WDATA ),
    .BUS_RDATA      (PERIPHERAL_BUS_RDATA )
  );

  fmrv32im_axis_uart #(
    .RESET_COUNT    (8'd107               )
  ) u_fmrv32im_axis_uart (
    .RST_N          (rst_n                ),
    .CLK            (clk                  ),
    // Write Address Channel
    .S_AXI_AWADDR   (IM_AXI_AWADDR        ),
    .S_AXI_AWCACHE  (IM_AXI_AWCACHE       ),
    .S_AXI_AWPROT   (IM_AXI_AWPROT        ),
    .S_AXI_AWVALID  (IM_AXI_AWVALID       ),
    .S_AXI_AWREADY  (IM_AXI_AWREADY       ),
    // Write Data Channel
    .S_AXI_WDATA    (IM_AXI_WDATA         ),
    .S_AXI_WSTRB    (IM_AXI_WSTRB         ),
    .S_AXI_WVALID   (IM_AXI_WVALID        ),
    .S_AXI_WREADY   (IM_AXI_WREADY        ),
    // Write Response Channel
    .S_AXI_BVALID   (IM_AXI_BVALID        ),
    .S_AXI_BREADY   (IM_AXI_BREADY        ),
    .S_AXI_BRESP    (IM_AXI_BRESP         ),
    // Read Address Channel
    .S_AXI_ARADDR   (IM_AXI_ARADDR        ),
    .S_AXI_ARCACHE  (IM_AXI_ARCACHE       ),
    .S_AXI_ARPROT   (IM_AXI_ARPROT        ),
    .S_AXI_ARVALID  (IM_AXI_ARVALID       ),
    .S_AXI_ARREADY  (IM_AXI_ARREADY       ),
    // Read Data Channel
    .S_AXI_RDATA    (IM_AXI_RDATA         ),
    .S_AXI_RRESP    (IM_AXI_RRESP         ),
    .S_AXI_RVALID   (IM_AXI_RVALID        ),
    .S_AXI_RREADY   (IM_AXI_RREADY        ),
    .INTERRUPT                             ,
    .RXD                                   ,
    .TXD                                   ,
    .GPIO_I                                ,
    .GPIO_O                                ,
    .GPIO_OT                               
  );

endmodule
