`timescale 1ns / 1ps

module idex_pipe_register(
    clk,
    rstn,
    //j_target,
    //pc_next_pip,
    reg_dst,
    alu_src,
    mem_to_reg,
    reg_w,
    mem_r,
    mem_w,
    branch,
    alu_op,
    //jump,
    ra_data,
    rb_data,
    imme_32,
    rd_for_rtype,
    rt_for_lw,
    rs,     //forwarding to solve data hazard
    stall_ctr,
    
    //j_target_pip,
    //pc_next_pip2,
    reg_dst_pip,
    alu_src_pip,
    mem_to_reg_pip,
    reg_w_pip,
    mem_r_pip,
    mem_w_pip,
    branch_pip,
    alu_op_pip,
    //jump_pip,
    ra_data_pip,
    rb_data_pip,
    imme_32_pip,
    rd_for_rtype_pip,
    rt_for_lw_pip,
    rs_pip,     //forwarding to solve data hazard
    rt_pip,      //forwarding to solve data hazard
    stall_ctr_pip
    );
    
    parameter byte = 8;
    parameter instruction_width = 32;
    parameter rom_depth = 256;
    parameter ram_depth = 256;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;
    
    input clk, rstn, reg_dst, alu_src, mem_to_reg, reg_w, mem_r, mem_w, branch/*, jump*/, stall_ctr;
    input [2:0] alu_op;
    input [instruction_width-1:0] /*j_target,*/ /*pc_next_pip,*/ ra_data, rb_data, imme_32;
    input [register_addr-1:0] rd_for_rtype, rt_for_lw, rs;
    
    output reg reg_dst_pip, alu_src_pip, mem_to_reg_pip, reg_w_pip, mem_r_pip, mem_w_pip, branch_pip/*, jump_pip*/, stall_ctr_pip;
    output reg [2:0] alu_op_pip;
    output reg [instruction_width-1:0] /*j_target_pip,*/ /*pc_next_pip2,*/ ra_data_pip, rb_data_pip, imme_32_pip;
    output reg [register_addr-1:0] rd_for_rtype_pip, rt_for_lw_pip, rs_pip, rt_pip;
    
    //for pc address and jump
    /*
    always @(posedge clk) begin
        if (~rstn) j_target_pip <= 0;
        else j_target_pip <= j_target;
    end
    */
    /*
    always @(posedge clk) begin
        if (~rstn) pc_next_pip2 <= 0;
        else pc_next_pip2 <= pc_next_pip;
    end
    */
    
    //for main control
    always @(posedge clk) begin
        if (~rstn) reg_dst_pip <= 0;
        else reg_dst_pip <= reg_dst;
    end
    
    always @(posedge clk) begin
        if (~rstn) alu_src_pip <= 0;
        else alu_src_pip <= alu_src;
    end

    always @(posedge clk) begin
        if (~rstn) mem_to_reg_pip <= 0;
        else mem_to_reg_pip <= mem_to_reg;
    end
    
    always @(posedge clk) begin
        if (~rstn) reg_w_pip <= 0;
        else reg_w_pip <= reg_w;
        
    end
    
    always @(posedge clk) begin
        if (~rstn) mem_r_pip <= 0;
        else mem_r_pip <= mem_r;
    end
    
    always @(posedge clk) begin
        if (~rstn) mem_w_pip <= 0;  
        else mem_w_pip <= mem_w;
    
    end
    
    always @(posedge clk) begin
        if (~rstn) branch_pip <= 0;
        else branch_pip <= branch;
    end
    
    always @(posedge clk) begin
        if (~rstn) alu_op_pip <= 0;
        else alu_op_pip <= alu_op;
    end
    
    /*
    always @(posedge clk) begin
        if (~rstn) jump_pip <= 0;
        else jump_pip <= jump;
    end
    */
    
    //for register file and the others
    always @(posedge clk) begin
        if (~rstn) ra_data_pip <= 0;
        else ra_data_pip <= ra_data;
    end
    
    always @(posedge clk) begin
        if (~rstn) rb_data_pip <= 0;
        else rb_data_pip <= rb_data;
    end

    always @(posedge clk) begin
        if (~rstn) imme_32_pip <= 0;
        else imme_32_pip <= imme_32;
    end

    always @(posedge clk) begin
        if (~rstn) rd_for_rtype_pip <= 0;
        else rd_for_rtype_pip <= rd_for_rtype;
    end

    always @(posedge clk) begin
        if (~rstn) rt_for_lw_pip <= 0;
        else rt_for_lw_pip <= rt_for_lw;
    end
    
    always @(posedge clk) begin
        if (~rstn) rs_pip <= 0;
        else rs_pip <= rs;
    end

    always @(posedge clk) begin
        if (~rstn) rt_pip <= 0;
        else rt_pip <= rt_for_lw;
    end
 
    always @(posedge clk) begin
        if (~rstn) stall_ctr_pip <= 0;
        else stall_ctr_pip <= stall_ctr;
    end

endmodule

    