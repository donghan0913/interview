/**************************************************************
 * Module name: percep_fp_mtply
 *
 * Features:
 *	1. Multiply two floating point numbers
 *    2. Check special cases before and after compute
 *    3. Combinational logic only
 *    4. Use chopping method for rounding stage, so don't need to do 2nd normalization
 *    5. Use saturating adder for exponent
 *
 * Descriptions:
 *	1. For more convenient computation,
 *        significand part extends to 11-bit, exponent part extends to 6-bit
 *    2. Doesn't need to check special case 3, because it won't happen
 *    3. For more convenient computation, treat special case 2 as special case 1,
 *        that is both cases output all zero for exponent and significand part
 *    4. Special case 4 outputs 5'b11111 for exponent part, nonzero for significand part
 *    5. Use leading 1s "detector" for normalize stage
 *    6. Special case 1 & 2 directly set output to zero at pack stage
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module percep_fp_mtply #(
    parameter FP_WIDTH = 16                                 // width of fp data
) (
    fp_a,
    fp_b,
    fp_prod
    );
    
    localparam EXP_WIDTH = 5;                               // width of exponent part of fp data
    localparam SIG_WIDTH = 10;                              // width of significand part of fp data
    localparam EXP1_WIDTH = 7;                              // width of exponent part of fp data after extension
    localparam SIG1_WIDTH = 11;                             // width of significand part of fp data after extension
    localparam SIG2_WIDTH = 22;                             // width of significand part after multiply significands stage
    localparam BIAS = 15;                                   // bias number for exponent part for 16-bit half precision format
    localparam EXP_MAX = BIAS*2 + 1;                        // maximum value for exponent part for 16-bit half precision format

    input   [FP_WIDTH-1:0]      fp_a;                       // 1st fp operand input
    input   [FP_WIDTH-1:0]      fp_b;                       // 2nd fp operand input
    output  [FP_WIDTH-1:0]      fp_prod;                    // fp data output after computation
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // unpack including check special cases
    wire                        sign_a;                     // sign bit for 1st fp operand
    wire                        sign_b;                     // sign bit for 2nd fp operand
    wire    [EXP1_WIDTH-1:0]    exp_a;                      // exponent part for 1st fp operand after zero extension
    wire    [EXP1_WIDTH-1:0]    exp_b;                      // exponent part for 2nd fp operand after zero extension
    wire    [SIG1_WIDTH-1:0]    sig_a;                      // significand part for 1st fp operand after combine with hidden-1, unsigned
    wire    [SIG1_WIDTH-1:0]    sig_b;                      // significand part for 2nd fp operand after combine with hidden-1, unsigned
    wire    [1:0]               special_a;                  // special case checker for 1st fp operand before multip]y
    wire    [1:0]               special_b;                  // special case checker for 2nd fp operand before multiply

    //// get sign & exp & sig parts repectively, exp do zero extension
    assign sign_a = fp_a[FP_WIDTH-1];
    assign sign_b = fp_b[FP_WIDTH-1];
    assign exp_a = {2'b00, fp_a[FP_WIDTH-2:SIG_WIDTH]};
    assign exp_b = {2'b00, fp_b[FP_WIDTH-2:SIG_WIDTH]};
    assign sig_a = {1'b1, fp_a[SIG_WIDTH-1:0]};             // including hidden-1
    assign sig_b = {1'b1, fp_b[SIG_WIDTH-1:0]};             // including hidden-1
       
    //// check special cases, 2'b00 for normal, 2'b01 for case 1 & 2, 2'b10 for case 4, 2'b11 for case 3
    assign special_a[0] = ~|(exp_a); 
    assign special_a[1] = &(exp_a);
    
    assign special_b[0] = ~|(exp_b); 
    assign special_b[1] = &(exp_b); 

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // add exponents in two cases, and sub biased number (-15)
    wire    [EXP1_WIDTH-1:0]    exp_sum0;                   // sum of exponents and biased number(-15)
    wire    [EXP1_WIDTH-1:0]    exp_sum1;                   // sum of exponents and biased number(-15), plus 1
    localparam BIAS_15_N = 7'b1110001;                      // 2's complement represent of negative biased number 15
    localparam BIAS_14_N = 7'b1110010;                      // 2's complement represent of (negative biased number 15) + 1
    
    assign exp_sum0 = exp_a + exp_b + BIAS_15_N;
    
    assign exp_sum1 = exp_a + exp_b + BIAS_14_N;
        
    //// detect overflow/underflow, set saturating value if needed    
    reg     [EXP1_WIDTH-1:0]    exp_sum0_good;              // exponent sum_0 after solve overflow/underflow
    reg     [EXP1_WIDTH-1:0]    exp_sum1_good;              // exponent sum_1 after solve overflow/underflow
    
    always @(*) begin
        if (exp_sum0[EXP1_WIDTH-1] == 0) begin
            // exp = 5'b11110 is max, 5'b11111 is for special case
            if ((exp_sum0[EXP1_WIDTH-2] == 1) || (~exp_sum0[EXP1_WIDTH-3:0] == 0))  exp_sum0_good = 30;
            // no overflow & underflow, or set 5'b00000 for special case
            else                                                                    exp_sum0_good = exp_sum0;
        end
        // underflow, so set to 5'b00000
        else                                                                        exp_sum0_good = 0;
    end
    
    always @(*) begin
        if (exp_sum1[EXP1_WIDTH-1] == 0) begin
            // exp = 5'b11110 is max, 5'b11111 is for special case
            if ((exp_sum1[EXP1_WIDTH-2] == 1) || (~exp_sum1[EXP1_WIDTH-3:0] == 0))  exp_sum1_good = 30;
            // no overflow & underflow, or set 5'b00000 for special case
            else                                                                    exp_sum1_good = exp_sum1;
        end
        // underflow, so set to 5'b00000
        else                                                                        exp_sum1_good = 0;
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // multiply significands (use unsigned array multiplier with modified FA cells)
    wire    [SIG2_WIDTH-1:0]    sig_prod;                   // product of significands, unsigned
    
    assign sig_prod = sig_a * sig_b;
        
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // normalize
    wire    [SIG2_WIDTH-1:0]    sig_prod_norm;              // product of significands after normalize, unsigned
    wire    [EXP1_WIDTH-1:0]    sig_shift;                  // shift amount of significand normalize
    
    assign sig_prod_norm = (sig_prod[SIG2_WIDTH-1]) ? sig_prod >> 1 : sig_prod;
    
    //// only right shift 1 bit or no shift
    assign sig_shift = sig_prod[SIG2_WIDTH-1];
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // adjust exponent
    wire   	[EXP1_WIDTH-1:0]    exp_adj;                    // exponent adjusted by shift amount
    
    assign exp_adj = (sig_shift) ? exp_sum1_good : exp_sum0_good;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // determine sign of product
    wire                        fp_sign;                    // get sign of product
    
    assign fp_sign = sign_a ^ sign_b;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pack, check special cases first, then output
    wire    [FP_WIDTH-1:0]      fp_prod_temp;               // check special case and combine sign & exp & sig after compute
    wire    [1:0]               special;                    // special check combine special case a and special case b
    
    assign special = special_a | special_b;
    
    assign fp_prod_temp[FP_WIDTH-1] = (special != 0) ? 0 : fp_sign;
    assign fp_prod_temp[FP_WIDTH-2:SIG_WIDTH] = (special[1] != 0) ? 5'b11111 : 
                                        (special[0] != 0) ? 0 : exp_adj[EXP_WIDTH-1:0];
    assign fp_prod_temp[SIG_WIDTH-1:0] = (special[0] != 0) ? 0 : sig_prod_norm[(SIG2_WIDTH-3):(SIG2_WIDTH-12)];
    
    assign fp_prod = fp_prod_temp;

    
endmodule
