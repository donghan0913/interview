`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/17 10:38:24
// Design Name: 
// Module Name: stall
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


module stall #(
    parameter ADDR_RFILE = 5
) (
    mem_r_idex,
    mult_sel_idex,
    addr_rt_idex,
    addr_rs_ifid,
    addr_rt_ifid,
    addr_rd_idex,
    stall_ctrl_ab,
    stall_ctrl
    );
    
    input                           mem_r_idex;
    input                           mult_sel_idex;
    input   [ADDR_RFILE-1:0]        addr_rt_idex;
    input   [ADDR_RFILE-1:0]        addr_rs_ifid;
    input   [ADDR_RFILE-1:0]        addr_rt_ifid;
    input   [ADDR_RFILE-1:0]        addr_rd_idex;
    output  reg [1:0]               stall_ctrl_ab;          // [1] for rs(a), [0] for rt(b)
    output                          stall_ctrl;
    
    
    always @(*) begin
        if (mem_r_idex == 1) begin
            if (addr_rt_idex == addr_rs_ifid) begin
                    stall_ctrl_ab = 2'b10;
            end
            else if (addr_rt_idex == addr_rt_ifid) begin
                    stall_ctrl_ab = 2'b01;
            end
            else    stall_ctrl_ab = 0;
        end
        else if (mult_sel_idex == 1) begin
            if (addr_rd_idex == addr_rs_ifid) begin
                    stall_ctrl_ab = 2'b10;
            end
            else if (addr_rd_idex == addr_rt_ifid) begin
                    stall_ctrl_ab = 2'b01;
            end
            else    stall_ctrl_ab = 0;
        end
        else        stall_ctrl_ab = 0;
    end

    assign stall_ctrl = |(stall_ctrl_ab); 


endmodule
