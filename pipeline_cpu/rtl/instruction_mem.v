`timescale 1ns / 1ps

//`define DIRECT_ADD

module instruction_mem #(
    parameter BYTE = 8,
    parameter WIDTH_I = 32,
    parameter DEPTH_I = 256
) (
    cs_rom,
    pc_addr,
    i_out
    );

    input                           cs_rom;
    input   [WIDTH_I-1:0]           pc_addr;
    output  [WIDTH_I-1:0]           i_out;

    reg     [WIDTH_I-1:0]           i_out_reg;
    wire    [BYTE-1:0]              i_out_0;
    wire    [BYTE-1:0]              i_out_1;
    wire    [BYTE-1:0]              i_out_2;
    wire    [BYTE-1:0]              i_out_3;
    wire    [WIDTH_I-1:0]           pc_addr_1;
    wire    [WIDTH_I-1:0]           pc_addr_2;
    wire    [WIDTH_I-1:0]           pc_addr_3;

    wire    [BYTE-1:0]              rom             [0:DEPTH_I-1];

    //addi $1, $0, 8
    assign rom[32'h0000_0000] = 8'h08;
    assign rom[32'h0000_0001] = 8'h00;
    assign rom[32'h0000_0002] = 8'h01;
    assign rom[32'h0000_0003] = 8'h20;
    
    //ori $2, $0, 12
    assign rom[32'h0000_0004] = 8'h0c;
    assign rom[32'h0000_0005] = 8'h00;
    assign rom[32'h0000_0006] = 8'h02;
    assign rom[32'h0000_0007] = 8'h34;
    
    //add $3, $1, $2
    assign rom[32'h0000_0008] = 8'h20;
    assign rom[32'h0000_0009] = 8'h18;
    assign rom[32'h0000_000a] = 8'h22;
    assign rom[32'h0000_000b] = 8'h00;
    
    //sub $4, $2, $1
    assign rom[32'h0000_000c] = 8'h22;
    assign rom[32'h0000_000d] = 8'h20;
    assign rom[32'h0000_000e] = 8'h41;
    assign rom[32'h0000_000f] = 8'h00;
    
    //and $5, $1, $2
    assign rom[32'h0000_0010] = 8'h24;
    assign rom[32'h0000_0011] = 8'h28;
    assign rom[32'h0000_0012] = 8'h22;
    assign rom[32'h0000_0013] = 8'h00;

    //or $6, $1, $2
    assign rom[32'h0000_0014] = 8'h25;
    assign rom[32'h0000_0015] = 8'h30;
    assign rom[32'h0000_0016] = 8'h22;
    assign rom[32'h0000_0017] = 8'h00;
    
    //bne $1, $2, 2
    assign rom[32'h0000_0018] = 8'h02;
    assign rom[32'h0000_0019] = 8'h00;
    assign rom[32'h0000_001a] = 8'h22;
    assign rom[32'h0000_001b] = 8'h14;
    
    //add $3, $1, $2
    assign rom[32'h0000_001c] = 8'h20;
    assign rom[32'h0000_001d] = 8'h18;
    assign rom[32'h0000_001e] = 8'h22;
    assign rom[32'h0000_001f] = 8'h00;
    
    //sub $4, $2, $1
    assign rom[32'h0000_0020] = 8'h22;
    assign rom[32'h0000_0021] = 8'h20;
    assign rom[32'h0000_0022] = 8'h41;
    assign rom[32'h0000_0023] = 8'h00;
    
    //beq $1, $2, 2
    //bne $1, $2, 2 to test jump hazard after branch instruction
    assign rom[32'h0000_0024] = 8'h02;
    assign rom[32'h0000_0025] = 8'h00;
    assign rom[32'h0000_0026] = 8'h22;
    assign rom[32'h0000_0027] = 8'h10;      //14 for bne, 10 for beq
    
    //j 0000_0034
    assign rom[32'h0000_0028] = 8'h0d;
    assign rom[32'h0000_0029] = 8'h00;
    assign rom[32'h0000_002a] = 8'h00;
    assign rom[32'h0000_002b] = 8'h08;
    
    //or $6, $1, $2
    assign rom[32'h0000_002c] = 8'h25;
    assign rom[32'h0000_002d] = 8'h30;
    assign rom[32'h0000_002e] = 8'h22;
    assign rom[32'h0000_002f] = 8'h00;
    
    //sw $2, 10($8)
    assign rom[32'h0000_0034] = 8'h0a;
    assign rom[32'h0000_0035] = 8'h00;
    assign rom[32'h0000_0036] = 8'h02;
    assign rom[32'h0000_0037] = 8'had;
    
    //lw $4, 10($8)
    assign rom[32'h0000_0038] = 8'h0a;
    assign rom[32'h0000_0039] = 8'h00;
    assign rom[32'h0000_003a] = 8'h04;
    assign rom[32'h0000_003b] = 8'h8d;
    
    //addi $4, $4, 12
    assign rom[32'h0000_003c] = 8'h0c;
    assign rom[32'h0000_003d] = 8'h00;
    assign rom[32'h0000_003e] = 8'h84;
    assign rom[32'h0000_003f] = 8'h20;
    
    //sub $4, $4, 2
    assign rom[32'h0000_0040] = 8'h22;
    assign rom[32'h0000_0041] = 8'h20;
    assign rom[32'h0000_0042] = 8'h82;
    assign rom[32'h0000_0043] = 8'h00;
    
    //beq $2, $4, 2
    assign rom[32'h0000_0044] = 8'h02;
    assign rom[32'h0000_0045] = 8'h00;
    assign rom[32'h0000_0046] = 8'h44;
    assign rom[32'h0000_0047] = 8'h10;
    
    //addi $1, $1, 4
    assign rom[32'h0000_0048] = 8'h04;
    assign rom[32'h0000_0049] = 8'h00;
    assign rom[32'h0000_004a] = 8'h21;
    assign rom[32'h0000_004b] = 8'h20;
    
    //and $5, $1, $2
    assign rom[32'h0000_004c] = 8'h24;
    assign rom[32'h0000_004d] = 8'h28;
    assign rom[32'h0000_004e] = 8'h22;
    assign rom[32'h0000_004f] = 8'h00;
    
    //bne $1, $2, 6
    assign rom[32'h0000_0050] = 8'h06;
    assign rom[32'h0000_0051] = 8'h00;
    assign rom[32'h0000_0052] = 8'h22;
    assign rom[32'h0000_0053] = 8'h14;
    
    //andi $2, 9, $7
    assign rom[32'h0000_0054] = 8'h09;
    assign rom[32'h0000_0055] = 8'h00;
    assign rom[32'h0000_0056] = 8'h47;
    assign rom[32'h0000_0057] = 8'h30;
    
    //mul $5, $3, $4
    assign rom[32'h0000_006c] = 8'h02;
    assign rom[32'h0000_006d] = 8'h28;
    assign rom[32'h0000_006e] = 8'h64;
    assign rom[32'h0000_006f] = 8'h70;
    
    //add $5, $5, $2
    assign rom[32'h0000_0070] = 8'h60;
    assign rom[32'h0000_0071] = 8'h28;
    assign rom[32'h0000_0072] = 8'ha2;
    assign rom[32'h0000_0073] = 8'h00;
    
    //add $3, $1, $2
    assign rom[32'h0000_0074] = 8'h20;
    assign rom[32'h0000_0075] = 8'h18;
    assign rom[32'h0000_0076] = 8'h22;
    assign rom[32'h0000_0077] = 8'h00;
    
    //j 0000_0080
    assign rom[32'h0000_0078] = 8'h20;
    assign rom[32'h0000_0079] = 8'h00;
    assign rom[32'h0000_007a] = 8'h00;
    assign rom[32'h0000_007b] = 8'h08;
    
    
    assign i_out = i_out_reg;
    always @(*) begin
        if (cs_rom) begin
            i_out_reg = {rom[pc_addr+3], rom[pc_addr+2], rom[pc_addr+1], rom[pc_addr]};
        end
        else begin
            i_out_reg = 32'h0000_0000;
        end
    end

    //assign i_out = (cs_rom) ? {rom[pc_addr+3], rom[pc_addr+2], rom[pc_addr+1], rom[pc_addr]} : 32'h0000_0000;

    /*
    assign i_out = (cs_rom) ? {rom[pc_addr_3], rom[pc_addr_2], rom[pc_addr_1], rom[pc_addr]} : 32'h0000_0000;

    //instance adder_32_bit to count pc_addr to access 
    adder_32_bit inst_pc_addr1(
        .a(pc_addr),
        .b(32'h0000_0001),
        .cin(1'b0),
        .sum(pc_addr_1)
        );    
    
    adder_32_bit inst_pc_addr2(
        .a(pc_addr),
        .b(32'h0000_0002),
        .cin(1'b0),
        .sum(pc_addr_2)
        );
    
    adder_32_bit inst_pc_addr3(
        .a(pc_addr),
        .b(32'h0000_0003),
        .cin(1'b0),
        .sum(pc_addr_3)
        );
*/

endmodule
