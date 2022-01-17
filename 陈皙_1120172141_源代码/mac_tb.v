module mac_tb;
reg[7:0] opa,opb;
reg clr,clk;
wire[15:0] out;

mac top(out,opa,opb,clk,clr);

always #(100) clk = ~clk;

initial begin
$dumpfile("mac_simtest.vcd");
$dumpvars;
#100 
clr=0;
opa=8'd1; 
opb=8'd10; 
#100 
opa=8'd2; 
opb=8'd10;
#100 
opa=8'd3; 
opb=8'd10;
#100 
opa=8'd4; 
opb=8'd10; 
#100 
opa=8'd5; 
opb=8'd10; 
#100 
opa=8'd6; 
opb=8'd10; 
#100 
opa=8'd7; 
opb=8'd10; 
#100 
opa=8'd8; 
opb=8'd10; 
#100 
opa=8'd9; 
opb=8'd10; 
#100 
opa=8'd10; 
opb=8'd10; 
#100 
$finish;
end

endmodule

