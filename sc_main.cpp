#include <gtest/gtest.h>
#include <systemc>
#include <string>
#include <fstream>
#include <iostream>

#include "Vtb_top.h"
#include "verilated_vcd_sc.h"
#include "tb.hpp"

#define BUF_SIZE 1024

class SystemCFixture : public testing::Test {
 protected:
    tb* top;

    // Tracing (vcd)
    VerilatedVcdSc* tfp = NULL;

    void SetUp() override {
        top = new tb("top");

        sc_start(0, SC_NS);

        // If verilator was invoked with --trace argument,
        // and if at run time passed the +trace argument, turn on tracing
        const char* flag_vcd = Verilated::commandArgsPlusMatch("trace");
        if (flag_vcd && 0 == strcmp(flag_vcd, "+trace")) {
            std::cout << "VCD dump on" << std::endl;
            Verilated::traceEverOn(true);
            tfp = new VerilatedVcdSc;
            top->dut->trace(tfp, 99);
            tfp->open("wave.vcd");
        }
    };

    void TearDown() override {
        if (tfp) {
            tfp->flush();
            tfp->close();
            tfp = NULL;
        }
        delete top;
        RestartSim();
    };

    void RestartSim() {
        // Deconstructing the sc_curr_simcontext isn't support by SystemC
        // so we expect to leak some amount of memory here.
        sc_core::sc_curr_simcontext = new sc_core::sc_simcontext();
        sc_core::sc_default_global_context = sc_core::sc_curr_simcontext;
    }

    void readmemh(std::string path) {
        svSetScope(svGetScopeFromName(
            "top.Vtb_top.tb_top.u_fmrv32im_core.u_fmrv32im_cache"));
        // Verilated::scopesDump();
        Vtb_top::set_imem(path.c_str());
        Vtb_top::set_dmem(path.c_str());
        std::cout << "Process Start" << std::endl;
    }

    void run(void) {
        int rslt;
        // while (!Verilated::gotFinish()) {
        while (top->dut->rslt == 0) {
            sc_start(1, SC_NS);
        }

        rslt = top->dut->rslt;
        if (rslt == 1)
            std::cout << "Success Result: " << rslt << std::endl;
        else
            std::cerr << "Error Result: " << rslt << std::endl;
        ASSERT_EQ(1, rslt);
    }

    // ~SystemCFixture() {
    //     if (tfp) {
    //         tfp->flush();
    //         tfp->close();
    //         tfp = NULL;
    //     }
    //     delete top;
    // }
};

TEST_F(SystemCFixture, rv32ui_p_add) {
    readmemh("env/tests/rv32ui-p-add.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_addi) {
    readmemh("env/tests/rv32ui-p-addi.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_and) {
    readmemh("env/tests/rv32ui-p-and.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_andi) {
    readmemh("env/tests/rv32ui-p-andi.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_auipc) {
    readmemh("env/tests/rv32ui-p-auipc.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_beq) {
    readmemh("env/tests/rv32ui-p-beq.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_bge) {
    readmemh("env/tests/rv32ui-p-bge.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_bgeu) {
    readmemh("env/tests/rv32ui-p-bgeu.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_blt) {
    readmemh("env/tests/rv32ui-p-blt.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_bltu) {
    readmemh("env/tests/rv32ui-p-bltu.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_bne) {
    readmemh("env/tests/rv32ui-p-bne.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_fence_i) {
    readmemh("env/tests/rv32ui-p-fence_i.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_jal) {
    readmemh("env/tests/rv32ui-p-jal.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_jalr) {
    readmemh("env/tests/rv32ui-p-jalr.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_lb) {
    readmemh("env/tests/rv32ui-p-lb.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_lbu) {
    readmemh("env/tests/rv32ui-p-lbu.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_lh) {
    readmemh("env/tests/rv32ui-p-lh.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_lhu) {
    readmemh("env/tests/rv32ui-p-lhu.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_lui) {
    readmemh("env/tests/rv32ui-p-lui.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_lw) {
    readmemh("env/tests/rv32ui-p-lw.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_or) {
    readmemh("env/tests/rv32ui-p-or.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_ori) {
    readmemh("env/tests/rv32ui-p-ori.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_sb) {
    readmemh("env/tests/rv32ui-p-sb.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_sh) {
    readmemh("env/tests/rv32ui-p-sh.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_simple) {
    readmemh("env/tests/rv32ui-p-simple.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_sll) {
    readmemh("env/tests/rv32ui-p-sll.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_slli) {
    readmemh("env/tests/rv32ui-p-slli.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_slt) {
    readmemh("env/tests/rv32ui-p-slt.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_slti) {
    readmemh("env/tests/rv32ui-p-slti.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_sltiu) {
    readmemh("env/tests/rv32ui-p-sltiu.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_sltu) {
    readmemh("env/tests/rv32ui-p-sltu.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_sra) {
    readmemh("env/tests/rv32ui-p-sra.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_srai) {
    readmemh("env/tests/rv32ui-p-srai.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_srl) {
    readmemh("env/tests/rv32ui-p-srl.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_srli) {
    readmemh("env/tests/rv32ui-p-srli.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_sub) {
    readmemh("env/tests/rv32ui-p-sub.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_sw) {
    readmemh("env/tests/rv32ui-p-sw.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_xor) {
    readmemh("env/tests/rv32ui-p-xor.hex");
    run();
}

TEST_F(SystemCFixture, rv32ui_p_xori) {
    readmemh("env/tests/rv32ui-p-xori.hex");
    run();
}

TEST_F(SystemCFixture, rv32um_p_div) {
    readmemh("env/tests/rv32um-p-div.hex");
    run();
}

TEST_F(SystemCFixture, rv32um_p_divu) {
    readmemh("env/tests/rv32um-p-divu.hex");
    run();
}

TEST_F(SystemCFixture, rv32um_p_mul) {
    readmemh("env/tests/rv32um-p-mul.hex");
    run();
}

TEST_F(SystemCFixture, rv32um_p_mulh) {
    readmemh("env/tests/rv32um-p-mulh.hex");
    run();
}

TEST_F(SystemCFixture, rv32um_p_mulhsu) {
    readmemh("env/tests/rv32um-p-mulhsu.hex");
    run();
}

TEST_F(SystemCFixture, rv32um_p_mulhu) {
    readmemh("env/tests/rv32um-p-mulhu.hex");
    run();
}

TEST_F(SystemCFixture, rv32um_p_rem) {
    readmemh("env/tests/rv32um-p-rem.hex");
    run();
}

TEST_F(SystemCFixture, rv32um_p_remu) {
    readmemh("env/tests/rv32um-p-remu.hex");
    run();
}

int sc_main(int argc, char** argv) {
    printf("Built with %s %s.\n",
        Verilated::productName(), Verilated::productVersion());
    printf("Recommended: Verilator 4.0 or later.\n");
    Verilated::commandArgs(argc, argv);

    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
    return 0;
}
