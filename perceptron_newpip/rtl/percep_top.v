/**************************************************************
 * Module name: percep_top_new
 *
 * Features:
 *	1. Top module of inference part of perceptron model circuit
 *    2. Only do connection
 *    3. Do 20 datasets in inference to test weights after training in C Language
 *    4. Use infer_fail & infer_done output signals to check if the inference success
 *    5. define: "FMU" is for 1st improvement,
 *        "ADD_MUL_PIP" is for 2nd improvement"
 *
 * Descriptions:
 *	1. There are 4 submodules, "percep_mem", "percep_add", "percep_mtply",
 *        "percep_fsm", in same hierarchy
 *    2. Outputs d_mem_out, d_mem_addr only for checking memory operation
 *        in the first state of FSM
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/
`timescale 1ns / 1ps
//`define PIP4


module percep_top #(
    parameter MEM_WIDTH_YDX = 17,                           // ydx memory width
    parameter MEM_ADDR_YDX  = 7,                            // ydx memory address width
    parameter MEM_DEPTH_YDX = 2 ** MEM_ADDR_YDX,            // ydx memory depth, for only inference dataset, and some spaces
    parameter MEM_ADDR_WGHT = 3,                            // weight memory address width
    parameter INFER_NUM     = 20,                           // inference dataset number
    parameter ATTR          = 5,                            // represent 5 attritibutes
    parameter FP_WIDTH      = 16                            // width of fp data
) (
    clk,
    rst_n,
    infer_ena,
    d_txt_in,
    d_mem_out,
    d_mem_addr,
    infer_fail,
    infer_done
    );

    input                       clk;                        // clock
    input                       rst_n;                      // asynchronous active low reset
    input                       infer_ena;                  // determine whether to start inference
    input   [MEM_WIDTH_YDX-1:0] d_txt_in;                   // data from datamem.txt store into ydx & wght memories
    output  [MEM_WIDTH_YDX-1:0] d_mem_out;                  // data output of ydx memory, read yd when address %5 == 0 and xi at a time
    output  [MEM_ADDR_YDX-1:0]  d_mem_addr;                 // ydx memory address
    output                      infer_done;                 // active when inference done
    output                      infer_fail;                 // active if all ya unequal to yd
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate fsm
    wire    [MEM_WIDTH_YDX-1:0] d_out;                      // data output of ydx memory, read yd when address %5 == 0 and xi at a time
    wire                        sign_out;                   // output sign from sign control stage of pipeline "percep_fp_add_new" module
    wire                        mem_cs_ydx;                 // chip enable of ydx memory
    wire                        mem_we_ydx;                 // write enable of ydx memory
    wire                        mem_oe_ydx;                 // read enable of ydx memory
    wire    [MEM_ADDR_YDX-1:0]  d_addr_ydx;                 // ydx memory address
    wire                        mem_cs_wght;                // chip enable of wght memory
    wire                        mem_we_wght;                // write enable of wght memory
    wire                        mem_oe_wght;                // read enable of wght memory
    wire    [MEM_ADDR_WGHT-1:0] d_addr_wght;                // wght memory address
`ifdef PIP4
    wire                        stall;                      // signal detected need to stall one cycle
`endif
    wire                        rst_add1;                   // reset fp_sum_pip of 2nd pipeline register to 0 when new inference
    
    percep_fsm #(
        .MEM_WIDTH_YDX(MEM_WIDTH_YDX),
        .MEM_ADDR_YDX(MEM_ADDR_YDX),
        .MEM_DEPTH_YDX(MEM_DEPTH_YDX),
        .MEM_ADDR_WGHT(MEM_ADDR_WGHT),
        .INFER_NUM(INFER_NUM),
        .ATTR(ATTR),
        .FP_WIDTH(FP_WIDTH)
    ) inst_fsm(
        .clk(clk),
        .rst_n(rst_n),
        .infer_ena(infer_ena),
        .sign_out(sign_out),
        .yd(d_out[MEM_WIDTH_YDX-1]),
        .infer_done(infer_done),
        .infer_fail(infer_fail),
        .mem_cs_ydx(mem_cs_ydx),
        .mem_we_ydx(mem_we_ydx),
        .mem_oe_ydx(mem_oe_ydx),
        .d_addr_ydx(d_addr_ydx),
        .mem_cs_wght(mem_cs_wght),
        .mem_we_wght(mem_we_wght),
        .mem_oe_wght(mem_oe_wght),
        .d_addr_wght(d_addr_wght),
`ifdef PIP4        
        .stall(stall),
`endif        
        .rst_add1(rst_add1)
    );
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate memory for storing x0~x4 & yd
    percep_mem_ydx #(
        .MEM_WIDTH(MEM_WIDTH_YDX),
        .MEM_ADDR(MEM_ADDR_YDX),
        .MEM_DEPTH(MEM_DEPTH_YDX),
        .ATTR(ATTR)
    ) inst_mem_ydx(
        .clk(clk),
        .cs(mem_cs_ydx),
        .we(mem_we_ydx),
        .oe(mem_oe_ydx),
        .d_addr(d_addr_ydx),
        .d_in(d_txt_in),
        .d_out(d_out)
    );
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate memory for storing w0~w4
    wire    [FP_WIDTH-1:0]      w_out;                      // w to fp_b of fp multiplier
    
    percep_mem_wght #(
        .ATTR(ATTR),
        .MEM_ADDR_WGHT(MEM_ADDR_WGHT),
        .FP_WIDTH(FP_WIDTH)
    ) inst_mem_wght(
        .clk(clk),
        .cs(mem_cs_wght),
        .we(mem_we_wght),
        .oe(mem_oe_wght),
        .d_addr(d_addr_wght),
        .d_in(d_txt_in[FP_WIDTH-1:0]),
        .d_out(w_out)
    );

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pipeline register before fp multiplier
    wire    [FP_WIDTH-1:0]      w_out_pip;                  // w_out after pipeline
    wire    [FP_WIDTH-1:0]      x_out_pip;                  // x_out after pipeline

`ifdef PIP4
    percep_pipreg_xw #(
        .FP_WIDTH(FP_WIDTH)
    ) inst_pipreg1(
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .w_out(w_out),
        .x_out(d_out[FP_WIDTH-1:0]),
        .w_out_pip(w_out_pip),
        .x_out_pip(x_out_pip)
    );
`else
    assign w_out_pip = w_out;
    assign x_out_pip = d_out[FP_WIDTH-1:0];
`endif

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate fp multiplier
    wire    [FP_WIDTH-1:0]      fp_prod;                    // fp data output from fp multiplier
    
    percep_fp_mtply #(
        .FP_WIDTH(FP_WIDTH)
    ) inst_fp_mtply(
        .fp_a(x_out_pip),
        .fp_b(w_out_pip),
        .fp_prod(fp_prod)
    );

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pipeline register between fp multiplier and fp adder
    wire    [FP_WIDTH-1:0]      fp_sum;                     // output accumulation sum of fp adder
    wire    [FP_WIDTH-1:0]      fp_prod_pip;                // fp_prod after pipeline
    wire    [FP_WIDTH-1:0]      fp_sum_pip;                 // connect to input operand of fp adder to do accumulation
    
    percep_pipreg_prodnet #(
        .FP_WIDTH(FP_WIDTH)
    ) inst_pipreg2(
        .clk(clk),
        .rst_n(rst_n),
`ifdef PIP4
        .stall(stall),
`endif
        .rst_add1(rst_add1),
        .fp_prod(fp_prod),
        .fp_sum(fp_sum),
        .fp_prod_pip(fp_prod_pip),
        .fp_sum_pip(fp_sum_pip)
    );

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate fp adder    
    percep_fp_add_new #(
        .FP_WIDTH(FP_WIDTH)
    ) inst_fp_add(
`ifdef PIP4
        .clk(clk),
        .rst_n(rst_n),
`endif
        .fp_a(fp_sum_pip),
        .fp_b(fp_prod_pip),
        .fp_sum(fp_sum),
        .sign_out(sign_out)
    );

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // outputs assignment
    assign d_mem_out = d_out;
    assign d_mem_addr = d_addr_ydx;


endmodule