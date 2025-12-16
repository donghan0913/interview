`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/08 11:45:30
// Design Name: 
// Module Name: afifo
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


module afifo (
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
    
    localparam WIDTH = 1;                                    // data width
    localparam DEPTH = 8;                                    // FIFO depth
    localparam PTR_SIZE = 3;                                  // pointer size of FIFO
    localparam FIFO_MAX = DEPTH - 1;

    input                           clk_a;                  // source clock
    input                           clk_b;                  // destination clock
    input                           rst_n;
    input                           wr_en;                  // pull-up when writing
    input                           rd_en;                  // pull-up when reading
    input                           wr_data;                // write data
    output                          rd_data;                // read data
    output                          full;                   // indicate FIFO full
    output                          empty;                  // indicate FIFO empty
    
    reg                             fifo    [0:DEPTH-1];    // FIFO memory
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // reset synchronizer
    wire                            rst_n_a;
    wire                            rst_n_b;
    
    rst_sync inst_rst_sync_a(
        .clk(clk_a),
	    .rst_n(rst_n),
	    .rst_sync_n(rst_n_a)
        );
    
    rst_sync inst_rst_sync_b(
        .clk(clk_b),
	    .rst_n(rst_n),
	    .rst_sync_n(rst_n_b)
        );
    

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // pointer logic
    reg     [PTR_SIZE:0]            wr_ptr_bin;             // binary write pointer
    reg     [PTR_SIZE:0]            rd_ptr_bin;             // binary read pointer
    wire    [PTR_SIZE:0]            wr_ptr_gry;             // gray code write pointer
    wire    [PTR_SIZE:0]            rd_ptr_gry;             // gray code read pointer
    
    always @ (posedge clk_a, negedge rst_n_a) begin
        if (~rst_n_a)   wr_ptr_bin <= 0;
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

    always @ (posedge clk_b, negedge rst_n_b) begin
        if (~rst_n_b)   rd_ptr_bin <= 0;
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

    afifo_btog_cvtr #(
        .WIDTH(PTR_SIZE + 1)
    ) inst_btog_wr( 
        .bin(wr_ptr_bin),
        .gray(wr_ptr_gry)
    );
    
    afifo_btog_cvtr #(
        .WIDTH(PTR_SIZE + 1)
    ) inst_btog_rd( 
        .bin(rd_ptr_bin),
        .gray(rd_ptr_gry)
    );    

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // access FIFO data
    reg                             rd_data_reg;            // read data
    integer i_fifo;
    
    always @ (posedge clk_a, negedge rst_n_a) begin
        if (~rst_n_a) begin
            for (i_fifo = 0; i_fifo < DEPTH; i_fifo = i_fifo + 1) begin
						fifo[i_fifo] <= 0;
			end
        end
        else if ((wr_en == 1) && (full == 0)) begin
                        fifo[wr_ptr_bin[2:0]] <= wr_data;
        end
        else            fifo[wr_ptr_bin[2:0]] <= fifo[wr_ptr_bin[2:0]];
    end

    always @ (posedge clk_b, negedge rst_n_b) begin
        if (~rst_n_b)   rd_data_reg <= 0;
        else if ((rd_en == 1) && (empty == 0)) begin
                        rd_data_reg <= fifo[rd_ptr_bin[2:0]];
        end
        else            rd_data_reg <= {WIDTH{1'b0/*1'bz*/}};
    end
    assign rd_data = rd_data_reg;

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // FIFO status    
    reg     [PTR_SIZE:0]            wr_ptr_gry_src_t1;          // gray code write pointer
    reg     [PTR_SIZE:0]            rd_ptr_gry_dst_t1;          // gray code read pointer
    reg     [PTR_SIZE:0]            wr_ptr_gry_t1;          // gray code write pointer
    reg     [PTR_SIZE:0]            rd_ptr_gry_t1;          // gray code read pointer
    reg     [PTR_SIZE:0]            wr_ptr_gry_t2;          // gray code write pointer
    reg     [PTR_SIZE:0]            rd_ptr_gry_t2;          // gray code read pointer
    
    always @ (posedge clk_a, negedge rst_n_a) begin
        if (~rst_n_a)   wr_ptr_gry_src_t1 <= 0;
        else            wr_ptr_gry_src_t1 <= wr_ptr_gry;
    end
    
    always @ (posedge clk_b, negedge rst_n_b) begin
        if (~rst_n_b)   rd_ptr_gry_dst_t1 <= 0;
        else            rd_ptr_gry_dst_t1 <= rd_ptr_gry;
    end
    
    always @ (posedge clk_b, negedge rst_n_b) begin
        if (~rst_n_b) begin
            wr_ptr_gry_t1 <= 0;
            wr_ptr_gry_t2 <= 0;
        end
        else begin
            wr_ptr_gry_t1 <= wr_ptr_gry_src_t1;
            wr_ptr_gry_t2 <= wr_ptr_gry_t1;
        end
    end
    
    always @ (posedge clk_a, negedge rst_n_a) begin
        if (~rst_n_a) begin
            rd_ptr_gry_t1 <= 0;
            rd_ptr_gry_t2 <= 0;
        end
        else begin
            rd_ptr_gry_t1 <= rd_ptr_gry_dst_t1;
            rd_ptr_gry_t2 <= rd_ptr_gry_t1;
        end
    end
    
    assign full =   ((wr_ptr_gry[3:2] == ~rd_ptr_gry_t2[3:2]) && (wr_ptr_gry[1:0] == rd_ptr_gry_t2[1:0])) ? 1 : 0;
    assign empty =  (wr_ptr_gry_t2 == rd_ptr_gry) ? 1 : 0;
    
    
endmodule

