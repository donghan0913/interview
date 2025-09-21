/**************************************************************
 * Module name: fifo_sync
 *
 * Features:
 *	1. Synchronous FIFO use memory and pointer
 *
 * Descriptions:
 *    1.
 *
 * Author: Jason Wu, master's student, NTHU
 *
 **************************************************************/
`timescale 1ns / 100ps


module fifo_sync #(
    parameter WIDTH = 8,                                    // data width
    parameter DEPTH = 8,                                    // FIFO depth
    parameter PTR_SIZE = 3                                  // pointer size of FIFO
) (
    clk,
    rst_n,
    wr_en,
    rd_en,
    wr_data,
    rd_data,
    full,
    empty
    );

    localparam FIFO_MAX = DEPTH - 1;

    input                           clk;                    // clock
    input                           rst_n;                  // negative triggered reset
    input                           wr_en;                  // pull-up when writing
    input                           rd_en;                  // pull-up when reading
    input   [WIDTH-1:0]             wr_data;                // write data
    output  [WIDTH-1:0]             rd_data;                // read data
    output                          full;                   // indicate FIFO full
    output                          empty;                  // indicate FIFO empty
    
    reg     [WIDTH-1:0]             fifo    [0:DEPTH-1];    // FIFO memory


    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pointer logic
    reg     [PTR_SIZE:0]            wr_ptr;                 // write pointer
    reg     [PTR_SIZE:0]            rd_ptr;                 // read pointer
    
    always @ (posedge clk, negedge rst_n) begin
        if (~rst_n)     wr_ptr <= 0;
        else begin
            if ((wr_en == 1) && (full == 0)) begin
                        wr_ptr <= wr_ptr + 1;
            end
            else        wr_ptr <= wr_ptr;
        end
    end

    always @ (posedge clk, negedge rst_n) begin
        if (~rst_n)     rd_ptr <= 0;
        else begin
            if ((rd_en == 1) && (empty == 0)) begin
                        rd_ptr <= rd_ptr + 1;
            end
            else        rd_ptr <= rd_ptr;
        end
    end

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // access FIFO data
    reg     [WIDTH-1:0]             rd_data_reg;            // read data
    
    always @ (negedge clk, negedge rst_n) begin
        if ((wr_en == 1) && (full == 0)) begin
                        fifo[wr_ptr[PTR_SIZE-1:0]] <= wr_data;
        end
        else            fifo[wr_ptr[PTR_SIZE-1:0]] <= fifo[wr_ptr[PTR_SIZE-1:0]];
    end

    always @ (posedge clk, negedge rst_n) begin
        if ((rd_en == 1) && (empty == 0)) begin
                        rd_data_reg <= fifo[rd_ptr[PTR_SIZE-1:0]];
        end
        else            rd_data_reg <= rd_data_reg;
    end
    assign rd_data = rd_data_reg;

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FIFO status 
    assign full =   ((wr_ptr[PTR_SIZE] == ~rd_ptr[PTR_SIZE]) && (wr_ptr[PTR_SIZE-1:0] == rd_ptr[PTR_SIZE-1:0])) ? 1 : 0;
    assign empty =  (wr_ptr == rd_ptr) ? 1 : 0;
    
    
endmodule
