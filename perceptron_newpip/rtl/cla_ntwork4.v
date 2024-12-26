/**************************************************************
 * Module name: cla_ntwork4
 *
 * Features:
 *	1. 4-bit lookahead carry generator to output block pg and cout from bit pg and cin
 *
 * Descriptions:
 *    1. 
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module cla_ntwork4(
    g_in,
    p_in,
    cin,
    cout,
    g_out,
    p_out
    );
    
    localparam WIDTH = 4;                                   // width of generator

    input   [WIDTH-1:0]         p_in;                       // input bit p
    input   [WIDTH-1:0]         g_in;                       // input bit g
    input                       cin;                        // carry of generator block input 
    output  [WIDTH-1:0]         cout;                       // carry of generator block output
    output                      p_out;                      // output block p
    output                      g_out;                      // output block g
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // block pg generate
    assign g_out = g_in[3] | (g_in[2] & p_in[3]) | (g_in[1] & p_in[2] & p_in[3]) | (g_in[0] & p_in[1] & p_in[2] & p_in[3]);
    assign p_out = p_in[0] & p_in[1] & p_in[2] & p_in[3];

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // block carry generate
    assign cout[0] = g_in[0] | (cin & p_in[0]);
    assign cout[1] = g_in[1] | (g_in[0] & p_in[1]) | (cin & p_in[0] & p_in[1]);
    assign cout[2] = g_in[2] | (g_in[1] & p_in[2]) | (g_in[0] & p_in[1] & p_in[2]) | (cin & p_in[0] & p_in[1] & p_in[2]);
    assign cout[3] = g_in[3] | (cout[2] & p_in[3]);
    
    
endmodule
