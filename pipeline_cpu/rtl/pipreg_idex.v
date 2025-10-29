`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 13:28:06
// Design Name: 
// Module Name: pipreg_idex
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
`define LP_GATE


module pipreg_idex #(
    parameter WIDTH_D = 32,
    parameter ADDR_RFILE = 5
) (
    clk,
    rst_n,
    rfile_dst,
    alu_src,
    mem_to_rfile,
    rfile_w,
    mem_r,
    mem_w,
    alu_op,
    ra_data_wab,
    rb_data_wab,
    imme_32,
    addr_rd,
    addr_rt,
    addr_rs,     //forwarding to solve data hazard
    stall_ctrl_ab,
    stall_ctrl,
    mult_sel,
`ifdef LP_GATE
    flush_ctrl,
`endif

    rfile_dst_t,
    alu_src_t,
    mem_to_rfile_t,
    rfile_w_t,
    mem_r_t,
    mem_w_t,
    alu_op_t,
    ra_data_wab_t,
    rb_data_wab_t,
    imme_32_t,
    addr_rd_t,
    addr_rt_t,
    addr_rs_t,     //forwarding to solve data hazard
    stall_ctrl_ab_t,
    stall_ctrl_t,
`ifdef LP_GATE
    flush_ctrl_t,
`endif
    mult_sel_t
    );
    
    input                           clk;
    input                           rst_n;
    input                           rfile_dst;
    input                           alu_src;
    input                           mem_to_rfile;
    input                           rfile_w;
    input                           mem_r;
    input                           mem_w;
    output  [1:0]                   stall_ctrl_ab;          // [1] for rs(a), [0] for rt(b)
    input                           stall_ctrl;
    input   [2:0]                   alu_op;
    input   [WIDTH_D-1:0]           ra_data_wab;
    input   [WIDTH_D-1:0]           rb_data_wab;
    input   [WIDTH_D-1:0]           imme_32;
    input   [ADDR_RFILE-1:0]        addr_rd;
    input   [ADDR_RFILE-1:0]        addr_rt;
    input   [ADDR_RFILE-1:0]        addr_rs;
    input                           mult_sel;
`ifdef LP_GATE
    input                           flush_ctrl;
`endif
    
    output  reg                     rfile_dst_t;
    output  reg                     alu_src_t;
    output  reg                     mem_to_rfile_t;
    output  reg                     rfile_w_t;
    output  reg                     mem_r_t;
    output  reg                     mem_w_t;
    output  reg [1:0]               stall_ctrl_ab_t;        // [1] for rs(a), [0] for rt(b)
    output  reg                     stall_ctrl_t;
    output  reg [2:0]               alu_op_t;
    output  reg [WIDTH_D-1:0]       ra_data_wab_t;
    output  reg [WIDTH_D-1:0]       rb_data_wab_t;
    output  reg [WIDTH_D-1:0]       imme_32_t;
    output  reg [ADDR_RFILE-1:0]    addr_rd_t;
    output  reg [ADDR_RFILE-1:0]    addr_rt_t;
    output  reg [ADDR_RFILE-1:0]    addr_rs_t;
    output  reg                     mult_sel_t;
`ifdef LP_GATE
    output  reg                     flush_ctrl_t;
`endif


    //for main control
    always @(posedge clk) begin
        if (~rst_n) rfile_dst_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    rfile_dst_t <= rfile_dst_t;
            end
            else    rfile_dst_t <= rfile_dst;
        end
`else
        else        rfile_dst_t <= rfile_dst;
`endif
    end
    
    always @(posedge clk) begin
        if (~rst_n) alu_src_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    alu_src_t <= alu_src_t;
            end
            else    alu_src_t <= alu_src;
        end
`else
        else        alu_src_t <= alu_src;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) mem_to_rfile_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    mem_to_rfile_t <= mem_to_rfile_t;
            end
            else    mem_to_rfile_t <= mem_to_rfile;
        end
`else
        else        mem_to_rfile_t <= mem_to_rfile;
`endif
    end
    
    always @(posedge clk) begin
        if (~rst_n) rfile_w_t <= 0;
`ifdef LP_GATE
        else if (stall_ctrl | flush_ctrl_t) begin
`else
        else if (stall_ctrl) begin
`endif
                    rfile_w_t <= 0;
        end
        else        rfile_w_t <= rfile_w;
    end
    
    always @(posedge clk) begin
        if (~rst_n) mem_r_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    mem_r_t <= mem_r_t;
            end
            else    mem_r_t <= mem_r;
        end
`else
        else        mem_r_t <= mem_r;
`endif
    end
    
    always @(posedge clk) begin
        if (~rst_n) mem_w_t <= 0;
`ifdef LP_GATE
        else if (stall_ctrl | flush_ctrl_t) begin
`else
        else if (stall_ctrl) begin
`endif
                    mem_w_t <= 0;
        end  
        else        mem_w_t <= mem_w;
    end

    always @(posedge clk) begin
        if (~rst_n) alu_op_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    alu_op_t <= alu_op_t;
            end
            else    alu_op_t <= alu_op;
        end
`else
        else        alu_op_t <= alu_op;
`endif
    end
    
    //for register file and the others
    always @(posedge clk) begin
        if (~rst_n) ra_data_wab_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    ra_data_wab_t <= ra_data_wab_t;
            end
            else    ra_data_wab_t <= ra_data_wab;
        end
`else
        else        ra_data_wab_t <= ra_data_wab;
`endif
    end
    
    always @(posedge clk) begin
        if (~rst_n) rb_data_wab_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    rb_data_wab_t <= rb_data_wab_t;
            end
            else    rb_data_wab_t <= rb_data_wab;
        end
`else
        else        rb_data_wab_t <= rb_data_wab;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) imme_32_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    imme_32_t <= imme_32_t;
            end
            else    imme_32_t <= imme_32;
        end
`else
        else        imme_32_t <= imme_32;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) addr_rd_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    addr_rd_t <= addr_rd_t;
            end  
            else    addr_rd_t <= addr_rd;
        end
`else
        else        addr_rd_t <= addr_rd;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) addr_rt_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    addr_rt_t <= addr_rt_t;
            end
            else    addr_rt_t <= addr_rt;
        end
`else
        else        addr_rt_t <= addr_rt;
`endif
    end
    
    always @(posedge clk) begin
        if (~rst_n) addr_rs_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    addr_rs_t <= addr_rs_t;
            end
            else    addr_rs_t <= addr_rs;
        end
`else
        else        addr_rs_t <= addr_rs;
`endif
    end

    always @(posedge clk) begin
        if (~rst_n) stall_ctrl_ab_t <= 0;
        else        stall_ctrl_ab_t <= stall_ctrl_ab;
    end

    always @(posedge clk) begin
        if (~rst_n) stall_ctrl_t <= 0;
        else        stall_ctrl_t <= stall_ctrl;
    end
    
    always @(posedge clk) begin
        if (~rst_n) mult_sel_t <= 0;
`ifdef LP_GATE
        else begin
            if (flush_ctrl_t) begin
                    mult_sel_t <= mult_sel_t;
            end
            else    mult_sel_t <= mult_sel;
        end
`else
        else        mult_sel_t <= mult_sel;
`endif
    end

`ifdef LP_GATE
    always @(posedge clk) begin
        if (~rst_n) flush_ctrl_t <= 0;
        else        flush_ctrl_t <= flush_ctrl;
    end
`endif


endmodule
