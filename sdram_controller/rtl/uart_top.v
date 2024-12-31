/**************************************************************
 * Module name: uart_top
 *
 * Features:
 *	1. UART top module with RX & TX
 *    2. Data packet: {start bit, data frame[7:0], stop bit}
 *    3. Data frame width is 8-digit
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


module uart_top #(
    parameter CLK_FREQ          = 133_000_000,              // reciever part system clock frequency
    parameter BAUD_RATE         = 9600,                     // baud rate
    parameter D_WIDTH           = 8                         // width of data frame
) (
    sys_clk,
    sys_rst_n,
    d_in,
    trig,
    d_out,
    tx_done,
    rx_done
    );
    
    input                           sys_clk;                // system clock
    input                           sys_rst_n;              // system negative triggered reset
    input   [D_WIDTH-1:0]           d_in;                   // parallel data input from user
    input                           trig;                   // indicate UART_TX start 
    output  [D_WIDTH-1:0]           d_out;                  // parallel data output from UART_RX
    output                          tx_done;                // indicate UART_TX finish job
    output                          rx_done;                // indicate UART parallel-serial-parallel job finish
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // different clock frequency generation using frequency divider, TX fixed, RX generated
    wire                            sys_clk_tx;             // UART_TX system clock, fixed at 133MHz eventually
    wire                            sys_clk_rx;             // UART_RX system clock, generated depends on TX
    
    assign sys_clk_tx = sys_clk;
    assign sys_clk_rx = sys_clk;
    
    localparam CLK_FREQ_TX = CLK_FREQ;
    localparam CLK_FREQ_RX = CLK_FREQ;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    wire                            d_srl;                  // serial data output from UART_TX, input for UART_RX
    
    uart_tx #(
        .CLK_FREQ(CLK_FREQ_TX),
        .BAUD_RATE(BAUD_RATE),
        .D_WIDTH(D_WIDTH)
    ) inst_uart_tx(
        // system signals
        .sys_clk(sys_clk_tx),
        .sys_rst_n(sys_rst_n),
        // UART_RX interface
        .tx_data(d_in),
        .tx_trig(trig),
        .tx(d_srl),
        .tx_done(tx_done)
        );

    uart_rx #(
        .CLK_FREQ(CLK_FREQ_RX),
        .BAUD_RATE(BAUD_RATE),
        .D_WIDTH(D_WIDTH)
    ) inst_uart_rx(
        // system signals
        .sys_clk(sys_clk_rx),
        .sys_rst_n(sys_rst_n),
        // UART_RX interface
        .rx(d_srl),
        .rx_data(d_out),
        .po_flag(rx_done)
        );


endmodule
