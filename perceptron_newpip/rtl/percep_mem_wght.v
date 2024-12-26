/**************************************************************
 * Module name: percep_mem_wght
 *
 * Features:
 *	1. Store w0~w4 for training weight result
 *    2. Size = 8 * 16
 *        Row: 0~4 are for w0~w4, otherwise ignored
 *
 * Descriptions:
 *	1. All values are stored by using $readmemb function at the beginning of the testbench
 * 
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module percep_mem_wght #(
    parameter ATTR          = 5,                            // represent 5 attritibutes
    parameter MEM_ADDR_WGHT = 3,                            // weight memory address width
    parameter FP_WIDTH      = 16                            // width of fp data
) (
    clk,
    cs,
    we,
    oe,
    d_addr,
    d_in,
    d_out
    );
    
    localparam MEM_DEPTH_WGHT = 2 ** MEM_ADDR_WGHT;         // depth of weight memory
    
    input                       clk;                        // clock
    input                       cs;                         // chip select
    input                       we;                         // write enable
    input                       oe;                         // read enable
    input   [FP_WIDTH-1:0]      d_in;                       // memory input
    input   [MEM_ADDR_WGHT-1:0] d_addr;                     // memory address
    output  [FP_WIDTH-1:0]      d_out;                      // memory output
    
    reg     [FP_WIDTH-1:0]      mem     [0:MEM_DEPTH_WGHT-1];// memory body
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // memory read
    wire    [FP_WIDTH-1:0]      dcare;                      // don't care data to d_out
    
    assign dcare = {FP_WIDTH{1'b0}};
    assign d_out = (cs & oe) ? mem[d_addr] : dcare;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // memory write 
    always @(posedge clk) begin
        if (cs & we)    mem[d_addr] <= d_in;
    end    
    
    
endmodule
