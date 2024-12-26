`timescale 1ns / 1ps

//`define DIRECT_ADD

module data_mem(
    clk,
    cs_ram,
    we,
    oe,
    d_addr,
    d_in,
    d_out
    );
    
    parameter byte = 8;
    parameter instruction_width = 32;
    parameter ram_depth = 256;  //for 64 data space
    
    input clk, cs_ram, we, oe;
    input [instruction_width-1:0] d_in, d_addr;
    output [instruction_width-1:0] d_out;
    
    reg [byte-1:0] ram [0:ram_depth-1];
    reg [instruction_width-1:0] d_out_reg;
    wire [instruction_width-1:0] d_addr_1, d_addr_2, d_addr_3;
    
    
    assign d_out = d_out_reg;
    always @(*) begin
        if (cs_ram & oe) begin
            d_out_reg = {ram[d_addr+3], ram[d_addr+2], ram[d_addr+1], ram[d_addr]};
        end
        else begin
            d_out_reg = 32'h0000_0000;
        end
    end
    
    always @(posedge clk) begin
        if (cs_ram & we) begin
            {ram[d_addr+3], ram[d_addr+2], ram[d_addr+1], ram[d_addr]} <= d_in;
        end
    end

/*
    assign d_out = (cs_ram & oe) ? {ram[d_addr_3], ram[d_addr_2], ram[d_addr_1], ram[d_addr]} : 32'h0000_0000;

    always @(posedge clk) begin
        if (cs_ram & we) begin
            {ram[d_addr_3], ram[d_addr_2], ram[d_addr_1], ram[d_addr]} <= d_in;
        end
    end
    
    //instance adder_32_bit to count d_addr to access 
    adder_32_bit inst_d_addr1(
        .a(d_addr),
        .b(32'h0000_0001),
        .cin(1'b0),
        .sum(d_addr_1)
        );    
    
    adder_32_bit inst_d_addr2(
        .a(d_addr),
        .b(32'h0000_0002),
        .cin(1'b0),
        .sum(d_addr_2)
        );
    
    adder_32_bit inst_d_addr3(
        .a(d_addr),
        .b(32'h0000_0003),
        .cin(1'b0),
        .sum(d_addr_3)
        );
    */
    
endmodule
