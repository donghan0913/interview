`timescale 1ns / 1ps

module forwarding_unit(
    reg_w_pip2,
    reg_w_pip3,
    wb_addr_pip,
    wb_addr_pip2,
    rs_pip,
    rt_pip,
    a_forward_ctr,
    b_forward_ctr
    );

    parameter byte = 8;
    parameter instruction_width = 32;
    parameter rom_depth = 256;
    parameter ram_depth = 256;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;
    
    input reg_w_pip2, reg_w_pip3;
    input [register_addr-1:0] wb_addr_pip, wb_addr_pip2, rs_pip, rt_pip;
    output [1:0] a_forward_ctr, b_forward_ctr;

    //a_forwarrd_ctr, b_forwarrd_ctr before improvement
    assign a_forward_ctr[1] = reg_w_pip2 && (wb_addr_pip != 0) && (wb_addr_pip == rs_pip);
    assign a_forward_ctr[0] = reg_w_pip3 && (wb_addr_pip2 != 0) && (wb_addr_pip2 == rs_pip) && (wb_addr_pip != rs_pip);

    assign b_forward_ctr[1] = reg_w_pip2 && (wb_addr_pip != 0) && (wb_addr_pip == rt_pip);
    assign b_forward_ctr[0] = reg_w_pip3 && (wb_addr_pip2 != 0) && (wb_addr_pip2 == rt_pip) && (wb_addr_pip != rt_pip);


endmodule
