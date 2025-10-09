/**************************************************************
 * Module name: sdram_write
 *
 * Features:
 *	1. Doing WRITE without AUTO-PRECHARGE
 *
 * Descriptions:
 *    1.
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/


module sdram_write(
    sdram_clk,
    rst_n,
    wr_trig,
    aref_req,
    wr_en,
    wr_addr,
    wr_data,
    wr_req,
    wr_cmd,  
    addr_out,  
    data_out,
    ba_out,
    go_aref,
    wr_done_all,
    wfifo_rd_en
    );
    
	//`include "/home/m110/m110063556/interview/sdram_controller/rtl/sdr_parameters.vh"
    `include "sdr_parameters.vh"    
    
    input                           sdram_clk;              // use sdram clock
    input                           rst_n;                  // system negative triggered reset    
    input                           wr_trig;                // write trigger
    input                           aref_req;               // refresh request from refresh block
    input                           wr_en;                  // write enable
    input   [ADDR_BITS-1:0]         wr_addr;                // sdram address for write from testbench, A11 ~A0
    input   [7:0]                   wr_data;                // write data from wFIFO, which is 8-bit due to UART
    output                          wr_req;                 // write request send to arbiter
    output  [3:0]                   wr_cmd;                 // mode register for write: {CS_n, RAS_n, CAS_n, WE_n}
    output  [ADDR_BITS-1:0]         addr_out;               // generate sdram address for write, A11 ~A0
    output  [DQ_BITS-1:0]           data_out;               // send write data from testbench through WRITE module to SDRAM
    output  [BA_BITS-1:0]           ba_out;                 // for test, generate bank address
    output                          go_aref;                // finish a burst write and go to AUTO-REFRESH for aref_req
    output                          wr_done_all;            // indicate all write operation finish
    output                          wfifo_rd_en;            // generate data read enable for wFIFO

    localparam  CMD_NOP = 4'b0111;                          // NOP command
    localparam  CMD_PRE = 4'b0010;                          // PRECHARGE command
    localparam  CMD_AREF = 4'b0001;                         // AUTO-REFRESH command
    localparam  CMD_ACT = 4'b0011;                          // ACTIVATE command
    localparam  CMD_WR = 4'b0100;                           // WRITE command
    
    localparam T_RCD    = 3;                                // 3 cycle for tRCD 20 ns for ACT min latency
    localparam T_RP     = 3;                                // 3 cycle for tRP 20 ns for PRE min latency
    localparam T_WR     = 2;                                // 2 cycle for tWR 15 ns min latency between last write burst cycle and PRE state
    
    localparam COL_ADDR_MAX = 3/*511*/;                          // for col_addr in one row count to max
    localparam ROW_MAX = 0/*1*/;                                 // assume consecutive row number write for test, (consecutive row number - 1)

    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM CS Logic
    localparam WR_IDLE  = 3'b000;                           // FSM state, IDLE state while no WRITE command
    localparam WR_REQ   = 3'b001;                           // FSM state, REQ state to wait arbiter send enable signal
    localparam WR_ACT   = 3'b010;                           // FSM state, ACT state to activate row
    localparam WR_WRITE = 3'b011;                           // FSM state, WRITE state to write burst
    localparam WR_PRE   = 3'b100;                           // FSM state, PRE state to do precharge after write
    reg     [2:0]               state;                      // current state of FSM
    reg     [2:0]               n_state;                    // next state of FSM
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) state <= WR_IDLE;
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
    reg     [6:0]               col_cnt;                    // count column address to finish one row writing
    reg                         col_done;                   // indicate one row finish
    reg     [ROW_BITS-1:0]      row_cnt;                    // count from 0 to last row write
    reg                         row_done;                   // indicate row count finish
    reg                         wr_flag;                    // indicate entire WRITE function is working
    reg     [3:0]               break_cnt;                  // count when clock frequency is large at PRE state
    reg                         pre_done;                   // indicate PRECHARGE state is done
    wire    [ROW_BITS-1:0]      row_max;                    // indicate max consecutive row write number
    reg                         aref_req_t;                 // keep high if refresh request, and pull down until finish burst
    reg     [3:0]               twr_cnt;                    // T_WR counter
    reg                         twr_done;                   // indicate twr count finish

    always @(*) begin
        case(state)
            WR_IDLE:    if (wr_trig == 1) begin
                                n_state = WR_REQ;
                        end
                        else    n_state = WR_IDLE;
            WR_REQ:     if (wr_en == 1) begin
                                n_state = WR_ACT;
                        end
                        else    n_state = WR_REQ;
            WR_ACT:     if (act_done == 1) begin
                                n_state = WR_WRITE;
                        end
                        else    n_state = WR_ACT;
            WR_WRITE:   if (twr_done == 1) begin
                            if ((burst_done == 1) && (aref_req_t == 1)) begin
                                n_state = WR_REQ;
                            end
                            else begin
                                n_state = WR_PRE;
                            end
                        end
                        else    n_state = WR_WRITE;
            WR_PRE:     if (pre_done == 1) begin
                            if (wr_done_all) begin
                                n_state = WR_IDLE;
                            end
                            else begin
                                n_state = WR_ACT;
                            end
                        end
                        else    n_state = WR_PRE;
            default:            n_state = WR_IDLE;
        endcase
    end

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Other Internal Logic
    //// ACT signals
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) act_cnt <= 0;
        else begin
            if (state == WR_ACT) begin
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
            if (state == WR_PRE) begin
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
            if (twr_cnt != 0) begin
                        burst_cnt <= 0;
            end
            else if (state == WR_WRITE) begin
                        burst_cnt <= burst_cnt + 1;
            end
            else        burst_cnt <= 0;
        end
    end
    
    always @(*) begin
        if ((burst_cnt == 3) || (twr_cnt != 0)) begin
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
            if (state == WR_IDLE) begin
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
            else if (twr_cnt != 0) begin
                        row_done <= row_done;
            end
            else        row_done <= 0;
        end
    end
   
    assign row_max = ROW_MAX;
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) addr_row <= 0;
        else begin
            if (state == WR_REQ) begin
                        addr_row <= wr_addr;
            end
            else        addr_row <= addr_row;
        end
    end
    
    //// twr signals
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) twr_cnt <= 0;
        else begin
            if ((col_done == 1) || ((aref_req_t == 1) && (burst_cnt == 3))) begin
                        twr_cnt <= twr_cnt + 1;
            end
            else if ((twr_cnt != 0) && (twr_cnt != T_WR)) begin
                        twr_cnt <= twr_cnt + 1;
            end
            else        twr_cnt <= 0;
        end
    end
    
    always @(*) begin
        if (twr_cnt == T_WR) begin
                        twr_done = 1;
        end
        else            twr_done = 0;
    end
    
    //// aref handling
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) aref_req_t <= 0;
        else begin
            if (aref_req == 1) begin
                        aref_req_t <= 1;
            end
            else if ((act_done == 1) || (state == WR_IDLE)) begin
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
        else if (state == WR_PRE) begin
                        row_done_t <= row_done_t;
        end
        else            row_done_t <= 0;
    end

    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) wr_flag <= 0;
        else begin
            if ((wr_trig == 1) && (wr_flag == 0)) begin
                        wr_flag <= 1;
            end
            else if (state == WR_PRE) begin
                if ((row_done_t == 1) && (pre_done == 1)) begin
                        wr_flag <= 0;
                end
                else    wr_flag <= wr_flag;
            end
            else        wr_flag <= wr_flag;
        end
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM Output Logic
    reg     [3:0]                   wr_cmd_reg;             // mode register for write: {CS_n, RAS_n, CAS_n, WE_n}
    reg     [ADDR_BITS-1:0]         addr_out_reg;           // sdram address for write, A11 ~A0
    //reg     [DQ_BITS-1:0]           data_out_reg;           // generate test data for write
    reg                             wr_done_all_reg;        // indicate entire write finish
    reg                             go_aref_reg;            // finish a burst write and go to AUTO-REFRESH for aref_req
    
    always @(*) begin
        case (state)
            WR_ACT:     addr_out_reg = row_cnt; // assign row_cnt is only for test, need change to addr_row later
            WR_WRITE:   addr_out_reg = {3'b000, addr_col};             
            WR_PRE:     addr_out_reg = 12'b0100_0000_0000;
            default:    addr_out_reg = 0;
        endcase
    end
    
    always @(*) begin
        case (state)
            WR_IDLE:            wr_cmd_reg = CMD_NOP;
            WR_REQ:             wr_cmd_reg = CMD_NOP;
            WR_ACT:     if (act_cnt == 0) begin
                                wr_cmd_reg = CMD_ACT;
                        end
                        else    wr_cmd_reg = CMD_NOP;
            WR_WRITE:   if ((burst_cnt == 0) && (twr_cnt == 0)) begin
                                wr_cmd_reg = CMD_WR;
                        end
                        else    wr_cmd_reg = CMD_NOP;               
            WR_PRE:     if (break_cnt == 0) begin
                                wr_cmd_reg = CMD_PRE;
                        end
                        else    wr_cmd_reg = CMD_NOP;
            default:            wr_cmd_reg = CMD_NOP;
        endcase
    end
/*    
    always @(*) begin
        case (burst_cnt)
            0:          data_out_reg = 3;
            1:          data_out_reg = 5;
            2:          data_out_reg = 7;
            3:          data_out_reg = 9;
            default:    data_out_reg = 0;
        endcase
    end
*/    
    always @(*) begin
        if ((row_done_t == 1) && (pre_done == 1)) begin
                    wr_done_all_reg = 1;
        end
        else        wr_done_all_reg = 0;
    end
    
     always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) go_aref_reg <= 0;
        else begin
            if ((twr_done == 1) && (burst_done == 1) && (aref_req_t == 1)) begin
                        go_aref_reg <= 1;
            end
            else        go_aref_reg <= 0;
        end
    end
    
    assign wr_req = (state == WR_REQ) ? 1 : 0;
    assign wr_done_all = wr_done_all_reg;
    assign ba_out = 2'b00;
    assign wr_cmd = wr_cmd_reg;
    assign addr_out = addr_out_reg;
    assign go_aref = go_aref_reg;    
    
    assign wfifo_rd_en = (act_done == 1) || (state == WR_WRITE);
    assign data_out = wr_data;


endmodule
