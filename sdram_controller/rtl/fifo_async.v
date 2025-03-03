/**************************************************************
 * Module name: fifo_async
 *
 * Features:
 *    1. Asynchronous FIFO use memory and pointer
 *    2. CDC handling from source domain to destination domain
 *
 * Descriptions:
 *    1.
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/
`timescale 1ns / 100ps


module fifo_async #(
    parameter WIDTH = 8,                                    // data width
    parameter DEPTH = 8,                                    // FIFO depth
    parameter PTR_SIZE = 3                                  // pointer size of FIFO
) (
    clk_a,
    clk_b,
    rst_n,
    wr_en,
    rd_en,
    wr_data,
    rd_data,
    full,
    empty
    );

    localparam FIFO_MAX = DEPTH - 1;

    input                           clk_a;                  // source clock
    input                           clk_b;                  // destination clock
    input                           rst_n;                // negative triggered reset
    input                           wr_en;                  // pull-up when writing
    input                           rd_en;                  // pull-up when reading
    input   [WIDTH-1:0]             wr_data;                // write data
    output  [WIDTH-1:0]             rd_data;                // read data
    output                          full;                   // indicate FIFO full
    output                          empty;                  // indicate FIFO empty
    
    reg     [WIDTH-1:0]             fifo    [0:DEPTH-1];    // FIFO memory
    

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pointer logic
    reg     [PTR_SIZE:0]            wr_ptr_bin;             // binary write pointer
    reg     [PTR_SIZE:0]            rd_ptr_bin;             // binary read pointer
    wire    [PTR_SIZE:0]            wr_ptr_gry;             // gray code write pointer
    wire    [PTR_SIZE:0]            rd_ptr_gry;             // gray code read pointer
    
    always @ (posedge clk_a, negedge rst_n) begin
        if (~rst_n)     wr_ptr_bin <= 0;
        else begin
            if (wr_en) begin
                if (full == 0) begin
                        wr_ptr_bin <= wr_ptr_bin + 1;
                end
                else    wr_ptr_bin <= wr_ptr_bin;
            end
            else        wr_ptr_bin <= wr_ptr_bin;
        end
    end

    always @ (posedge clk_b, negedge rst_n) begin
        if (~rst_n)     rd_ptr_bin <= 0;
        else begin
            if (rd_en) begin
                if (empty == 0) begin
                        rd_ptr_bin <= rd_ptr_bin + 1;
                end
                else    rd_ptr_bin <= rd_ptr_bin;
            end
            else        rd_ptr_bin <= rd_ptr_bin;
        end
    end

    fifo_async_btog_cvtr #(
        .WIDTH(PTR_SIZE + 1)
    ) inst_btog_wr( 
        .bin(wr_ptr_bin),
        .gray(wr_ptr_gry)
    );
    
    fifo_async_btog_cvtr #(
        .WIDTH(PTR_SIZE + 1)
    ) inst_btog_rd( 
        .bin(rd_ptr_bin),
        .gray(rd_ptr_gry)
    );    

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // access FIFO data
    reg     [WIDTH-1:0]             rd_data_reg;            // read data
    
    always @ (posedge clk_a, negedge rst_n) begin
        if ((wr_en == 1) && (full == 0)) begin
                        fifo[wr_ptr_bin[2:0]] <= wr_data;
        end
        else            fifo[wr_ptr_bin[2:0]] <= fifo[wr_ptr_bin[2:0]];
    end

    always @ (posedge clk_b, negedge rst_n) begin
        if ((rd_en == 1) && (empty == 0)) begin
                        rd_data_reg <= fifo[rd_ptr_bin[2:0]];
        end
        else            rd_data_reg <= {WIDTH{1'bz}};
    end
    assign rd_data = rd_data_reg;

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FIFO status
/*    
    reg     [PTR_SIZE:0]            status_cnt;             // inc/dec to determine FIFO status
    
    always @ (posedge clk, negedge rst_n) begin
        if(~rst_n)      status_cnt <= 0;
        else begin
            if ((wr_en == 1) && (rd_en == 0) && (full == 0)) begin
                if (status_cnt == DEPTH) begin
                        status_cnt <= 0;
                end            
                else    status_cnt <= status_cnt + 1;
            end
            else if ((wr_en == 0) && (rd_en == 1) && (empty == 0)) begin
                        status_cnt <= status_cnt - 1;
            end
            else        status_cnt <= status_cnt;
        end
    end
*/

    //// empty and full    
    //assign full = (status_cnt == DEPTH) ? 1 : 0;
    //assign empty = (status_cnt == 0) ? 1 : 0;
    
    reg     [PTR_SIZE:0]            wr_ptr_gry_t1;          // gray code write pointer
    reg     [PTR_SIZE:0]            rd_ptr_gry_t1;          // gray code read pointer
    reg     [PTR_SIZE:0]            wr_ptr_gry_t2;          // gray code write pointer
    reg     [PTR_SIZE:0]            rd_ptr_gry_t2;          // gray code read pointer
    
    always @ (posedge clk_b) begin
        wr_ptr_gry_t1 <= wr_ptr_gry;
        wr_ptr_gry_t2 <= wr_ptr_gry_t1;
    end
    
    always @ (posedge clk_a) begin
        rd_ptr_gry_t1 <= rd_ptr_gry;
        rd_ptr_gry_t2 <= rd_ptr_gry_t1;
    end
    
    assign full =   ((wr_ptr_gry[3:2] == ~rd_ptr_gry_t2[3:2]) && (wr_ptr_gry[1:0] == rd_ptr_gry_t2[1:0])) ? 1 : 0;
    assign empty =  (wr_ptr_gry_t2 == rd_ptr_gry) ? 1 : 0;
    
    
endmodule
