`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/24 15:08:58
// Design Name: 
// Module Name: mbist_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`define CHECKERBOARD
//`define MARCH_C_SUB
//`define MARCH_X


module mbist_fsm #(
    parameter ADDR = 8                                      // width of {row addr, col addr}
) (
    clk,
    rst_n,
    mode,
    response,
    addr,
    addr_done,
    pattern,
    cs_bist,
    we_bist,
    oe_bist,
    addr_en,
    addr_ff,
    pattern_en,
    fault_flag,
    bist_done
    );
    
    localparam ADDR_MAX             = (2 ** ADDR) - 1;      // address max
    
    input                           clk;                    // clock
    input                           rst_n;                  // reset
    input                           mode;                   // functional mode (0) or test mode (1)
    input                           response;               // data output from memory
    input   [ADDR-1:0]              addr;                   // address {row addr, col addr} from address generator
    input                           addr_done;              // address generated to max
    input                           pattern;                // test pattern from pattern generator
    output                          cs_bist;                // 
    output                          we_bist;                // 
    output                          oe_bist;                // 
`ifdef CHECKERBOARD
    output                          addr_en;                // enable address generator
`else
    output  [1:0]                   addr_en;                // enable address generator
`endif
    output                          addr_ff;                // set address to MAX at the beginning of the down counting
    output  [1:0]                   pattern_en;             // enable pattern generator, and select pattern type
    output                          fault_flag;             // indicate fault detected
    output                          bist_done;              // indicate bist finish


    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM CS logic
`ifdef CHECKERBOARD
    localparam IDLE = 3'b000;                               // FSM state
    localparam WR_01 = 3'b001;                              // FSM state
    localparam RD_01 = 3'b010;                              // FSM state
    localparam WR_10 = 3'b011;                              // FSM state
    localparam RD_10 = 3'b100;                              // FSM state
    localparam DONE = 3'b101;                               // FSM state
    reg     [2:0]               state;                      // current state of FSM
    reg     [2:0]               n_state;                    // next state of FSM
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) state <= IDLE;
        else        state <= n_state;
    end
`elsif MARCH_C_SUB
    localparam IDLE         = 4'b0000;                      // FSM state
    localparam WR0_U        = 4'b0001;                      // FSM state
    localparam RD0_WR1_U    = 4'b0010;                      // FSM state
    localparam RD1_WR0_U    = 4'b0100;                      // FSM state
    localparam RD0_WR1_D    = 4'b1010;                      // FSM state
    localparam RD1_WR0_D    = 4'b1100;                      // FSM state
    localparam RD0_D        = 4'b1011;                      // FSM state
    localparam DONE         = 4'b1000;                      // FSM state
    reg     [3:0]               state;                      // current state of FSM
    reg     [3:0]               n_state;                    // next state of FSM

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) state <= IDLE;
        else        state <= n_state;
    end
`elsif MARCH_X
    localparam IDLE         = 3'b000;                      // FSM state
    localparam WR0_U        = 3'b001;                      // FSM state
    localparam RD0_WR1_U    = 3'b010;                      // FSM state
    localparam RD1_WR0_D    = 3'b101;                      // FSM state
    localparam RD0_D        = 3'b110;                      // FSM state
    localparam DONE         = 3'b100;                      // FSM state
    reg     [2:0]               state;                      // current state of FSM
    reg     [2:0]               n_state;                    // next state of FSM

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) state <= IDLE;
        else        state <= n_state;
    end
`endif

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM NS logic
`ifdef CHECKERBOARD    
    always @(*) begin
        case (state)
            IDLE:       if (mode == 1) begin
                                    n_state = WR_01;
                        end
                        else        n_state = IDLE;
            WR_01:      if (addr_done == 1) begin
                                    n_state = RD_01;
                        end
                        else        n_state = WR_01;
            RD_01:      if (addr_done == 1) begin
                                    n_state = WR_10;
                        end
                        else        n_state = RD_01;
            WR_10:      if (addr_done == 1) begin
                                    n_state = RD_10;
                        end
                        else        n_state = WR_10;
            RD_10:      if (addr_done == 1) begin
                                    n_state = DONE;
                        end
                        else        n_state = RD_10;
            DONE:       n_state = DONE;
            default:    n_state = IDLE;
        endcase
    end  
`elsif MARCH_C_SUB
    always @(*) begin
        case (state)
            IDLE:       if (mode == 1) begin
                                    n_state = WR0_U;
                        end
                        else        n_state = IDLE;
            WR0_U:      if (addr_done == 1) begin
                                    n_state = RD0_WR1_U;
                        end
                        else        n_state = WR0_U;
            RD0_WR1_U:  if (addr_done == 1) begin
                                    n_state = RD1_WR0_U;
                        end
                        else        n_state = RD0_WR1_U;
            RD1_WR0_U:  if (addr_done == 1) begin
                                    n_state = RD0_WR1_D;
                        end
                        else        n_state = RD1_WR0_U;
            RD0_WR1_D:  if (addr_done == 1) begin
                                    n_state = RD1_WR0_D;
                        end
                        else        n_state = RD0_WR1_D;
            RD1_WR0_D:  if (addr_done == 1) begin
                                    n_state = RD0_D;
                        end
                        else        n_state = RD1_WR0_D;
            RD0_D:      if (addr_done == 1) begin
                                    n_state = DONE;
                        end
                        else        n_state = RD0_D;
            DONE:       n_state = DONE;
            default:    n_state = IDLE;
        endcase
    end
`elsif MARCH_X
    always @(*) begin
        case (state)
            IDLE:       if (mode == 1) begin
                                    n_state = WR0_U;
                        end
                        else        n_state = IDLE;
            WR0_U:      if (addr_done == 1) begin
                                    n_state = RD0_WR1_U;
                        end
                        else        n_state = WR0_U;
            RD0_WR1_U:  if (addr_done == 1) begin
                                    n_state = RD1_WR0_D;
                        end
                        else        n_state = RD0_WR1_U;
            RD1_WR0_D:  if (addr_done == 1) begin
                                    n_state = RD0_D;
                        end
                        else        n_state = RD1_WR0_D;
            RD0_D:      if (addr_done == 1) begin
                                    n_state = DONE;
                        end
                        else        n_state = RD0_D;
            DONE:       n_state = DONE;
            default:    n_state = IDLE;
        endcase
    end     
`endif    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Internal logic
`ifdef CHECKERBOARD
    reg                             fault_flag;             // indicate when fault occur    
    always @(*) begin
        if ((state == RD_01) || (state == RD_10)) begin
            if (response != pattern) begin
                    fault_flag = 1;
            end
            else    fault_flag = 0;
        end
        else        fault_flag = 0;
    end
`elsif MARCH_C_SUB
    reg                             rw_flag;
    reg                             fault_flag;             // indicate when fault occur    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
					fault_flag <= 0;
		end
		else if (oe_bist == 1) begin
            if (state[1] == 1) begin
                if (response != 0) begin
                    fault_flag <= 1;
                end
                else fault_flag <= 0;
            end
            else if (state[2] == 1) begin
                if (response != 1) begin
                    fault_flag <= 1;                    
                end
                else fault_flag <= 0;
            end
            else    fault_flag <= 0;
        end
        else        fault_flag <= 0;
    end
    
`elsif MARCH_X
    reg                             rw_flag;
    reg                             fault_flag;             // indicate when fault occur    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
					fault_flag <= 0;
		end
        else if (oe_bist == 1) begin
            if (state == RD1_WR0_D) begin
                if (response != 1) begin
                    fault_flag <= 1;
                end
                else fault_flag <= 0;
            end
            else if (state[1] == 1) begin
                if (response != 0) begin
                    fault_flag <= 1;                    
                end
                else fault_flag <= 0;
            end
            else    fault_flag <= 0;
        end
        else        fault_flag <= 0;
    end
`endif

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Output logic
`ifdef CHECKERBOARD
    reg     [1:0]                   pattern_en_reg;
    
    always @(*) begin
        if ((state == WR_01) || (state == RD_01)) begin
                pattern_en_reg = 2'b10;
        end
        else if ((state == WR_10) || (state == RD_10)) begin
                pattern_en_reg = 2'b11;
        end
        else    pattern_en_reg = 2'b00;
    end
    
    assign cs_bist = ((state != IDLE) || (state != DONE)) ? 1 : 0;
    assign we_bist = ((state == WR_01) || (state == WR_10)) ? 1 : 0;
    assign oe_bist = ((state == RD_01) || (state == RD_10)) ? 1 : 0;
    assign bist_done = (state == DONE) ? 1 : 0;
    assign addr_en = ((state == IDLE) || (state == DONE)) ? 0 : 1;
    assign pattern_en = pattern_en_reg;
`elsif MARCH_C_SUB
/*
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) rw_flag <= 0;
        else begin
            if ((state == IDLE) || (state == DONE) || (addr_done == 1)) begin
                    rw_flag <= 0;
            end
            else if ((state == WR0_U) || (state == RD0_D)) begin
                    rw_flag <= 1;
            end
            else    rw_flag <= ~rw_flag;
        end
    end
*/
 
    assign cs_bist =        ((state == IDLE) || (state == DONE)) ? 0 : 1;
    assign we_bist =        ((state == IDLE) || (state == RD0_D) || (state == DONE)) ? 0 : 1;
    assign oe_bist =        ((state == IDLE) || (state == WR0_U) || (state == DONE)) ? 0 : 1;
	assign bist_done =      (state == DONE) ? 1 : 0;
    assign addr_en[1] =     ((state == IDLE) || (state == DONE)) ? 0 : 1;
    assign addr_en[0] =     state[3];
    assign addr_ff =        ((state[3] == 0) && (n_state[3] == 1)) ? 1 : 0;
    assign pattern_en[1] =  ((state == IDLE) || (state == DONE) || (state == RD0_D)) ? 0 : 1;
    assign pattern_en[0] =  state[1];
`elsif MARCH_X
/*
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) rw_flag <= 0;
        else begin
            if ((state == IDLE) || (state == DONE) || (addr_done == 1)) begin
                    rw_flag <= 0;
            end
            else if ((state == WR0_U) || (state == RD0_D)) begin
                    rw_flag <= 1;
            end
            else    rw_flag <= ~rw_flag;
        end
    end    
*/    
    assign cs_bist =        ((state == IDLE) || (state == DONE)) ? 0 : 1;
    assign we_bist =        ((state == IDLE) || (state == RD0_D) || (state == DONE)) ? 0 : 1;
    assign oe_bist =        ((state == IDLE) || (state == WR0_U) || (state == DONE)) ? 0 : 1;
    assign bist_done =      (state == DONE) ? 1 : 0;
    assign addr_en[1] =     ((state == IDLE) || (state == DONE)) ? 0 : 1;
    assign addr_en[0] =     state[2];
    assign addr_ff =        ((state[2] == 0) && (n_state[2] == 1)) ? 1 : 0;
    assign pattern_en[1] =  ((state == IDLE) || (state == DONE) || (state == RD0_D)) ? 0 : 1;
    assign pattern_en[0] =  state[1];
`endif  
    
    
endmodule
