`timescale 1ns / 1ps

module main_controller(
    opcode,
    reg_dst,
    alu_src,
    mem_to_reg,
    reg_w,
    mem_r,
    mem_w,
    branch,
    alu_op
    //jump
    );

    parameter instruction_width = 32;

    input [5:0] opcode;
    output reg reg_dst, alu_src, mem_to_reg, reg_w, mem_r, mem_w, branch/*, jump*/;
    output reg [2:0] alu_op;

    always @(*) begin
        reg_dst = ~(|opcode);    
    end

    always @(*) begin
        alu_src = (~opcode[5] & opcode[3]) | opcode[5];    
    end

    always @(*) begin
        mem_to_reg = opcode[5] & ~opcode[3];
    end
    
    always @(*) begin
        reg_w = (opcode[5] & ~opcode[3]) | (opcode[3] & opcode[2]) | (~opcode[2] & ~opcode[1]);
    end
    
    always @(*) begin
        mem_r = opcode[5] & ~opcode[3];    
    end

    always @(*) begin
        mem_w = opcode[5] & opcode[3];    
    end
    
    always @(*) begin
        branch = ~opcode[5] & ~opcode[4] & ~opcode[3] & opcode[2];    
    end
    
    always @(*) begin
        alu_op[2] = (~opcode[5] & opcode[3]) | (~opcode[5] & opcode[0]);
    end
    
    always @(*) begin
        alu_op[1] = ~(|opcode) | (opcode[3] & ~opcode[0]);
    end
    
    always @(*) begin
        alu_op[0] = (opcode[2] & ~opcode[0]) | (~opcode[3] & ~opcode[1] & opcode[0]);    
    end
    
    /*
    always @(*) begin
        jump = opcode[1] & ~opcode[0];    
    end
    */

endmodule
