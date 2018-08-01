`timescale 1ns / 1ps

module testbench();
    reg clk, rstd;
//    wire [31:0] ins;
    initial
     begin
        clk = 0;
        rstd = 0;
        #10
        rstd = 1;
     end
     always #50
     begin
        clk = ~clk;
     end
    computer com(clk, rstd);
endmodule
