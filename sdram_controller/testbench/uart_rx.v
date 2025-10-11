/**************************************************************
 * Module name: uart_rx
 *
 * Features:
 *	1. UART RX part
 *    2. w/o parity check function, w/ one stop bit
 *    3. Data frame width is 8-bit
 *    4. RX part system clock frequency assume half of TX part system clock
 *
 * Descriptions:
 *    1.
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/
`timescale 1ns / 100ps
//`define SIM                                                 // Only used in Vivado, deleted in Linux, simulation only for small baud count


module uart_rx #(
    parameter CLK_FREQ = 200_000_000,                       // reciever part system clock frequency
    parameter BAUD_RATE = 9600,                             // baud rate
    parameter D_WIDTH = 8                                   // width of data frame
) (
    // system signals
    sys_clk,
    sys_rst_n,
    // UART_RX interface
    rx,
    rx_data,
    po_flag
    );

`ifdef SIM
    localparam BAUD_CNT_MAX = 10 - 1;                       // for baud_cnt to count, simulation only
    localparam BAUD_CNT_MID = BAUD_CNT_MAX / 2;             // for baud_cnt to count middle, simulation only
`else
    localparam BAUD_CNT_MAX = (CLK_FREQ / BAUD_RATE) - 1;   // for baud_cnt to count, which is (20833 - 1) in here (0x5160)
    localparam BAUD_CNT_MID = BAUD_CNT_MAX / 2;             // for baud_cnt to count middle
`endif
    
    localparam BAUD_CNT_WIDTH = 15;                         // baud_cnt width


    input                           sys_clk;                // system clock
    input                           sys_rst_n;              // system negative triggered reset
    input                           rx;                     // serial data from UART_RX
    output  [D_WIDTH-1:0]           rx_data;                // parallel data output
    output                          po_flag;                // indicate UART_RX job complete

    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // solve CDC and to better determine state and capture data, use 2 stage register
    reg                             rx_r1;                  // parallel data output after 1st register for solving CDC
    reg                             rx_r2;                  // parallel data output after 2nd register for solving CDC
    reg                             rx_r3;                  // parallel data output after 3rd register for better determine state and capture data
    reg                             rx_flag;                // indicate UART_RX is working, combine the features of "start_flag" & "work_en"
    reg     [BAUD_CNT_WIDTH-1:0]    baud_cnt;               // baud rate counter, use system clock to count to match bit data width of rx
    reg     [D_WIDTH:0]             bit_cnt;                // data frame counter
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) rx_r1 <= 1;  
        else            rx_r1 <= rx;    
    end
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) rx_r2 <= 1;
        else            rx_r2 <= rx_r1;    
    end
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) rx_r3 <= 1;
        else            rx_r3 <= rx_r2;    
    end
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) rx_flag <= 0;
        else begin
            if ((rx_r2 == 0) && (rx_r3 == 1)) begin
                        rx_flag <= 1'b1;
            end
            else if ((baud_cnt == BAUD_CNT_MAX) && (bit_cnt == 0)) begin
                        rx_flag <= 0;
            end
            else        rx_flag <= rx_flag;
        end    
    end
        
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // baud rate counter    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) baud_cnt <= 0;
        else begin
            if ((baud_cnt == BAUD_CNT_MAX) || (rx_flag == 0)) begin
                        baud_cnt <= 0;
            end
            else        baud_cnt <= baud_cnt + 1'b1;
        end    
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // capture data then output
    wire                            bit_flag;               // indicate when to start bit_cnt and when can capture data
    reg     [D_WIDTH-1:0]           rx_data_reg;            // capture rx input data and remove start bit and stop bit by doing right shift 
    reg                             po_flag_reg;            // indicate finish serial-parallel job
    
    assign bit_flag = (baud_cnt == BAUD_CNT_MID) ? 1'b1 : 0;
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n)                 bit_cnt <= 0;
        else begin
            if (bit_flag) begin
                if (bit_cnt == D_WIDTH) bit_cnt <= 0;
                else                    bit_cnt <= bit_cnt + 1'b1;
            end
            else                        bit_cnt <= bit_cnt;
        end    
    end
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n)     rx_data_reg <= 0;
        else begin
            if (bit_flag)   rx_data_reg <= {rx_r3, rx_data_reg[D_WIDTH-1:1]};
            else            rx_data_reg <= rx_data_reg;
        end    
    end
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) po_flag_reg <= 0;
        else begin
            if ((bit_flag == 1) && (bit_cnt == D_WIDTH)) begin
                        po_flag_reg <= 1'b1;
            end
            else        po_flag_reg <= 0;
        end    
    end
    
    assign rx_data = rx_data_reg;
    assign po_flag = po_flag_reg;
    
    
endmodule
