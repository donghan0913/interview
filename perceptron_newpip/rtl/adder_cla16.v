/**************************************************************
 * Module name: adder_cla16
 *
 * Features:
 *	1. Multi-level 16-bit carry lookahead adder
 *
 * Descriptions:
 *    1. 
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module adder_cla16(
    a,
    b,
    cin,
    sum,
    cout
    );
   
    localparam CLA_WIDTH = 16;                              // width of data
    localparam BLOCK_NUM = CLA_WIDTH/4;                     // block number in level 1 of multi-level cla
    localparam BLOCK_WIDTH = CLA_WIDTH/4;                   // width of data per block
    
    input   [CLA_WIDTH-1:0]     a;                          // operand a of cla
    input   [CLA_WIDTH-1:0]     b;                          // operand b of cla
    input                       cin;                        // carry in of cla
    output                      cout;                       // carry out of cla
    output  [CLA_WIDTH-1:0]     sum;                        // sum of cla
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // bit pg generate logic
    wire    [CLA_WIDTH-1:0]     bit_p;                      // bit p of 2 operands
    wire    [CLA_WIDTH-1:0]     bit_g;                      // bit g of 2 operands
    
    assign bit_p = a ^ b;
    assign bit_g = a & b;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // block pg and block carry and bit carry generated from bit pg. (block pg -> block carry -> bit carry)
    wire    [BLOCK_NUM-1:0]     block_p;                    // block p of each lookahead network block
    wire    [BLOCK_NUM-1:0]     block_g;                    // block g of each lookahead network block
    wire    [BLOCK_NUM-1:0]     block_c;                    // block c of each lookahead network block
    wire    [CLA_WIDTH:0]       carry;                      // carry in per bit cell in cla
    wire    [CLA_WIDTH:0]       carry_wire;                 // carry out per bit cell in cla
    
    genvar i;
    generate
        for(i = 0; i < BLOCK_NUM; i = i + 1) begin: cla_lv1
            assign carry[i*4+1 +: 3] = carry_wire[i*4 +: 3];
            cla_ntwork4 inst_cla_lv1(
                .g_in(bit_g[i*BLOCK_NUM +: 4]),
                .p_in(bit_p[i*BLOCK_NUM +: 4]),
                .cin(carry[i*BLOCK_NUM]),
                .cout(carry_wire[i*BLOCK_NUM +: 4]),
                .g_out(block_g[i]),
                .p_out(block_p[i])
            );
        end
    endgenerate
    
    cla_ntwork4 inst_cla_lv2(
        .g_in(block_g),
        .p_in(block_p),
        .cin(carry[0]),
        .cout(block_c)
    );
    
    assign carry[0] = cin;
    assign carry[4] = block_c[0];
    assign carry[8] = block_c[1];
    assign carry[12] = block_c[2];
    assign carry[16] = block_c[3];
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // bit sum generated from bit carry and bit p
    assign sum = bit_p ^ carry[CLA_WIDTH-1:0];
    assign cout = carry[CLA_WIDTH];


endmodule
