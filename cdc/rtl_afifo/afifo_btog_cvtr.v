`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/08 11:57:23
// Design Name: 
// Module Name: afifo_btog_cvtr
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


module afifo_btog_cvtr #(
    parameter WIDTH = 4
) ( 
    input  [WIDTH-1:0] bin,
    output [WIDTH-1:0] gray
    );
    
    genvar i;
    generate
    for(i = 0; i < WIDTH-1; i = i + 1) begin: afifo_b2g
        assign gray[i] = bin[i] ^ bin[i+1];
    end
    endgenerate

    assign gray[WIDTH-1] = bin[WIDTH-1];
    
    
endmodule

