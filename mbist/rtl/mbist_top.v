`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/24 15:45:37
// Design Name: 
// Module Name: mbist_top
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
//`define CHECKERBOARD
//`define MARCH_C_SUB
//`define MARCH_X
//`define LOPOW_ADDR_GEN


module mbist_top #(
    parameter ADDR = 6                                      // width of {row addr, col addr}
) (
    clk,
    clk_1,
    clk_2,
    rst_n,
    mode,
    mem_d_out,
    mem_addr,
    mem_pattern,
    cs_bist,
    we_bist,
    oe_bist,
    fault_flag,
    bist_done
    );
    
    input                           clk;                    // clock
    input                           clk_1;                  // clock 1 for CLFSR
    input                           clk_2;                  // clock 2 for modified-LFSR   
    input                           rst_n;                  // reset
    input                           mode;                   // functional mode or test mode
    input                           mem_d_out;              // data output from memory
    output  [ADDR-1:0]              mem_addr;               // address {row addr, col addr} from address generator
    output                          mem_pattern;            // test pattern from pattern generator
    output                          cs_bist;                // 
    output                          we_bist;                // 
    output                          oe_bist;                // 
    output                          fault_flag;             // indicate fault detected
    output                          bist_done;              // indicate bist finish
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    wire    [ADDR-1:0]              addr;                   // address {row addr, col addr} from address generator
    wire                            addr_done;
    wire                            pattern;
`ifdef CHECKERBOARD
    wire                            addr_en;                // enable address generator
`else
    wire  	[1:0]                   addr_en;                // enable address generator
`endif    
    wire                          	addr_ff;                // set address to MAX at the beginning of the down counting
    wire    [1:0]                   pattern_en;
    mbist_fsm #(
        .ADDR(ADDR)
    ) inst_fsm(
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .response(mem_d_out),
        .addr(addr),
        .addr_done(addr_done),
        .pattern(pattern),
        .cs_bist(cs_bist),
        .we_bist(we_bist),
        .oe_bist(oe_bist),
        .addr_en(addr_en),
        .addr_ff(addr_ff),
        .pattern_en(pattern_en),
        .fault_flag(fault_flag),
        .bist_done(bist_done)
        );
    
    mbist_addr_gen #(
        .ADDR(ADDR)
    ) inst_addr_gen(
        .clk(clk),
        .clk_1(clk_1),
        .clk_2(clk_2),
        .rst_n(rst_n),
        .addr_en(addr_en),
        .addr_ff(addr_ff),
        .addr(addr),
        .addr_done(addr_done)
        );
    
    mbist_pattern_gen #(
        .ADDR(ADDR)
    ) inst_pattern_gen(
        .pattern_en(pattern_en),
        .addr(addr),
        .pattern(pattern)
        ); 
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // output assignment
    assign mem_addr = addr;
    assign mem_pattern = pattern;
    
    
endmodule
