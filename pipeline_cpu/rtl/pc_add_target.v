`timescale 1ns / 1ps

//`define DIRECT_ADD

module pc_add_target(
    pc_next,
    imme_32,
    pc_target
    );

    parameter instruction_width = 32;

    input [instruction_width-1:0] imme_32, pc_next;
    output [instruction_width-1:0] pc_target;
    
    wire [instruction_width-1:0] a, b;

    assign b = imme_32 << 2'd2;
    
    //before improvement
    assign pc_target = pc_next + b;

    /*
    //instance adder_32_bit
    adder_32_bit inst_pctarget_adder(
        .a(pc_next),
        .b(b),
        .cin(1'b0),
        .sum(pc_target)
    );    
*/

endmodule
