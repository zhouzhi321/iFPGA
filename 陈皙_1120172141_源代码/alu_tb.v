module alu_tb;
reg[3:0] a,b;
reg[1:0] code;
wire[4:0] c;


alu top(code,a,b,c);

initial 
begin
$dumpfile("alu_simtest.vcd");
$dumpvars;
code=4'd0; 
a= 4'b0000; 
b= 4'b1111; 
#100 
code=4'd0;
a= 4'b0111;
b= 4'b1101; 
#100 
code=4'd1; 
a= 4'b0001; 
b= 4'b0011; 
#100 
code=4'd2; 
a= 4'b1001; 
b= 4'b0011; 
#100 
code=4'd3; 
a= 4'b0011; 
b= 4'b0001; 
#100 
code=4'd3; 
a= 4'b0111; 
b= 4'b1001;
#100	
$finish;
end
endmodule

