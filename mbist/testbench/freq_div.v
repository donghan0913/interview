`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/28 11:55:09
// Design Name: 
// Module Name: freq_div
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
//`define FREQ_DIV_EVEN
//`define FREQ_DIV_ODD_NO50
//`define FREQ_DIV_ODD_50
//`define FREQ_DIV_DUTY_NO50
//`define FREQ_DIV_HALFINT


module freq_div #(
    parameter CLK_DIV = 4,                                  // frequency divide number
    parameter DUTY_CYCLE = 375,                             // duty cycle percentage, N/1000
    parameter DUTY_NUM = 2                                  // duty cycle logic 1 cycles number
) (
    clk,
    rst_n,
    clk_div_num
    );
    
    input                           clk;                    // clock
    input                           rst_n;                  // reset
    output                          clk_div_num;            // clock divided by N
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Logic
    reg                             clk_div_num_reg;        // 
    reg     [3:0]                   clk_div_cnt;            // 

`ifdef FREQ_DIV_EVEN 
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_div_cnt <= 0;
        else if (clk_div_cnt == ((CLK_DIV/2) - 1)) begin
                        clk_div_cnt <= 0;
        end
        else            clk_div_cnt <= clk_div_cnt + 1;
    end
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_div_num_reg <= 0;
        else if (clk_div_cnt == ((CLK_DIV/2) - 1)) begin
                        clk_div_num_reg <= ~clk_div_num_reg;
        end
        else            clk_div_num_reg <= clk_div_num_reg;
    end
    
    assign clk_div_num = clk_div_num_reg;
`endif

`ifdef FREQ_DIV_ODD_NO50
    localparam CLK_DIV_MAX = CLK_DIV - 1;
    localparam OFF_NUM = CLK_DIV_MAX - DUTY_NUM;            // Off time cycle number, which is invert of Duty cycle number
     
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_div_cnt <= 0;
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_div_cnt <= 0;
        end
        else            clk_div_cnt <= clk_div_cnt + 1;
    end
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_div_num_reg <= 0;
        else if (clk_div_cnt == OFF_NUM) begin
                        clk_div_num_reg <= ~clk_div_num_reg;
        end
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_div_num_reg <= ~clk_div_num_reg;
        end
        else            clk_div_num_reg <= clk_div_num_reg;
    end
    
    assign clk_div_num = clk_div_num_reg;
`endif    

`ifdef FREQ_DIV_ODD_50
    localparam CLK_DIV_HALF = CLK_DIV/2;
    localparam CLK_DIV_MAX = CLK_DIV- 1;
    reg                             clk_1;        // 
    reg                             clk_2; 

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_div_cnt <= 0;
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_div_cnt <= 0;
        end
        else            clk_div_cnt <= clk_div_cnt + 1;
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_1 <= 0;
        else if (clk_div_cnt == CLK_DIV_HALF) begin
                        clk_1 <= ~clk_1;
        end
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_1 <= ~clk_1;
        end
        else            clk_1 <= clk_1;
    end

    always @(negedge clk, negedge rst_n) begin
        if (~rst_n)     clk_2 <= 0;
        else if (clk_div_cnt == CLK_DIV_HALF) begin
                        clk_2 <= ~clk_2;
        end
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_2 <= ~clk_2;
        end
        else            clk_2 <= clk_2;
    end

    assign clk_div_num = ~(clk_1 | clk_2);

`endif

`ifdef FREQ_DIV_DUTY_NO50
    localparam DUTY_CYCLE_CNT = (DUTY_CYCLE * CLK_DIV) / 1000;
    localparam CLK_DIV_MAX = CLK_DIV- 1;
    reg                             clk_1;        // 
    reg                             clk_2; 

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_div_cnt <= 0;
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_div_cnt <= 0;
        end
        else            clk_div_cnt <= clk_div_cnt + 1;
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_1 <= 0;
        else if (clk_div_cnt == DUTY_CYCLE_CNT) begin
                        clk_1 <= ~clk_1;
        end
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_1 <= ~clk_1;
        end
        else            clk_1 <= clk_1;
    end

    always @(negedge clk, negedge rst_n) begin
        if (~rst_n)     clk_2 <= 0;
        else if (clk_div_cnt == DUTY_CYCLE_CNT) begin
                        clk_2 <= ~clk_2;
        end
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_2 <= ~clk_2;
        end
        else            clk_2 <= clk_2;
    end

    assign clk_div_num = ~(clk_1 | clk_2);
`endif

`ifdef FREQ_DIV_HALFINT
    localparam CLK_DIV_MAX = (CLK_DIV / 2) + 1;
    localparam CLK_DIV_HALF = CLK_DIV / 4;
    reg                             clk_1;        // 
    reg                             clk_2;
    

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_div_cnt <= 0;
        else if (clk_div_cnt == (CLK_DIV - 1)) begin
                        clk_div_cnt <= 0;
        end
        else            clk_div_cnt <= clk_div_cnt + 1;
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     clk_1 <= 0;
        else if (clk_div_cnt == 0) begin
                        clk_1 <= 1;
        end
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_1 <= 1;
        end
        else            clk_1 <= 0;
    end
    
    always @(negedge clk, negedge rst_n) begin
        if (~rst_n)     clk_2 <= 0;
        else if (clk_div_cnt == 1) begin
                        clk_2 <= 1;
        end
        else if (clk_div_cnt == CLK_DIV_MAX) begin
                        clk_2 <= 1;
        end
        else            clk_2 <= 0;
    end
    
    assign clk_div_num = clk_1 | clk_2;

`endif   
    
    
endmodule
