/**************************************************************
 * Module name: tb_top
 *
 * Features:
 *	1. SDRAM controller clock frequency same as SDRAM model
 *
 * Descriptions:
 *    1. 
 *
 * Author: Jason Wu, master's student, NTHU
 *  
 * ***********************************************************/
`timescale 1ns / 100ps
//`define SIM                                                 // Only used in Vivado, deleted in Linux, simulation only for small baud count
`define sg75                                                // Only used in Vivado, deleted in Linux, SDRAM model timing spec
`define den128Mb                                            // Only used in Vivado, deleted in Linux, SDRAM model size spec
`define x16                                                 // Only used in Vivado, deleted in Linux, SDRAM model size spec


module tb_top;

    	`include "/home/m110/m110063556/interview/sdram_controller_w_cdc/rtl/sdr_parameters.vh"
	//`include "sdr_parameters.vh"

    parameter SEED              = 2;                        // seed for random pattern generation
    parameter T_SYS             = `PERIOD;                  // system clock period
    parameter T_SDR             = 7.5;                      // sdram clock period, to 7.5ns generate 133MHz system clock for SDRAM controller
    parameter DELAY             = T_SYS/4.0;                // small time interval used in stimulus
    parameter TEST_NUM          = 10;                       // total random pattern numbers of test
    parameter WAIT100           = 13333;                    // wait 100us after power-up, count 13333(0x3415) times for sdram clock
    parameter WAIT100_WIDTH     = 15;                       // 15-bit to count 13333
    parameter CLK_FREQ          = 200_000_000;              // system clock frequency
    parameter BAUD_RATE         = 9600;                     // baud rate
    parameter D_WIDTH_UART      = 8;                        // data width for UART
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    reg                                 sys_clk;            // system clock
    reg                                 rst_n;              // negative triggered reset
    reg                                 tx_tb;              // serial packet data input from testbench
    wire                                rx_tb;              // serial packet data output to testbench
    reg                                 sdram_clk;          // SDRAM clock
    wire                                sdram_cke;          // SDRAM clock enable
    wire                                sdram_cs_n;         // SDRAM negative trigger chip select
    wire                                sdram_cas_n;        // SDRAM negative trigger column address enable
    wire                                sdram_ras_n;        // SDRAM negative trigger raw address enable
    wire                                sdram_we_n;         // SDRAM negative trigger write enable
    wire    [BA_BITS-1:0]               sdram_bank;         // SDRAM bank address
    wire    [ADDR_BITS-1:0]             sdram_addr;         // SDRAM address, A11 ~A0
    wire    [DM_BITS-1:0]               sdram_dqm;          // SDRAM {UDQM, LDQM}
    wire    [DQ_BITS-1:0]               sdram_dq;           // SDRAM data
    wire                                aref_done_out;      // indicate AUTO-REFRESH done        
    wire                                uart_tx_done;       // indicate UART_TX done
       
    top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .D_WIDTH_UART(D_WIDTH_UART)
    ) inst_top(
        .sys_clk(sys_clk),
        .rst_n(rst_n),
        .uart_rx(tx_tb),
        .uart_tx(rx_tb),
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
        .uart_tx_done(uart_tx_done)
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
    
    //// UART_RX in testbench for debugging
    wire    [D_WIDTH_UART-1:0]      rx_data_tb;             // parallel data output from UART_RX to "cmd_decode"
    wire                            rx_done_tb;             // ???
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .D_WIDTH(D_WIDTH_UART)
    ) inst_uart_rx(
        .sys_clk(sys_clk),
        .sys_rst_n(rst_n),
        .rx(rx_tb),
        .rx_data(rx_data_tb),
        .po_flag(rx_done_tb)
        );
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk
    initial begin
        sys_clk = 0;
        //sys_clk = ~sys_clk;
        forever #(T_SYS/2) sys_clk = ~sys_clk;
    end
    
    initial begin
        sdram_clk = 0;
        //sdram_clk = ~sdram_clk;
        forever #(T_SDR/2) sdram_clk = ~sdram_clk;
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // task
    //// generate serial data packet pattern
    localparam BAUD_CNT_MAX = (CLK_FREQ / BAUD_RATE) - 1;   // for baud_cnt to count, which is (20833 - 1) in here (0x5160)
    reg             [31:0]              seed;           // for random pattern generation
    integer i_task;
    integer j_task;
    task rand_in_gen;
        input       [31:0]              pattern_cnt;
		begin            
            // generate random input patterns, 20-digit width including data packet and buffering, and get golden answer            
            //// random pattern for stop bit (1 -> 0) and data frame
            for (i_task = 0; i_task < (D_WIDTH_UART + 2); i_task = i_task + 1) begin
                #(DELAY);
                if (i_task == 0)        tx_tb = 1'b1;
                else if (i_task == 1)   tx_tb = 0;
                else begin
                    if (pattern_cnt == 0) begin
                        // generate 8'h44 for WRITE command at first UART data frame
                        case (i_task)
                            2:          tx_tb = 0;
                            3:          tx_tb = 0;
                            4:          tx_tb = 1;
                            5:          tx_tb = 0;
                            6:          tx_tb = 0;
                            7:          tx_tb = 0;
                            8:          tx_tb = 1;
                            9:          tx_tb = 0;
                        endcase
                    end
                    else if (pattern_cnt == 5) begin
                        // generate 8'h55 for READ command immediately after one burst writing finish
                        case (i_task)
                            2:          tx_tb = 1;
                            3:          tx_tb = 0;
                            4:          tx_tb = 1;
                            5:          tx_tb = 0;
                            6:          tx_tb = 1;
                            7:          tx_tb = 0;
                            8:          tx_tb = 1;
                            9:          tx_tb = 0;
                        endcase
                    end
                    else                tx_tb = $random(seed) % 2;
                end
                for (j_task = 0; j_task < (BAUD_CNT_MAX + 1); j_task = j_task + 1) begin
                                        @(posedge sys_clk);
                end
            end
            
            //// pattern for stop bit and 9-bit buffering
            for (i_task = 0; i_task < (D_WIDTH_UART + 2); i_task = i_task + 1) begin
                #(DELAY);                
                tx_tb = 1;
                for (j_task = 0; j_task < (BAUD_CNT_MAX + 1); j_task = j_task + 1) begin
                    @(posedge sys_clk);
                end
            end
		end
	endtask
    
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    integer i;                                              // test loop count
    initial begin
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // initialize
        //sys_clk = 0;
        //sdram_clk = 0;
        rst_n = 1;
        tx_tb = 1;
        i = 0;
        seed = SEED;

        #(T_SYS*5);
        #(DELAY);
        rst_n = 0;

        for (i = 0 ; i < 10; i = i + 1) @(posedge sdram_clk);
        #(DELAY);
        rst_n = 1;
        
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
		// stimulus start
        $display();
        $display("Stimulus start >>>");
        $display("------------------------------------------------");

        //// test initialization
        #100_000;   // 100us for initialization
        for (i = 0 ; i < 15; i = i + 1) @(posedge sys_clk);
   
        
        #1_000;
        //// test auto-refresh 3 times
        //#50_000;

        wait (aref_done_out);
        #1_000;
        wait (aref_done_out);
        #1_000;
        wait (aref_done_out);
        #1_000;

        
        #10_000;
        //// 1st test write, write data & address directly given from SDRAM controller before FIFO design finish
        @(posedge sys_clk);
        for (i = 0 ; i < 5; i = i + 1) begin
            rand_in_gen(i);
        end
        
        #20_000;
        //// 1st test read, read address directly given from SDRAM controller before FIFO design finish      
        @(posedge sys_clk);
        #(DELAY);
        rand_in_gen(5); // generate 8-bit data frame READ command serial packet
        #4_500_000;
 
/*
        #10_000;
        //// 2nd test write, write data & address directly given from SDRAM controller before FIFO design finish
        for (i = 0 ; i < 5; i = i + 1) begin
            rand_in_gen(i);
        end
        
        #20_000;
        //// 2nd test read, read address directly given from SDRAM controller before FIFO design finish      
        @(posedge sys_clk);
        #(DELAY);
        rand_in_gen(5); // generate 8-bit data frame READ command serial packet
        
        #5_000_000;
*/
        
        $finish();
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------     
	// fsdb dump
  	initial begin
`ifdef GATE_SIM
		$sdf_annotate("./mapped/top_syn.sdf", inst_top);
		$fsdbDumpfile("./waveform/top_syn.fsdb");
`else
		$fsdbDumpfile("./waveform/top.fsdb");
`endif
  		$fsdbDumpvars();
	end


endmodule
