`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/28 12:12:26
// Design Name: 
// Module Name: tb_freq_div
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


module tb_freq_div;
    
    parameter SEED          = 2;                            // seed for random pattern generation
    parameter TEST_NUM      = 20;                           // total random pattern numbers of test
    parameter PERIOD        = 10;                           // clock period
    parameter DELAY         = PERIOD/4.0;                   // small time interval used in stimulus
    parameter CLK_DIV       = 4;                            // clock divide for integer, double value for half integer
    parameter DUTY_CYCLE    = 375;                          // duty cycle percentage, N/1000
    parameter DUTY_NUM      = 2;                            // duty cycle logic 1 cycles number
    
    reg                                 clk;                // clock


    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    reg                                 rst_n;
    wire                                clk_div_num;
    
    freq_div #(
        .CLK_DIV(CLK_DIV),
        .DUTY_CYCLE(DUTY_CYCLE),
        .DUTY_NUM(DUTY_NUM)
    ) inst_freq_div(
        .clk(clk),
        .rst_n(rst_n),
        .clk_div_num(clk_div_num)
        );

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk
    always #(PERIOD/2) clk = ~clk;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    reg     [31:0]                      seed;               // for random pattern generation    
    
    integer i;
    initial begin
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // initialize
        clk = 0;
        rst_n = 1;
        i = 0;
        seed = SEED;
        
        $display();
        $display("Test Mode Stimulus start >>>");
        $display("------------------------------------------------");
        @(posedge clk);
        
        ////rst test
        @(posedge clk);
        #(DELAY);
        rst_n = 0;
        
        @(posedge clk);
        #(DELAY);
        rst_n = 1;
        
        for (i = 0; i < 50; i = i + 1) begin
            @ (posedge clk);
        end

        $finish();
    end


endmodule
