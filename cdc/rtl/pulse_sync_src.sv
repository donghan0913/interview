`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/03 13:42:32
// Design Name: 
// Module Name: pulse_sync_src
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
//`define HAND_CNT_BASED


module pulse_sync_src #(
    parameter     PERIOD_SRC    = 20,
    parameter     PERIOD_DST    = 70
) (
    clk_src,
    rst_n,
    d_in,
`ifdef HAND_CNT_BASED
    ack,
    busy,
`endif
    tq
    );
   
    localparam int PEND_CNT = ((2 * PERIOD_SRC) + (2 * PERIOD_DST)) / PERIOD_SRC;
    localparam int PEND_CNT_SIZE = $clog2(PEND_CNT + 1);;
    localparam PEND_CNT_SUB = {PEND_CNT_SIZE{1'b1}};
 
    input                           clk_src;
    input                           rst_n;
    input                           d_in;
`ifdef HAND_CNT_BASED
    input                           ack;
    output                          busy;
`endif
    output                          tq;
    
    reg                             d_src_tq;
`ifdef HAND_CNT_BASED
    reg                             ack_src_t1;
    reg                             ack_src_t2;
    reg     [PEND_CNT_SIZE-1:0]     pend_cnt;
`endif
    reg                             d_in_t1;

    // --------------------------------------------------------------------------------------------------------------------------------------------------------
    // input pulse control
`ifdef HAND_CNT_BASED
    always @(posedge clk_src, negedge rst_n) begin
        if (~rst_n)             pend_cnt <= 0;
        else begin
            if (d_in_t1 & d_in) pend_cnt <= pend_cnt;
            else if (d_in_t1)   pend_cnt <= pend_cnt + PEND_CNT_SUB;
            else if (d_in)      pend_cnt <= pend_cnt + 1;
            else                pend_cnt <= pend_cnt;
        end
    end

    always @(posedge clk_src, negedge rst_n) begin
        if (~rst_n) d_in_t1 <= 0;
        else begin
            if ((busy == 0) && (pend_cnt != 0)) begin
                    d_in_t1 <= 1;
            end
            else    d_in_t1 <= 0;
        end
    end
`else
    always @(posedge clk_src, negedge rst_n) begin
        if (~rst_n) d_in_t1 <= 0;
        else        d_in_t1 <= d_in;
    end
`endif

    // ------------------------------------------------------------------------------------------------------------------------------------------------
    // pulse synchronizer main circuit
    always @(posedge clk_src, negedge rst_n) begin
        if (~rst_n)     d_src_tq <= 0;
`ifdef HAND_CNT_BASED
        else begin
            if ((pend_cnt != 0) && (busy == 0)) begin
                        d_src_tq <= ~d_src_tq;
            end
            else        d_src_tq <= d_src_tq;
        end
`else        
        else            d_src_tq <= d_src_tq ^ d_in_t1;    
`endif
    end    
    
`ifdef HAND_CNT_BASED
    always @(posedge clk_src, negedge rst_n) begin
        if (~rst_n)     ack_src_t1 <= 0;
        else            ack_src_t1 <= ack;       
    end
    
    always @(posedge clk_src, negedge rst_n) begin
        if (~rst_n)     ack_src_t2 <= 0;
        else            ack_src_t2 <= ack_src_t1;       
    end
    
    assign busy = (ack_src_t2 ^ d_src_tq);
`endif
    assign tq = d_src_tq;
    
    
endmodule

