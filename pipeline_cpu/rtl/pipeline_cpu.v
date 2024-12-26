`timescale 1ns / 1ps

//define for submodule simulation
    `define I_MEM
    `define D_MEM
    `define REG_FILE
    `define ALU
    `define MAIN_CONT
    `define ALU_CONT
    `define PC_REG
    `define PC_ADD4
    `define PC_ADD_TAR
    `define J_TAR
    `define SIGN_EXT

    `define BRANCH_HAZARD_SOL


module pipeline_cpu(
    clk,
    rstn,
    addr_out
    );

    parameter byte = 8;
    parameter instruction_width = 32;
    parameter rom_depth = 256;
    parameter ram_depth = 256;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;

    input clk, rstn;
    output [instruction_width-1:0] addr_out;

    wire                            cs_rom, cs_ram,
                                    mem_w, mem_w_pip, mem_w_pip2,
                                    reg_w, reg_w_pip, reg_w_pip2, reg_w_pip3,
                                    mem_r, mem_r_pip, mem_r_pip2,
                                    zero, z_control, /*z_control_pip,*/
                                    reg_dst, reg_dst_pip,
                                    alu_src, alu_src_pip,
                                    mem_to_reg, mem_to_reg_pip, mem_to_reg_pip2, mem_to_reg_pip3,
                                    branch, branch_pip, branch_pip2,
                                    jump, /*jump_pip, jump_pip2,*/
                                    flush_ctr,
                                    stall_ctr, stall_ctr_pip, stall_ctr_pip2, reg_w_in, mem_w_in;

    wire [instruction_width-1:0]    pc_addr,
                                    pc_result,
                                    pc_next, pc_next_pip, pc_next_pip2,
                                    pc_target, pc_target_pip,
                                    i_out, i_out_pip,
                                    y, y_pip, y_pip2,
                                    ra_data, ra_data1, ra_data_pip,
                                    rb_data, rb_data1, rb_data_pip, rb_data_pip2,
                                    b,
                                    forward_a, forward_b,
                                    d_out, d_out_pip,
                                    w_data,
                                    imme_32, imme_32_pip,
                                    j_target/*, j_target_pip, j_target_pip2*/,
                                    ra_data2, rb_data2;
    
    wire [register_addr-1:0]        wb_addr, wb_addr_pip, wb_addr_pip2, 
                                    rd_for_rtype_pip, rt_for_lw_pip,
                                    rs_pip, rt_pip;

    wire [3:0]                      alu_ctr;
    wire [2:0]                      alu_op, alu_op_pip;
    wire [1:0]                      a_forward_ctr, b_forward_ctr;

    //test done condition
    assign addr_out = pc_addr; 


    //================================================================
    // instance (placing depends on pipeline stage), MUXes, AND
    //================================================================
    //IF stage
    `ifdef PC_REG
        assign pc_result = (flush_ctr) ? pc_target :          //to do static branch prediction and solve jump hazard
            (jump) ? j_target : pc_next;
    
        assign jump = i_out[27] & ~i_out[26];
    
        pc_register inst_pc_reg(
            .clk(clk),
            .rstn(rstn),
            .stall_ctr(stall_ctr),
            .pc_result(pc_result),
            .pc_addr(pc_addr)
        );
    `endif
    
    `ifdef I_MEM
        assign cs_rom = 1;      //enable ROM

        instruction_mem inst_rom(
            .cs_rom(cs_rom),
            .pc_addr(pc_addr),
            .i_out(i_out)
        );
    `endif

    `ifdef PC_ADD4
        pc_add4 inst_pc_add4(
            .pc_addr(pc_addr),
            .pc_next(pc_next)
        );
    `endif
    
    `ifdef J_TAR
        jump_target inst_j(
            `ifdef BRANCH_HAZARD_SOL                //after solve branch hazard
                .imme_26(i_out[25:0]),
                .pc_next_top(pc_next[31:28]),
                .j_target(j_target)
            
            `else                                   //before solve branch hazard
                .imme_26(i_out_pip[25:0]),
                .pc_next_top(pc_next_pip[31:28]),
                .j_target(j_target)
            `endif
        );
    `endif
    
    ////pipeline register
    ifid_pipe_register inst_ifid_pipereg(
        .clk(clk),
        .rstn(rstn),
        .flush_ctr(flush_ctr),
        .stall_ctr(stall_ctr),
        .pc_next(pc_next),
        .i_out(i_out),
        .i_out_pip(i_out_pip),
        .pc_next_pip(pc_next_pip)
    );
    
    //ID stage
    assign flush_ctr = (branch & z_control);          //to do flush for static branch prediction, can put into hazard detect logic
    
    `ifdef MAIN_CONT
        main_controller inst_main_cont(
            .opcode(i_out_pip[31:26]),
            .reg_dst(reg_dst),
            .alu_src(alu_src),
            .mem_to_reg(mem_to_reg),
            .reg_w(reg_w),
            .mem_r(mem_r),
            .mem_w(mem_w),
            .branch(branch),
            .alu_op(alu_op)
            //.jump(jump)
        );
    `endif
    
    `ifdef REG_FILE
        assign w_data = (mem_to_reg_pip3) ? d_out_pip : y_pip2;
    
        register_file inst_regfile(
            .clk(clk),
            .rstn(rstn),
            .w_data(w_data),
            .w_en(reg_w_pip3),
            .w_addr(wb_addr_pip2),
            .ra_addr(i_out_pip[25:21]),
            .rb_addr(i_out_pip[20:16]),
            .ra_data(ra_data),
            .rb_data(rb_data)
        );
    `endif
    
    ////to solve branch hazard
    compare_ra_rb inst_comp_ab(
        .ra_data(ra_data),
        .rb_data(rb_data),
        .beq_bne_ctr(i_out_pip[26]),
        .ab_equal(z_control)
    );
    
    `ifdef SIGN_EXT
        sign_extend inst_sign_ext(
            .imme_16(i_out_pip[15:0]),
            .imme_32(imme_32)
        );
    `endif
    
    `ifdef PC_ADD_TAR
        pc_add_target inst_addtarget(
            `ifdef BRANCH_HAZARD_SOL                //after solve branch hazard
                .pc_next(pc_next_pip),
                .imme_32(imme_32),
                .pc_target(pc_target)
            
            `else                                   //before solve branch hazard
                .pc_next(pc_next_pip2),
                .imme_32(imme_32_pip),
                .pc_target(pc_target)
            `endif
        );
    `endif
    
    ////solve data hazard between 1st and 4th instruction
    compare_wb_rarb inst_comp_w_ab(
        .ra_addr(i_out_pip[25:21]),
        .rb_addr(i_out_pip[20:16]),
        .wb_addr(wb_addr_pip2),
        .ra_data(ra_data),
        .rb_data(rb_data),
        .w_data(w_data),
        .ra_data1(ra_data1),
        .rb_data1(rb_data1)
    );
    
    ////to solve lw to R-type data hazard
    hazard_detect_unit inst_hazard_detect(
        .idex_mem_r(mem_r_pip),
        .idex_rt(rt_for_lw_pip),
        .ifid_rs(i_out_pip[25:21]),
        .ifid_rt((i_out_pip[20:16])),
        .stall_ctr(stall_ctr)
    );
    
    ////pipeline register
    assign reg_w_in = (stall_ctr) ? 0 : reg_w;
    assign mem_w_in = (stall_ctr) ? 0 : mem_w;
    
    idex_pipe_register inst_idex_pipereg(
        .clk(clk),
        .rstn(rstn),
        //.j_target(j_target),                      //remove to solve jump hazard
        //.pc_next_pip(pc_next_pip),        //remove to do static branch prediction
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_w(reg_w_in),
        .mem_r(mem_r),
        .mem_w(mem_w_in),
        .branch(branch),
        .alu_op(alu_op),
        //.jump(jump),                          //remove to solve jump hazard
        .ra_data(ra_data1),
        .rb_data(rb_data1),
        .imme_32(imme_32),
        .rd_for_rtype(i_out_pip[15:11]),
        .rt_for_lw(i_out_pip[20:16]),
        .rs(i_out_pip[25:21]),      //forwarding to solve data hazard
        .stall_ctr(stall_ctr),
    
        //.j_target_pip(j_target_pip),           //remove to solve jump hazard
        //.pc_next_pip2(pc_next_pip2),      //remove to do static branch prediction
        .reg_dst_pip(reg_dst_pip),
        .alu_src_pip(alu_src_pip),
        .mem_to_reg_pip(mem_to_reg_pip),
        .reg_w_pip(reg_w_pip),
        .mem_r_pip(mem_r_pip),
        .mem_w_pip(mem_w_pip),
        .branch_pip(branch_pip),
        .alu_op_pip(alu_op_pip),
        //.jump_pip(jump_pip),              //remove to solve jump hazard
        .ra_data_pip(ra_data_pip),
        .rb_data_pip(rb_data_pip),
        .imme_32_pip(imme_32_pip),
        .rd_for_rtype_pip(rd_for_rtype_pip),
        .rt_for_lw_pip(rt_for_lw_pip),
        .rs_pip(rs_pip),     //forwarding to solve data hazard
        .rt_pip(rt_pip),     //forwarding to solve data hazard
        .stall_ctr_pip(stall_ctr_pip)
    );
    
    //EX stage
    `ifdef ALU_CONT
        alu_controller inst_alu_cont(
            .funct(imme_32_pip[5:0]),
            .alu_op(alu_op_pip),
            .alu_ctr(alu_ctr)
        );
    `endif
    
    `ifdef ALU
        //solve R-type to R-type data hazard
        assign forward_a = (a_forward_ctr[1]) ? y_pip : 
            (a_forward_ctr[0]) ? w_data : ra_data_pip;
        assign forward_b = (b_forward_ctr[1]) ? y_pip : 
            (b_forward_ctr[0]) ? w_data : b;
    
        assign b = (~alu_src_pip) ? rb_data_pip : imme_32_pip;
    
        //to do stalling
        assign ra_data2 = (stall_ctr_pip2) ? w_data : forward_a;
        assign rb_data2 = (stall_ctr_pip2) ? w_data : forward_b;
    
        alu inst_alu(
            .a(ra_data2),
            .b(rb_data2),
            .alu_ctr(alu_ctr),
            .y(y),
            .zero(zero)
        );
    `endif
    
    ////forwarding unit to solve R-type to R-type data hazard
    forwarding_unit inst_forwarding(
        .reg_w_pip2(reg_w_pip2),
        .reg_w_pip3(reg_w_pip3),
        .wb_addr_pip(wb_addr_pip),
        .wb_addr_pip2(wb_addr_pip2),
        .rs_pip(rs_pip),
        .rt_pip(rt_pip),
        .a_forward_ctr(a_forward_ctr),
        .b_forward_ctr(b_forward_ctr)
    );
    
    ////pipeline register
    assign wb_addr = (~reg_dst_pip) ? rt_for_lw_pip : rd_for_rtype_pip;
    
    exmem_pipe_register inst_exmem_pipereg(
        .clk(clk),
        .rstn(rstn),
        //.j_target_pip(j_target_pip),       //remove to solve jump hazard
        //.pc_target(pc_target),        //remove to do static branch prediction
        .mem_to_reg_pip(mem_to_reg_pip),
        .reg_w_pip(reg_w_pip),
        .mem_r_pip(mem_r_pip),
        .mem_w_pip(mem_w_pip),
        .branch_pip(branch_pip),
        //.jump_pip(jump_pip),                  //remove to solve jump hazard
        //.z_control(z_control),                    //remove to do static predtiction
        .y(y),
        .rb_data_pip(rb_data_pip),
        .wb_addr(wb_addr),
        .stall_ctr_pip(stall_ctr_pip),
    
        //.j_target_pip2(j_target_pip2),         //remove to solve jump hazard
        //.pc_target_pip(pc_target_pip),        //remove to do static branch prediction
        .mem_to_reg_pip2(mem_to_reg_pip2),
        .reg_w_pip2(reg_w_pip2),
        .mem_r_pip2(mem_r_pip2),
        .mem_w_pip2(mem_w_pip2),
        .branch_pip2(branch_pip2),
        //.jump_pip2(jump_pip2),                //remove to solve jump hazard
        //.z_control_pip(z_control_pip),        //remove to do static predtiction
        .y_pip(y_pip),
        .rb_data_pip2(rb_data_pip2),
        .wb_addr_pip(wb_addr_pip),
        .stall_ctr_pip2(stall_ctr_pip2)
    );
    
    //MEM stage
    `ifdef D_MEM
        assign cs_ram = 1;      //enable RAM
        
        data_mem inst_ram(
            .clk(clk),
            .cs_ram(cs_ram),
            .we(mem_w_pip2),
            .oe(mem_r_pip2),
            .d_addr(y_pip),
            .d_in(rb_data_pip2),
            .d_out(d_out)
        );
    `endif
    
    ////pipeline register
    memwb_pipe_register inst_memwb_pipereg(
        .clk(clk),
        .rstn(rstn),
        .mem_to_reg_pip2(mem_to_reg_pip2),
        .reg_w_pip2(reg_w_pip2),
        .y_pip(y_pip),
        .wb_addr_pip(wb_addr_pip),
        .d_out(d_out),
    
        .mem_to_reg_pip3(mem_to_reg_pip3),
        .reg_w_pip3(reg_w_pip3),
        .y_pip2(y_pip2),
        .wb_addr_pip2(wb_addr_pip2),
        .d_out_pip(d_out_pip)
    );
    

endmodule
