`timescale 1ns / 1ps

module lookahead_carry_generator_4bit(
    g_in,
    p_in,
    cin,
    cout,
    g_out,
    p_out
    );

    parameter instruction_width = 32;
    parameter cla_width = instruction_width/2;
    parameter block_num = cla_width/4;
    parameter block_width = cla_width/4;

    input [block_width-1:0] g_in, p_in;
    input cin;
    output [block_width-1:0] cout;
    output g_out, p_out;

    //block pg generate
    assign g_out = g_in[3] | (g_in[2] & p_in[3]) | (g_in[1] & p_in[2] & p_in[3]) | (g_in[0] & p_in[1] & p_in[2] & p_in[3]);
    assign p_out = p_in[0] & p_in[1] & p_in[2] & p_in[3];

    //carries
    assign cout[0] = g_in[0] | (cin & p_in[0]);
    assign cout[1] = g_in[1] | (g_in[0] & p_in[1]) | (cin & p_in[0] & p_in[1]);
    assign cout[2] = g_in[2] | (g_in[1] & p_in[2]) | (g_in[0] & p_in[1] & p_in[2]) | (cin & p_in[0] & p_in[1] & p_in[2]);
    assign cout[3] = g_in[3] | (cout[2] & p_in[3]);

endmodule
