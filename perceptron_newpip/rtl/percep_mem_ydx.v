/**************************************************************
 * Module name: percep_mem_ydx
 *
 * Features:
 *	1. Store x0~x4 & yd for inference dataset
 *    2. Size = 128 * 17
 *        Column: 16 is for yd, 15~0 are for x0~x4
 *        Row: 0~99 are for attributes, otherwise ignored
 *
 * Descriptions:
 *	1. All values are stored by using $readmemb function at the beginning of the testbench
 * 
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module percep_mem_ydx #(
    parameter MEM_WIDTH     = 17,                   // memory width
    parameter MEM_ADDR      = 7,                    // memory address width
    parameter MEM_DEPTH     = 2 ** MEM_ADDR,        // memory depth, for only inference dataset, and some spaces
    parameter ATTR          = 5                     // represent 5 attritibutes
) (
    clk,
    cs,
    we,
    oe,
    d_addr,
    d_in,
    d_out
);
    
    input                       clk;                // clock
    input                       cs;                 // chip select
    input                       we;                 // write enable
    input                       oe;                 // read enable
    input   [MEM_WIDTH-1:0]     d_in;               // memory input, due to write yd when address %5 == 0 and xi at a time
    input   [MEM_ADDR-1:0]      d_addr;             // memory address
    output  [MEM_WIDTH-1:0]     d_out;              // memory output, due to read yd when address %5 == 0 and xi at a time
    
    reg [MEM_WIDTH-1:0] mem [0:MEM_DEPTH-1];        // memory body
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // memory read
    wire    [MEM_WIDTH-1:0]     dcare;              // don't care data to d_out
    
    assign dcare = {MEM_WIDTH{1'b0}};
    assign d_out = (cs & oe) ? mem[d_addr] : dcare;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // memory write 
    always @(posedge clk) begin
        if (cs & we)    mem[d_addr] <= d_in;
    end


endmodule
