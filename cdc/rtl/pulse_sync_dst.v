`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/03 13:37:52
// Design Name: 
// Module Name: pulse_sync_dst
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


module pulse_sync_dst(
    clk_dst,
    rst_n,
    tq,
`ifdef HAND_CNT_BASED
    ack,
`endif
    d_out
    );
    
    input                           clk_dst;
    input                           rst_n;
    input                           tq;
`ifdef HAND_CNT_BASED
    output                          ack;
`endif
    output                          d_out;
    
    reg                             d_dst_t1;
    reg                             d_dst_t2;
    reg                             d_dst_t3;
    
    always @(posedge clk_dst, negedge rst_n) begin
        if (~rst_n)     d_dst_t1 <= 0;
        else            d_dst_t1 <= tq;       
    end
    
    always @(posedge clk_dst, negedge rst_n) begin
        if (~rst_n)     d_dst_t2 <= 0;
        else            d_dst_t2 <= d_dst_t1;       
    end
    
    always @(posedge clk_dst, negedge rst_n) begin
        if (~rst_n)     d_dst_t3 <= 0;
        else            d_dst_t3 <= d_dst_t2;       
    end

`ifdef HAND_CNT_BASED
    assign ack = d_dst_t2;    
`endif
    assign d_out = d_dst_t2 ^ d_dst_t3;

    
endmodule

