module jsq(res,rst,clk);
output[3:0] res; input rst,clk; reg[3:0] res;
always @(posedge clk)
begin
if (rst)
 res<=0;	
else 
 res<=res+1;
end	
endmodule

