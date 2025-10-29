`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 13:59:33
// Design Name: 
// Module Name: alu_ctrl
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


module alu_ctrl(
    funct,
    alu_op,
    alu_ctrl
    );
    
    input   [5:0]                   funct;
    input   [2:0]                   alu_op;
    output  reg [3:0]               alu_ctrl;
    
    
    always @(*) begin
        alu_ctrl[3] = ~alu_op[2] & alu_op[1] & funct[1] & funct[0];
    end
    
    always @(*) begin
        alu_ctrl[2] = (~alu_op[2] & alu_op[1] & funct[1]) | (~alu_op[1] & alu_op[0]);
    end
    
    always @(*) begin
        alu_ctrl[1] = (~alu_op[2] & alu_op[1] & ~funct[2]) | (~alu_op[2] & ~alu_op[1]) | (alu_op[2] & alu_op[1] & ~alu_op[0]) | (~alu_op[1] & alu_op[0]);
    end
    
    always @(*) begin
        alu_ctrl[0] = (~alu_op[2] & alu_op[1] & ~funct[1] & funct[0]) | (alu_op[2] & ~alu_op[1] & ~alu_op[0]);
    end


endmodule
