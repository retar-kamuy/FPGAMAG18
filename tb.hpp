#ifndef TB_HPP_
#define TB_HPP_

#include <systemc.h>
#include "Vtb_top.h"

class tb:
    public sc_core::sc_module {
 public:
    sc_clock clk;
    sc_signal<uint32_t> rslt;

    Vtb_top *dut;

    // sc_event clk_posedge_event;

    SC_HAS_PROCESS(tb);
    explicit tb(sc_core::sc_module_name name):
        clk("clk", 10, SC_NS) {
        dut = new Vtb_top{"Vtb_top"};

        dut->clk(clk);
        dut->rslt(rslt);

        // SC_THREAD(thread);
        // SC_METHOD(clock_method);
        //     sensitive << clk.posedge_event();
    }

    // void thread();
    // void clock_method() {
    //     clk_posedge_event.notify();
    // }

    ~tb() {
        dut->final();
        delete dut;
    }
};

#endif  // TB_HPP_
