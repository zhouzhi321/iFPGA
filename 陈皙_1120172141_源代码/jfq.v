module jfq(calling,clk,type,outtime,outmoney,write,warn,cut);
output write,warn,cut;
input calling,clk; 
input[2:1] type; 
output[10:0] outmoney; 
output[8:0] outtime; reg[10:0] money; 
reg[8:0] regtime;
reg warn,cut,write,minutes,set,rst;
integer seconds,temp;

assign outmoney=moeny;
assign outtime=regtime;

always @(posedge clk)
begin
if (seconds==59) 
begin 
seconds<=0; 
minutes<=1; 
end 
else 
begin
if(calling)	
seconds<=seconds+1;
else	
seconds<=0; 
minutes<=0;
end
end

always @(negedge clk)
begin
if(!set)
begin 
money<=11'h500; 
set<=1; 
end 
if(calling)
if(minutes)

case({calling,type}) 
3'b101:	
if(money<3)
begin 
warn<=1; 
write<=0; 
rst<=1; 
end 
else
begin	
if(money[3:0]<4'b0011) 
begin 
money[3:0]<=money[3:0]+7;
if(money[7:4]!=0)
money[7:4]<=money[7:4]-1;
else
begin 
money[7:4]<=9; 
money[10:8]<=money[10:8]-1; 
end 
end
else 
money[3:0]<=money[3:0]-3; 
write<=1;
if(regtime[3:0]==9) 
begin 
regtime[3:0]<=0; 
if(regtime[7:4]==9)
 begin
 regtime[7:4]<=0;
 regtime[8]<=regtime[8]+1;
 end 
else
 regtime[7:4]<=regtime[7:4]+1;
end 
else 
begin
regtime[3:0]<=regtime[3:0]+1; 
warn<=0; 
rst<=0;
end
end

3'b110: 
if(money<6)
begin 
warn<=1; 
write<=0; 
rst<=1; 
end 
else 
begin
if(regtime[3:0]==9) 
begin
regtime[3:0]<=0; 
if(regtime[7:4]==9)
begin 
regtime[7:4]<=0; 
regtime[8]<=regtime[8]+1; 
end 
else 
regtime[7:4]<=regtime[7:4]+1;
end
else 
regtime[3:0]<=regtime[3:0]+1;

if(money[3:0]<4'b0110) 
begin 
money[3:0]<=money[3:0]+4; 
if(!money[7:4])
begin 
money[7:4]<=9; 
money[10:8]<=money[10:8]-1; 
end 
else 
money[7:4]<=money[7:4]-1;
end
else 
money[3:0]<=money[3:0]-6; 
write<=1; 
rst<=0;	
warn<=0;
end
endcase
else 
write<=0;
else 
begin 
regtime<=0; 
warn<=0; 
write<=0; 
rst<=0; 
end
end

always @(posedge clk)	
begin
if(warn) 
temp<=temp+1; 
else temp<=0; 
if(temp==15)
begin 
cut<=1; 
temp<=0; 
end 
if(!rst)
begin
cut<=0;
temp<=0;
end
end endmodule


