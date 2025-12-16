`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/15 11:00:41
// Design Name: 
// Module Name: mult_array
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`define MULT_PIP


module mult_array #(
    parameter WIDTH_D = 4
) (
    clk,
    rst_n,
    a,
    b,
    p_out
    );
    
    localparam WIDTH_P = WIDTH_D * 2;
    localparam IDX_PIP = WIDTH_D - 2;                       // pipeline stage row index
    
    input                           clk;
    input                           rst_n;
    input   [WIDTH_D-1:0]           a;
    input   [WIDTH_D-1:0]           b;
    output  [WIDTH_D-1:0]           p_out;                  // 32-bit product

    wire    [WIDTH_D:0]             array_sum   [0:WIDTH_D];
    wire    [WIDTH_D-1:0]           array_carry [0:WIDTH_D];
    
    wire    [WIDTH_D:0]             array_sum_pip;
    wire    [WIDTH_D-1:0]           array_carry_pip;
    
    reg     [WIDTH_D:0]             array_sum_pip_t;
    reg     [WIDTH_D-1:0]           array_carry_pip_t;
    reg     [WIDTH_D-1:0]           a_t;
    reg     [WIDTH_D-1:0]           b_t;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // modified array FA cells
    genvar i_row, i_col;
    generate
        for(i_col = 0; i_col < WIDTH_D; i_col = i_col + 1) begin: array_row_0
            assign array_sum[0][i_col] = 0;
            assign array_carry[0][i_col] = 0;
        end
    endgenerate
    
    generate
        for(i_row = 0; i_row < WIDTH_D; i_row = i_row + 1) begin: array_col_last
            assign array_sum[i_row][WIDTH_D] = 0;
        end
    endgenerate
    
    genvar j, k;
    generate
        for(j = 1; j < WIDTH_D + 1; j = j + 1) begin: array_row
`ifdef MULT_PIP        
            if (j == IDX_PIP) begin: array_row_pip
                for(k = 0; k < WIDTH_D; k = k + 1) begin: array_col_pip
                    assign {array_carry_pip[k], array_sum_pip[k]} = (a[k] & b[j-1]) + array_sum[j-1][k+1] + array_carry[j-1][k];
                end
            end
            else if (j == IDX_PIP + 1) begin: array_row_pipnext
                for(k = 0; k < WIDTH_D; k = k + 1) begin: array_col_pip
                    assign {array_carry[j][k], array_sum[j][k]} = (a_t[k] & b_t[j-1]) + array_sum_pip_t[k+1] + array_carry_pip_t[k];
                end
            end
            else begin: array_row_nonpip
                for(k = 0; k < WIDTH_D; k = k + 1) begin: array_col_nonpip
                    assign {array_carry[j][k], array_sum[j][k]} = (a[k] & b[j-1]) + array_sum[j-1][k+1] + array_carry[j-1][k];
                end
            end
`else
            for(k = 0; k < WIDTH_D; k = k + 1) begin: array_col
                assign {array_carry[j][k], array_sum[j][k]} = (a[k] & b[j-1]) + array_sum[j-1][k+1] + array_carry[j-1][k];
            end
`endif
        end
    endgenerate

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pipeline
`ifdef MULT_PIP
    always @(posedge clk) begin
        if (~rst_n) array_sum_pip_t <= 0;
        else array_sum_pip_t <= array_sum_pip;
    end
    
    always @(posedge clk) begin
        if (~rst_n) array_carry_pip_t <= 0;
        else array_carry_pip_t <= array_carry_pip;
    end
    
    always @(posedge clk) begin
        if (~rst_n) a_t <= 0;
        else a_t <= a;
    end

    always @(posedge clk) begin
        if (~rst_n) b_t <= 0;
        else b_t <= b;
    end
`endif

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // CPA and product output
    wire    [WIDTH_P-1:0]           p;                      // 64-bit product
    wire    [IDX_PIP-1:0]           p_lowpip;               // product pipeline needed
    reg     [IDX_PIP-1:0]           p_lowpip_t;             // product after pipeline
    genvar i_p;

`ifdef MULT_PIP
    generate
        for(i_p = 0; i_p < IDX_PIP; i_p = i_p + 1) begin: product_lowpip
            if (i_p == IDX_PIP - 1) begin: product_lowpip_next
                assign p_lowpip[i_p] = array_sum_pip[0];
            end
            else begin: product_lowpip_other
                assign p_lowpip[i_p] = array_sum[i_p+1][0];
            end
        end
        for(i_p = IDX_PIP; i_p < WIDTH_D; i_p = i_p + 1) begin: product_other
            assign p[i_p] = array_sum[i_p+1][0];
        end
    endgenerate

    always @(posedge clk) begin
        if (~rst_n) p_lowpip_t <= 0;
        else p_lowpip_t <= p_lowpip;
    end

    assign p[WIDTH_P-1:WIDTH_D] = array_sum[WIDTH_D][WIDTH_D-1:1] + array_carry[WIDTH_D][WIDTH_D-2:0];
    assign p[IDX_PIP-1:0] = p_lowpip_t;

    assign p_out = p[WIDTH_D-1:0];
`else
    reg     [WIDTH_D-1:0]           p_reg;                  // 32-bit product

    assign p[WIDTH_P-1:WIDTH_D] = array_sum[WIDTH_D][WIDTH_D-1:1] + array_carry[WIDTH_D][WIDTH_D-2:0];

    generate
        for(i_p = 0; i_p < WIDTH_D; i_p = i_p + 1) begin: product_low
            assign p[i_p] = array_sum[i_p+1][0];
        end
    endgenerate
    
    always @(posedge clk) begin
        if (~rst_n) p_reg <= 0;
        else p_reg <= p[WIDTH_D-1:0];
    end
    
    assign p_out = p_reg;
`endif


endmodule
