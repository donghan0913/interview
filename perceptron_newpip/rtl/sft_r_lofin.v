/**************************************************************
 * Module name: sft_r_lofin
 *
 * Features:
 *	1. Use 16-to-1 MUX with low fan-in to do arithmetic right shift
 *
 * Descriptions:
 *	1. Use 4-stage select network which is similar to parallel prefix network of adder
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/


module sft_r_lofin(
    x,
    sign,
    sel,
    y
    );

    localparam D_WIDTH = 16;                                // width of data
    localparam SEL_WIDTH = 6;                               // width of sel

    input   [D_WIDTH-1:0]       x;                          // input data
    input                       sign;                       // sign of input x
    input   [SEL_WIDTH-1:0]     sel;                        // select signal of MUX
    output  [D_WIDTH-1:0]       y;                          // output data

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // 4-stage select cell network
    wire    [D_WIDTH-1:0]       x_lv1;                      // stage one selected data
    wire    [D_WIDTH-1:0]       x_lv2;                      // stage two selected data
    wire    [D_WIDTH-1:0]       x_lv3;                      // stage three selected data
    wire    [D_WIDTH-1:0]       x_lv4;                      // stage four selected data

    genvar i;
    generate
        for(i = 0; i < (D_WIDTH - 1); i = i + 1) begin: mux_lv1
            assign x_lv1[i] = (sel[0]) ? x[i+1] : x[i];
        end
        assign x_lv1[D_WIDTH-1] = (sel[0]) ? sign : x[D_WIDTH-1];
    endgenerate

    genvar j;
    generate
        for(j = 0; j < (D_WIDTH - 2); j = j + 1) begin: mux_lv2_lo
            assign x_lv2[j] = (sel[1]) ? x_lv1[j+2] : x_lv1[j];
        end
        for(j = (D_WIDTH - 2); j < D_WIDTH; j = j + 1) begin: mux_lv2_hi
            assign x_lv2[j] = (sel[1]) ? sign : x_lv1[j];
        end
    endgenerate

    genvar k;
    generate
        for(k = 0; k < (D_WIDTH - 4); k = k + 1) begin: mux_lv3_lo
            assign x_lv3[k] = (sel[2]) ? x_lv2[k+4] : x_lv2[k];
        end
        for(k = (D_WIDTH - 4); k < D_WIDTH; k = k + 1) begin: mux_lv3_hi
            assign x_lv3[k] = (sel[2]) ? sign : x_lv2[k];
        end
    endgenerate

    genvar l;
    generate
        for(l = 0; l < (D_WIDTH - 8); l = l + 1) begin: mux_lv4_lo
            assign x_lv4[l] = (sel[3]) ? x_lv3[l+8] : x_lv3[l];
        end
        for(l = (D_WIDTH - 8); l < D_WIDTH; l = l + 1) begin: mux_lv4_hi
            assign x_lv4[l] = (sel[3]) ? sign : x_lv3[l];
        end
    endgenerate

    assign y = (sel[SEL_WIDTH-2:4] > 0) ? {D_WIDTH{sign}} : x_lv4;


endmodule
