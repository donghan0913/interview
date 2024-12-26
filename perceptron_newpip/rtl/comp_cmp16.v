/**************************************************************
 * Module name: comp_cmp16
 *
 * Features:
 *	1. Comparing 2 absolute value a & b by 2-level modular design
 *    2. Output = {a == b, a > b, a < b}
 *
 * Descriptions:
 *    1. Refer to CMP lookahead logic of high speed comparator structure
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module comp_cmp16(
    a,
    b,
    result
    );

    localparam D_WIDTH = 16;                                // width of data
    localparam BLOCK_WIDTH = 4;                             // width of data per block
    localparam BLOCK_NUM = 4;                               // block number

    input   [D_WIDTH-1:0]       a;                          // input a
    input   [D_WIDTH-1:0]       b;                          // input b
    output  [2:0]               result;                     // output of compare result 


    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // compute propagate, level 1 4-bit CMP lookahead logic, and level 1 4-bit comparator logic
    wire    [D_WIDTH-1:0]       p_lv1;                      // propagate for signals a and b
    wire    [D_WIDTH-1:0]       g_lv1;                      // asserted when a > b each bit
    wire    [D_WIDTH-1:0]       s_lv1;                      // asserted when a < b each bit
    wire    [D_WIDTH-1:0]       cmp_lv1;                    // CMP signal to represent one-hot sft count in level 1
    wire    [BLOCK_NUM-1:0]     aeb_lv1;                    // signals for value a == b each block in level 1 blocks
    wire    [BLOCK_NUM-1:0]     agb_lv1;                    // signals for value a > b each block in level 1 blocks
    wire    [BLOCK_NUM-1:0]     asb_lv1;                    // signals for value a < b each block in level 1 blocks
    
    assign p_lv1 = a ^ b;
    assign g_lv1 = a & ~b;
    assign s_lv1 = ~a & b;
    
    genvar i;
    generate
        for(i = 0; i < BLOCK_NUM; i = i + 1) begin: comp_lv1
            // CMP lookahead logic
            assign cmp_lv1[i*BLOCK_NUM + 3] = p_lv1[i*BLOCK_NUM + 3];
            assign cmp_lv1[i*BLOCK_NUM + 2] = p_lv1[i*BLOCK_NUM + 2] & ~p_lv1[i*BLOCK_NUM + 3];
            assign cmp_lv1[i*BLOCK_NUM + 1] = p_lv1[i*BLOCK_NUM + 1] & ~p_lv1[i*BLOCK_NUM + 2] & ~p_lv1[i*BLOCK_NUM + 3];
            assign cmp_lv1[i*BLOCK_NUM]     = p_lv1[i*BLOCK_NUM] & ~p_lv1[i*BLOCK_NUM + 1] & ~p_lv1[i*BLOCK_NUM + 2] & ~p_lv1[i*BLOCK_NUM + 3];
        
            // generate signal for a == b, a > b, a < b
            assign aeb_lv1[i] = ~|(cmp_lv1[(i*BLOCK_NUM + 3) : (i*BLOCK_NUM)]);
            assign agb_lv1[i] = |(cmp_lv1[(i*BLOCK_NUM + 3) : (i*BLOCK_NUM)] & g_lv1[(i*BLOCK_NUM + 3) : (i*BLOCK_NUM)]);
            assign asb_lv1[i] = |(cmp_lv1[(i*BLOCK_NUM + 3) : (i*BLOCK_NUM)] & s_lv1[(i*BLOCK_NUM + 3) : (i*BLOCK_NUM)]);
        end 
    endgenerate

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // level 2 4-bit CMP lookahead detection logic
    wire    [BLOCK_NUM-1:0]     p_lv2;                      // propagate for signals agb_lv1 and asb_lv1 in level 2
    wire    [BLOCK_NUM-1:0]     g_lv2;                      // asserted when agb_lv1 > asb_lv1 each bit in level 2
    wire    [BLOCK_NUM-1:0]     s_lv2;                      // asserted when agb_lv1 < asb_lv1 each bit in level 2
    wire    [BLOCK_NUM-1:0]     cmp_lv2;                    // CMP signal to represent one-hot sft count in level 2
    wire                        aeb_lv2;                    // signals for value agb_lv1 == asb_lv1 in level 2 block
    wire                        agb_lv2;                    // signals for value agb_lv1 > asb_lv1 in level 2 block
    wire                        asb_lv2;                    // signals for value agb_lv1 < asb_lv1 in level 2 block
    
    assign p_lv2 = agb_lv1 ^ asb_lv1;
    assign g_lv2 = agb_lv1 & ~asb_lv1;
    assign s_lv2 = ~agb_lv1 & asb_lv1;

    // CMP lookahead logic
    assign cmp_lv2[3] = p_lv2[3];
    assign cmp_lv2[2] = p_lv2[2] & ~p_lv2[3];
    assign cmp_lv2[1] = p_lv2[1] & ~p_lv2[2] & ~p_lv2[3];
    assign cmp_lv2[0] = p_lv2[0] & ~p_lv2[1] & ~p_lv2[2] & ~p_lv2[3];

    // generate signal for a == b, a > b, a < b
    assign aeb_lv2 = ~|(cmp_lv2);
    assign agb_lv2 = |(cmp_lv2 & g_lv2);
    assign asb_lv2 = |(cmp_lv2 & s_lv2);

    assign result = {aeb_lv2, agb_lv2, asb_lv2};


endmodule
