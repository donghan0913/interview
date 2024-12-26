`timescale 1ns / 1ps

module compare_wb_rarb(
    ra_addr,
    rb_addr,
    wb_addr,
    ra_data,
    rb_data,
    w_data,
    ra_data1,
    rb_data1
    );

    parameter byte = 8;
    parameter instruction_width = 32;
    parameter rom_depth = 256;
    parameter ram_depth = 256;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;

    input [register_addr-1:0] ra_addr, rb_addr, wb_addr;
    input [instruction_width-1:0] ra_data, rb_data, w_data;
    output [instruction_width-1:0] ra_data1, rb_data1;

    wire compare_ra, compare_rb;

    assign compare_ra = ~|(ra_addr ^ wb_addr);
    assign compare_rb = ~|(rb_addr ^ wb_addr);

    assign ra_data1 = (compare_ra) ? w_data : ra_data;
    assign rb_data1 = (compare_rb) ? w_data : rb_data;


endmodule
