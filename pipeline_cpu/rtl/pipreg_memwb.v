`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 14:36:53
// Design Name: 
// Module Name: pipreg_memwb
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
//`define LP_GATE


module pipreg_memwb #(
     parameter WIDTH_D = 32,
     parameter ADDR_RFILE = 5
) (
    clk,
    rst_n,
    mem_to_rfile_t2,
    rfile_w_t2,
    py_out,
    wb_addr_t,
    memd_out,
    stall_ctrl_t2,
`ifdef LP_GATE
    flush_ctrl_t2,
`endif
    
    mem_to_rfile_t3,
    rfile_w_t3,
    py_out_t,
    wb_addr_t2,
`ifdef LP_GATE
    flush_ctrl_t3,
`endif
    memd_out_t
    );

    input                           clk;
    input                           rst_n;
    input                           mem_to_rfile_t2;
    input                           rfile_w_t2;
    input   [WIDTH_D-1:0]           py_out;
    input   [WIDTH_D-1:0]           memd_out;
    input   [ADDR_RFILE-1:0]        wb_addr_t;    
    input                           stall_ctrl_t2;
`ifdef LP_GATE
    input                           flush_ctrl_t2;    
`endif

    output  reg                     mem_to_rfile_t3;
    output  reg                     rfile_w_t3;
    output  reg [WIDTH_D-1:0]       py_out_t;
    output  reg [WIDTH_D-1:0]       memd_out_t;
    output  reg [ADDR_RFILE-1:0]    wb_addr_t2;
`ifdef LP_GATE
    output  reg                     flush_ctrl_t3;
`endif

    
    //for main control    
    always @(posedge clk) begin
        if (~rst_n) mem_to_rfile_t3 <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t3) begin
                    mem_to_rfile_t3 <= mem_to_rfile_t3;
            end
            else    mem_to_rfile_t3 <= mem_to_rfile_t2;
        end
`else
        else        mem_to_rfile_t3 <= mem_to_rfile_t2;
`endif
    end
    
    always @(posedge clk) begin
        if (~rst_n) rfile_w_t3 <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t3) begin
                    rfile_w_t3 <= 0;
            end
            else    rfile_w_t3 <= rfile_w_t2;
        end
`else
        else        rfile_w_t3 <= rfile_w_t2;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) py_out_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t3) begin
                    py_out_t <= py_out_t;
            end
            else    py_out_t <= py_out;
        end
`else
        else        py_out_t <= py_out;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) wb_addr_t2 <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t3) begin
                    wb_addr_t2 <= wb_addr_t2;
            end
            else    wb_addr_t2 <= wb_addr_t;
        end
`else
        else        wb_addr_t2 <= wb_addr_t;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) memd_out_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t3) begin
                    memd_out_t <= memd_out_t;
            end
            else    memd_out_t <= memd_out;
        end
`else
        else        memd_out_t <= memd_out;
`endif
    end

`ifdef LP_GATE
    always @(posedge clk) begin
        if (~rst_n) flush_ctrl_t3 <= 0;
        else        flush_ctrl_t3 <= flush_ctrl_t2;
    end
`endif


endmodule
