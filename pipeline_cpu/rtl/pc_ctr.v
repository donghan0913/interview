`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 11:59:19
// Design Name: 
// Module Name: pc_ctr
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


module pc_ctr #(
    parameter WIDTH_I = 32
) (
    clk,
    rst_n,
    stall_ctrl,
    pc_result,
    pc_addr
    );

    input                           clk;
    input                           rst_n;
    input                           stall_ctrl;
    input   [WIDTH_I-1:0]           pc_result;              // pc address to pc counter
    output reg  [WIDTH_I-1:0]       pc_addr;                // pc address from pc counter

    //reg     [WIDTH_I-1:0]           pc_addr_reg;

    always @(posedge clk) begin
        if(~rst_n) begin
            pc_addr <= 0;
        end
        else begin
            if (stall_ctrl) pc_addr <= pc_addr;
            else pc_addr <= pc_result;
        end
    end

    
endmodule
