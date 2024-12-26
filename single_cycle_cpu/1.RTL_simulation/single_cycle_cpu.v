`timescale 1ns / 1ps

////define for submodule simulation
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

module single_cycle_cpu(
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

    wire cs_rom, cs_ram, we, oe, w_en, zero, z_control, reg_dst, alu_src, mem_to_reg, reg_w, mem_r, mem_w, branch, jump;
    wire [instruction_width-1:0] i_out, d_in, d_out, w_data, ra_data, rb_data, a, b, y, imme_32, pc_result, pc_addr, pc_next, pc_target, j_target, d_addr;
    wire [instruction_width-7:0] imme_26;
    wire [instruction_width-17:0] imme_16;
    wire [5:0] opcode, funct;
    wire [register_addr-1:0] w_addr, ra_addr, rb_addr;
    wire [2:0] alu_op;
    wire [3:0] alu_ctr, pc_next_top;


    //================================================================
    // MUXes, AND
    //================================================================
    assign w_addr = (~reg_dst) ? i_out[20:16] : i_out[15:11];
    assign w_data = (mem_to_reg) ? d_out : y;
    assign b = (~alu_src) ? rb_data : imme_32;
    assign pc_result = (jump) ? j_target :
        (branch & z_control) ? pc_target : pc_next;
    assign z_control = (~alu_op[2]) ? zero : ~zero;

    assign cs_rom = 1;
    assign cs_ram = 1;

    assign addr_out = pc_addr;  //test done condition


    //================================================================
    // instance
    //================================================================   
    `ifdef I_MEM
    instruction_mem inst_rom(
        .cs_rom(cs_rom),
        .pc_addr(pc_addr),
        .i_out(i_out)
    );
    `endif

    `ifdef D_MEM
    data_mem inst_ram(
        .clk(clk),
        .cs_ram(cs_ram),
        .we(mem_w),
        .oe(mem_r),
        .d_addr(y),
        .d_in(rb_data),
        .d_out(d_out)
    );
    `endif
    
    `ifdef REG_FILE
    register_file inst_regfile(
        .clk(clk),
        .rstn(rstn),
        .w_data(w_data),
        .w_en(reg_w),
        .w_addr(w_addr),
        .ra_addr(i_out[25:21]),
        .rb_addr(i_out[20:16]),
        .ra_data(ra_data),
        .rb_data(rb_data)
    );
    `endif

    `ifdef ALU
    alu inst_alu(
        .a(ra_data),
        .b(b),
        .alu_ctr(alu_ctr),
        .y(y),
        .zero(zero)
    );
    `endif
    
    `ifdef MAIN_CONT
    main_controller inst_main_cont(
        .opcode(i_out[31:26]),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_w(reg_w),
        .mem_r(mem_r),
        .mem_w(mem_w),
        .branch(branch),
        .alu_op(alu_op),
        .jump(jump)
    );
    `endif
    
    `ifdef ALU_CONT
    alu_controller inst_alu_cont(
        .funct(i_out[5:0]),
        .alu_op(alu_op),
        .alu_ctr(alu_ctr)
    );
    `endif

    `ifdef PC_REG
    pc_register inst_pc_reg(
        .clk(clk),
        .rstn(rstn),
        .pc_result(pc_result),
        .pc_addr(pc_addr)
    );
    `endif
    
    `ifdef PC_ADD4
    pc_add4 inst_pc_add4(
        .pc_addr(pc_addr),
        .pc_next(pc_next)
    );
    `endif
    
    `ifdef PC_ADD_TAR
    pc_add_target inst_addtarget(
        .pc_next(pc_next),
        .imme_32(imme_32),
        .pc_target(pc_target)
    );
    `endif
    
    `ifdef J_TAR
    jump_target inst_j(
        .imme_26(i_out[25:0]),
        .pc_next_top(pc_next[31:28]),
        .j_target(j_target)
    );
    `endif
    
    `ifdef SIGN_EXT
    sign_extend inst_sign_ext(
        .imme_16(i_out[15:0]),
        .imme_32(imme_32)
    );
    `endif


endmodule
