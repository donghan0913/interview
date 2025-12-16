`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 12:56:54
// Design Name: 
// Module Name: clk_gen
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


module clk_gen(
    clk,
    rst_n,
    test_mode,
    clk_1,
    clk_2
    );

    input                           clk;                    // clock
    input                           rst_n;   
    input                           test_mode;               
    output                          clk_1;
    output                          clk_2;

    wire                            clk_div2_n;
    wire                            clk_div2_gate;
    wire                            en_1_func;                   // enable for clk_1 clock gating
    wire                            en_2_func;                   // enable for clk_2 clock gating
    wire                            en_1;
    wire                            en_2;
    reg                             clk_div2;
    reg                             clk_div4;
    reg                             clk_1_latch;
    reg                             clk_2_latch;
    wire                            clk_1_func;
    wire                            clk_2_func;
   
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) clk_div2 <= 0;
        else        clk_div2 <= ~clk_div2;
    end

    assign clk_div2_gate = (test_mode) ? clk : clk_div2;
    always @(posedge clk_div2_gate, negedge rst_n) begin
        if (~rst_n) clk_div4 <= 0;
        else        clk_div4 <= ~clk_div4;
    end

    //assign en_1 = ~(clk_div4 ^ clk_div2_n);
    //assign en_2 = clk_div4 & clk_div2;
    assign clk_div2_n = ~clk_div2;

    assign en_1 = (test_mode) ? 1 : en_1_func;
    assign en_2 = (test_mode) ? 1 : en_2_func;
    assign clk_1 = (test_mode) ? clk : clk_1_func;
    assign clk_2 = (test_mode) ? clk : clk_2_func;

    // instance clk_1 latch-or circuit    
    XNOR2X1 u_xnor_en1(
        .Y (en_1_func),
        .A (clk_div2_n),
        .B (clk_div4)
        );
    
    TLATX1 u_lat_en1(
        .Q (clk_1_lat),
        .QN(),
        .D (en_1),
        .G (clk_div2_n)
        );
    
    OR2X1 u_or_clk1(
        .Y (clk_1_func),
        .A (clk_div2_n),
        .B (clk_1_lat)
        );
    
    // instance clk_2 latch-or circuit
    AND2X1 u_and_en2(
        .Y (en_2_func),
        .A (clk_div2),
        .B (clk_div4)
        );
    
    TLATX1 u_lat_en2(
        .Q (clk_2_lat),
        .QN(),
        .D (en_2),
        .G (clk)
        );
    
    OR2X1 u_or_clk2(
        .Y (clk_2_func),
        .A (clk),
        .B (clk_2_lat)
        );    

/*  
    always @(*) begin
        if (clk_div2_n) begin  
                    clk_1_latch <= en_1;
        end
    end
    assign clk_1 = clk_1_latch | clk_div2_n;

    always @(*) begin
        if (clk) begin  
                    clk_2_latch <= en_2;
        end
    end
    assign clk_2 = clk_2_latch | clk;   
*/


endmodule

