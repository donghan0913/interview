`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 12:23:27
// Design Name: 
// Module Name: pipreg_ifid
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


module pipreg_ifid #(
    parameter WIDTH_I = 32
) (
    clk,
    rst_n,
    flush_ctrl,
    stall_ctrl,
    pc_next,
    memi_out,
    memi_out_t,
    pc_next_t
    );

    input                           clk;
    input                           rst_n;
    input                           flush_ctrl;
    input                           stall_ctrl;
    input   [WIDTH_I-1:0]           pc_next;
    input   [WIDTH_I-1:0]           memi_out;
    output  reg [WIDTH_I-1:0]       pc_next_t;
    output  reg [WIDTH_I-1:0]       memi_out_t;


    always @(posedge clk) begin
        if (~rst_n) begin
            memi_out_t <= 0;
        end
        else begin
            if (stall_ctrl) memi_out_t <= memi_out_t;
            else begin
                if (flush_ctrl) memi_out_t <= 0;
                else memi_out_t <= memi_out;
            end
        end
    end
    
    always @(posedge clk) begin
        if (~rst_n) begin
            pc_next_t <= 0;
        end
        else begin
            if (flush_ctrl) pc_next_t <= pc_next_t;
            else pc_next_t <= pc_next;
        end
    end
    
    
endmodule
