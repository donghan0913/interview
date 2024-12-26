module pc_add4(
    pc_addr,
    pc_next
    );

    parameter instruction_width = 32;
    
    input [instruction_width-1:0] pc_addr;
    output [instruction_width-1:0] pc_next;
    
    wire [instruction_width-1:0] b;
    
    assign b = 32'h0000_0004;
    
    //instance adder_32_bit (after improvement)
    /*
    adder_32_bit inst_pc4_adder(
        .a(pc_addr),
        .b(b),
        .cin(1'b0),
        .sum(pc_next)
    );
    */
    
    //before improvement
    assign pc_next = pc_addr + b;


endmodule
