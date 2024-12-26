/**************************************************************
 * Module name: percep_fp_add_new/
 *
 * Features:
 *	1. Add/Sub two floating point numbers
 *    2. Check special cases before and after compute
 *    3. Sequential circuit, has one stage register in the middle
 *    4. Use chopping method for rounding stage, so don't need to do 2nd normalization
 *    5. Use saturating adder for exponent
 *    6. New fp adder module to instantiate LZD & LZA
 *    7. Use CLA adder for significand addition, use normal adder for exp adjust
 *
 * Descriptions:
 *	1. For more convenient computation,
 *        significand part extends to 16-bit, exponent part extends to 6-bit
 *    2. For more convenient computation, treat special case 2 as special case 1,
 *        that is both cases output all zero for exponent and significand part
 *    3. Use low fan-in shifter instead of original 16-to-1 casez shifter
 *    4. In fp addition, special case 1 & 2 also be computed like normal case
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/
//`define LZA                                                 // Only used in Vivado, deleted in Linux, for improvement including "lza16" and fine shifter
//`define NO_CEC                                              // Only used in Vivado, deleted in Linux, replace LZA concurrent error correction with compensated MUX
//`define PIP4                                                // Only used in Vivado, deleted in Linux, do 4-stage pipeline, otherwise do 2-stage pipeline for `else
//`define LOPREC_ADD                                          // Only used in Vivado, deleted in Linux, low precision OR adder for low part significand add

module percep_fp_add_new #(
    parameter FP_WIDTH = 16                                 // width of fp data
) (
`ifdef PIP4
    clk,
    rst_n,
`endif
    fp_a,
    fp_b,
    fp_sum,
    sign_out
    );
    
    localparam EXP_WIDTH = 5;                               // width of exponent part of fp data
    localparam SIG_WIDTH = 10;                              // width of significand part of fp data
    localparam EXP1_WIDTH = 6;                              // width of exponent part of fp data after extension
    localparam SIG1_WIDTH = 16;                             // width of significand part of fp data after extension
    localparam BIAS = 15;                                   // bias number for exponent part for 16-bit half precision format
    localparam EXP_MAX = BIAS*2 + 1;                        // maximum value for exponent part for 16-bit half precision format

`ifdef PIP4
    input                       clk;                        // clock
    input                       rst_n;                      // asynchronous active low reset
`endif
    input   [FP_WIDTH-1:0]      fp_a;                       // 1st fp operand input
    input   [FP_WIDTH-1:0]      fp_b;                       // 2nd fp operand input
    output  [FP_WIDTH-1:0]      fp_sum;                     // fp data output after computation
    output                      sign_out;                   // output sign from sign control stage
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // unpack including check special cases
    wire                        sign_a;                     // sign bit for 1st fp operand
    wire                        sign_b;                     // sign bit for 2nd fp operand
    wire    [EXP1_WIDTH-1:0]    exp_a;                      // exponent part for 1st fp operand after zero extension
    wire    [EXP1_WIDTH-1:0]    exp_b;                      // exponent part for 2nd fp operand after zero extension
    wire    [SIG1_WIDTH-1:0]    sig_a;                      // significand part for 1st fp operand after zero extension
    wire    [SIG1_WIDTH-1:0]    sig_b;                      // significand part for 2nd fp operand after zero extension
    wire    [1:0]               special_a;                  // special case checker for 1st fp operand before addition
    wire    [1:0]               special_b;                  // special case checker for 2nd fp operand before addition
    reg     [1:0]               special_a_pip;              // special case checker for 1st fp operand before addition, pipeline
    reg     [1:0]               special_b_pip;              // special case checker for 2nd fp operand before addition, pipeline

    //// get sign & exp & sig parts repectively, exp and sig do zero extension
    assign sign_a = fp_a[FP_WIDTH-1];
    assign sign_b = fp_b[FP_WIDTH-1];
    assign exp_a = {1'b0, fp_a[FP_WIDTH-2:SIG_WIDTH]};
    assign exp_b = {1'b0, fp_b[FP_WIDTH-2:SIG_WIDTH]};
    assign sig_a = {3'b001, fp_a[SIG_WIDTH-1:0], 3'b000};   // including hidden-1
    assign sig_b = {3'b001, fp_b[SIG_WIDTH-1:0], 3'b000};   // including hidden-1

    //// check special cases, 2'b00 for normal, 2'b01 for case 1 & 2, 2'b10 for case 4, 2'b11 for case 3
    assign special_a[0] = ~|(exp_a); 
    assign special_a[1] = &(exp_a);
    
    assign special_b[0] = ~|(exp_b); 
    assign special_b[1] = &(exp_b);

`ifdef PIP4
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     special_a_pip <= 0;
        else            special_a_pip <= special_a;
    end
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     special_b_pip <= 0;
        else            special_b_pip <= special_b;
    end
`else
    always @(*) begin
        special_a_pip = special_a;
    end
    always @(*) begin
        special_b_pip = special_b;
    end
`endif
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // sub exponents
    wire    [EXP1_WIDTH-1:0]    exp_dif_ab;                 // difference between exp_a - exp_b
    wire    [EXP1_WIDTH-1:0]    exp_dif_ba;                 // difference between exp_b - exp_a
    wire    [EXP1_WIDTH-1:0]    exp_big;                    // bigger exponent after comparison
    wire    [EXP1_WIDTH-1:0]    exp_small;                  // smaller exponent after comparison, for pack stage special case 1,2
    wire                        exp_eq;                     // asserted if 2 exponents equal
    reg     [EXP1_WIDTH-1:0]    exp_big_pip;                // bigger exponent after comparison, pipeline
    
    assign exp_dif_ab = exp_a + (~exp_b) + 1;
    assign exp_dif_ba = exp_b + (~exp_a) + 1;
    assign exp_big = (exp_dif_ab[EXP1_WIDTH-1] == 0) ? exp_a : exp_b;
    assign exp_small = (exp_dif_ab[EXP1_WIDTH-1] == 0) ? exp_b : exp_a;
    assign exp_eq = ~|(exp_dif_ab);

`ifdef PIP4
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     exp_big_pip <= 0;
        else            exp_big_pip <= exp_big;
    end
`else
    always @(*) begin
        exp_big_pip = exp_big;
    end
`endif
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // preshifter, align significand for smaller fp number, do right shift
    wire    [EXP1_WIDTH-1:0]    exp_dif;                    // difference between exp_a & exp_b
    wire    [SIG1_WIDTH-1:0]    sig_big_1;                  // significand of bigger fp after preshift stage
    wire    [SIG1_WIDTH-1:0]    sig_small;                  // significand of smaller fp before preshift stage
    wire    [SIG1_WIDTH-1:0]    sig_small_1;                // significand of smaller fp after preshift stage
    
    assign exp_dif = (exp_dif_ab[EXP1_WIDTH-1] == 0) ? exp_dif_ab : exp_dif_ba;
    assign sig_big_1 = (exp_dif_ab[EXP1_WIDTH-1] == 0) ? sig_a : sig_b;
    assign sig_small = (exp_dif_ab[EXP1_WIDTH-1] == 0) ? sig_b : sig_a;
    
    sft_r_lofin inst_sft_r(
        .x(sig_small),
        .sign(1'b0),
        .sel(exp_dif),
        .y(sig_small_1)
    );
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // comparator, and output bigger and smaller sig
    wire    [2:0]               comp_result;                // result of comparator
    wire    [SIG1_WIDTH-1:0]    sig_big_2;                  // significand of bigger fp after CMP comparator
    wire    [SIG1_WIDTH-1:0]    sig_small_2;                // significand of smaller fp after CMP comparator
    
    comp_cmp16 inst_comp(
        .a(sig_a),
        .b(sig_b),
        .result(comp_result)
    );
    
    assign sig_big_2 = (~comp_result[0]) ? sig_a : sig_b;
    assign sig_small_2 = (comp_result[0]) ? sig_a : sig_b;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // select preshifter or comparator as input to do sig add
    wire    [SIG1_WIDTH-1:0]    sig_g;                      // significand of bigger(greater) fp before sig add
    wire    [SIG1_WIDTH-1:0]    sig_s;                      // significand of smaller fp before sig add
    reg     [SIG1_WIDTH-1:0]    sig_g_pip;                  // significand of bigger(greater) fp before sig add, pipeline
    reg     [SIG1_WIDTH-1:0]    sig_s_pip;                  // significand of smaller fp before sig add, pipeline
    
    assign sig_g = (exp_eq) ? sig_big_2 : sig_big_1;
    assign sig_s = (exp_eq) ? sig_small_2 : sig_small_1;

`ifdef PIP4
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     sig_g_pip <= 0;
        else            sig_g_pip <= sig_g;
    end
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     sig_s_pip <= 0;
        else            sig_s_pip <= sig_s;
    end
`else
    always @(*) begin
        sig_g_pip = sig_g;
    end
    always @(*) begin
        sig_s_pip = sig_s;
    end
`endif

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // sign control, including cin of sig add
    wire                        cin_sigadd;                 // cin for sig add
    reg                         sign_sub;                   // sign of sig sum for (+) + (-) case
    reg                         sign_final;                 // final sign for pack stage
    reg                         cin_sigadd_pip;             // cin for sig add, pipeline
    reg                         sign_final_pip;             // final sign for pack stage, pipeline
    
    assign cin_sigadd = sign_a ^ sign_b;

    //// predict sign of (+) + (-) for sign controller
    always @(*) begin
        if (exp_eq) begin
            if (comp_result[0])             sign_sub = sign_b;
            else                            sign_sub = sign_a;
        end
        else begin
            if (exp_dif_ab[EXP1_WIDTH-1])   sign_sub = sign_b;
            else                            sign_sub = sign_a;
        end
    end

    //// main sign control
    always @(*) begin
        // sub
        if (cin_sigadd) begin
            if (comp_result[2] & exp_eq)        sign_final = 0;
            else                                sign_final = sign_sub;
        end
        // add
        else begin
            if (special_a[0] & special_b[0])    sign_final = 0;
            else                                sign_final = sign_a;
        end
    end
    
    assign sign_out = sign_final;

`ifdef PIP4
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     cin_sigadd_pip <= 0;
        else            cin_sigadd_pip <= cin_sigadd;
    end
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     sign_final_pip <= 0;
        else            sign_final_pip <= sign_final;
    end
`else
    always @(*) begin
        cin_sigadd_pip = cin_sigadd;
    end
    always @(*) begin
        sign_final_pip = sign_final;
    end
`endif
   
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // sig add for only sum >= 0
    wire    [SIG1_WIDTH-1:0]    sig_sum;                    // sum of sig add
    wire                        cout_sigadd;                // cout for sig add, useless
    
`ifdef LOPREC_ADD
    adder_loprec16 inst_add_cla_loprec(
        .a(sig_g_pip),
        .b(sig_s_pip),
        .cin(cin_sigadd_pip),
        .sum(sig_sum),
        .cout(cout_sigadd)
    );
`else
    adder_cla16 inst_add_cla(
        .a(sig_g_pip),
        .b(sig_s_pip),
        .cin(cin_sigadd_pip),
        .sum(sig_sum),
        .cout(cout_sigadd)
    );
`endif
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // post-shifter for (+) + (+) and (-) + (-)
    wire                        sft_r;                      // shift amount for right shift significand normalization
    wire    [SIG1_WIDTH-1:0]    sig_sum_norm_1;             // sig sum normalize for (+) + (+) and (-) + (-) case
    
    assign sig_sum_norm_1 = (sig_sum[SIG1_WIDTH-2]) ? sig_sum >> 1 : sig_sum;
    
	assign sft_r = sig_sum[SIG1_WIDTH-2];
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // LZD or LZA for (+) + (-), only sum >= 0 situation
    wire    [4:0]               sft_l_idx;                  // leading-one position for left shift sig normalize, bit 4 indicate zero
    
`ifdef LZA
    wire                        correct_cec;                // asserted when lza predict wrong need correct by 1 bit for concurrent error correction structure
    lza16 inst_lza(
        .a(sig_g_pip),
        .b(sig_s_pip),
        .sft_cnt(sft_l_idx[3:0]),
        .v(sft_l_idx[4]),
        .correct(correct_cec)
    );
`else
    lzd_lka16 inst_lzd(
        .d_in(sig_sum),
        .sft_cnt(sft_l_idx[3:0]),
        .zero(sft_l_idx[4])
    );
`endif

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // post-shifter using low fan-in left shifter, another fine shifter for LZA
    wire    [3:0]               sft_l_inv;                  // shift amount for left shift significand normalization
    wire    [SIG1_WIDTH-1:0]    sig_sum_norm_pre;           // sig sum left shift for (+) + (-) to 1.(X)
    wire    [SIG1_WIDTH-1:0]    sig_sum_norm_2;             // sig sum normalize for (+) + (-) to 1.(X) after error correction
    
    assign sft_l_inv = ~sft_l_idx[3:0];

    sft_l_lofin inst_sft_l(
        .x(sig_sum),
        .sel({sft_l_inv[0], sft_l_inv[1], sft_l_inv[2], sft_l_inv[3]}),
        .y(sig_sum_norm_pre)
    );
    
`ifdef LZA
`ifdef NO_CEC
    wire                        correct_no_cec;             // asserted when lza predict wrong need correct by 1 bit for compensated MUX
    assign correct_no_cec = ~sig_sum_norm_pre[SIG1_WIDTH-1];
    assign sig_sum_norm_2 = (correct_no_cec) ? sig_sum_norm_pre << 1 : sig_sum_norm_pre;
`else
    assign sig_sum_norm_2 = (correct_cec) ? sig_sum_norm_pre << 1 : sig_sum_norm_pre;
`endif
`endif
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // select which sig post-shifter result to go final pack stage
    wire    [SIG1_WIDTH-1:0]    sig_final;                  // final sig part after normalize stage

    assign sig_final = (cin_sigadd_pip) ? sig_sum_norm_2 : sig_sum_norm_1;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // adjust exp for LZD or LZA, including underflow detection and handling
    wire    [EXP1_WIDTH-1:0]    exp_adj_2_pre;              // pre-adjust exp for LZD case because decimal point is at bit 13
    wire    [EXP1_WIDTH-1:0]    exp_adj_2;                  // adjust exp by subtraction due to left shift
    wire    [EXP1_WIDTH-1:0]    exp_adj_2_uv;               // underflow detection and handling for adjust exp of left shift case

    assign exp_adj_2_pre = exp_big_pip + 6'd3;
    
`ifdef LZA
`ifdef NO_CEC
    assign exp_adj_2 = exp_adj_2_pre + {2'b11, sft_l_idx[3:0]} + correct_no_cec;
`else
    assign exp_adj_2 = exp_adj_2_pre + {2'b11, sft_l_idx[3:0]} + correct_cec;
`endif
`else
    assign exp_adj_2 = exp_adj_2_pre + {2'b11, sft_l_idx[3:0]};
`endif
    
    //// underflow detection amd handling, saturating to 5'b00000
    assign exp_adj_2_uv = (exp_adj_2[EXP1_WIDTH-1]) ? 6'b000000 : exp_adj_2;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // adjust exp for (+) + (+) and (-) + (-) post-shifter, including overflow detection and handling
    wire    [EXP1_WIDTH-1:0]    exp_adj_1;                  // adjust exp by addition due to right shift
    wire    [EXP1_WIDTH-2:0]    exp_adj_conc;               // predict exp_adj_1 overflow by concatenate
    wire    [EXP1_WIDTH-1:0]    exp_adj_1_ov;               // overflow detection and handling for adjust exp of right shift case
    
    assign exp_adj_1 = exp_big_pip + {{5{1'b0}}, sft_r};
    
    //// overflow detection amd handling, saturating to 5'b11110
    assign exp_adj_conc = {exp_big[EXP1_WIDTH-2:1], sft_r};
    assign exp_adj_1_ov = (&(exp_adj_conc)) ? 6'b011110 : exp_adj_1;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // select which exp adjustment to go
    wire    [EXP1_WIDTH-1:0]    exp_final;                  // final exp part after adjust

    assign exp_final = (cin_sigadd_pip) ? exp_adj_2_uv : exp_adj_1_ov;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pack, check special cases first, special case 1 and 2 from unpack stage of fp adder don't need to check at here
    wire    [2:0]               special;                    // special check combine special case a and special case b and sig sum = 0
    
    assign special[0] = ~|(sig_sum);
    assign special[2:1] = special_a_pip | special_b_pip;
    
    assign fp_sum[FP_WIDTH-1] = sign_final_pip;
    assign fp_sum[FP_WIDTH-2:SIG_WIDTH] = (special[2]) ? 5'b11111 :
                                        (special[0]) ? 0 : exp_final[EXP_WIDTH-1:0];
    assign fp_sum[SIG_WIDTH-1:0] = (special[1]) ? sig_big_1[SIG1_WIDTH-4:SIG1_WIDTH-13] : sig_final[SIG1_WIDTH-2:SIG1_WIDTH-11];
    
    
endmodule
