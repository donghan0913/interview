`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 14:07:59
// Design Name: 
// Module Name: forward
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


module forward #(
    parameter ADDR_RFILE = 5
) (
    rfile_w_t2,
    rfile_w_t3,
    wb_addr_t,
    wb_addr_t2,
    addr_rs_t,
    addr_rt_t,
`ifdef LP_GATE
    flush_ctrl_t,
`endif    
    stall_ctrl_t2,
    frd_ctrl_a,
    frd_ctrl_b
    );
    
    input                           rfile_w_t2;
    input                           rfile_w_t3;
    input   [ADDR_RFILE-1:0]        wb_addr_t;
    input   [ADDR_RFILE-1:0]        wb_addr_t2;
    input   [ADDR_RFILE-1:0]        addr_rs_t;
    input   [ADDR_RFILE-1:0]        addr_rt_t;
`ifdef LP_GATE
    input                           flush_ctrl_t;
`endif
    input                           stall_ctrl_t2;
    output  [1:0]                   frd_ctrl_a;
    output  [1:0]                   frd_ctrl_b;

    reg     [1:0]                   frd_ctrl_a_reg;
    reg     [1:0]                   frd_ctrl_b_reg;
    
    //a_forwarrd_ctr, b_forwarrd_ctr before improvement    
    always @(*) begin
        if ((rfile_w_t2 == 1) && (wb_addr_t != 0)) begin
`ifdef LP_GATE
            if (flush_ctrl_t) begin
                    frd_ctrl_a_reg[1] = 0;
            end
            else if (wb_addr_t == addr_rs_t) begin
                    frd_ctrl_a_reg[1] = 1;
            end
`else
            if (wb_addr_t == addr_rs_t) begin
                    frd_ctrl_a_reg[1] = 1;
            end
`endif
            else    frd_ctrl_a_reg[1] = 0;
        end
        else        frd_ctrl_a_reg[1] = 0;
    end
    
    always @(*) begin
        if ((rfile_w_t3 == 1) && (wb_addr_t2 != 0)) begin
            if ((wb_addr_t2 == addr_rs_t) && (wb_addr_t != addr_rs_t)) begin
                    frd_ctrl_a_reg[0] = 1;
            end
            else if ((wb_addr_t2 == addr_rs_t) && (stall_ctrl_t2 == 1)) begin
                    frd_ctrl_a_reg[0] = 1;
            end
            else    frd_ctrl_a_reg[0] = 0;
        end
        else        frd_ctrl_a_reg[0] = 0;
    end
    
    always @(*) begin
        if ((rfile_w_t2 == 1) && (wb_addr_t != 0)) begin
`ifdef LP_GATE
            if (flush_ctrl_t) begin
                    frd_ctrl_b_reg[1] = 0;
            end
            else if (wb_addr_t == addr_rt_t) begin
                    frd_ctrl_b_reg[1] = 1;
            end
`else
            if (wb_addr_t == addr_rt_t) begin
                    frd_ctrl_b_reg[1] = 1;
            end
`endif
            else    frd_ctrl_b_reg[1] = 0;
        end
        else        frd_ctrl_b_reg[1] = 0;
    end
    
    always @(*) begin
        if ((rfile_w_t3 == 1) && (wb_addr_t2 != 0)) begin
            if ((wb_addr_t2 == addr_rt_t) && (wb_addr_t != addr_rt_t)) begin
                    frd_ctrl_b_reg[0] = 1;
            end
            else if ((wb_addr_t2 == addr_rt_t) && (stall_ctrl_t2 == 1)) begin
                    frd_ctrl_b_reg[0] = 1;
            end
            else    frd_ctrl_b_reg[0] = 0;
        end
        else        frd_ctrl_b_reg[0] = 0;
    end
    
    assign frd_ctrl_a = frd_ctrl_a_reg;
    assign frd_ctrl_b = frd_ctrl_b_reg;
    
    
    //assign frd_ctrl_a[1] = rfile_w_t2 && (wb_addr_t != 0) && (wb_addr_t == addr_rs_t);
    //assign frd_ctrl_a[0] = rfile_w_t3 && (wb_addr_t2 != 0) && (wb_addr_t2 == addr_rs_t) && (wb_addr_t != addr_rs_t);
    //assign frd_ctrl_b[1] = rfile_w_t2 && (wb_addr_t != 0) && (wb_addr_t == addr_rt_t);
    //assign frd_ctrl_b[0] = rfile_w_t3 && (wb_addr_t2 != 0) && (wb_addr_t2 == addr_rt_t) && (wb_addr_t != addr_rt_t);


endmodule
