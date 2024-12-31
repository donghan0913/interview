`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/24 14:56:36
// Design Name: 
// Module Name: mbist_pattern_gen
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


module mbist_pattern_gen #(
    parameter ADDR = 8                                      // width of {row addr, col addr}
) (
    pattern_en,
    addr,
    pattern
    );
    
    localparam ROW_ADDR         = ADDR / 2;                 // row address
    localparam COL_ADDR         = ADDR / 2;                 // column address
    
    input   [1:0]                   pattern_en;             // enable generate 1-bit pattern for cell
    input   [ADDR-1:0]              addr;                   // address {row addr, col addr}
    output                          pattern;                // pattern generated
    
    
    wire    [ROW_ADDR-1:0]          row;                    // row address
    wire    [COL_ADDR-1:0]          col;                    // col address
    reg                             pattern_reg;
    
    assign row = addr[ADDR-1:ROW_ADDR];
    assign col = addr[COL_ADDR-1:0];

`ifdef CHECKERBOARD
    always @(*) begin
        if (pattern_en[1] == 1) begin
            if (row[0] == 0) begin
                pattern_reg = col[0] ^ pattern_en;
            end
            else begin
                pattern_reg = ~col[0] ^ pattern_en;
            end   
        end 
        else    pattern_reg = 0;
    end
//`elsif MARCH_C_SUB
`else
    always @(*) begin
        if (pattern_en[1] == 1) begin
                pattern_reg = pattern_en[0];            
        end
        else    pattern_reg = 0;
    end
`endif    
    
    assign pattern = pattern_reg;
    
    
endmodule
