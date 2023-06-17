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

        while (!Verilated::gotFinish()) {
            sc_start(1, SC_NS);
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

TEST_F(SystemCFixture, test1) {
    sc_start(-1, SC_NS);
}

int sc_main(int argc, char** argv) {
    printf("Built with %s %s.\n", Verilated::productName(), Verilated::productVersion());
    printf("Recommended: Verilator 4.0 or later.\n");
    Verilated::commandArgs(argc, argv);

    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
    return 0;
}
