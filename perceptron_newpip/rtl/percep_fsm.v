/**************************************************************
 * Module name: percep_fsm
 *
 * Features:
 *	1. Only execute inference mode,
 *        training and the w0 ~ w4 were already done by C language, then load into verilog
 *    2. Main perceptron model body, including control logic and datapath
 *    3. Iinference dataset number set to 20
 *    4. Dataset yd and x0~x4 are in ydx memory
 *    5. Weights are in wght memory
 *
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/
//`define PIP4 
 
 
module percep_fsm #(
    parameter MEM_WIDTH_YDX = 17,                           // ydx memory width
    parameter MEM_ADDR_YDX  = 7,                            // ydx memory address width
    parameter MEM_DEPTH_YDX = 2 ** (MEM_ADDR_YDX - 1),      // ydx memory depth, for only inference dataset, and some spaces
    parameter MEM_ADDR_WGHT = 3,                            // wght memory address width
    parameter INFER_NUM     = 20,                           // inference dataset number
    parameter ATTR          = 5,                            // represent 5 attritibutes
    parameter FP_WIDTH      = 16                            // width of fp data
) (
    clk,
    rst_n,
    infer_ena,
    sign_out,
    yd,
    infer_done,
    infer_fail,
    mem_cs_ydx,
    mem_we_ydx,
    mem_oe_ydx,
    d_addr_ydx,
    mem_cs_wght,
    mem_we_wght,
    mem_oe_wght,
    d_addr_wght,
`ifdef PIP4    
    stall,
`endif
    rst_add1
    );
        
    input                       clk;                        // clock
    input                       rst_n;                      // asynchronous active low reset
    input                       infer_ena;                  // determine whether to start inference
    input                       sign_out;                   // sign output from percep adder
    input                       yd;                         // yd read from ydx memory 
    output                      infer_done;                 // active when inference done
    output                      infer_fail;                 // active if all ya unequal to yd
    output                      mem_cs_ydx;                 // chip enable of ydx memory
    output                      mem_we_ydx;                 // write enable of ydx memory
    output                      mem_oe_ydx;                 // read enable of ydx memory
    output  [MEM_ADDR_YDX-1:0]  d_addr_ydx;                 // ydx memory address
    output                      mem_cs_wght;                // chip enable of wght memory
    output                      mem_we_wght;                // write enable of wght memory
    output                      mem_oe_wght;                // read enable of wght memory
    output  [MEM_ADDR_WGHT-1:0] d_addr_wght;                // wght memory address
`ifdef PIP4    
    output                      stall;                      // signal detected need to stall one cycle
`endif    
    output                      rst_add1;                   // reset fp_sum_pip of 2nd pipeline register to 0 when new inference
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM CS Logic
    localparam IDLE = 3'b000;                               // FSM state, before inference start
    localparam STORE = 3'b011;                              // FSM state, store inference dataset & weights after training into memory
    localparam CAL_NET = 3'b001;                            // FSM state, do inference compute net
    localparam CAL_YA = 3'b010;                             // FSM state, do inference compute yd
    localparam DONE = 3'b100;                               // FSM state, inference done
    reg     [2:0]               state;                      // current state of FSM
    reg     [2:0]               n_state;                    // next state of FSM
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) state <= IDLE;
        else        state <= n_state;
    end    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM NS Logic
    localparam SW_CNT1 = (INFER_NUM * ATTR) - 1;            // store state count limit, except w0~w4
    localparam SW_CNT2 = (INFER_NUM * ATTR) + 4;            // store state count limit, including w0~w4
    localparam INFER_CNT = INFER_NUM - 1;                   // let infer_cnt from 0~19
    localparam MEM_CNT_YDX = ATTR + 1;                      // max CAL_NET state count due to pipeline issue
`ifdef PIP4
    localparam NET_CNT = 10;                                // max net_cnt for CAL_NET state for 4-stage pipeline
`else    
    localparam NET_CNT = 5;                                // max net_cnt for CAL_NET state for 2-stage pipeline
`endif    
    
    reg     [MEM_ADDR_YDX-1:0]  mem_cnt_ydx;                // ydx memory address pointer(counter)
    reg     [4:0]               infer_cnt;                  // inference dataset count
    reg     [3:0]               net_cnt;                    // count net pipeline computation in CAL_NET state
    
    always @(*) begin
        case (state)
            IDLE:       n_state = (infer_ena == 1) ? STORE : IDLE;
            STORE:      n_state = (mem_cnt_ydx == SW_CNT2) ? CAL_NET : STORE;
            CAL_NET:    n_state = (net_cnt == NET_CNT) ? CAL_YA : CAL_NET;
            CAL_YA:     n_state = (infer_cnt == INFER_CNT) ? DONE : CAL_NET;
            DONE:       n_state = DONE;
        endcase
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Internal logic
    //// counter for net_cnt
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)                     net_cnt <= 0;
        else begin
            if (state == CAL_NET) begin
                if (net_cnt == NET_CNT) net_cnt <= 0;
                else                    net_cnt <= net_cnt + 1;
            end
            else                        net_cnt <= net_cnt;
        end
    end
    
    //// counter for mem_cnt_ydx
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)                                 mem_cnt_ydx <= 0;
        else begin
            if (state[0]) begin
                if (mem_cnt_ydx == SW_CNT2)         mem_cnt_ydx <= 0;
`ifdef PIP4
                else if ((net_cnt > 6) || (stall))  mem_cnt_ydx <= mem_cnt_ydx;
`else
                else if (net_cnt == 5)              mem_cnt_ydx <= mem_cnt_ydx;
`endif
                else                                mem_cnt_ydx <= mem_cnt_ydx + 1;
            end
            else                                    mem_cnt_ydx <= mem_cnt_ydx;
        end
    end
    
    //// counter for mem_cnt_wght
    reg     [MEM_ADDR_WGHT-1:0] mem_cnt_wght;               // wght memory address pointer(counter)
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)                         mem_cnt_wght <= 0;
        else begin
            if (state[0]) begin
`ifdef PIP4
                if (stall)                  mem_cnt_wght <= mem_cnt_wght;
                else if (mem_cnt_wght == 4) mem_cnt_wght <= 0;
`else
                if (mem_cnt_wght == 4)      mem_cnt_wght <= 0;
`endif
                else                        mem_cnt_wght <= mem_cnt_wght + 1;
            end
            else                            mem_cnt_wght <= 0;
        end
    end
    
    //// counter for infer_cnt
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)                         infer_cnt <= 0;
        else begin
            if (state == CAL_YA) begin
                if (infer_cnt == INFER_CNT) infer_cnt <= 0;
                else                        infer_cnt <= infer_cnt + 1;
            end
            else                            infer_cnt <= infer_cnt;
        end
    end    
    
    //// get valid yd
    reg                         yd_valid;                   // valid yd to check at CAL_YA state
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)                             yd_valid <= 0;
        else begin
            if ((state[0]) && (net_cnt == 0))   yd_valid <= yd;
            else                                yd_valid <= yd_valid;
        end
    end
    
    //// compute ya and compare with answer yd
    reg                         ya;                         // ya determined by net 
    reg                         error;                      // active when ya & yd are different
       
    always @(*) begin
        if (state == CAL_YA)    ya = ~sign_out;
        else                    ya = 0;
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)             error <= 0;
        else begin
            if (state == CAL_YA) begin
                if (error)      error <= error;
                else            error <= ya ^ yd_valid;
            end
        end
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM Output Logic
    assign infer_done = state[2];
    assign infer_fail = (state[2]) ? error : 0;
    assign mem_cs_ydx = state[0];
    assign mem_we_ydx = (state == STORE);
    assign mem_oe_ydx = (state == CAL_NET);
    assign d_addr_ydx = mem_cnt_ydx;
    assign mem_cs_wght = state[0];
    assign mem_we_wght = ((state == STORE) && (mem_cnt_ydx > SW_CNT1)) ? 1'b1 : 0;
    assign mem_oe_wght = (state == CAL_NET);
    assign d_addr_wght = mem_cnt_wght;
`ifdef PIP4    
    assign stall = ((state == CAL_NET) && (net_cnt >= 3) && (net_cnt[0])) ? 1'b1 : 0;
    assign rst_add1 = (net_cnt <= 3) ? 1'b1 : 0;
`else
    assign rst_add1 = (net_cnt == 0) ? 1'b1 : 0;
`endif    

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FSM total clock cycle compute, only for debugging

    reg		[13:0] 				fsm_cnt;              		// total FSM operation cycles number  

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)             		fsm_cnt <= 0;
        else begin
            if ((state == CAL_NET) || (state == CAL_YA))	fsm_cnt <= fsm_cnt + 1;
            else 						fsm_cnt <= fsm_cnt;
        end
    end

 

endmodule
