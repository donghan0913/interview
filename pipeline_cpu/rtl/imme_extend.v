`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 13:05:29
// Design Name: 
// Module Name: imme_extend
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


module imme_extend #(
    parameter WIDTH_I = 32
) (
    imme_16,
    imme_32
    );
    
    input   [WIDTH_I-17:0]          imme_16;
    output  reg [WIDTH_I-1:0]       imme_32;

    always @(*) begin
        imme_32 = {{16{imme_16[15]}}, imme_16};
    end


endmodule
