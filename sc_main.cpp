#include <fstream>
#include <iostream>
#include <gtest/gtest.h>
#include <systemc>

#include "Vtb_top.h"
#include "verilated_vcd_sc.h"
#include "tb.hpp"

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
    };
};

#define BUF_SIZE 1024

TEST_F(SystemCFixture, test1) {
    std::ifstream ifs("env/tests/rv32ui-p-add.hex");
    int buf_size = BUF_SIZE;
    char str[BUF_SIZE];
    if (ifs.fail()) {
        std::cerr << "Failed to open file." << std::endl;
        ASSERT_TRUE(false);
    }

    int addr = 0;
    svSetScope(svGetScopeFromName(
        "top.Vtb_top.tb_top.u_fmrv32im_core.u_fmrv32im_cache"));
    // Verilated::scopesDump();
    while (ifs.getline(str, buf_size)) {
        Vtb_top::set_imem(addr, std::stol(str, nullptr, 16));
        Vtb_top::set_dmem(addr, std::stol(str, nullptr, 16));
        addr += 4;
    }

    while (!Verilated::gotFinish()) {
        sc_start(1, SC_NS);
    }
    std::cout << "Success Result: " << top->dut->rslt << std::endl;
    ASSERT_EQ(1, top->dut->rslt);
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
