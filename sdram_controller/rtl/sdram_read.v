/**************************************************************
 * Module name: sdram_read
 *
 * Features:
 *	1. Doing READ without AUTO-PRECHARGE
 *
 * Descriptions:
 *    1.
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/


module sdram_read(
    sdram_clk,
    rst_n,
    rd_trig,
    aref_req,
    rd_en,
    rd_addr,
    data_in,
    rd_req,
    rd_cmd,  
    addr_out,
    ba_out,
    go_aref,
    rd_done_all,
    rfifo_wr_en,
    data_out
    );

	//`include "/home/m110/m110063556/interview/sdram_controller/rtl/sdr_parameters.vh"
    `include "sdr_parameters.vh"    
    
    input                           sdram_clk;                // system clock
    input                           rst_n;              // system negative triggered reset    
    input                           rd_trig;                // rerad trigger
    input                           aref_req;               // refresh request from refresh block
    input                           rd_en;                  // read enable
    input   [ADDR_BITS-1:0]         rd_addr;                // sdram address for read from testbench, A11 ~A0
    input   [DQ_BITS-1:0]           data_in;                // data read from SDRAM
    output                          rd_req;                 // read request send to arbiter
    output  [3:0]                   rd_cmd;                 // mode register for read: {CS_n, RAS_n, CAS_n, WE_n}
    output  [ADDR_BITS-1:0]         addr_out;               // generate sdram address for read, A11 ~A0
    output  [BA_BITS-1:0]           ba_out;                 // for test, generate bank address
    output                          go_aref;                // finish a burst read and go to AUTO-REFRESH for aref_req
    output                          rd_done_all;            // indicate all read operation finish
    output                          rfifo_wr_en;            // generate data write enable for rFIFO
    output  [7:0]                   data_out;               // send read data from SDRAM through READ module to testbench

    localparam  CMD_NOP = 4'b0111;                          // NOP command
    localparam  CMD_PRE = 4'b0010;                          // PRECHARGE command
    localparam  CMD_AREF = 4'b0001;                         // AUTO-REFRESH command
    localparam  CMD_ACT = 4'b0011;                          // ACTIVATE command
    localparam  CMD_RD = 4'b0101;                           // READ command
    
    localparam T_RCD    = 3;                                // 3 cycle for tRCD 20 ns for ACT min latency
    localparam T_RP     = 3;                                // 3 cycle for tRP 20 ns for PRE min latency
    localparam CAS      = 3;                                // 3 cycle for CAS latency due to LMR setting
    
    localparam COL_ADDR_MAX = 3/*511*/;                          // for col_addr in one row count to max
    localparam ROW_MAX = 0/*1*/;                                 // assume consecutive row number read for test, (consecutive row number - 1)

    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM CS Logic
    localparam RD_IDLE  = 3'b000;                           // FSM state, IDLE state while no READ command
    localparam RD_REQ   = 3'b001;                           // FSM state, REQ state to wait arbiter send enable signal
    localparam RD_ACT   = 3'b010;                           // FSM state, ACT state to activate row
    localparam RD_READ  = 3'b011;                           // FSM state, READ state to read burst
    localparam RD_PRE   = 3'b100;                           // FSM state, PRE state to do precharge after read
    reg     [2:0]               state;                      // current state of FSM
    reg     [2:0]               n_state;                    // next state of FSM
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) state <= RD_IDLE;
        else            state <= n_state;
    end    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM NS Logic
    reg     [3:0]               act_cnt;                    // count when clock frequency is large at ACT state
    reg                         act_done;                   // indicate ACTIVATE is done
    reg     [ROW_BITS-1:0]      addr_row;                   // row address
    wire    [COL_BITS-1:0]      addr_col;                   // column address
    reg     [1:0]               burst_cnt;                  // count burst from 0~3
    reg                         burst_done;                 // indicate burst count to 3
    reg     [6:0]               col_cnt;                    // count column address to finish one row reading
    reg                         col_done;                   // indicate one row finish
    reg     [ROW_BITS-1:0]      row_cnt;                    // count from 0 to last row read
    reg                         row_done;                   // indicate row count finish
    reg                         rd_flag;                    // indicate entire READ function is working
    reg     [3:0]               break_cnt;                  // count when clock frequency is large at PRE state
    reg                         pre_done;                   // indicate PRECHARGE state is done
    wire    [ROW_BITS-1:0]      row_max;                    // indicate max consecutive row read number
    reg                         aref_req_t;                 // keep high if refresh request, and pull down until finish burst

    always @(*) begin
        case(state)
            RD_IDLE:    if (rd_trig == 1) begin
                                n_state = RD_REQ;
                        end
                        else    n_state = RD_IDLE;
            RD_REQ:     if (rd_en == 1) begin
                                n_state = RD_ACT;
                        end
                        else    n_state = RD_REQ;
            RD_ACT:     if (act_done == 1) begin
                                n_state = RD_READ;
                        end
                        else    n_state = RD_ACT;
            RD_READ:    if ((burst_done == 1) && (aref_req_t == 1)) begin
                                n_state = RD_REQ;
                        end
                        else if (col_done == 1) begin
                                n_state = RD_PRE;
                        end
                        else    n_state = RD_READ;
            RD_PRE:     if (pre_done == 1) begin
                            if (rd_done_all) begin
                                n_state = RD_IDLE;
                            end
                            else begin
                                n_state = RD_ACT;
                            end
                        end
                        else    n_state = RD_PRE;
            default:            n_state = RD_IDLE;
        endcase
    end

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Other Internal Logic
    //// ACT signals
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) act_cnt <= 0;
        else begin
            if (state == RD_ACT) begin
                        act_cnt <= act_cnt + 1;
            end
            else        act_cnt <= 0;
        end
    end

    always @(*) begin
        if (act_cnt == T_RCD) begin
                        act_done = 1;
        end
        else            act_done = 0;
    end
    
    //// PRE signals
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) break_cnt <= 0;
        else begin
            if (state == RD_PRE) begin
                        break_cnt <= break_cnt + 1;
            end
            else        break_cnt <= 0;
        end
    end
    
    always @(*) begin
        if (break_cnt == T_RP) begin
                        pre_done = 1;
        end
        else            pre_done = 0;
    end
    
    //// burst signals
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) burst_cnt <= 0;
        else begin
            if (state == RD_READ) begin
                        burst_cnt <= burst_cnt + 1;
            end
            else        burst_cnt <= 0;
        end
    end
    
    always @(*) begin
        if (burst_cnt == 3) begin
                        burst_done = 1;
        end
        else            burst_done = 0;
    end
    
    //// column signals
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) col_cnt <= 0;
        else begin
            if (burst_cnt == 3) begin
                if (addr_col == COL_ADDR_MAX) begin
                        col_cnt <= 0;
                end
                else    col_cnt <= col_cnt + 1;
            end
            else        col_cnt <= col_cnt;
        end
    end
    
    always @(*) begin
        if (addr_col == COL_ADDR_MAX) begin
                        col_done = 1;
        end
        else            col_done = 0;
    end
    
    assign addr_col = {col_cnt, burst_cnt};

    //// row signals
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) row_cnt <= 0;
        else begin
            if (state == RD_IDLE) begin
                        row_cnt <= 0;
            end
            else if (col_done == 1) begin
                        row_cnt <= row_cnt + 1;
            end
            else        row_cnt <= row_cnt;
        end
    end
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) row_done <= 0;
        else begin
            if ((addr_col == COL_ADDR_MAX) && (row_cnt == row_max)) begin
                        row_done <= 1;
            end
            else        row_done <= 0;
        end
    end
   
    assign row_max = ROW_MAX;
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) addr_row <= 0;
        else begin
            if (state == RD_REQ) begin
                        addr_row <= rd_addr;
            end
            else        addr_row <= addr_row;
        end
    end
    
    //// aref handling
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) aref_req_t <= 0;
        else begin
            if (aref_req == 1) begin
                        aref_req_t <= 1;
            end
            else if ((act_done == 1) || (state == RD_IDLE)) begin
                        aref_req_t <= 0;
            end
            else        aref_req_t <= aref_req_t;
        end
    end
    
    //// others
    reg                         row_done_t;                 // indicate row count finish with one more cycle delay
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) row_done_t <= 0;
        else if (row_done == 1) begin
                        row_done_t <= 1;
        end
        else if (state == RD_PRE) begin
                        row_done_t <= row_done_t;
        end
        else            row_done_t <= 0;
    end
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) rd_flag <= 0;
        else begin
            if ((rd_trig == 1) && (rd_flag == 0)) begin
                        rd_flag <= 1;
            end
            else if (state == RD_PRE) begin
                if ((row_done_t == 1) && (pre_done == 1)) begin
                        rd_flag <= 0;
                end
                else    rd_flag <= rd_flag;
            end
            else        rd_flag <= rd_flag;
        end
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM Output Logic
    reg     [3:0]                   rd_cmd_reg;             // mode register for read: {CS_n, RAS_n, CAS_n, WE_n}
    reg     [ADDR_BITS-1:0]         addr_out_reg;           // sdram address for read, A11 ~A0
    reg     [DQ_BITS-1:0]           data_out_reg;           // generate test data for read
    reg                             rd_done_all_reg;        // indicate entire read finish
    reg                             go_aref_reg;            // finish a burst read and go to AUTO-REFRESH for aref_req
    reg     [1:0]                   cas_cnt;                // count CAS latency cycles for for rfifo_wr_en asserted correctly
    reg                             rfifo_wr_en_reg;
    reg                             rfifo_wr_en_reg_t1;
    reg                             rfifo_wr_en_reg_t2;
    reg                             rfifo_wr_en_reg_t3;
    reg                             rfifo_wr_en_reg_t4;
    
    always @(*) begin
        case (state)
            RD_ACT:     addr_out_reg = row_cnt; // assign row_cnt is only for test, need change to addr_row
            RD_READ:    addr_out_reg = {3'b000, addr_col};             
            RD_PRE:     addr_out_reg = 12'b0100_0000_0000;
            default:    addr_out_reg = 0;
        endcase
    end
    
    always @(*) begin
        case (state)
            RD_IDLE:            rd_cmd_reg = CMD_NOP;
            RD_REQ:             rd_cmd_reg = CMD_NOP;
            RD_ACT:     if (act_cnt == 0) begin
                                rd_cmd_reg = CMD_ACT;
                        end
                        else    rd_cmd_reg = CMD_NOP;
            RD_READ:    if (burst_cnt == 0) begin
                                rd_cmd_reg = CMD_RD;
                        end
                        else    rd_cmd_reg = CMD_NOP;               
            RD_PRE:     if (break_cnt == 0) begin
                                rd_cmd_reg = CMD_PRE;
                        end
                        else    rd_cmd_reg = CMD_NOP;
            default:            rd_cmd_reg = CMD_NOP;
        endcase
    end
    
    always @(*) begin
        if ((row_done_t == 1) && (pre_done == 1)) begin
                    rd_done_all_reg = 1;
        end
        else        rd_done_all_reg = 0;
    end
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) go_aref_reg <= 0;
        else begin
            if ((burst_done == 1) && (aref_req_t == 1)) begin
                        go_aref_reg <= 1;
            end
            else        go_aref_reg <= 0;
        end
    end
    
    always @(*) begin
        if ((act_done == 1) || (state == RD_READ)) begin
                        rfifo_wr_en_reg = 1;
        end
        else            rfifo_wr_en_reg = 0;
    end
    
    // delay CAS latency to let rFIFO catch data
    always @(posedge sdram_clk) begin
                        rfifo_wr_en_reg_t1 <= rfifo_wr_en_reg;
                        rfifo_wr_en_reg_t2 <= rfifo_wr_en_reg_t1;
                        rfifo_wr_en_reg_t3 <= rfifo_wr_en_reg_t2;
                        rfifo_wr_en_reg_t4 <= rfifo_wr_en_reg_t3;
    end
    
    assign rd_req = (state == RD_REQ) ? 1 : 0;
    assign rd_done_all = rd_done_all_reg;
    assign ba_out = 2'b00;
    assign rd_cmd = rd_cmd_reg;
    assign addr_out = addr_out_reg;
    assign go_aref = go_aref_reg;    
    assign data_out = data_in[7:0];
    assign rfifo_wr_en = rfifo_wr_en_reg_t4 & rfifo_wr_en_reg_t3;
    
    
endmodule
