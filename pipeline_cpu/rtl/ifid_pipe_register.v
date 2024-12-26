`timescale 1ns / 1ps

module ifid_pipe_register(
    clk,
    rstn,
    flush_ctr,
    stall_ctr,
    pc_next,
    i_out,
    i_out_pip,
    pc_next_pip
    );

    parameter byte = 8;
    parameter instruction_width = 32;
    parameter rom_depth = 256;
    parameter ram_depth = 256;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;

    input clk, rstn, flush_ctr, stall_ctr;
    input [instruction_width-1:0] i_out, pc_next;
    output reg [instruction_width-1:0] i_out_pip, pc_next_pip;

    always @(posedge clk) begin
        if (~rstn) begin
            i_out_pip <= 0;
        end
        else begin
            if (stall_ctr) i_out_pip <= i_out_pip;
            else begin
                if (flush_ctr) i_out_pip <= 0;
                else i_out_pip <= i_out;
            end
        end
    end
    
    always @(posedge clk) begin
        if (~rstn) begin
            pc_next_pip <= 0;
        end
        else begin
            if (flush_ctr) pc_next_pip <= pc_next_pip;
            else pc_next_pip <= pc_next;
        end
    end


endmodule
