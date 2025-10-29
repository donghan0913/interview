`timescale 1ns / 1ps

//`define DIRECT_ADD

module pc_add4 #(
    parameter WIDTH_I = 32
) (
    pc_addr,
    pc_next
    );
    
    input   [WIDTH_I-1:0]           pc_addr;
    output  [WIDTH_I-1:0]           pc_next;
    
    //before improvement
    assign pc_next = pc_addr + 32'h0000_0004;
    
    /*
    //instance adder_32_bit
    adder_32_bit inst_pc4_adder(
        .a(pc_addr),
        .b(b),
        .cin(1'b0),
        .sum(pc_next)
    );
*/


endmodule
