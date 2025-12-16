`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/03 14:03:16
// Design Name: 
// Module Name: pulse_sync
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


module pulse_sync (
    clk_src,
    clk_dst,
    rst_n,
    d_in,
    d_out
    );
    
    input                           clk_src;                // source domain clock
    input                           clk_dst;                // destination domain clock
    input                           rst_n;                  // same reset for both source domain and destination
    input                           d_in;                   // single bit pulse data from source domain
    output                          d_out;                  // output data after CDC dealing
    
    localparam     PERIOD_SRC    = `PERIOD_SRC;
    localparam     PERIOD_DST    = `PERIOD_DST;
    
    // --------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
`ifdef HAND_CNT_BASED
    wire                            ack;
    wire                            busy;
`endif
    wire                            tq;
    wire                            rst_n_src;
    wire                            rst_n_dst;
    
    rst_sync inst_rst_sync_src(
        .clk(clk_src),
	    .rst_n(rst_n),
	    .rst_sync_n(rst_n_src)
        );
    
    rst_sync inst_rst_sync_dst(
        .clk(clk_dst),
	    .rst_n(rst_n),
	    .rst_sync_n(rst_n_dst)
        );
    
    
    pulse_sync_src #(
        .PERIOD_SRC(PERIOD_SRC),
        .PERIOD_DST(PERIOD_DST)
    ) inst_psync_src(
        .clk_src(clk_src),
        .rst_n(rst_n_src),
        .d_in(d_in),
`ifdef HAND_CNT_BASED
        .ack(ack),
        .busy(busy),
`endif
        .tq(tq)
        );
        
    pulse_sync_dst inst_psync_dst(
        .clk_dst(clk_dst),
        .rst_n(rst_n_dst),
        .tq(tq),
`ifdef HAND_CNT_BASED
        .ack(ack),
`endif
        .d_out(d_out)
        );
   
    
endmodule

