`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 12:56:00
// Design Name: 
// Module Name: comp_ab
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


module comp_ab #(
    parameter WIDTH_I = 32
) (
    ra_data,
    rb_data,
    branch_sel,
    branch,
    flush_ctrl
    );
    
    input   [WIDTH_I-1:0]           ra_data;
    input   [WIDTH_I-1:0]           rb_data;
    input                           branch_sel;
    input                           branch;
    output                          flush_ctrl;
    
    wire                            compare;
    wire                            eq_ab;

    assign compare = ~|(ra_data ^ rb_data);
    assign eq_ab = (~branch_sel) ? compare : ~compare;
    assign flush_ctrl = (branch & eq_ab); 


endmodule
