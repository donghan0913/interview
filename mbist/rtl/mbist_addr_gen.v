`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/24 14:37:47
// Design Name: 
// Module Name: mbist_addr_gen
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
//`define LOPOW_ADDR_GEN										// low power LFSR address generator
//`define SIM                                                 // Simulation only, to check whether LFSR address fully covered


module mbist_addr_gen #(
    parameter ADDR = 8                                      // width of {row addr, col addr}
) (
    clk,    
`ifdef LOPOW_ADDR_GEN
    clk_1,
    clk_2,
`endif
    rst_n,
    addr_en,
    addr_ff,
    addr,
    addr_done    
    );
    
    localparam ROW_ADDR         = ADDR / 2;                 // row address
    localparam COL_ADDR         = ADDR / 2;                 // column address
    localparam ROW_MAX          = (2 ** ROW_ADDR) - 1;      // row max
    localparam COL_MAX          = (2 ** COL_ADDR) - 1;      // column max
    
    input                           clk;                    // clock
`ifdef LOPOW_ADDR_GEN
    input                           clk_1;                  // clock 1 for CLFSR
    input                           clk_2;                  // clock 2 for modified-LFSR
`endif
    input                           rst_n;                  // reset
`ifdef CHECKERBOARD
    input                           addr_en;                // enable address generator
`else
    input   [1:0]                   addr_en;                // enable address generator
`endif    
    input                           addr_ff;                // set address to MAX at the beginning of the down counting
    output  [ADDR-1:0]              addr;                   // address {row addr, col addr}
    output                          addr_done;              // indicate address count done
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // count address
    reg     [ROW_ADDR-1:0]          row;                    // row address
    reg     [COL_ADDR-1:0]          col;                    // col address

`ifdef CHECKERBOARD    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     col <= 0;
        else begin
            if (addr_en) begin
                        col <= col + 1;
            end
            else        col <= col;       
        end
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     row <= 0;
        else begin
            if (addr_en) begin
                if (col == COL_MAX) begin
                        row <= row + 1;
                end
                else    row <= row;
            end
            else        row <= 0;       
        end
    end    
    
    assign addr = {row, col};
    assign addr_done = ((row == ROW_MAX) && (col == COL_MAX)) ? 1 : 0;

`elsif LOPOW_ADDR_GEN
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // N-2 CLFSR
    localparam ADDR_CLFSR = ADDR - 2;
    //localparam B = 5'b1_0011;                                
    reg     [ADDR_CLFSR:1]          cff_q;                  // (n-2)-bit CLFSR flip-flop Q
    wire    [ADDR_CLFSR:1]          cff_q_next;             // (n-2)-bit CLFSR flip-flop D
    wire    [ADDR_CLFSR-2:1]        net_or;                 // 
    wire    [ADDR_CLFSR-1:1]        net_xor;                // 
    wire    [ADDR_CLFSR:1]          B;                      // 

    always @(posedge clk_1, negedge rst_n) begin
        if (~rst_n)     cff_q <= {ADDR_CLFSR{1'b1}};
        else if (addr_en[1] == 0) begin
                        cff_q <= cff_q;
        end
        else if (addr_done == 1) begin
                        cff_q <= {ADDR_CLFSR{1'b1}};
        end
        else            cff_q <= cff_q_next;                
    end
    
    assign B = 4'b1001;
    
    assign net_or[ADDR_CLFSR-2] = cff_q[ADDR_CLFSR-2] | cff_q[ADDR_CLFSR-1];
    //assign net_or[ADDR_CLFSR-3:2] = cff_q[ADDR_CLFSR-3:2] | net_or[ADDR_CLFSR-2:3];
    assign net_or[1] = ~(cff_q[1] | net_or[2]);
    
    assign net_xor[ADDR_CLFSR-1] = (cff_q[ADDR_CLFSR-1] & B[ADDR_CLFSR-1]) ^ cff_q[ADDR_CLFSR];
    assign net_xor[ADDR_CLFSR-2:1] = (cff_q[ADDR_CLFSR-2:1] & B[ADDR_CLFSR-2:1]) ^ net_xor[ADDR_CLFSR-1:2];

    assign cff_q_next[1] = net_xor[1] ^ net_or[1];
    assign cff_q_next[ADDR_CLFSR:2] = cff_q[ADDR_CLFSR-1:1];

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // 2-bit modified LFSR
    reg     [2:1]                   mff_q;                  // 2-bit modified-LFSR flip-flop Q
    wire    [2:1]                   mff_q_next;             // 2-bit modified-LFSR flip-flop D

    always @(posedge clk_2, negedge rst_n) begin
        if (~rst_n)     mff_q <= {2{1'b1}};
        else if (addr_en[1] == 0) begin
                        mff_q <= mff_q;
        end
        else if (addr_done == 1) begin
                        mff_q <= {2{1'b1}};
        end
        else            mff_q <= mff_q_next;                
    end

    assign mff_q_next[2] = mff_q[1];
    assign mff_q_next[1] = ~mff_q[2];

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // output Logic
    localparam ADDR_END_UP = 6'b111_101;
    localparam ADDR_END_DOWN = 6'b000_010;
    reg                             addr_done_reg;          //

    always @(*) begin
        if (addr_en[0] == 0) begin
            if (addr == ADDR_END_UP) begin
                        addr_done_reg = 1;
            end
            else        addr_done_reg = 0;
        end
        else begin
            if (addr == ADDR_END_DOWN) begin
                        addr_done_reg = 1;
            end
            else        addr_done_reg = 0;
        end
    end
    
    assign addr = (addr_en[0] == 0) ? {cff_q, mff_q} : ~{cff_q, mff_q};
                    
    assign addr_done = addr_done_reg;
    

`ifdef SIM
    reg [63:0]  lfsr_chk [0:5];
    integer chk_cnt;
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) chk_cnt <= 0;
        else begin
            if (addr_en[1] == 0) chk_cnt <= 0;
            else begin
                if (addr_done == 1) chk_cnt <= chk_cnt + 1;
                else                chk_cnt <= chk_cnt;
            end
        end 
    end
    
    integer chk_i;
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            for (chk_i = 0; chk_i < 6; chk_i = chk_i + 1) begin
                lfsr_chk[chk_i] <= 0;
            end
        end
        else lfsr_chk[chk_cnt][addr] <= ~lfsr_chk[chk_cnt][addr];
    end    
    
    
`endif
`else
    localparam COL_SUB          = {COL_ADDR{1'b1}};         // 
    localparam ROW_SUB          = {ROW_ADDR{1'b1}};         //
    reg                             addr_done_reg;          // indicate address count done

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     col <= 0;
        else if (addr_en[1] == 0) begin
                        col <= col;
        end
        else begin
            if (addr_en[0] == 1) begin
                        col <= col + COL_SUB;
            end
            else begin
                if (addr_ff == 1) begin
                        col <= col;
                end
                else    col <= col + 1;
            end
        end
    end
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)     row <= 0;
        else if (addr_en[1] == 0) begin
                        row <= row;
        end
        else begin
            if (addr_en[0] == 1) begin
                if (col == 0) begin
                        row <= row + ROW_SUB;
                end
                else    row <= row;
            end
            else begin
                if ((col == COL_MAX) && (addr_ff == 0)) begin
                        row <= row + 1;
                end
                else    row <= row;
            end            
        end    
    end
    
    always @(*) begin
        if (addr_en[0] == 1) begin
            if ((row == 0) && (col == 0)) begin
                        addr_done_reg = addr_en[1];
            end
            else        addr_done_reg = 0;
        end
        else begin
            if ((row == ROW_MAX) && (col == COL_MAX)) begin
                        addr_done_reg = addr_en[1];
            end
            else        addr_done_reg = 0;        
        end
    end

    assign addr = {row, col};
    assign addr_done = addr_done_reg;  

`endif  
 
        
endmodule
