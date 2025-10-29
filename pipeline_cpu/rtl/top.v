`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/13 13:36:22
// Design Name: 
// Module Name: top
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
//`define LP_GATE


module top(
    clk,
    rst_n,
    addr_out
    );

    parameter BYTE = 8;
    parameter WIDTH_I = 32;
    parameter WIDTH_D = 32;
    parameter DEPTH_I = 256;
    parameter DEPTH_D = 256;
    parameter ADDR_RFILE = 5;
    parameter DEPTH_RFILE = 2**ADDR_RFILE;

    input                           clk;
    input                           rst_n;
    output  [WIDTH_I-1:0]           addr_out;               // pc address output to check correctness


    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // internal signals declaration
    //// pc & pc adders signals
    wire    [WIDTH_I-1:0]           pc_addr;                // pc address from pc counter
    wire    [WIDTH_I-1:0]           pc_result;              // pc address to pc counter
    wire    [WIDTH_I-1:0]           pc_next;                // pc next address for PC + 4
    wire    [WIDTH_I-1:0]           pc_target;              // branch target after branch adder
    
    //// jump signals
    wire                            jump;                   // jump instruction enable
    wire    [WIDTH_I-1:0]           j_target;               // jump target after concatenate
    
    //// instruction memory signals
    wire    [WIDTH_I-1:0]           memi_out;               // insruction memory output
    
    //// main controller signals
    wire                            rfile_dst;              // select whether rt(load) or rd(r-type) as wb address
    wire                            alu_src;                // select whether rb or imme as ALU input
    wire                            mem_to_rfile;           // select whether d_out or y as wb_data
    wire                            rfile_w;                // register file write enable
    wire                            mem_r;                  // data memory read enable
    wire                            mem_w;                  // data memory write enable
    wire                            branch;                 // branch instruction enable
    wire    [2:0]                   alu_op;                 // ALU opcode
    wire                            mult_sel;               // select multiplier or ALU output into pipreg_exmem
    
    //// register file signals
    wire    [WIDTH_D-1:0]           wb_data;                // write back data to register file
    wire    [WIDTH_D-1:0]           ra_data;                // register file data output
    wire    [WIDTH_D-1:0]           rb_data;                // register file data output
    
    //// immediate extension signals
    wire    [WIDTH_D-1:0]           imme_32;                // immediate do signed extension to 32-bit
    
    //// comp_wab signals
    wire    [WIDTH_D-1:0]           ra_data_wab;            // register file data output after comp_wab data hazard dealing
    wire    [WIDTH_D-1:0]           rb_data_wab;            // register file data output after comp_wab data hazard dealing
    
    //// ALU controller signals
    wire    [3:0]                   alu_ctrl;               // select ALU operation
    
    //// ALU signals
    wire    [WIDTH_D-1:0]           ra_data_frd;            // ALU input after forwarding or not
    wire    [WIDTH_D-1:0]           rb_data_frd;            // ALU input after forwarding or not
    wire    [WIDTH_D-1:0]           rb_data_alusrc;         // ALU input after alu_src select
    wire    [WIDTH_D-1:0]           ra_data_alu;            // ALU input after stalling or not
    wire    [WIDTH_D-1:0]           rb_data_alu;            // ALU input after stalling or not
    wire    [WIDTH_D-1:0]           y;                      // ALU output
    wire                            zero;                   // ALU output all zero or not
    
    //// MDU signals
    wire    [WIDTH_D-1:0]           p;                      // MDU output
    
    //// data memory signals
    wire    [WIDTH_D-1:0]           memd_out;               // data memory d_out
    
    //// hazard control signals
    wire                            flush_ctrl;             // flush control to solve branch hazard
    wire    [1:0]                   stall_ctrl_ab;          // [1] for rs(a), [0] for rt(b)
    wire                            stall_ctrl;             // stall control to solve lw-to-R data hazard
    wire    [1:0]                   frd_ctrl_a;             // forwarding control to solve R-R data hazard
    wire    [1:0]                   frd_ctrl_b;             // forwarding control to solve R-R data hazard
`ifdef LP_GATE    
    wire                            valid;                  // data gating enable signal for low power ICG cell combine stall and flush
`endif

    //// if-id pipeline register signals
    wire    [WIDTH_I-1:0]           memi_out_t;             // insruction memory output after pipeline
    wire    [WIDTH_I-1:0]           pc_next_t;              // pc next address for PC + 4 after pipeline
    
    //// id-ex pipeline register signals
    wire                            rfile_dst_t;            // select whether rt(load) or rd(r-type) as wb address after pipeline
    wire                            alu_src_t;              // select whether rb or imme as ALU input after pipeline
    wire                            mem_to_rfile_t;         // select whether d_out or y as wb_data after pipeline
    wire                            rfile_w_t;              // register file write enable after pipeline
    wire                            mem_r_t;                // data memory read enable after pipeline
    wire                            mem_w_t;                // data memory write enable after pipeline
    wire    [2:0]                   alu_op_t;               // ALU opcode after pipeline
    wire    [WIDTH_D-1:0]           ra_data_wab_t;          // register file data output after pipeline
    wire    [WIDTH_D-1:0]           rb_data_wab_t;          // register file data output after pipeline
    wire    [WIDTH_D-1:0]           imme_32_t;              // immediate do signed extension to 32-bit after pipeline
    wire    [ADDR_RFILE-1:0]        addr_rd_t;              // register file Rd address after pipeline
    wire    [ADDR_RFILE-1:0]        addr_rt_t;              // register file Rt address after pipeline
    wire    [ADDR_RFILE-1:0]        addr_rs_t;              // register file Rs address after pipeline
    wire    [1:0]                   stall_ctrl_ab_t;        // [1] for rs(a), [0] for rt(b)
    wire                            stall_ctrl_t;           // stall control to solve lw-to-R data hazard after pipeline
    wire                            mult_sel_t;             // select multiplier or ALU output into pipreg_exmem after pipeline
`ifdef LP_GATE 
    wire                            flush_ctrl_t;           // flush control to solve branch hazard after pipeline
    wire                            valid_t;                // data gating enable signal for low power ICG cell combine stall and flush after pipeline
`endif
    
    //// ex-mem pipeline register signals
    wire    [ADDR_RFILE-1:0]        wb_addr;                // write back address for register file
    wire                            mem_to_rfile_t2;        // select whether d_out or y as wb_data after 2 stage pipeline
    wire                            rfile_w_t2;             // register file write enable after 2 stage pipeline
    wire                            mem_r_t2;               // data memory read enable after 2 stage pipeline
    wire                            mem_w_t2;               // data memory write enable after 2 stage pipeline
    //wire                            branch_t2;              // branch instruction enable after 2 stage pipeline
    wire    [WIDTH_D-1:0]           rb_data_wab_t2;         // register file data output after 2 stage pipeline
    wire    [ADDR_RFILE-1:0]        wb_addr_t;              // write back address for register file after pipeline
    wire    [1:0]                   stall_ctrl_ab_t2;       // [1] for rs(a), [0] for rt(b)
    wire                            stall_ctrl_t2;          // stall control to solve lw-to-R data hazard after 2 stage pipeline
    wire                            mult_sel_t2;            // select multiplier or ALU output into pipreg_exmem after 2 stage pipeline
    wire    [WIDTH_D-1:0]           y_t;                    // ALU output after pipeline
`ifdef LP_GATE 
    wire                            flush_ctrl_t2;          // flush control to solve branch hazard after 2 stage pipeline
    wire                            valid_t2;               // data gating enable signal for low power ICG cell combine stall and flush after 2 stage pipeline
`endif
    
    //// mem-wb pipeline register signals
    wire                            mem_to_rfile_t3;        // select whether d_out or y as wb_data after 3 stage pipeline
    wire                            rfile_w_t3;             // register file write enable after 3 stage pipeline
    wire    [ADDR_RFILE-1:0]        wb_addr_t2;             // write back address for register file after 2 stage pipeline
    wire    [WIDTH_D-1:0]           memd_out_t;             // data memory d_out after pipeline
    wire    [WIDTH_D-1:0]           py_out;                 // output after selected by mult_sel_t2
    wire    [WIDTH_D-1:0]           py_out_t;               // output selected by mult_sel_t after pipeline
`ifdef LP_GATE
    wire                            flush_ctrl_t3;          // flush control to solve branch hazard after 3 stage pipeline
    wire                            valid_t3;               // data gating enable signal for low power ICG cell combine stall and flush after 3 stage pipeline
`endif
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // output
    assign addr_out = pc_addr;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // low power data gating
`ifdef LP_GATE     
    //assign valid = ~(stall_ctrl | flush_ctrl);
    assign valid = ~flush_ctrl;
`endif
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    //// pc counter
    assign pc_result = (flush_ctrl) ? pc_target :           // do static branch prediction and solve jump hazard
            (jump) ? j_target : pc_next;
    
    assign jump = memi_out[27] & ~memi_out[26];

    pc_ctr #(
        .WIDTH_I(WIDTH_I)
    ) inst_pc_ctr(
        .clk(clk),
        .rst_n(rst_n),
        .stall_ctrl(stall_ctrl),
        .pc_result(pc_result),
        .pc_addr(pc_addr)
        );
        
    pc_add4 #(
        .WIDTH_I(WIDTH_I)
    ) inst_pc_add4(
        .pc_addr(pc_addr),
        .pc_next(pc_next)
        );

    //// instruction memory
    instruction_mem #(
        .BYTE(BYTE),
        .WIDTH_I(WIDTH_I),
        .DEPTH_I(DEPTH_I)
    ) inst_rom(
        .cs_rom(1'b1),
        .pc_addr(pc_addr),
        .i_out(memi_out)
        );

    //// jump
    jump_target #(
        .WIDTH_I(WIDTH_I)
    ) inst_j_target(
        .imme_26(memi_out[25:0]),
        .pc_next_top(pc_next[31:28]),
        .j_target(j_target)
        );

    //// if-id pipeline register  
    pipreg_ifid #(
        .WIDTH_I(WIDTH_I)
    ) inst_pipreg_ifid(
        .clk(clk),
        .rst_n(rst_n),
        .flush_ctrl(flush_ctrl),
        .stall_ctrl(stall_ctrl),
        .pc_next(pc_next),
        .memi_out(memi_out),
        .memi_out_t(memi_out_t),
        .pc_next_t(pc_next_t)
        );

    //// main controller
    main_ctrl #(
        .WIDTH_I(WIDTH_I)
    ) inst_main_ctrl(
            .opcode(memi_out_t[31:26]),
            .rfile_dst(rfile_dst),
            .alu_src(alu_src),
            .mem_to_rfile(mem_to_rfile),
            .rfile_w(rfile_w),
            .mem_r(mem_r),
            .mem_w(mem_w),
            .branch(branch),
            .alu_op(alu_op),
            .mult_sel(mult_sel)
        );

    //// register file
    assign wb_data = (mem_to_rfile_t3) ? memd_out_t : py_out_t;
    
    rfile #(
        .WIDTH_I(WIDTH_I),
        .ADDR_RFILE(ADDR_RFILE),
        .DEPTH_RFILE(DEPTH_RFILE)
    ) inst_rfile(
        .clk(clk),
        .rst_n(rst_n),
        .w_data(wb_data),
        .w_en(rfile_w_t3),
        .w_addr(wb_addr_t2),
        .ra_addr(memi_out_t[25:21]),
        .rb_addr(memi_out_t[20:16]),
        .ra_data(ra_data),
        .rb_data(rb_data)
        );

    //// compare ra & rb to do branch or not, and solve branch hazard
    comp_ab #(
        .WIDTH_I(WIDTH_I)
    ) inst_comp_ab(
        .ra_data(ra_data),
        .rb_data(rb_data),
        .branch_sel(memi_out_t[26]),
        .branch(branch),
        .flush_ctrl(flush_ctrl)
        );

    //// signed extension for immediate
    imme_extend #(
        .WIDTH_I(WIDTH_I)
    ) inst_imme_extend(
        .imme_16(memi_out_t[15:0]),
        .imme_32(imme_32)
        );
    
    //// pc target adder
    pc_add_target #(
        .WIDTH_I(WIDTH_I)
    ) inst_addtarget(
        .pc_next(pc_next_t),
        .imme_32(imme_32),
        .pc_target(pc_target)
        );
    
    //// solve 1st-4th R-R data hazard by forward
    comp_wab #(
        .WIDTH_D(WIDTH_D),
        .ADDR_RFILE(ADDR_RFILE)
    ) inst_comp_wab(
        .ra_addr(memi_out_t[25:21]),
        .rb_addr(memi_out_t[20:16]),
        .rfile_w_t3(rfile_w_t3),
        .wb_addr(wb_addr_t2),
        .ra_data(ra_data),
        .rb_data(rb_data),
        .wb_data(wb_data),
        .ra_data_wab(ra_data_wab),
        .rb_data_wab(rb_data_wab)
        );

    //// solve lw-R data hazard
    stall #(
        .ADDR_RFILE(ADDR_RFILE)
    ) inst_stall(
        .mem_r_idex(mem_r_t),
        .mult_sel_idex(mult_sel_t),
        .addr_rt_idex(addr_rt_t),
        .addr_rs_ifid(memi_out_t[25:21]),
        .addr_rt_ifid(memi_out_t[20:16]),
        .addr_rd_idex(addr_rd_t),
        .stall_ctrl_ab(stall_ctrl_ab),
        .stall_ctrl(stall_ctrl)
        );    
    
    //// id-ex pipeline register    
    pipreg_idex #(
        .WIDTH_D(WIDTH_D),
        .ADDR_RFILE(ADDR_RFILE)
    ) inst_pipreg_idex(
        .clk(clk),
        .rst_n(rst_n),
        .rfile_dst(rfile_dst),
        .alu_src(alu_src),
        .mem_to_rfile(mem_to_rfile),
        .rfile_w(rfile_w),
        .mem_r(mem_r),
        .mem_w(mem_w),
        .alu_op(alu_op),
        .ra_data_wab(ra_data_wab),
        .rb_data_wab(rb_data_wab),
        .imme_32(imme_32),
        .addr_rd(memi_out_t[15:11]),
        .addr_rt(memi_out_t[20:16]),
        .addr_rs(memi_out_t[25:21]),      //forwarding to solve data hazard
        .stall_ctrl_ab(stall_ctrl_ab),
        .stall_ctrl(stall_ctrl),
        .mult_sel(mult_sel),
`ifdef LP_GATE         
        .flush_ctrl(flush_ctrl),
`endif        

        .rfile_dst_t(rfile_dst_t),
        .alu_src_t(alu_src_t),
        .mem_to_rfile_t(mem_to_rfile_t),
        .rfile_w_t(rfile_w_t),
        .mem_r_t(mem_r_t),
        .mem_w_t(mem_w_t),
        .alu_op_t(alu_op_t),
        .ra_data_wab_t(ra_data_wab_t),
        .rb_data_wab_t(rb_data_wab_t),
        .imme_32_t(imme_32_t),
        .addr_rd_t(addr_rd_t),
        .addr_rt_t(addr_rt_t),
        .addr_rs_t(addr_rs_t),     //forwarding to solve data hazard
        .stall_ctrl_ab_t(stall_ctrl_ab_t),
        .stall_ctrl_t(stall_ctrl_t),
`ifdef LP_GATE 
        .flush_ctrl_t(flush_ctrl_t),
`endif        
        .mult_sel_t(mult_sel_t)
        );

    //// ALU controller
    alu_ctrl inst_alu_ctrl(
        .funct(imme_32_t[5:0]),
        .alu_op(alu_op_t),
        .alu_ctrl(alu_ctrl)
        );
        
    //// ALU
    assign ra_data_frd = (frd_ctrl_a[1]) ? y_t : 
        (frd_ctrl_a[0]) ? wb_data : ra_data_wab_t;
    assign rb_data_frd = (frd_ctrl_b[1]) ? y_t : 
        (frd_ctrl_b[0]) ? wb_data : rb_data_wab_t;

    assign rb_data_alusrc = (~alu_src_t) ? rb_data_frd : imme_32_t;

    alu #(
        .WIDTH_D(WIDTH_D)
    ) inst_alu(
        .a(ra_data_frd),
        .b(rb_data_alusrc),
        .alu_ctrl(alu_ctrl),
        .y(y),
        .zero(zero)
        );

    //// forwarding unit
    forward #(
        .ADDR_RFILE(ADDR_RFILE)
    ) inst_forward(
        .rfile_w_t2(rfile_w_t2),
        .rfile_w_t3(rfile_w_t3),
        .wb_addr_t(wb_addr_t),
        .wb_addr_t2(wb_addr_t2),
        .addr_rs_t(addr_rs_t),
        .addr_rt_t(addr_rt_t),
`ifdef LP_GATE
        .flush_ctrl_t(flush_ctrl_t),
`endif
        .stall_ctrl_t2(stall_ctrl_t2),
        .frd_ctrl_a(frd_ctrl_a),
        .frd_ctrl_b(frd_ctrl_b)
        );

    //// MDU
    mult_array #(
        .WIDTH_D(WIDTH_D)
    ) inst_mdu(
        .clk(clk),
        .rst_n(rst_n),
        .a(ra_data_frd),
        .b(rb_data_alusrc),
        .p_out(p)
        );

    //// ex-mem pipeline register   
    assign wb_addr = (~rfile_dst_t) ? addr_rt_t : addr_rd_t;
    
    pipreg_exmem #(
        .WIDTH_D(WIDTH_D),
        .ADDR_RFILE(ADDR_RFILE)
    ) inst_pipreg_exmem(
        .clk(clk),
        .rst_n(rst_n),
        .mem_to_rfile_t(mem_to_rfile_t),
        .rfile_w_t(rfile_w_t),
        .mem_r_t(mem_r_t),
        .mem_w_t(mem_w_t),
        .y(y),
        .rb_data_wab_t(rb_data_wab_t),
        .wb_addr(wb_addr),
        .stall_ctrl_ab_t(stall_ctrl_ab_t),
        .stall_ctrl_t(stall_ctrl_t),
        .mult_sel_t(mult_sel_t),
`ifdef LP_GATE
        .flush_ctrl_t(flush_ctrl_t),
`endif
    
        .mem_to_rfile_t2(mem_to_rfile_t2),
        .rfile_w_t2(rfile_w_t2),
        .mem_r_t2(mem_r_t2),
        .mem_w_t2(mem_w_t2),
        .y_t(y_t),
        .rb_data_wab_t2(rb_data_wab_t2),
        .wb_addr_t(wb_addr_t),
        .stall_ctrl_ab_t2(stall_ctrl_ab_t2),
        .stall_ctrl_t2(stall_ctrl_t2),
 `ifdef LP_GATE
        .flush_ctrl_t2(flush_ctrl_t2),
`endif
        .mult_sel_t2(mult_sel_t2)
        );

    //// data memory
    data_mem #(
        .BYTE(BYTE),
        .WIDTH_D(WIDTH_D),
        .DEPTH_D(DEPTH_D)
    ) inst_ram(
        .clk(clk),
        .cs_ram(1'b1),
        .we(mem_w_t2),
        .oe(mem_r_t2),
        .d_addr(y_t),
        .d_in(rb_data_wab_t2),
        .d_out(memd_out)
        );

    //// mem-wb pipeline register   
    assign py_out = (mult_sel_t2) ? p : y_t;
    
    pipreg_memwb #(
        .WIDTH_D(WIDTH_D),
        .ADDR_RFILE(ADDR_RFILE)
    ) inst_pipreg_memwb(
        .clk(clk),
        .rst_n(rst_n),
        .mem_to_rfile_t2(mem_to_rfile_t2),
        .rfile_w_t2(rfile_w_t2),
        .py_out(py_out),
        .wb_addr_t(wb_addr_t),
        .memd_out(memd_out),
        .stall_ctrl_t2(stall_ctrl_t2),
`ifdef LP_GATE
        .flush_ctrl_t2(flush_ctrl_t2),
`endif
    
        .mem_to_rfile_t3(mem_to_rfile_t3),
        .rfile_w_t3(rfile_w_t3),
        .py_out_t(py_out_t),
        .wb_addr_t2(wb_addr_t2),
`ifdef LP_GATE
        .flush_ctrl_t3(flush_ctrl_t3),
`endif
        .memd_out_t(memd_out_t)
        );


endmodule

