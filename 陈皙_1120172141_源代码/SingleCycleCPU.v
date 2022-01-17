`timescale 1ns / 1ps

module SingleCycleCPU(
    input clk,
    input rst
    );

    // wires for control, inst_mem, pc and branch unit
    wire [31:0] inst;
    wire c1;
    wire c2;
    wire c3;
    wire c4;
    wire [3:0] c_ALU;
    wire [1:0] c_jmp;
    wire data_mem_we;
    wire register_we;
    wire [31:0] current_pc;
    wire [31:0] new_pc_val;
    wire [31:0] ext_inst_num;

    // wires for register file
    wire [4:0] reg_file_wb_addr;
    wire [4:0] reg_file_rs_addr;
    wire [4:0] reg_file_rt_addr;
    wire [31:0] reg_file_wb_data;
    wire [31:0] reg_file_rs_data;
    wire [31:0] reg_file_rt_data;
    
    wire [31:0] ext_32bit_reg_file_wb_addr;
    assign reg_file_wb_addr = ext_32bit_reg_file_wb_addr[4:0];
    
    // wires for data memory
    wire[31:0] dmem_addr;
    wire[31:0] dmem_w_data;
    wire[31:0] dmem_r_data;

    // wires for ALU
    wire [31:0] ALU_operands1;
    wire [31:0] ALU_operands2;
    wire [31:0] ALU_answer;
    assign dmem_addr = ALU_answer;
    
    Control ctrl(.opcode(inst[31:26]), .func(inst[5:0]), .c1(c1), .c2(c2), .c3(c3), .c4(c4), .c_ALU(c_ALU), .c_jmp(c_jmp), .data_mem_we(data_mem_we), .reg_we(register_we));
    PC pc(.clk(clk), .rst(rst), .new_pc_val(new_pc_val), .out_pc_value(current_pc));
    BranchUnit br_unit(.clk(clk), .rst(rst), .mode(c_jmp), .jmp_flag(ALU_answer[0]), .imm_16bits(inst[15:0]), .imm_26bits(inst[25:0]), .pc(current_pc), .address(new_pc_val));
    InstMem inst_mem(.clk(clk), .rst(rst), ._addr(current_pc), .inst_data(inst));
    SignalExtend signal_ext(.clk(clk), .rst(rst), .ctrl_ext(1'b1), .inst_num(inst[15:0]), .ext_result(ext_inst_num));

    MUX mux1(.clk(clk), .rst(rst), .select(c1), .signal0(reg_file_rt_data), .signal1(ext_inst_num), .out_signal(ALU_operands2));
    MUX mux2(.clk(clk), .rst(rst), .select(c2), .signal0({27'b0, inst[20:16]}), .signal1({27'b0, inst[15:11]}), .out_signal(ext_32bit_reg_file_wb_addr));
    MUX mux3(.clk(clk), .rst(rst), .select(c3), .signal0(reg_file_rs_data), .signal1(ext_inst_num), .out_signal(ALU_operands1));
    MUX mux4(.clk(clk), .rst(rst), .select(c4), .signal0(ALU_answer), .signal1(dmem_r_data), .out_signal(reg_file_wb_data));

    assign reg_file_rs_addr = inst[25:21];
    assign reg_file_rt_addr = inst[20:16];
    assign dmem_w_data = reg_file_rt_data;
    RegisterFile reg_file(.clk(clk), .rst(rst), .reg_we(register_we), .rs_addr(reg_file_rs_addr), .rt_addr(reg_file_rt_addr), .rs_data(reg_file_rs_data), .rt_data(reg_file_rt_data), .wb_addr(reg_file_wb_addr), .wb_data(reg_file_wb_data));
    ALU alu(.clk(clk), .rst(rst), .ctrl(c_ALU), .operands1(ALU_operands1), .operands2(ALU_operands2), .answer(ALU_answer));
    DataMem data_mem(.clk(clk), .rst(rst), .we(data_mem_we), ._addr(dmem_addr), .wdata(dmem_w_data), .rdata(dmem_r_data));

endmodule

module ALU(
    input clk,
    input rst,
    
    input[3:0] ctrl, // 
    input[31:0] operands1,
    input[31:0] operands2,

    output[31:0] answer
    );

    // add
    wire [32:0] ext_operands1 = {operands1[31], operands1};
    wire [32:0] ext_operands2 = {operands2[31], operands2};
    wire [32:0] ext_add_ans = ext_operands1 + ext_operands2;
    wire [31:0] add_ans = ext_add_ans[31:0];

    // addi
    wire [31:0] addi_ans = add_ans;

    // addiu
    wire [32:0] zero_ext_operands2 = {1'b0, operands2};
    wire [32:0] ext_addiu_ans = ext_operands1 + zero_ext_operands2;
    wire [31:0] addiu_ans= ext_addiu_ans[31:0];
    // sub
    wire [32:0] ext_sub_ans = ext_operands1 - ext_operands2;
    wire [31:0] sub_ans = ext_sub_ans[31:0];

    // and
    wire [32:0] ext_and_ans = ext_operands1 & ext_operands2;
    wire [31:0] and_ans = ext_and_ans[31:0];

    // or
    wire [32:0] ext_or_ans = ext_operands1 | ext_operands2;
    wire [31:0] or_ans = ext_or_ans[31:0];

    // sll: shift logical left  
    wire [32:0] ext_sll_ans = ext_operands1 << ext_operands2;
    wire [31:0] sll_ans = ext_sll_ans[31:0];

    // lui
    wire [31:0] lui_ans = {operands2[15:0], 16'b0};

    // lw & sw
    wire [31:0] lw_sw_addr = add_ans;

    // SLT 
    wire [31:0] slt_ans = (operands1 < operands2) ? 32'b1 : 32'b0;

    // SLTI
    wire [31:0] slti_ans = slt_ans;

    // Beq
    wire [31:0] beq_flag = (operands1 == operands2) ? 32'b1 : 32'b0;

    // J
    wire [31:0] j_flag = 32'b1;

    assign answer = (ctrl == 1) ? add_ans:
                    (ctrl == 2) ? addi_ans:
                    (ctrl == 3) ? addiu_ans:
                    (ctrl == 4) ? sub_ans:
                    (ctrl == 5) ? and_ans:
                    (ctrl == 6) ? or_ans:
                    (ctrl == 7) ? sll_ans:
                    (ctrl == 8) ? lui_ans:
                    (ctrl == 9 || ctrl == 10) ? lw_sw_addr:
                    (ctrl == 11) ? slt_ans:
                    (ctrl == 12) ? slti_ans:
                    (ctrl == 13) ? beq_flag:
                    (ctrl == 14) ? j_flag:
                    32'b0;

endmodule

module BranchUnit(
    input clk,
    input rst,
    input[1:0] mode, // mode==0 -> sequential execute, mode == 1 -> j,  mode == 2 -> beq
    input jmp_flag, // used by beq instruction, only jump when jmp_flag == 1
    input[15:0] imm_16bits, // used for beq instruction
    input[25:0] imm_26bits, // used for j instruction
    input[31:0] pc, // current value of pc

    output[31:0] address
    );
    wire[31:0] pc_plus_4 = pc + 4;
    wire [31:0] ext_imm_16bits;
    SignalExtend sig_ext(.clk(clk), .rst(rst), .ctrl_ext(1'b1), .inst_num(imm_16bits), .ext_result(ext_imm_16bits));
    assign address = (mode == 0 || (mode == 2 && jmp_flag == 0))? pc_plus_4:
                     (mode == 1)? {pc_plus_4[31:28], imm_26bits << 2}:
                     (mode == 2 && jmp_flag == 1)?(pc_plus_4 + (ext_imm_16bits << 2)):
                     0;
endmodule

module Control(
    input [5:0] opcode,
    input [5:0] func,

    output c1, // operands2 = rt if (c1 == 0) else imm
    output c2, // targert_register = rt if (c2 == 0) else rd
    output c3, // operands1 = rs if (c1 == 0) else imm
    output c4, // write_back_data from ALU if (c1 == 0) else data_mem
    output[3:0] c_ALU, // choose the operator of ALU
    output[1:0] c_jmp, // c_jmp==0 -> sequential execute, c_jmp == 1 -> j,  c_jmp == 2 -> beq
    output data_mem_we, // write enable of data memory
    output reg_we // write enable of register file
    );

    wire [3:0] inst_type; // indentifies different instruction,  the same as 'ctrl' parameter in ALU module.
    assign inst_type = (opcode == 6'b001000)? 2: // addi
                       (opcode == 6'b001001)? 3: // addiu
                       (opcode == 6'b001111)? 8: // lui
                       (opcode == 6'b100011)? 9: // lw
                       (opcode == 6'b101011)? 10: // sw
                       (opcode == 6'b001010)? 12: // slti
                       (opcode == 6'b000100)? 13: // beq
                       (opcode == 6'b000010)? 14: // j
                       (opcode == 6'b000000)? (
                           (func == 6'b100000)? 1: // add
                           (func == 6'b100010)? 4: // sub
                           (func == 6'b100100)? 5: // and
                           (func == 6'b100101)? 6: // or
                           (func == 6'b000000)? 7: // sll
                           (func == 6'b101010)? 11: 0// slt
                       ):0;

    assign c1 = (inst_type == 2 || inst_type == 3 || inst_type == 8 || inst_type == 9 || inst_type == 10 || inst_type == 12) ? 1 : 0;
    assign c2 = (inst_type == 1 || inst_type == 4 || inst_type == 5 || inst_type == 6 || inst_type == 7 || inst_type == 11) ? 1 : 0;
    assign c3 = (inst_type == 7 || inst_type == 8) ? 1 : 0;
    assign c4 = (inst_type == 9) ? 1 : 0;
    assign data_mem_we = (inst_type == 10) ? 1 : 0;
    assign reg_we = (inst_type != 10 && inst_type != 13 && inst_type != 14) ? 1 : 0;
    assign c_ALU = inst_type;
    assign c_jmp = (inst_type == 14) ? 1 : (
                        (inst_type == 13) ? 2 : 0);

endmodule

module DataMem(
    input clk,
    input rst,
    input we, // write enable, we == 0 -> Read only; we == 1 -> writeable.

    input [31:0] _addr, // address to read/write data
    input [31:0] wdata,

    output [31:0] rdata
    );
    reg[7:0] data_mem[255:0]; // 255 * 8 bit registers to store data
    integer i;
    initial begin             
        for(i=0;i<=255;i=i+1) begin
            data_mem[i] <= 0;            
        end
    end
    
    wire [7:0] addr = _addr[7:0];
    assign rdata = {data_mem[addr+3],data_mem[addr+2],data_mem[addr+1],data_mem[addr]};

    always @(posedge clk) begin
        if (we) begin
            data_mem[addr] <= wdata[7:0];
            data_mem[addr + 1] <= wdata[15:8];
            data_mem[addr + 2] <= wdata[23:16];
            data_mem[addr + 3] <= wdata[31:24];
        end
    end

endmodule

module InstMem(
    input clk,
    input rst,
    input [31:0] _addr, // address of instruction
    output [31:0] inst_data // the bits of instructions
    );
    
    reg[7:0] inst_mem[255:0]; // 255 * 8 bit registers to store instructions
    integer i;
    initial begin             
        // load instructiuons from file
        //$readmemb("", inst_mem);

        // or setting memories manually
        // assign instructions ....
        for(i = 36; i <= 255;i = i + 1) 
            inst_mem[i] <= 0;

        inst_mem[0]<=8'h64;
	inst_mem[1]<=8'h00;
	inst_mem[2]<=8'h08;
	inst_mem[3]<=8'h20;       
        inst_mem[4]<=8'h19;
	inst_mem[5]<=8'h00;
	inst_mem[6]<=8'h0a;
	inst_mem[7]<=8'h25;     
        inst_mem[8]<=8'h00;
	inst_mem[9]<=8'h00;
	inst_mem[10]<=8'h4c;
	inst_mem[11]<=8'h21;   
        inst_mem[12]<=8'h22;
	inst_mem[13]<=8'h48;
	inst_mem[14]<=8'h00;
	inst_mem[15]<=8'h01;  
        inst_mem[16]<=8'h20;
	inst_mem[17]<=8'h58;
	inst_mem[18]<=8'h88;
	inst_mem[19]<=8'h01; 
        inst_mem[16]<=8'h2a;
	inst_mem[17]<=8'h78;
	inst_mem[18]<=8'h68;
	inst_mem[19]<=8'h01;  
        inst_mem[20]<=8'hff;
	inst_mem[21]<=8'h00;
	inst_mem[22]<=8'h6f;
	inst_mem[23]<=8'h29;  
        inst_mem[24]<=8'h64;
	inst_mem[25]<=8'h00;
	inst_mem[26]<=8'h0e;
	inst_mem[27]<=8'h3c;  
        inst_mem[28]<=8'h02;
	inst_mem[29]<=8'h00;
	inst_mem[30]<=8'h4c;
	inst_mem[31]<=8'h11;   
        inst_mem[32]<=8'h00;
	inst_mem[33]<=8'h00;
	inst_mem[34]<=8'heb;
	inst_mem[35]<=8'hac;  
        inst_mem[36]<=8'h00;
	inst_mem[37]<=8'h00;
	inst_mem[38]<=8'hed;
	inst_mem[39]<=8'h8c;  
        inst_mem[40]<=8'h03;
	inst_mem[41]<=8'h00;
	inst_mem[42]<=8'h10;
	inst_mem[43]<=8'h08;  

    end
    // read instructions
    wire [7:0] addr = _addr[7:0];
    assign inst_data = {inst_mem[addr+3],inst_mem[addr+2],inst_mem[addr+1],inst_mem[addr]};


endmodule

module MUX(
    input clk,
    input rst,
    input select,
    input[31:0] signal0,
    input[31:0] signal1,

    output[31:0] out_signal
    );

    assign out_signal = (select == 0) ? signal0 : signal1;
endmodule

module PC(
    input clk,
    input rst,
    input[31:0] new_pc_val,
    output[31:0] out_pc_value
    );

    reg [31:0] current_pc;
    initial begin
        current_pc <= -4;
    end

    assign out_pc_value = current_pc;
    always @(posedge clk) begin
        current_pc = new_pc_val;
    end
endmodule

module RegisterFile(
    input clk,
    input rst,
    
    input reg_we,
    input[4:0] rs_addr,
    input[4:0] rt_addr,
    input[4:0] wb_addr,
    input[31:0] wb_data,

    output[31:0] rs_data, 
    output[31:0] rt_data
    );
    reg[31:0] registers[31:0];
    integer i;

    initial begin
        for (i = 0; i <= 31; i=i+1) begin
            registers[i] <= 32'b0;
        end
    end

    always @(posedge clk) begin
        if (reg_we && wb_addr) begin
            registers[wb_addr] <= wb_data;
        end
    end

    assign rs_data = (rs_addr == 0) ? 0 : registers[rs_addr];
    assign rt_data = (rt_addr == 0) ? 0 : registers[rt_addr];

endmodule

module SignalExtend(
    input clk,
    input rst,
    input ctrl_ext,
    input[15:0] inst_num,
    
    output[31:0] ext_result
    );
    assign ext_result = (ctrl_ext == 1) ? 
                            ((inst_num[15] == 1)?{16'hffff, inst_num}:{16'h0000, inst_num})
                            :inst_num;    

    
endmodule
