/**************************************************************
 * Module name: cmd_decode
 *
 * Features:
 *	1. Decode data from UART_RX to become write/read commands and write burst data
 *
 * Descriptions:
 *    1. If want to simulate this module alone, than need to assign wire for "uart_flag" & "uart_data"
 *        before use, otherwise will leads to timing problem
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/


module cmd_decode #(
    parameter D_WIDTH = 8                                   // width of data
) (
    sys_clk,
    sys_rst_n,
    uart_flag,
    uart_data,
    wr_trig,
    rd_trig,
    wfifo_wr_en,
    wfifo_data
    );

    localparam DATA_CNT = D_WIDTH / 4;                      
    localparam REC_WIDTH = 3;                               // count from 0 to 4 for BL = 4
    localparam REC_MAX = 4;                                 // count from 1 to 4 for BL = 4, 0 for command
    localparam WR_CMD = 4'b0100;                            // 4-bit command for WRITE
    localparam RD_CMD = 4'b0101;                            // 4-bit command for READ
    localparam WR_CMD8 = {DATA_CNT{WR_CMD}};                // 8-bit command for WRITE
    localparam RD_CMD8 = {DATA_CNT{RD_CMD}};                // 8-bit command for READ
    
    input                           sys_clk;                // system clock
    input                           sys_rst_n;              // system negative triggered reset
    input   [D_WIDTH-1:0]           uart_data;              // parallel data from UART_RX
    input                           uart_flag;              // indicate UART_RX job complete
    output                          wr_trig;                // WRITE operation trigger
    output                          rd_trig;                // READ operation trigger
    output                          wfifo_wr_en;            // write data enable to control write FIFO
    output  [D_WIDTH-1:0]           wfifo_data;             // parallel data from UART_RX directly send to wfifo

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // internal signals
    reg     [REC_WIDTH-1:0]         rec_cnt;                // decide whether uart_data is commands or write data
    reg     [D_WIDTH-1:0]           cmd_reg;                // read or write command    

    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) rec_cnt <= 0;
        else begin
            if (uart_flag == 1) begin
                if (rec_cnt == 0) begin
                    if (uart_data == WR_CMD8) begin
                        rec_cnt <= rec_cnt + 1;
                    end
                    else if (uart_data == RD_CMD8) begin
                        rec_cnt <= 0;
                    end
                    else begin
                        rec_cnt <= 0;
                    end                    
                end
                else if (rec_cnt == REC_MAX) begin
                        rec_cnt <= 0;
                end
                else    rec_cnt <= rec_cnt + 1;
            end
            else        rec_cnt <= rec_cnt;
        end
    end

    always @(posedge sys_clk, negedge sys_rst_n) begin
        if (~sys_rst_n) cmd_reg <= 0;
        else begin    
            if ((rec_cnt == 0) && (uart_flag == 1)) begin
                        cmd_reg <= uart_data;
            end
            else        cmd_reg <= cmd_reg;
        end
    end

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // output signals
    assign wr_trig = (rec_cnt == REC_MAX) ? uart_flag : 0;
    assign rd_trig = ((rec_cnt == 0) && (uart_data == RD_CMD8)) ? uart_flag : 0;
    assign wfifo_wr_en = (rec_cnt != 0) ? uart_flag : 0;
    assign wfifo_data = uart_data;


endmodule
