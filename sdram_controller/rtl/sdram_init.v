/**************************************************************
 * Module name: sdram_init (Success!!)
 *
 * Features:
 *	1. Do initialization of SDRAM
 *    2. Require at least 10 cycle commands latency for initialization  
 *    3. Use sequential and burst length = 4
 *    4. Use 3 cycles for CAS latency
 *    5. Use Burst read and burst write
 *
 * Procedures:
 *    1. Power-up, then wait 100us
 *    2. Precharge all banks, then wait t_RP
 *    3. Auto-refresh, then wait t_RC
 *    4. Repeat step 3 at least 1 time
 *    5. Load mode register
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/
`timescale 1ns / 100ps
//`define SIM                                                 // Only used in Vivado, deleted in Linux, simulation only for small baud count 


module sdram_init (
    sdram_clk,
    rst_n,
    cmd_reg,
    sdram_addr,
    init_done
    );
    
    //`include "/home/m110/m110063556/interview/sdram_controller/rtl/sdr_parameters.vh"
    `include "sdr_parameters.vh"
    
    localparam WAIT100 = 13333;                             // wait 100us after power-up, count 13333(0x3415) times for system clock
    localparam WAIT100_WIDTH = 15;                          // 15-bit to count 13333
    localparam T_RP = 3;                                    // 3 cycle for tRP = 20.0 ns
    localparam T_RFC = 9;                                   // 9 cycle for tRFC = 66.0 ns
    localparam T_MRD = 2;                                   // 2 cycle for tMRD, fixed to 2 cycle no matter what frequency sdram_clk is
    
    localparam  NOP = 4'b0111;                              // NOP command
    localparam  PRE = 4'b0010;                              // PRECHARGE command
    localparam  AREF = 4'b0001;                             // AUTO-REFRESH command
    localparam  LMR = 4'b0000;                              // LOAD MODE REGISTER command
    
    input                           sdram_clk;              // use sdram clock
    input                           rst_n;                  // use system negative triggered reset 
    output  [3:0]                   cmd_reg;                // mode register: {CS_n, RAS_n, CAS_n, WE_n}
    output  [ADDR_BITS-1:0]         sdram_addr;             // sdram address, A11 ~A0
    output                          init_done;              // indicate SDRAM initialization done
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Power-up after reset, then wait 100us
    reg     [WAIT100_WIDTH-1:0]     pup_cnt;                // count 100us after power-up
    wire                            pup_done;               // indicate 100us wait is done
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n)     pup_cnt <= 0;
        else begin
            if (~pup_done)  pup_cnt <= pup_cnt + 1;
            else            pup_cnt <= pup_cnt;
        end
    end
    
    assign pup_done = (pup_cnt >= WAIT100) ? 1 : 0;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // step 2 ~step 4, and set output
    localparam T_RP1 = 1 + T_RP;                            // cycles for first AREF
    localparam T_RP_RFC = 1 + T_RP + T_RFC;                 // cycles for second AREF
    localparam T_RP_RFC2 = 1 + T_RP + T_RFC + T_RFC;        // cycles for LMR
    localparam T_LMR = 1 + T_RP + T_RFC + T_RFC + T_MRD;    // cycles after LMR done
    
    reg     [5:0]                   cmd_cnt;                // count initialize latency cycles required start from precharge
    reg     [3:0]                   cmd_reg_reg;            // mode register: {CS_n, RAS_n, CAS_n, WE_n}
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) cmd_cnt <= 0;
        else begin
            if ((pup_done == 1) && (init_done == 0)) begin
                        cmd_cnt <= cmd_cnt + 1;
            end
            else        cmd_cnt <= cmd_cnt;
        end
    end   
    
    always @(*) begin
        if (pup_done) begin
            case (cmd_cnt)
                0:          cmd_reg_reg = NOP;
                1:          cmd_reg_reg = PRE;
                T_RP1:      cmd_reg_reg = AREF;
                T_RP_RFC:   cmd_reg_reg = AREF;
                T_RP_RFC2:  cmd_reg_reg = LMR;
                default:    cmd_reg_reg = NOP;
            endcase
        end
        else                cmd_reg_reg = NOP;
    end
     
    assign cmd_reg = cmd_reg_reg;
    assign sdram_addr = (cmd_reg_reg == LMR) ? 12'b0000_0011_0010 : 12'b0100_0000_0000;
    assign init_done = (cmd_cnt > T_LMR) ? 1 : 0;
    
endmodule
