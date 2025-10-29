`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 13:13:54
// Design Name: 
// Module Name: comp_wab
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


module comp_wab #(
    parameter WIDTH_D = 32,
    parameter ADDR_RFILE = 5
) (
    ra_addr,
    rb_addr,
    rfile_w_t3,
    wb_addr,
    ra_data,
    rb_data,
    wb_data,
    ra_data_wab,
    rb_data_wab
    );

    input   [ADDR_RFILE-1:0]        ra_addr;
    input   [ADDR_RFILE-1:0]        rb_addr;
    input                           rfile_w_t3;
    input   [ADDR_RFILE-1:0]        wb_addr;
    input   [WIDTH_D-1:0]           ra_data;
    input   [WIDTH_D-1:0]           rb_data;
    input   [WIDTH_D-1:0]           wb_data;
    output  [WIDTH_D-1:0]           ra_data_wab;
    output  [WIDTH_D-1:0]           rb_data_wab;

    wire                            compare_ra;
    wire                            compare_rb;

    assign compare_ra = ~|(ra_addr ^ wb_addr);
    assign compare_rb = ~|(rb_addr ^ wb_addr);

    assign ra_data_wab = (compare_ra & rfile_w_t3) ? wb_data : ra_data;
    assign rb_data_wab = (compare_rb & rfile_w_t3) ? wb_data : rb_data;


endmodule
