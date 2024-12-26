/**************************************************************
 * Module name: lzd_lka16
 *
 * Features:
 *	1. To detect leading one position by 2-level modular design
 *    2. Only for non-negative data
 *
 * Descriptions:
 *    1. Encode shift count from One-Hot to binary
 *    2. Refer to CMP lookahead logic of high speed comparator structure
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module lzd_lka16(
    d_in,
    sft_cnt,
    zero
    );
    
    localparam D_WIDTH = 16;                                // width of data
    localparam CNT_WIDTH = 4;                               // width of shift count after encoding
    localparam BLOCK_WIDTH = 4;                             // width of data per block
    localparam BLOCK_CNT_WIDTH = 2;                         // width of shift count after encoding per block
    localparam BLOCK_NUM = 4;                               // block number in level 1
    localparam SFT_WIDTH1 = BLOCK_NUM * BLOCK_CNT_WIDTH;    // combine 4 block of binary shift count after decoding

    input   [D_WIDTH-1:0]       d_in;                       // input data
    output  [CNT_WIDTH-1:0]     sft_cnt;                    // output of shift count after encoding
    output                      zero;                       // output of checking all zeros
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // level 1 4-bit LZD CMP lookahead detection logic & decoding logic
    wire    [SFT_WIDTH1-1:0]    sft_cnt_lv1;                // 4 block of binary shift count after decoding in level 1
    wire    [D_WIDTH-1:0]       cmp_lv1;                    // CMP signal to represent one-hot sft count in level 1
    wire    [BLOCK_NUM-1:0]     zero_lv1;                   // check zero signals of level 1 blocks
    
    genvar i;
    generate
        for(i = 0; i < BLOCK_NUM; i = i + 1) begin: lzd_lka_lv1
            assign zero_lv1[i] = d_in[i*BLOCK_NUM + 3] | d_in[i*BLOCK_NUM + 2] | d_in[i*BLOCK_NUM + 1] | d_in[i*BLOCK_NUM];
            
            assign cmp_lv1[i*BLOCK_NUM + 3] = d_in[i*BLOCK_NUM + 3];
            assign cmp_lv1[i*BLOCK_NUM + 2] = d_in[i*BLOCK_NUM + 2] & ~d_in[i*BLOCK_NUM + 3];
            assign cmp_lv1[i*BLOCK_NUM + 1] = d_in[i*BLOCK_NUM + 1] & ~d_in[i*BLOCK_NUM + 2] & ~d_in[i*BLOCK_NUM + 3];
            //assign cmp_lv1[i*BLOCK_NUM]     = d_in[i*BLOCK_NUM] & ~d_in[i*BLOCK_NUM + 1] & ~d_in[i*BLOCK_NUM + 2] & ~d_in[i*BLOCK_NUM + 3];
            assign cmp_lv1[i*BLOCK_NUM]     = 0;
        
            assign sft_cnt_lv1[i*BLOCK_CNT_WIDTH]     = cmp_lv1[i*BLOCK_NUM + 3] | cmp_lv1[i*BLOCK_NUM + 1];
            assign sft_cnt_lv1[i*BLOCK_CNT_WIDTH + 1] = cmp_lv1[i*BLOCK_NUM + 3] | cmp_lv1[i*BLOCK_NUM + 2];
        end
    endgenerate 
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // level 2 4-bit LZD CMP lookahead detection logic & decoding logic
    wire    [BLOCK_WIDTH-1:0]       cmp_lv2;                // CMP signal to represent one-hot sft count in level 2
    wire    [BLOCK_CNT_WIDTH-1:0]   sft_cnt_hi;             // high part of 4-bit binary shift count
    
    assign zero = |(zero_lv1);
            
    assign cmp_lv2[3] = zero_lv1[3];
    assign cmp_lv2[2] = zero_lv1[2] & ~zero_lv1[3];
    assign cmp_lv2[1] = zero_lv1[1] & ~zero_lv1[2] & ~zero_lv1[3];
    //assign cmp_lv2[0] = zero_lv1[0] & ~zero_lv1[1] & ~zero_lv1[2] & ~zero_lv1[3];
    assign cmp_lv2[0] = 0;

    assign sft_cnt_hi[0] = cmp_lv2[3] | cmp_lv2[1];
    assign sft_cnt_hi[1] = cmp_lv2[3] | cmp_lv2[2];
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // decoding logic to generate low part of 4-bit binary shift count, then output
    reg     [BLOCK_CNT_WIDTH-1:0]   sft_cnt_lo;             // low part of 4-bit binary shift count

    always @(*) begin
        case (sft_cnt_hi)
            0:      sft_cnt_lo = sft_cnt_lv1[1:0];
            1:      sft_cnt_lo = sft_cnt_lv1[3:2];
            2:      sft_cnt_lo = sft_cnt_lv1[5:4];
            3:      sft_cnt_lo = sft_cnt_lv1[7:6];
            default:sft_cnt_lo = 0;
        endcase
    end
    
    assign sft_cnt = {sft_cnt_hi, sft_cnt_lo};
    
    
endmodule
