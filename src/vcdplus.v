module vcdplus;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_fmrv32im_core);
    end

endmodule
