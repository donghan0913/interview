/**************************************************************
 * Module name: sdram_aref
 *
 * Features:
 *	1. Doing AUTO-REFRESH for one row
 *
 * Descriptions:
 *    1.
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/


module sdram_aref(
    sys_clk,
    sys_rst_n,
    aref_en,
    init_done,
    aref_req,
    aref_done,
    aref_cmd,
    sdram_addr
    );

    `include "/home/m110/m110063556/interview/sdram_controller/rtl/sdr_parameters.vh"
    //`include "sdr_parameters.vh"
    
    localparam  NOP = 4'b0111;                              // NOP command
    localparam  PRE = 4'b0010;                              // PRECHARGE command
    localparam  AREF = 4'b0001;                             // AUTO-REFRESH command
    
    localparam T_RP = 3;                                    // 3 cycle for tRP = 20.0 ns
    localparam T_RFC = 9;                                   // 9 cycle for tRFC = 66.0 ns
    
    input                           sys_clk;                // system clock
    input                           sys_rst_n;              // system negative triggered reset
    input                           aref_en;                // AUTO-REFRESH enable
    input                           init_done;              // indicate INITIALIZE done
    output                          aref_req;               // request to arbiter module, after 15us count done, and pull-up after until next "aref_en"
    output                          aref_done;              // indicate AUTO-REFRESH done after tRFC, pull-up 
    output  [3:0]                   aref_cmd;               // mode register: {CS_n, RAS_n, CAS_n, WE_n}
    output  [ADDR_BITS-1:0]         sdram_addr;             // sdram address, A11 ~A0
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // count 15us to request next AUTO-REFRESH command
    localparam DELAY_15us = 2000;                           // 2000 cycles for 15us for AURO-REFRESH
    reg     [12:0]                   aref_cnt;              // count 15us to send next AUTO-REFRESH reqire
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) aref_cnt <= 0;
        else begin
            if ((init_done == 1) && (aref_cnt != DELAY_15us)) begin
                        aref_cnt <= aref_cnt + 1;
            end
            else        aref_cnt <= 0;
        end        
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // do AUTO-REFRESH for tRFC time
    reg                             aref_flag;              // indicate refresh is working, need tRFC to finish
    reg     [4:0]                   cmd_cnt;                // count initialize latency cycles required start from precharge
    reg     [3:0]                   cmd_reg_reg;            // mode register: {CS_n, RAS_n, CAS_n, WE_n}
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) aref_flag <= 0;
        else begin
            if (aref_en) begin
                        aref_flag <= 1;
            end
            else if (aref_done) begin
                        aref_flag <= 0;
            end
            else        aref_flag <= aref_flag;
        end
    end
    
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) cmd_cnt <= 0;
        else begin
            if (aref_flag) begin
                        cmd_cnt <= cmd_cnt + 1;
            end
            else        cmd_cnt <= 0;
        end
    end  
    
    localparam T_RP1 = 1 + T_RP;
    always @(*) begin
            case (cmd_cnt)
                0:          cmd_reg_reg = NOP;
                1:          cmd_reg_reg = PRE; // need start with 1, otherwise will keep precharge after AREF, waste power
                T_RP1:      cmd_reg_reg = AREF;
                default:    cmd_reg_reg = NOP;
            endcase
        //end
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // output
    localparam T_AREF = T_RP + T_RFC;                       // 3+9 cycles after AREF done
    
    assign aref_done = (cmd_cnt == T_AREF) ? 1 : 0;
    assign aref_req = (aref_cnt >= DELAY_15us) ? 1 : 0;
    assign aref_cmd = cmd_reg_reg;
    assign sdram_addr = 12'b0100_0000_0000;
    
    
endmodule
