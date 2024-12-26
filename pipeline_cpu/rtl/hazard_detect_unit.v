`timescale 1ns / 1ps

module hazard_detect_unit(
    idex_mem_r,
    idex_rt,
    ifid_rs,
    ifid_rt,
    stall_ctr
    );

    parameter register_addr = 5;
    
    input idex_mem_r;
    input [register_addr-1:0] idex_rt, ifid_rs, ifid_rt;
    output stall_ctr;

    assign stall_ctr = idex_mem_r & ((idex_rt == ifid_rs) | (idex_rt == ifid_rt));


endmodule
