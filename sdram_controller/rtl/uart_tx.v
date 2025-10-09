/**************************************************************
 * Module name: uart_tx
 *
 * Features:
 *	1. UART TX part
 *    2. w/o parity check function, w/ 2 stop bits
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


module uart_tx #(
    parameter CLK_FREQ = 200_000_000,                       // transmitter part system clock frequency
    parameter BAUD_RATE = 9600,                             // baud rate
    parameter D_WIDTH = 8                                   // width of data frame
) (
    // system signals
    sys_clk,
    sys_rst_n,
    // UART_TX interface
    tx_data,
    //tx_trig,
    tx,
    tx_done,
    rfifo_empty,
    rfifo_rd_en
    );

`ifdef SIM
    localparam BAUD_CNT_MAX = 10 - 1;                       // for baud_cnt to count, simulation only
    localparam BAUD_CNT_MID = BAUD_CNT_MAX / 2;             // for baud_cnt to count middle, simulation only
`else
    localparam BAUD_CNT_MAX = (CLK_FREQ / BAUD_RATE) - 1;   // for baud_cnt to count, which is (20833 - 1) in here (0x5160)
    localparam BAUD_CNT_MID = BAUD_CNT_MAX / 2;             // for baud_cnt to count middle
`endif
    localparam BAUD_CNT_WIDTH = 15;                         // baud_cnt width
    localparam PACKET_CNT = 10;

    input                           sys_clk;                // system clock
    input                           sys_rst_n;              // system negative triggered reset
    //input                           tx_trig;                // indicate UART_TX start 
    input   [D_WIDTH-1:0]           tx_data;                // parallel data input from user, rfifo_rd_data
    output                          tx;                     // serial data output for UART_TX
    output                          tx_done;                // indicate UART_TX finish job
    
    input                           rfifo_empty;
    output                          rfifo_rd_en;            // generate data read enable to rFIFO
    

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // logic
    reg     [D_WIDTH-1:0]           tx_data_reg;            // temporary store valid input parallel data
    reg     [D_WIDTH+2:0]           tx_reg;                 // shift valid parallel data for output tx
    reg                             tx_flag;                // indicate UART_TX is working
    reg                             tx_flag_t1;             // indicate UART_TX is working
    reg                             tx_flag_t2;             // indicate UART_TX is working
    reg     [BAUD_CNT_WIDTH-1:0]    baud_cnt;               // baud rate counter, use system clock to count to match bit data width of rx
    reg     [D_WIDTH:0]             bit_cnt;                // data frame counter
    wire                            bit_flag;               // indicate when to start bit_cnt and when can capture data
    reg                             rfifo_rd_en_reg;
    reg                             tx_trig;                // indicate UART_TX start 
    
    always @(posedge sys_clk) begin
                            tx_trig <= rfifo_rd_en;
    end

    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n)     tx_data_reg <= 0;
        else begin
            if (tx_trig)    tx_data_reg <= tx_data;
            else            tx_data_reg <= tx_data_reg;
        end
    end

    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n)     tx_flag <= 0;
        else begin
            if (tx_trig)    tx_flag <= 1;
            else if ((bit_cnt == PACKET_CNT) && (bit_flag == 1)) begin
                            tx_flag <= 0;
            end
            else            tx_flag <= tx_flag;
        end
    end
    always @(posedge sys_clk) begin
                            tx_flag_t1 <= tx_flag;
    end

    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n)     baud_cnt <= 0;
        else begin
            if ((baud_cnt == BAUD_CNT_MAX) || (tx_flag == 0)) begin
                            baud_cnt <= 0;
            end
            else            baud_cnt <= baud_cnt + 1'b1;
        end    
    end
    
    assign bit_flag = (baud_cnt == BAUD_CNT_MAX) ? 1'b1 : 0;
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n)     bit_cnt <= 0;
        else begin
            if (bit_flag) begin
                if (bit_cnt == PACKET_CNT) begin
                            bit_cnt <= 0;
                end
                else        bit_cnt <= bit_cnt + 1'b1;
            end
            else            bit_cnt <= bit_cnt;
        end    
    end

    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n)     tx_reg <= 0;
        else begin
            if (tx_trig)    tx_reg <= {1'b1, 1'b1, tx_data, 1'b0};
            else if (bit_flag == 1) begin
                            tx_reg <= tx_reg >> 1;            
            end            
            else            tx_reg <= tx_reg;
        end
    end

    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n)     rfifo_rd_en_reg <= 0;
        else begin
            if ((rfifo_empty == 0) && (tx_flag == 0)) begin
                            rfifo_rd_en_reg <= 1;
            end
            else            rfifo_rd_en_reg <= 0;
        end
    end

    assign tx = (tx_flag == 0) ? 1 : tx_reg[0];
    assign tx_done = ((bit_cnt == PACKET_CNT) && (bit_flag == 1)) ? 1 : 0;
    //assign rfifo_rd_en = rfifo_rd_en_reg;
    assign rfifo_rd_en = ((rfifo_rd_en_reg == 0) && (rfifo_empty == 0) && (tx_flag == 0)) ? 1 : 0;


endmodule
