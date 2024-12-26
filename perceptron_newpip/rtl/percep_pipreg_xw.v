/**************************************************************
 * Module name: percep_pipreg_xw
 *
 * Features:
 *	1. Pipeline register for x_out and w_out
 *
 * Descriptions:
 *	1. Not sure need to do stalling or not ???
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module percep_pipreg_xw #(
    parameter FP_WIDTH      = 16                            // width of fp data
)(
    clk,
    rst_n,
    stall,
    w_out,
    x_out,
    w_out_pip,
    x_out_pip
    );
    
    input                           clk;                        // clock
    input                           rst_n;                      // asynchronous active low reset
    input                           stall;                      // control pipeline to stall one cycle
    input       [FP_WIDTH-1:0]      x_out;                      // x_out before pipeline
    input       [FP_WIDTH-1:0]      w_out;                      // w_out before pipeline
    output  reg [FP_WIDTH-1:0]      x_out_pip;                  // x_out after pipeline
    output  reg [FP_WIDTH-1:0]      w_out_pip;                  // w_out after pipeline
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pipeline assignment
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     x_out_pip <= 0;
        else if (stall) x_out_pip <= x_out_pip;
        else            x_out_pip <= x_out;
    end
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     w_out_pip <= 0;
        else if (stall) w_out_pip <= w_out_pip;
        else            w_out_pip <= w_out;
    end
    
    
endmodule
