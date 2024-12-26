/**************************************************************
 * Module name: percep_pipreg_prodnet
 *
 * Features:
 *	1. Pipeline register for fp_prod from fp multiplier and fp_sum from fp adder
 *
 * Descriptions:
 *	1. Not sure need to do stalling or not ???
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/
//`define PIP4


module percep_pipreg_prodnet #(
    parameter FP_WIDTH      = 16                                // width of fp data
)(
    clk,
    rst_n,
`ifdef PIP4
    stall,
`endif    
    rst_add1,
    fp_prod,
    fp_sum,
    fp_prod_pip,
    fp_sum_pip
    );
    
    input                           clk;                        // clock
    input                           rst_n;                      // asynchronous active low reset
`ifdef PIP4    
    input                           stall;                      // control pipeline to stall one cycle
`endif    
    input                           rst_add1;                   // reset fp_sum_pip of 2nd pipeline register to 0 when new inference
    input       [FP_WIDTH-1:0]      fp_prod;                    // fp_prod before pipeline
    input       [FP_WIDTH-1:0]      fp_sum;                     // fp_sum before pipeline
    output  reg [FP_WIDTH-1:0]      fp_prod_pip;                // fp_prod after pipeline
    output  reg [FP_WIDTH-1:0]      fp_sum_pip;                 // fp_sum after pipeline
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pipeline assignment
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     fp_prod_pip <= 0;
`ifdef PIP4
        else if (stall) fp_prod_pip <= fp_prod_pip;
`endif
        else            fp_prod_pip <= fp_prod;
    end
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)         fp_sum_pip <= 0;
        else if (rst_add1)  fp_sum_pip <= 0;
        else                fp_sum_pip <= fp_sum;
    end
    
    
endmodule

