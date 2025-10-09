/**************************************************************
 * Module name: sdram_top
 *
 * Features:
 *	1. SDRAM controller main part
 *    2. Included modules: sdram_init, sdram_read, sdram_write, auto_refresh
 *    3. Connect with SDRAM and user logic (testbench)
 *
 * Descriptions:
 *    1. Need to use sdram_clk
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/
`timescale 1ns / 100ps
//`define SIM                                                 // Only used in Vivado, deleted in Linux, simulation only for small baud count 


module sdram_top(
    sdram_clk,
    rst_n,
    wr_trig,
    rd_trig,
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
    // FIFO
    wfifo_rd_data, // input
    wfifo_rd_en,
    rfifo_wr_data,
    rfifo_wr_en
    );
    
    //`include "/home/m110/m110063556/interview/sdram_controller/rtl/sdr_parameters.vh"
    `include "sdr_parameters.vh"

    input                           sdram_clk;              // use SDRAM clock
    input                           rst_n;                  // use system negative triggered reset, thus need reset synchronizer
    input                           wr_trig;                // WRITE operation trigger
    input                           rd_trig;                // READ operation trigger
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

    // FIFO
    input   [7:0]                   wfifo_rd_data;          // sdram write data from wFIFO  
    output                          wfifo_rd_en;            // generate data read enable to wFIFO from WRITE module
    output  [7:0]                   rfifo_wr_data;          // sdram read data out to rFIFO  
    output                          rfifo_wr_en;            // generate data write enable to rFIFO from READ module
    

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    //// sdram initialize
    wire    [3:0]                   init_cmd;
    wire    [ADDR_BITS-1:0]         init_addr;              // SDRAM address depends on initialization
    wire                            init_done;
    sdram_init inst_sdram_init(
        .sdram_clk(sdram_clk),
        .rst_n(rst_n),
        .cmd_reg(init_cmd),
        .sdram_addr(init_addr),
        .init_done(init_done)
        );
    
    //// sdram auto-refresh
    wire                            aref_req;               // request from AUTO-REFRESH function
    wire                            aref_done;              // indicate AUTO-REFRESH done
    wire                            aref_en;                // AUTO-REFRESH enable
    wire    [3:0]                   aref_cmd;
    wire    [ADDR_BITS-1:0]         aref_addr;              // SDRAM address depends on auto-refresh
    sdram_aref inst_sdram_aref(
        .sdram_clk(sdram_clk),
        .rst_n(rst_n),
        .aref_en(aref_en),
        .init_done(init_done),
        .aref_req(aref_req),
        .aref_done(aref_done),
        .aref_cmd(aref_cmd),
        .sdram_addr(aref_addr)
        );       
    
    //// sdram write
    wire                            wr_req;                 // request from WRITE function
    wire                            wr_en;                  // WRITE enable
    wire    [ADDR_BITS-1:0]         wr_addr;                // SDRAM address depends on write
    wire    [3:0]                   wr_cmd;                 // command generate by WRITE module
    wire    [ADDR_BITS-1:0]         wr_addr_out;            // SDRAM address depends on write
    wire    [DQ_BITS-1:0]           wr_data_out;            // generate test data for write  
    wire    [BA_BITS-1:0]           wr_ba_out;              // sdram bank address for write
    wire                            wr_go_aref;             // finish a burst write and go to AUTO-REFRESH for aref_req
    wire                            wr_done_all;            // indicate all write operation finish
    sdram_write inst_sdram_write(
        .sdram_clk(sdram_clk),
        .rst_n(rst_n),
        .wr_trig(wr_trig),
        .aref_req(aref_req),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wfifo_rd_data),        
        .wr_req(wr_req),
        .wr_cmd(wr_cmd),
        .addr_out(wr_addr_out),
        .data_out(wr_data_out),
        .ba_out(wr_ba_out),
        .go_aref(wr_go_aref),
        .wr_done_all(wr_done_all),
        .wfifo_rd_en(wfifo_rd_en)
        );
        
    //// sdram read
    wire                            rd_en;                  // READ enable
    wire    [ADDR_BITS-1:0]         rd_addr;                // SDRAM address depends on read
    wire                            rd_req;                 // request from READ function
    wire    [3:0]                   rd_cmd;                 // command generated by READ module
    wire    [ADDR_BITS-1:0]         rd_addr_out;            // generate sdram address for read, A11 ~A0
    wire    [BA_BITS-1:0]           rd_ba_out;              // for test, generate bank address
    wire                            rd_go_aref;             // finish a burst read and go to AUTO-REFRESH for aref_req
    wire                            rd_done_all;            // indicate READ done
    sdram_read inst_sdram_read(
        .sdram_clk(sdram_clk),
        .rst_n(rst_n),
        .rd_trig(rd_trig),
        .aref_req(aref_req),
        .rd_en(rd_en),
        .rd_addr(rd_addr),
        .data_in(sdram_dq),
        .rd_req(rd_req),
        .rd_cmd(rd_cmd),  
        .addr_out(rd_addr_out),
        .ba_out(rd_ba_out),
        .go_aref(rd_go_aref),
        .rd_done_all(rd_done_all),
        .rfifo_wr_en(rfifo_wr_en),
        .data_out(rfifo_wr_data)
        );    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // arbiter FSM CS Logic
    localparam IDLE     = 3'b000;                           // FSM state, IDLE state after INITIALIZE
    localparam ARBIT    = 3'b001;                           // FSM state, determine to whether AUTO-REFRESH or READ or WRITE
    localparam AREF     = 3'b110;                           // FSM state, AUTO-REFRESH function
    localparam READ     = 3'b010;                           // FSM state, READ function
    localparam WRITE    = 3'b100;                           // FSM state, WRITE function
    reg     [2:0]               state;                      // current state of FSM
    reg     [2:0]               n_state;                    // next state of FSM
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) state <= IDLE;
        else            state <= n_state;
    end    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // arbiter FSM NS Logic
    always @(*) begin
        case(state)
            IDLE:       n_state =   (init_done)     ?   ARBIT : IDLE;
            ARBIT:      n_state =   (aref_en)       ?   AREF  :
                                    (wr_en)         ?   WRITE :
                                    (rd_en)         ?   READ  : ARBIT;
            AREF:       n_state =   (aref_done)     ?   ARBIT : AREF;
            READ:       n_state =   (rd_go_aref)    ?   ARBIT : 
                                    (rd_done_all)   ?   ARBIT : READ;
            WRITE:      n_state =   (wr_go_aref)    ?   ARBIT :  
                                    (wr_done_all)   ?   ARBIT : WRITE;
            default:    n_state =                       IDLE;
        endcase
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // arbiter FSM output Logic
    reg                             aref_en_reg;            // AUTO-REFRESH enable
    reg                             read_en_reg;            // READ enable
    reg                             write_en_reg;           // WRITE enable
    reg                             aref_req_t;             // request from AUTO-REFRESH function
    
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) aref_en_reg <= 0;
        else begin
            if ((state == ARBIT) && (aref_req_t == 1)) begin
                        aref_en_reg <= 1;
            end
            else        aref_en_reg <= 0;
        end
    end

    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) write_en_reg <= 0;
        else begin
            if ((state == ARBIT) && (aref_req_t == 0) && (wr_req == 1)) begin
                        write_en_reg <= 1;
            end
            else        write_en_reg <= 0;
        end
    end

    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) read_en_reg <= 0;
        else begin
            if ((state == ARBIT) && (aref_req_t == 0) && (wr_en == 0) && (rd_req == 1)) begin
                        read_en_reg <= 1;
            end
            else        read_en_reg <= 0;
        end
    end

    assign aref_en = aref_en_reg;
    assign wr_en = write_en_reg;
    assign rd_en = read_en_reg;

    //// aref_req wait
    always @(posedge sdram_clk, negedge rst_n) begin
        if (~rst_n) aref_req_t <= 0;
        else begin
            if (aref_req == 1) begin
                        aref_req_t <= 1;
            end
            else if (aref_en == 0) begin
                        aref_req_t <= aref_req_t;
            end
            else        aref_req_t <= 0;
        end
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // set SDRAM output signals, and generate SDRAM clock with inverted and same frequency to better sampling signal
    localparam  CMD_NOP = 4'b0111;                          // NOP command
    reg     [3:0]                   sdram_cmd;
    reg     [ADDR_BITS-1:0]         sdram_addr_reg;         // SDRAM address depends on initialization    
    reg     [ADDR_BITS-1:0]         sdram_addr_reg2;
    reg     [3:0]                   sdram_cmd_reg;
    reg     [BA_BITS-1:0]           sdram_bank_reg;
    reg     [DQ_BITS-1:0]           sdram_dq_reg;
    
    always @(*) begin
        if (~init_done)     sdram_cmd = init_cmd;
        else begin
            case (state)
                AREF:       sdram_cmd = aref_cmd;
                WRITE:      sdram_cmd = wr_cmd;
                READ:       sdram_cmd = rd_cmd;
                default:    sdram_cmd = CMD_NOP;
            endcase
        end
    end
    
    always @(*) begin
        if (~init_done)     sdram_addr_reg = init_addr;
        else begin
            case (state)
                AREF:       sdram_addr_reg = aref_addr;
                WRITE:      sdram_addr_reg = wr_addr_out;
                READ:       sdram_addr_reg = rd_addr_out;
                default:    sdram_addr_reg = 0;
            endcase
        end
    end

    always @(negedge sdram_clk, negedge rst_n) begin
        if (~rst_n) sdram_addr_reg2 <= 0;
        else        sdram_addr_reg2 <= sdram_addr_reg;
    end
    
    always @(negedge sdram_clk, negedge rst_n) begin
        if (~rst_n) sdram_cmd_reg <= CMD_NOP;
        else        sdram_cmd_reg <= sdram_cmd;
    end
    
    always @(negedge sdram_clk, negedge rst_n) begin
        if (~rst_n) sdram_bank_reg <= 0;
        else        sdram_bank_reg <= (state == WRITE) ? wr_ba_out : rd_ba_out;
    end
    
    always @(negedge sdram_clk, negedge rst_n) begin
        if (~rst_n) sdram_dq_reg <= 0;
        else        sdram_dq_reg <= (state == WRITE) ? wr_data_out : {16{1'bz}};
    end

    assign sdram_addr = sdram_addr_reg2;
    assign sdram_cke = 1;
    assign {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = sdram_cmd_reg;
    assign sdram_dqm = 2'b00;
    assign sdram_bank = sdram_bank_reg;
    assign sdram_dq = sdram_dq_reg;
    assign aref_done_out = aref_done;

endmodule
