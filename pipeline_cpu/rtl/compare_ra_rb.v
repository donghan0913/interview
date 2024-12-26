`timescale 1ns / 1ps

module compare_ra_rb(
    ra_data,
    rb_data,
    beq_bne_ctr,
    ab_equal
    );

    parameter instruction_width = 32;
    
    input [instruction_width-1:0] ra_data, rb_data;
    input beq_bne_ctr;
    output ab_equal;
    
    wire compare;

    assign ab_equal = (~beq_bne_ctr) ? compare : ~compare;

    assign compare = ~|(ra_data ^ rb_data);


endmodule
