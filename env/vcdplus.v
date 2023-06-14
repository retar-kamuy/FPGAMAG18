module vcdplus;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);
  end

endmodule
