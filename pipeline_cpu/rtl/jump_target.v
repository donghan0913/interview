`timescale 1ns / 1ps

module jump_target #(
    parameter WIDTH_I = 32
) (
    imme_26,
    pc_next_top,
    j_target
    );

    input   [WIDTH_I-7:0]           imme_26;
    input   [3:0]                   pc_next_top;
    output  [WIDTH_I-1:0]           j_target;


    assign j_target = {pc_next_top, imme_26, 2'b00};


endmodule
