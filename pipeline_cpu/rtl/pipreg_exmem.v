`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 14:16:30
// Design Name: 
// Module Name: pipreg_exmem
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


module pipreg_exmem #(
    parameter WIDTH_D = 32,
    parameter ADDR_RFILE = 5
) (
    clk,
    rst_n,
    mem_to_rfile_t,
    rfile_w_t,
    mem_r_t,
    mem_w_t,
    y,
    rb_data_wab_t,
    wb_addr,
    stall_ctrl_ab_t,
    stall_ctrl_t,
    mult_sel_t,
`ifdef LP_GATE
    flush_ctrl_t,
`endif

    mem_to_rfile_t2,
    rfile_w_t2,
    mem_r_t2,
    mem_w_t2,
    y_t,
    rb_data_wab_t2,
    wb_addr_t,
    stall_ctrl_ab_t2,
    stall_ctrl_t2,
`ifdef LP_GATE
    flush_ctrl_t2,
`endif
    mult_sel_t2
    );

    input                           clk;
    input                           rst_n;
    input                           mem_to_rfile_t;
    input                           rfile_w_t;
    input                           mem_r_t;
    input                           mem_w_t;
    input   [1:0]                   stall_ctrl_ab_t;        // [1] for rs(a), [0] for rt(b)
    input                           stall_ctrl_t;
    input   [WIDTH_D-1:0]           y;
    input   [WIDTH_D-1:0]           rb_data_wab_t;
    input   [ADDR_RFILE-1:0]        wb_addr;
    input                           mult_sel_t;
`ifdef LP_GATE
    input                           flush_ctrl_t;
`endif

    output  reg                     mem_to_rfile_t2;
    output  reg                     rfile_w_t2;
    output  reg                     mem_r_t2;
    output  reg                     mem_w_t2;
    output  reg [1:0]               stall_ctrl_ab_t2;        // [1] for rs(a), [0] for rt(b)
    output  reg                     stall_ctrl_t2;
    output  reg [WIDTH_D-1:0]       y_t;
    output  reg [WIDTH_D-1:0]       rb_data_wab_t2;
    output  reg [ADDR_RFILE-1:0]    wb_addr_t;
    output  reg                     mult_sel_t2;
`ifdef LP_GATE
    output  reg                     flush_ctrl_t2;
`endif

    
    //for main control
    always @(posedge clk) begin
        if (~rst_n) mem_to_rfile_t2 <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t2) begin
                    mem_to_rfile_t2 <= mem_to_rfile_t2;
            end
            else    mem_to_rfile_t2 <= mem_to_rfile_t;
        end
`else
        else        mem_to_rfile_t2 <= mem_to_rfile_t;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) rfile_w_t2 <= 0;
`ifdef LP_GATE
        else if (flush_ctrl_t2) begin
                    rfile_w_t2 <= 0;
        end
`endif
        else        rfile_w_t2 <= rfile_w_t;
    end

    always @(posedge clk) begin
        if (~rst_n) mem_r_t2 <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t2) begin
                    mem_r_t2 <= mem_r_t2;
            end
            else    mem_r_t2 <= mem_r_t;
        end
`else
        else        mem_r_t2 <= mem_r_t;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) mem_w_t2 <= 0;
`ifdef LP_GATE
        else if (flush_ctrl_t2) begin
                    mem_w_t2 <= 0;
        end
`endif
        else        mem_w_t2 <= mem_w_t;
    end

    always @(posedge clk) begin
        if (~rst_n) y_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t2) begin
                    y_t <= y_t;
            end
            else    y_t <= y;
        end
`else
        else        y_t <= y;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) rb_data_wab_t2 <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t2) begin
                    rb_data_wab_t2 <= rb_data_wab_t2;
            end
            else    rb_data_wab_t2 <= rb_data_wab_t;
        end
`else
        else        rb_data_wab_t2 <= rb_data_wab_t;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) wb_addr_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t2) begin
                    wb_addr_t <= wb_addr_t;
            end
            else    wb_addr_t <= wb_addr;
        end
`else
        else        wb_addr_t <= wb_addr;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) stall_ctrl_ab_t2 <= 0;
        else        stall_ctrl_ab_t2 <= stall_ctrl_ab_t;
    end

    always @(posedge clk) begin
        if (~rst_n) stall_ctrl_t2 <= 0;
        else        stall_ctrl_t2 <= stall_ctrl_t;
    end

    always @(posedge clk) begin
        if (~rst_n) mult_sel_t2 <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t2) begin
                    mult_sel_t2 <= mult_sel_t2;
            end
            else    mult_sel_t2 <= mult_sel_t;
        end
`else
        else        mult_sel_t2 <= mult_sel_t;
`endif
    end

`ifdef LP_GATE
    always @(posedge clk) begin
        if (~rst_n) flush_ctrl_t2 <= 0;
        else        flush_ctrl_t2 <= flush_ctrl_t;
    end
`endif


endmodule
