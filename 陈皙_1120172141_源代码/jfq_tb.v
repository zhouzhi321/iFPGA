module jfq_tb
input calling,clk; 
input[2:1] type; 
output[10:0] outmoney; 
output[8:0] outtime;
output write,warn,cut;

jfq top(calling,clk,type,outtime,outmoney,write,warn,cut);

clk=0;
always #50
clk=~clk;

initial 
begin
$dumpfile("jfq_simtest.vcd");
$dumpvars;
clk=0;
#100
calling=1;
type=2'b01;
#100*65
calling=0;
#500
calling=1;
type=2'b10;
#100*20
calling=0;
#500
calling=1;
type=2'b11;
end
endmodule
