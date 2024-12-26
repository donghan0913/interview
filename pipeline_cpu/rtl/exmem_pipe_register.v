`timescale 1ns / 1ps

module exmem_pipe_register(
    clk,
    rstn,
    //j_target_pip,
    //pc_target,
    mem_to_reg_pip,
    reg_w_pip,
    mem_r_pip,
    mem_w_pip,
    branch_pip,
    //jump_pip,
    //z_control,
    y,
    rb_data_pip,
    wb_addr,
    stall_ctr_pip,
    
    //j_target_pip2,
    //pc_target_pip,
    mem_to_reg_pip2,
    reg_w_pip2,
    mem_r_pip2,
    mem_w_pip2,
    branch_pip2,
    //jump_pip2,
    //z_control_pip,
    y_pip,
    rb_data_pip2,
    wb_addr_pip,
    stall_ctr_pip2
    );

    //reg_dst, alu_src, alu_op used in EX stage, so don't need to propagate to next stage.
    parameter byte = 8;
    parameter instruction_width = 32;
    parameter rom_depth = 256;
    parameter ram_depth = 256;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;
    
    input clk, rstn, mem_to_reg_pip, reg_w_pip, mem_r_pip, mem_w_pip, branch_pip/*, jump_pip, z_control*/, stall_ctr_pip;
    input [instruction_width-1:0] /*j_target_pip,*/ /*pc_target,*/ y, rb_data_pip;
    input [register_addr-1:0] wb_addr;

    output reg mem_to_reg_pip2, reg_w_pip2, mem_r_pip2, mem_w_pip2, branch_pip2/*, jump_pip2, z_control_pip*/, stall_ctr_pip2;
    output reg [instruction_width-1:0] /*j_target_pip2,*/ /*pc_target_pip,*/ y_pip, rb_data_pip2;
    output reg [register_addr-1:0] wb_addr_pip;
    
    //for pc address and jump
    /*
    always @(posedge clk) begin
        if (~rstn) j_target_pip2 <= 0;
        else j_target_pip2 <= j_target_pip;
    end
    */
    /*
    always @(posedge clk) begin
        if (~rstn) pc_target_pip <= 0;
        else pc_target_pip <= pc_target;
    end
    */
    
    //for main control
    always @(posedge clk) begin
        if (~rstn) mem_to_reg_pip2 <= 0;
        else mem_to_reg_pip2 <= mem_to_reg_pip;
    end

    always @(posedge clk) begin
        if (~rstn) reg_w_pip2 <= 0;
        else reg_w_pip2 <= reg_w_pip;
    end

    always @(posedge clk) begin
        if (~rstn) mem_r_pip2 <= 0;
        else mem_r_pip2 <= mem_r_pip;
    end

    always @(posedge clk) begin
        if (~rstn) mem_w_pip2 <= 0;
        else mem_w_pip2 <= mem_w_pip;
    end

    always @(posedge clk) begin
        if (~rstn) branch_pip2 <= 0;
        else branch_pip2 <= branch_pip;
    end

    /*
    always @(posedge clk) begin
        if (~rstn) jump_pip2 <= 0;
        else jump_pip2 <= jump_pip;
    end
    */

    //for alu and the others
    /*
    always @(posedge clk) begin
        if (~rstn) z_control_pip <= 0;
        else z_control_pip <= z_control;
    end
    */

    always @(posedge clk) begin
        if (~rstn) y_pip <= 0;
        else y_pip <= y;
    end

    always @(posedge clk) begin
        if (~rstn) rb_data_pip2 <= 0;
        else rb_data_pip2 <= rb_data_pip;
    end

    always @(posedge clk) begin
        if (~rstn) wb_addr_pip <= 0;
        else wb_addr_pip <= wb_addr;
    end

    always @(posedge clk) begin
        if (~rstn) stall_ctr_pip2 <= 0;
        else stall_ctr_pip2 <= stall_ctr_pip;
    end


endmodule