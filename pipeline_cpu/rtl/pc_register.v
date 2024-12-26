`timescale 1ns / 1ps

module pc_register(
    clk,
    rstn,
    stall_ctr,
    pc_result,
    pc_addr
    );

    parameter instruction_width = 32;

    input clk, rstn, stall_ctr;
    input [instruction_width-1:0] pc_result;
    output reg [instruction_width-1:0] pc_addr;

    always @(posedge clk) begin
        if(~rstn) begin
            pc_addr <= 0;
        end
        else begin
            if (stall_ctr) pc_addr <= pc_addr;
            else pc_addr <= pc_result;
        end
    end


endmodule
