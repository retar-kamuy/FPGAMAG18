`timescale 1ns / 1ns
`include "vunit_defines.svh"

module tb;
  logic         rst_n   ;
  logic         clk     ;
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

  logic [31:0]  rslt            ;

  // Clock
  localparam CLK100M = 10ns;
  initial begin
    clk = 0;
    forever
      #(CLK100M / 2) clk = ~clk;
  end

  task load_elf(input string path);
    $info("Load ELF: Simulatin Start %s\n", path);
    $readmemh(path, u_fmrv32im_core.u_fmrv32im_cache.imem, 0, 1023);
    $readmemh(path, u_fmrv32im_core.u_fmrv32im_cache.dmem, 0, 1023);

    repeat(5) @(posedge clk);
    $info("Process Start");
  endtask

  // Sinario
  `TEST_SUITE begin
    `TEST_SUITE_SETUP begin
      $info("Running test suite setup code");
      rst_n   = 0;
      RXD     = 0;
      GPIO_I  = 0;
    end

    `TEST_CASE_SETUP begin
      $info("Running test case setup code");
      repeat(5) @(posedge clk);
      rst_n = 1;
      $info("Simulation Start");
    end

    `TEST_CASE("rv32ui-p-add"     ) load_elf( "rv32ui-p-add.hex"      );
    `TEST_CASE("rv32ui-p-addi"    ) load_elf( "rv32ui-p-addi.hex"     );
    `TEST_CASE("rv32ui-p-and"     ) load_elf( "rv32ui-p-and.hex"      );
    `TEST_CASE("rv32ui-p-andi"    ) load_elf( "rv32ui-p-andi.hex"     );
    `TEST_CASE("rv32ui-p-auipc"   ) load_elf( "rv32ui-p-auipc.hex"    );
    `TEST_CASE("rv32ui-p-beq"     ) load_elf( "rv32ui-p-beq.hex"      );
    `TEST_CASE("rv32ui-p-bge"     ) load_elf( "rv32ui-p-bge.hex"      );
    `TEST_CASE("rv32ui-p-bgeu"    ) load_elf( "rv32ui-p-bgeu.hex"     );
    `TEST_CASE("rv32ui-p-blt"     ) load_elf( "rv32ui-p-blt.hex"      );
    `TEST_CASE("rv32ui-p-bltu"    ) load_elf( "rv32ui-p-bltu.hex"     );
    `TEST_CASE("rv32ui-p-bne"     ) load_elf( "rv32ui-p-bne.hex"      );
    `TEST_CASE("rv32ui-p-fence_i" ) load_elf( "rv32ui-p-fence_i.hex"  );
    `TEST_CASE("rv32ui-p-jal"     ) load_elf( "rv32ui-p-jal.hex"      );
    `TEST_CASE("rv32ui-p-jalr"    ) load_elf( "rv32ui-p-jalr.hex"     );
    `TEST_CASE("rv32ui-p-lb"      ) load_elf( "rv32ui-p-lb.hex"       );
    `TEST_CASE("rv32ui-p-lbu"     ) load_elf( "rv32ui-p-lbu.hex"      );
    `TEST_CASE("rv32ui-p-lh"      ) load_elf( "rv32ui-p-lh.hex"       );
    `TEST_CASE("rv32ui-p-lhu"     ) load_elf( "rv32ui-p-lhu.hex"      );
    `TEST_CASE("rv32ui-p-lui"     ) load_elf( "rv32ui-p-lui.hex"      );
    `TEST_CASE("rv32ui-p-lw"      ) load_elf( "rv32ui-p-lw.hex"       );
    `TEST_CASE("rv32ui-p-or"      ) load_elf( "rv32ui-p-or.hex"       );
    `TEST_CASE("rv32ui-p-ori"     ) load_elf( "rv32ui-p-ori.hex"      );
    `TEST_CASE("rv32ui-p-sb"      ) load_elf( "rv32ui-p-sb.hex"       );
    `TEST_CASE("rv32ui-p-sh"      ) load_elf( "rv32ui-p-sh.hex"       );
    `TEST_CASE("rv32ui-p-simple"  ) load_elf( "rv32ui-p-simple.hex"   );
    `TEST_CASE("rv32ui-p-sll"     ) load_elf( "rv32ui-p-sll.hex"      );
    `TEST_CASE("rv32ui-p-slli"    ) load_elf( "rv32ui-p-slli.hex"     );
    `TEST_CASE("rv32ui-p-slt"     ) load_elf( "rv32ui-p-slt.hex"      );
    `TEST_CASE("rv32ui-p-slti"    ) load_elf( "rv32ui-p-slti.hex"     );
    `TEST_CASE("rv32ui-p-sltiu"   ) load_elf( "rv32ui-p-sltiu.hex"    );
    `TEST_CASE("rv32ui-p-sltu"    ) load_elf( "rv32ui-p-sltu.hex"     );
    `TEST_CASE("rv32ui-p-sra"     ) load_elf( "rv32ui-p-sra.hex"      );
    `TEST_CASE("rv32ui-p-srai"    ) load_elf( "rv32ui-p-srai.hex"     );
    `TEST_CASE("rv32ui-p-srl"     ) load_elf( "rv32ui-p-srl.hex"      );
    `TEST_CASE("rv32ui-p-srli"    ) load_elf( "rv32ui-p-srli.hex"     );
    `TEST_CASE("rv32ui-p-sub"     ) load_elf( "rv32ui-p-sub.hex"      );
    `TEST_CASE("rv32ui-p-sw"      ) load_elf( "rv32ui-p-sw.hex"       );
    `TEST_CASE("rv32ui-p-xor"     ) load_elf( "rv32ui-p-xor.hex"      );
    `TEST_CASE("rv32ui-p-xori"    ) load_elf( "rv32ui-p-xori.hex"     );
    `TEST_CASE("rv32um-p-div"     ) load_elf( "rv32um-p-div.hex"      );
    `TEST_CASE("rv32um-p-divu"    ) load_elf( "rv32um-p-divu.hex"     );
    `TEST_CASE("rv32um-p-mul"     ) load_elf( "rv32um-p-mul.hex"      );
    `TEST_CASE("rv32um-p-mulh"    ) load_elf( "rv32um-p-mulh.hex"     );
    `TEST_CASE("rv32um-p-mulhsu"  ) load_elf( "rv32um-p-mulhsu.hex"   );
    `TEST_CASE("rv32um-p-mulhu"   ) load_elf( "rv32um-p-mulhu.hex"    );
    `TEST_CASE("rv32um-p-rem"     ) load_elf( "rv32um-p-rem.hex"      );
    `TEST_CASE("rv32um-p-remu"    ) load_elf( "rv32um-p-remu.hex"     );

    `TEST_CASE_CLEANUP begin
      wait(
        (u_fmrv32im_core.dbus_addr === 32'h0000_0800) &
        (u_fmrv32im_core.dbus_wstb === 4'hF)
      );
      rslt <= u_fmrv32im_core.dbus_wdata;
      repeat(10) @(posedge clk);
    end

    `TEST_SUITE_CLEANUP begin
      $info("Simulatin Finish");
      assert(rslt === 1)
        $info("Success Result: %8x\n", rslt);
      else
        $fatal("Error Result: %8x\n", rslt);
    end
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
