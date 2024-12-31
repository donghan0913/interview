/**************************************************************
 * Module name: tb_sdram_top
 *
 * Features:
 *	1. 
 *
 * Descriptions:
 *    1. 
 *
 * Author: Jason Wu, master's student, NTHU
 *  
 * ***********************************************************/
`timescale 1ns / 100ps
//`define SIM                                                 // Only used in Vivado, deleted in Linux, simulation only for small baud count
//`define sg75                                                // Only used in Vivado, deleted in Linux, SDRAM model timing spec
//`define den128Mb                                            // Only used in Vivado, deleted in Linux, SDRAM model size spec
//`define x16                                                 // Only used in Vivado, deleted in Linux, SDRAM model size spec


module tb_sdram_top;

    //`include "sdr_parameters.vh"
	`include "/home/m110/m110063556/interview/sdram_controller/rtl/sdr_parameters.vh"

    parameter SEED              = 2;                        // seed for random pattern generation
    parameter PERIOD            = 20;                       // clock period, to 20ns generate 50MHz system clock for SDRAM controller
    parameter DELAY             = PERIOD/4.0;               // small time interval used in stimulus
    parameter TEST_NUM          = 10;                       // total random pattern numbers of test
    parameter BANK_WIDTH        = 2;                        // bank address width
    parameter WAIT200           = 10000;                    // wait 200us after power-up, count 10000 times for system clock
    parameter WAIT200_WIDTH     = 14;                       // 14-bit to count 10000
    parameter CLK_FREQ          = 50_000_000;               // reciever part system clock frequency
    parameter BAUD_RATE         = 9600;                     // baud rate

    reg                                 sys_clk;            // system clock
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    reg                                 sys_rst_n;          // system negative triggered reset
    wire                                sdram_clk;          // SDRAM clock
    wire                                sdram_cke;          // SDRAM clock enable
    wire                                sdram_cs_n;         // SDRAM negative trigger chip select
    wire                                sdram_cas_n;        // SDRAM negative trigger column address enable
    wire                                sdram_ras_n;        // SDRAM negative trigger raw address enable
    wire                                sdram_we_n;         // SDRAM negative trigger write enable
    wire    [BA_BITS-1:0]               sdram_bank;         // SDRAM bank address
    wire    [ADDR_BITS-1:0]             sdram_addr;         // SDRAM address, A11 ~A0
    wire    [DM_BITS-1:0]               sdram_dqm;          // SDRAM {UDQM, LDQM}
    wire    [DQ_BITS-1:0]               sdram_dq;           // SDRAM data
        
    sdram_top inst_sdram_top(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .sdram_clk(sdram_clk),
        .sdram_cke(sdram_cke),
        .sdram_cs_n(sdram_cs_n),
        .sdram_cas_n(sdram_cas_n),
        .sdram_ras_n(sdram_ras_n),
        .sdram_we_n(sdram_we_n),
        .sdram_bank(sdram_bank),
        .sdram_addr(sdram_addr),
        .sdram_dqm(sdram_dqm),
        .sdram_dq(sdram_dq)
    );
    
    sdram_model inst_sdram_model(
        .Dq(sdram_dq),
        .Addr(sdram_addr),
        .Ba(sdram_bank),
        .Clk(sdram_clk),
        .Cke(sdram_cke),
        .Cs_n(sdram_cs_n),
        .Ras_n(sdram_ras_n),
        .Cas_n(sdram_cas_n),
        .We_n(sdram_we_n),
        .Dqm(sdram_dqm)
        );
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk
    always #(PERIOD/2) sys_clk = ~sys_clk;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    reg             [31:0]              seed;               // for random pattern generation
    integer i;                                              // test loop count
    initial begin
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // initialize
        sys_clk = 0;
        sys_rst_n = 1;
        i = 0;
        seed = SEED;

        #(DELAY);
        sys_rst_n = 0;

        for (i = 0 ; i < 5; i = i + 1) @(posedge sys_clk);
        #(DELAY);
        sys_rst_n = 1;

        #200000;
        
        $finish();
    end

        // --------------------------------------------------------------------------------------------------------------------------------------------------------
		// fsdb dump
	initial begin
		$fsdbDumpfile("./waveform/sdram_top.fsdb");
		$fsdbDumpvars();
	end


endmodule
