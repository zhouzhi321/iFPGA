`timescale 1ns / 1ps

module SingleCycleCPU_tb(

    );
    reg clk,rst;
    initial begin
    $dumpfile("SingleCycleCPU.vcd");
    $dumpvars;
     clk=0;rst=0;
     #10;
     rst=1;
     $display("running...");
    end
    always #10 clk=~clk;
    
    SingleCycleCPU SingleCycleCPU(.clk(clk),.rst(rst));
endmodule
