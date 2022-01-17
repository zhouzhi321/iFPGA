module alu(code,a,b,c);
input[1:0] code;
input[3:0] a,b;
output[4:0] c;
reg[4:0] c;

task my_and;
input[3:0] a,b;
output[4:0] out;
integer i;
begin for(i=3;i>=0;i=i-1)
out[i]=a[i]&b[i];
end endtask

always@(code or a or b)
begin case(code)
2'b00: my_and(a,b,c);
2'b01: c=a|b;
2'b10: c=a-b;
2'b11: c=a+b;
endcase end
endmodule

