/**************************************************************
 * Module name: adder_loprec16
 *
 * Features:
 *	1. Low precision 16-bit addition
 *
 * Descriptions:
 *    1. High part 8-bit use single level CLA, low part 8-bit use OR adder
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module adder_loprec16(
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
    // low part OR adder
    localparam PART_WIDTH = CLA_WIDTH / 2;                  // width of low part OR adder and high part CLA adder
    wire                        cin_hi;                     // cin of high part CLA adder
    
    assign sum[PART_WIDTH-1:0] = a[PART_WIDTH-1:0] | b[PART_WIDTH-1:0];
    assign cin_hi = a[PART_WIDTH-1] & b[PART_WIDTH-1];
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // high part single level CLA adder
    //// bit pg generate logic
    wire    [PART_WIDTH-1:0]    bit_p;                      // bit p of 2 high part operands
    wire    [PART_WIDTH-1:0]    bit_g;                      // bit g of 2 high part operands
    
    assign bit_p = a[CLA_WIDTH-1:PART_WIDTH] ^ b[CLA_WIDTH-1:PART_WIDTH];
    assign bit_g = a[CLA_WIDTH-1:PART_WIDTH] & b[CLA_WIDTH-1:PART_WIDTH];
    
    //// bit carry
    wire    [PART_WIDTH-1:0]    carry;                      // carry in per bit cell in high part CLA adder
    wire    [CLA_WIDTH:0]       carry_wire;                 // carry out per bit cell in cla
     
    assign carry[0] = bit_g[0] | (cin_hi & bit_p[0]);
    assign carry[1] = bit_g[1] | (bit_g[0] & bit_p[1]) | (cin_hi & bit_p[0] & bit_p[1]);
    assign carry[2] = bit_g[2] | (bit_g[1] & bit_p[2]) | (bit_g[0] & bit_p[1] & bit_p[2]) | (cin_hi & bit_p[0] & bit_p[1] & bit_p[2]);
    assign carry[3] = bit_g[3] | (carry[2] & bit_p[3]);
    
    assign carry[4] = bit_g[4] | (carry[3] & bit_p[4]);
    assign carry[5] = bit_g[5] | (bit_g[0] & bit_p[5]) | (carry[3] & bit_p[4] & bit_p[5]);
    assign carry[6] = bit_g[6] | (bit_g[5] & bit_p[6]) | (bit_g[4] & bit_p[5] & bit_p[6]) | (carry[3] & bit_p[4] & bit_p[5] & bit_p[6]);
    assign carry[7] = bit_g[7] | (carry[6] & bit_p[7]);
    
    //// bit sum generated from bit carry and bit p
    assign sum[CLA_WIDTH-1:PART_WIDTH] = bit_p ^ carry;
    assign cout = 0;


endmodule
