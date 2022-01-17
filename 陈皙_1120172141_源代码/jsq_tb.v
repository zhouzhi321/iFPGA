`timescale 1ns/1ns

module jsq_tb;
reg clk,rst;
wire[3:0] res;

jsq jsq(res,rst,clk);
always #50
clk = ~clk;
initial
begin
$dumpfile("jsq_simtest.vcd");
$dumpvars;
clk =0; 
rst=0;
#100	
rst=1;
#100	
rst=0; 
#(2000) 
$finish;
end
endmodule

