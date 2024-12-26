`timescale 1ns / 1ps

module jump_target(
    imme_26,
    pc_next_top,
    j_target
    );

    parameter instruction_width = 32;

    input [instruction_width-7:0] imme_26;
    input [3:0] pc_next_top;
    output reg [instruction_width-1:0] j_target;

    always @(*) begin
        j_target = {pc_next_top, imme_26, 2'b00};
    end


endmodule
