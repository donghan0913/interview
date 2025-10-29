`timescale 1ns / 1ps

//`define DIRECT_ADD

module pc_add_target #(
    parameter WIDTH_I = 32
) (
    pc_next,
    imme_32,
    pc_target
    );

    input   [WIDTH_I-1:0]           imme_32;
    input   [WIDTH_I-1:0]           pc_next;
    output  [WIDTH_I-1:0]           pc_target;
    
    wire    [WIDTH_I-1:0]           a;
    wire    [WIDTH_I-1:0]           b;

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
