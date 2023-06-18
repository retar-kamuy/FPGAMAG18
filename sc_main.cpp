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
        // RestartSim();
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
        std::cout << "path: " << path << std::endl;
        Vtb_top::set_imem(path.c_str());
        Vtb_top::set_dmem(path.c_str());
    }

    void run(void) {
        while (!Verilated::gotFinish()) {
            sc_start(1, SC_NS);
        }

        int rslt = top->dut->rslt;
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

// TEST_F(SystemCFixture, rv32ui_p_addi) {
//     readmemh("env/tests/rv32ui-p-addi.hex");
//     run();
// }

// TEST_F(SystemCFixture, rv32ui_p_and) {
//     readmemh("env/tests/rv32ui-p-and.hex");
//     run();
// }

// TEST_F(SystemCFixture, rv32ui_p_andi) {
//     readmemh("env/tests/rv32ui-p-andi.hex");
//     run();
// }

int sc_main(int argc, char** argv) {
    printf("Built with %s %s.\n",
        Verilated::productName(), Verilated::productVersion());
    printf("Recommended: Verilator 4.0 or later.\n");
    Verilated::commandArgs(argc, argv);

    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
    return 0;
}
