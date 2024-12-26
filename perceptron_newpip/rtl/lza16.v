/**************************************************************
 * Module name: lza16
 *
 * Features:
 *	1. To predict leading one position with concurrent error correction
 *    2. Only for non-negative data
 *
 * Descriptions:
 *    1. Use "lzd_lka16" module for encoding tree
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/
//`define NO_CEC                                              // Only used in Vivado, deleted in Linux, replace concurrent error correction with compensated MUX


module lza16(
    a,
    b,
    sft_cnt,
    v,
    correct
    );
    
    localparam D_WIDTH = 16;                                // width of data
    localparam DTREE_WIDTH1 = D_WIDTH / 2;                  // level 1 width of detection tree
    localparam DTREE_WIDTH2 = DTREE_WIDTH1 / 2;             // level 2 width of detection tree
    localparam DTREE_WIDTH3 = DTREE_WIDTH2 / 2;             // level 3 width of detection tree
    localparam CNT_WIDTH = 4;                               // width of shift count after encoding

    input   [D_WIDTH-1:0]       a;                          // input data, bigger
    input   [D_WIDTH-1:0]       b;                          // input data, smaller
    output  [CNT_WIDTH-1:0]     sft_cnt;                    // output of shift count after encoding
    output                      v;                          // output of checking all zeros
    output                      correct;                    // output of checking prediction correct or not

    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // e,g,s generate
    wire    [D_WIDTH+1:0]       e_bit;                      // asserted when bit a equal to bit b, indicate wi = 0
    wire    [D_WIDTH+1:0]       g_bit;                      // asserted when bit a greater than bit b, indicate wi = 1
    wire    [D_WIDTH+1:0]       s_bit;                      // asserted when bit a smaller than bit b, indicate wi = -1

    assign e_bit[D_WIDTH:1] = ~(a ^ b);
    assign g_bit[D_WIDTH:1] = a & ~b;
    assign s_bit[D_WIDTH:1] = ~a & b;
    
    //// pad zero to bit 17 and bit 0 because of fi computation
    assign e_bit[D_WIDTH+1] = 0;
    assign g_bit[D_WIDTH+1] = 0;
    assign s_bit[D_WIDTH+1] = 0;
    
    assign e_bit[0] = 0;
    assign g_bit[0] = 0;
    assign s_bit[0] = 0;

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // leading-one pre-encoding
    wire    [D_WIDTH-1:0]       f_bit;                      // asserted when predict leading-one bit

    genvar i;
    generate
        for(i = 1; i < (D_WIDTH + 1); i = i + 1) begin: lza_cal_fi
            assign f_bit[i-1] = (e_bit[i+1] & g_bit[i] & ~s_bit[i-1]) | (~e_bit[i+1] & s_bit[i] & ~s_bit[i-1]);
        end
    endgenerate

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // encoding tree
    wire                        nouse;                      // check F is all zero or not, but useless here, because check e_bit is better
    
    assign v = &(e_bit[D_WIDTH:1]);
    
    lzd_lka16 inst_enctree(
        .d_in(f_bit),
        .sft_cnt(sft_cnt),
        .zero(nouse)
    );

`ifdef NO_CEC
    assign correct = 0;
`else
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // concurrent correction pre-encoding 
    wire    [D_WIDTH-1:0]       p_bit;                      // asserted means Gp = 1, depends on F, different to g_bit
    wire    [D_WIDTH-1:0]       n_bit;                      // asserted means Gp = -1, depends on F, different to s_bit
    wire    [D_WIDTH-1:0]       z_bit;                      // asserted means Gp = 0, depends on F, different to e_bit

    genvar j;
    generate
        for(j = 1; j < (D_WIDTH + 1); j = j + 1) begin: lza_cal_pnz
            assign p_bit[j-1] = (g_bit[j] | s_bit[j]) & ~s_bit[j-1];
            //assign p_bit[j-1] = (~e_bit[j+1] & s_bit[j] & ~s_bit[j-1]) | (g_bit[j] & ~s_bit[j-1]);
            assign n_bit[j-1] = e_bit[j+1] & s_bit[j];
            assign z_bit[j-1] = ~(p_bit[j-1] | n_bit[j-1]);
        end
    endgenerate

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // detection tree, total four levels
    wire    [DTREE_WIDTH1-1:0]  bigz_lv1;                   // indicate zero is detected in level 1
    wire    [DTREE_WIDTH1-1:0]  bigp_lv1;                   // indicate (z...zpz...z) is detected in level 1
    wire    [DTREE_WIDTH1-1:0]  bign_lv1;                   // indicate (z...zn) is detected in level 1
    wire    [DTREE_WIDTH1-1:0]  bigy_lv1;                   // indicate (z...zpz...zn) is detected in level 1

    wire    [DTREE_WIDTH2-1:0]  bigz_lv2;                   // indicate zero is detected in level 2
    wire    [DTREE_WIDTH2-1:0]  bigp_lv2;                   // indicate (z...zpz...z) is detected in level 2
    wire    [DTREE_WIDTH2-1:0]  bign_lv2;                   // indicate (z...zn) is detected in level 2
    wire    [DTREE_WIDTH2-1:0]  bigy_lv2;                   // indicate (z...zpz...zn) is detected in level 2

    wire    [DTREE_WIDTH3-1:0]  bigz_lv3;                   // indicate zero is detected in level 3
    wire    [DTREE_WIDTH3-1:0]  bigp_lv3;                   // indicate (z...zpz...z) is detected in level 3
    wire    [DTREE_WIDTH3-1:0]  bign_lv3;                   // indicate (z...zn) is detected in level 3
    wire    [DTREE_WIDTH3-1:0]  bigy_lv3;                   // indicate (z...zpz...zn) is detected in level 3

    wire                        bigy_lv4;                   // indicate (z...zpz...zn) is detected in level 4

    genvar k1;
    generate
        for (k1 = 0; k1 < DTREE_WIDTH1; k1 = k1 + 1) begin: dtree_lv1
            assign bigz_lv1[k1] = z_bit[k1*2 + 1] & z_bit[k1*2];
            assign bigp_lv1[k1] = (z_bit[k1*2 + 1] & p_bit[k1*2]) | (p_bit[k1*2 + 1] & z_bit[k1*2]);
            assign bign_lv1[k1] = n_bit[k1*2 + 1] | (z_bit[k1*2 + 1] & n_bit[k1*2]);
            assign bigy_lv1[k1] = 0;
        end
    endgenerate

    genvar k2;
    generate
        for (k2 = 0; k2 < DTREE_WIDTH2; k2 = k2 + 1) begin: dtree_lv2
            assign bigz_lv2[k2] = bigz_lv1[k2*2 + 1] & bigz_lv1[k2*2];
            assign bigp_lv2[k2] = (bigz_lv1[k2*2 + 1] & bigp_lv1[k2*2]) | (bigp_lv1[k2*2 + 1] & bigz_lv1[k2*2]);
            assign bign_lv2[k2] = bign_lv1[k2*2 + 1] | (bigz_lv1[k2*2 + 1] & bign_lv1[k2*2]);
            assign bigy_lv2[k2] = bigy_lv1[k2*2 + 1] | (bigz_lv1[k2*2 + 1] & bigy_lv1[k2*2]) | (bigp_lv1[k2*2 + 1] & bign_lv1[k2*2]);
        end
    endgenerate

    genvar k3;
    generate
        for (k3 = 0; k3 < DTREE_WIDTH3; k3 = k3 + 1) begin: dtree_lv3
            assign bigz_lv3[k3] = bigz_lv2[k3*2 + 1] & bigz_lv2[k3*2];
            assign bigp_lv3[k3] = (bigz_lv2[k3*2 + 1] & bigp_lv2[k3*2]) | (bigp_lv2[k3*2 + 1] & bigz_lv2[k3*2]);
            assign bign_lv3[k3] = bign_lv2[k3*2 + 1] | (bigz_lv2[k3*2 + 1] & bign_lv2[k3*2]);
            assign bigy_lv3[k3] = bigy_lv2[k3*2 + 1] | (bigz_lv2[k3*2 + 1] & bigy_lv2[k3*2]) | (bigp_lv2[k3*2 + 1] & bign_lv2[k3*2]);
        end
    endgenerate

    assign bigy_lv4 = bigy_lv3[1] | (bigz_lv3[1] & bigy_lv3[0]) | (bigp_lv3[1] & bign_lv3[0]);

    assign correct = bigy_lv4;
`endif

endmodule
