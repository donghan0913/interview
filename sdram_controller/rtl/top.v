/**************************************************************
 * Module name: top
 *
 * Features:
 *	1. Top module include sdram_top, uart_rx, uart_tx, wfifo, rfifo, cmd_decode
 *
 * Descriptions:
 *    1.
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/
`timescale 1ns / 100ps

`define AFIFO


module top #(
    parameter CLK_FREQ = 133_000_000,                       // reciever part system clock frequency
    parameter BAUD_RATE = 9600,                             // baud rate
    parameter D_WIDTH_UART = 8                              // width of data frame of UART
) (
    sys_clk,
    sys_rst_n,
    uart_rx,
    uart_tx,
    sdram_clk,
    sdram_cke,
    sdram_cs_n,
    sdram_cas_n,
    sdram_ras_n,
    sdram_we_n,
    sdram_bank,
    sdram_addr,
    sdram_dqm,
    sdram_dq,
    // for testbench convenience
    aref_done_out,
    uart_tx_done
    );
    
	`include "/home/m110/m110063556/interview/sdram_controller/rtl/sdr_parameters.vh"
    //`include "sdr_parameters.vh"
    
    localparam FIFO_DEPTH = 16;
    localparam FIFO_PTR_SIZE = 4;
    
    input                           sys_clk;                // system clock
    input                           sys_rst_n;              // system negative triggered reset
    input                           uart_rx;                // serial packet data input from testbench
    output                          uart_tx;                // serial packet data output to testbench
    
    output                          sdram_clk;              // SDRAM clock
    output                          sdram_cke;              // SDRAM clock enable
    output                          sdram_cs_n;             // SDRAM negative trigger chip select
    output                          sdram_cas_n;            // SDRAM negative trigger column address enable
    output                          sdram_ras_n;            // SDRAM negative trigger raw address enable
    output                          sdram_we_n;             // SDRAM negative trigger write enable
    output  [BA_BITS-1:0]           sdram_bank;             // SDRAM bank address
    output  [ADDR_BITS-1:0]         sdram_addr;             // SDRAM address, A11 ~A0
    output  [DM_BITS-1:0]           sdram_dqm;              // SDRAM {UDQM, LDQM}
    inout   [DQ_BITS-1:0]           sdram_dq;               // SDRAM data
    
    output                          aref_done_out;          // indicate AUTO-REFRESH done
    output                          uart_tx_done;           // indicate UART_TX done
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    wire    [D_WIDTH_UART-1:0]      rx_data;                // parallel data output from UART_RX to "cmd_decode"
    wire                            tx_trig;                // ???
    wire                            sdram_wr_trig;          // sdram write operation trigger
    wire                            sdram_rd_trig;          // sdram read operation trigger
    
    wire                            wfifo_wr_en;
    wire    [D_WIDTH_UART-1:0]      wfifo_wr_data;
    wire                            wfifo_rd_en;
    wire    [D_WIDTH_UART-1:0]      wfifo_rd_data;    
    wire                            wfifo_full;
    wire                            wfifo_empty;
    
    wire                            rfifo_wr_en;
    wire    [D_WIDTH_UART-1:0]      rfifo_wr_data;
    wire                            rfifo_rd_en;
    wire    [D_WIDTH_UART-1:0]      rfifo_rd_data;    
    wire                            rfifo_full;
    wire                            rfifo_empty;
    
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .D_WIDTH(D_WIDTH_UART)
    ) inst_uart_rx(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .rx(uart_rx),
        .rx_data(rx_data),
        .po_flag(tx_trig)
        );
    
    cmd_decode #(
        .D_WIDTH(D_WIDTH_UART)
    ) inst_cmd_decode(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .uart_flag(tx_trig),
        .uart_data(rx_data),
        .wr_trig(sdram_wr_trig),
        .rd_trig(sdram_rd_trig),
        .wfifo_wr_en(wfifo_wr_en),
        .wfifo_data(wfifo_wr_data)
        );
    
`ifdef AFIFO
    fifo_async #(
        .WIDTH(D_WIDTH_UART),
        .DEPTH(FIFO_DEPTH),
        .PTR_SIZE(FIFO_PTR_SIZE)
    ) inst_wfifo_16x8(
        .clk_a(sys_clk),
        .clk_b(sys_clk),
        .rst_n(sys_rst_n),
        .wr_en(wfifo_wr_en),
        .rd_en(wfifo_rd_en),
        .wr_data(wfifo_wr_data),
        .rd_data(wfifo_rd_data),
        .full(wfifo_full),
        .empty(wfifo_empty)
        );
`else    
    fifo_sync #(
        .WIDTH(D_WIDTH_UART),
        .DEPTH(FIFO_DEPTH),
        .PTR_SIZE(FIFO_PTR_SIZE)
    ) inst_wfifo_16x8(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .wr_en(wfifo_wr_en),
        .rd_en(wfifo_rd_en),
        .wr_data(wfifo_wr_data),
        .rd_data(wfifo_rd_data),
        .full(wfifo_full),
        .empty(wfifo_empty)
        );
`endif

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .D_WIDTH(D_WIDTH_UART)
    ) inst_uart_tx(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .tx_data(rfifo_rd_data),
        //tx_trig,
        .tx(uart_tx),
        .tx_done(uart_tx_done),
        .rfifo_empty(rfifo_empty),
        .rfifo_rd_en(rfifo_rd_en)
        );

`ifdef AFIFO
    fifo_async #(
        .WIDTH(D_WIDTH_UART),
        .DEPTH(FIFO_DEPTH),
        .PTR_SIZE(FIFO_PTR_SIZE)
    ) inst_rfifo_16x8(
        .clk_a(sdram_clk),
        .clk_b(sys_clk),
        .rst_n(sys_rst_n),
        .wr_en(rfifo_wr_en),
        .rd_en(rfifo_rd_en),
        .wr_data(rfifo_wr_data),
        .rd_data(rfifo_rd_data),
        .full(rfifo_full),
        .empty(rfifo_empty)
        );
`else
    fifo_sync #(
        .WIDTH(D_WIDTH_UART),
        .DEPTH(FIFO_DEPTH),
        .PTR_SIZE(FIFO_PTR_SIZE)
    ) inst_rfifo_16x8(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .wr_en(rfifo_wr_en),
        .rd_en(rfifo_rd_en),
        .wr_data(rfifo_wr_data),
        .rd_data(rfifo_rd_data),
        .full(rfifo_full),
        .empty(rfifo_empty)
        );    
`endif
    
    sdram_top inst_sdram_ctr_top(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .wr_trig(sdram_wr_trig),
        .rd_trig(sdram_rd_trig),
        .sdram_clk(sdram_clk),
        .sdram_cke(sdram_cke),
        .sdram_cs_n(sdram_cs_n),
        .sdram_cas_n(sdram_cas_n),
        .sdram_ras_n(sdram_ras_n),
        .sdram_we_n(sdram_we_n),
        .sdram_bank(sdram_bank),
        .sdram_addr(sdram_addr),
        .sdram_dqm(sdram_dqm),
        .sdram_dq(sdram_dq),
        // for testbench convenience
        .aref_done_out(aref_done_out),
        // FIFO
        .wfifo_rd_data(wfifo_rd_data), // input
        .wfifo_rd_en(wfifo_rd_en),
        .rfifo_wr_data(rfifo_wr_data),
        .rfifo_wr_en(rfifo_wr_en)
        );
    
    
    
    
endmodule
