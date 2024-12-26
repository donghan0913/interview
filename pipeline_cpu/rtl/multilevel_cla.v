`timescale 1ns / 1ps

//used for computer arithmetic project
module multilevel_cla(
    a,
    b,
    cin,
    sum,
    cout
    );

    parameter instruction_width = 32;
    parameter cla_width = instruction_width/2;
    parameter block_num = cla_width/4;
    parameter block_width = cla_width/4;
    
    input [cla_width-1:0] a, b;
    input cin; 
    output cout;
    output [cla_width-1:0] sum;
    
    wire [block_num-1:0] block_p, block_g, block_c;
    wire [cla_width-1:0] bit_p, bit_g;
    wire [cla_width:0] carry;
    wire [cla_width:0] carry_wire;
    
    assign carry[0] = cin;
    assign carry[4] = block_c[0];
    assign carry[8] = block_c[1];
    assign carry[12] = block_c[2];
    assign carry[16] = block_c[3];
    
    //bit pg generate (step 1)
    assign bit_g = a & b;
    assign bit_p = a ^ b;
    
    genvar j;
    generate
        for(j=0; j<block_num; j=j+1) begin: cla_network_level1
            assign carry[j*4+1 +: 3] = carry_wire[j*4 +: 3];
            lookahead_carry_generator_4bit inst_lookahead_network1(
                .g_in(bit_g[j*4 +: 4]),
                .p_in(bit_p[j*4 +: 4]),
                .cin(carry[j*4]),
                .cout(carry_wire[j*4 +: 4]),
                .g_out(block_g[j]),
                .p_out(block_p[j])
                );
        end
    endgenerate

    lookahead_carry_generator_4bit inst_lookahead_network2(
        .g_in(block_g),
        .p_in(block_p),
        .cin(carry[0]),
        .cout(block_c)
        );

    //bit sum generate (step 5)
    assign sum = bit_p ^ carry[cla_width-1:0];

    //cout
    assign cout = carry[16];


endmodule
