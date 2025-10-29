`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 12:42:53
// Design Name: 
// Module Name: rfile
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


module rfile #(
    parameter WIDTH_I = 32,
    parameter ADDR_RFILE = 5,
    parameter DEPTH_RFILE = 2**ADDR_RFILE
) (
    clk,
    rst_n,
    w_data,
    w_en,
    w_addr,
    ra_addr,
    rb_addr,
    ra_data,
    rb_data
    );
    
    input                           clk;
    input                           rst_n;
    input                           w_en;
    input   [WIDTH_I-1:0]           w_data;
    input   [ADDR_RFILE-1:0]        w_addr;
    input   [ADDR_RFILE-1:0]        ra_addr;
    input   [ADDR_RFILE-1:0]        rb_addr;
    output  reg [WIDTH_I-1:0]       ra_data;
    output  reg [WIDTH_I-1:0]       rb_data;
    
    reg     [WIDTH_I-1:0]           regfile     [DEPTH_RFILE-1:0];
    
    integer i;
    
    always @(*) begin
        ra_data = regfile[ra_addr];
    end
    
    always @(*) begin
        rb_data = regfile[rb_addr];
    end
    
    always @(posedge clk) begin
        if(~rst_n) begin
            for(i = 0; i < DEPTH_RFILE; i = i + 1) begin
                regfile[i] <= 0;
            end
        end
        else begin
            if (w_en) begin
                regfile[w_addr] <= w_data;
            end
        end
    end


endmodule
