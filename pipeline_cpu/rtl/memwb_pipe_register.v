`timescale 1ns / 1ps

module memwb_pipe_register(
    clk,
    rstn,
    mem_to_reg_pip2,
    reg_w_pip2,
    y_pip,
    wb_addr_pip,
    d_out,
    
    mem_to_reg_pip3,
    reg_w_pip3,
    y_pip2,
    wb_addr_pip2,
    d_out_pip
    );

    //pc_target_pip, branch_pip2, jump_pip2 direct sent back to pc_register, so don't need to propagate to next stage.
    //mem_r_pip2, mem_w_pip2, zero_pip, rb_data_pip2 used in MEM stage, so don't need to propagate to next stage.

    parameter byte = 8;
    parameter instruction_width = 32;
    parameter rom_depth = 256;
    parameter ram_depth = 256;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;
    
    input clk, rstn, mem_to_reg_pip2, reg_w_pip2;
    input [instruction_width-1:0] y_pip, d_out;
    input [register_addr-1:0] wb_addr_pip;    
    
    output reg mem_to_reg_pip3, reg_w_pip3;
    output reg [instruction_width-1:0] y_pip2, d_out_pip;
    output reg [register_addr-1:0] wb_addr_pip2;
    
    //for main control    
    always @(posedge clk) begin
        if (~rstn) mem_to_reg_pip3 <= 0;
        else mem_to_reg_pip3 <= mem_to_reg_pip2;
    end
    
    always @(posedge clk) begin
        if (~rstn) reg_w_pip3 <= 0;
        else reg_w_pip3 <= reg_w_pip2;
    end

    always @(posedge clk) begin
        if (~rstn) y_pip2 <= 0;
        else y_pip2 <= y_pip;
    end

    always @(posedge clk) begin
        if (~rstn) wb_addr_pip2 <= 0;
        else wb_addr_pip2 <= wb_addr_pip;
    end

    always @(posedge clk) begin
        if (~rstn) d_out_pip <= 0;
        else d_out_pip <= d_out;
    end


endmodule
