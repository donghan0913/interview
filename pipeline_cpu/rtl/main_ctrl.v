`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 12:35:37
// Design Name: 
// Module Name: main_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_ctrl #(
    parameter WIDTH_I = 32
) (
    opcode,
    rfile_dst,
    alu_src,
    mem_to_rfile,
    rfile_w,
    mem_r,
    mem_w,
    branch,
    alu_op,
    mult_sel
    );

    input   [5:0]                   opcode;
    output  reg                     rfile_dst;
    output  reg                     alu_src;
    output  reg                     mem_to_rfile;
    output  reg                     rfile_w;
    output  reg                     mem_r;
    output  reg                     mem_w;
    output  reg                     branch;
    output  reg [2:0]               alu_op;
    output  reg                     mult_sel;

    always @(*) begin
        rfile_dst = ~(|opcode) | (&opcode[4:2]);
    end

    always @(*) begin
        case(opcode)
            6'b001000:  alu_src = 1;
            6'b001100:  alu_src = 1;
            6'b001101:  alu_src = 1;
            6'b100011:  alu_src = 1;
            6'b101011:  alu_src = 1;
            default:    alu_src = 0;
        endcase
        //alu_src = (~opcode[5] & opcode[3]) | opcode[5];    
    end

    always @(*) begin
        mem_to_rfile = opcode[5] & ~opcode[3];
    end
    
    always @(*) begin
        case(opcode)
            6'b000000:  rfile_w = 1;
            6'b001000:  rfile_w = 1;
            6'b001100:  rfile_w = 1;
            6'b001101:  rfile_w = 1;
            6'b100011:  rfile_w = 1;
            6'b011100:  rfile_w = 1;
            default:    rfile_w = 0;
        endcase
        //rfile_w = (opcode[5] & ~opcode[3]) | (opcode[3] & opcode[2]) | (~opcode[2] & ~opcode[1]);
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
    
    always @(*) begin
        mult_sel = &opcode[4:2];    
    end


endmodule
