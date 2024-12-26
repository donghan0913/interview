`timescale 1ns / 1ps

module alu(
    a,
    b,
    alu_ctr,
    y,
    zero
    );
    
    parameter instruction_width = 32;

    input [instruction_width-1:0] a, b;
    input [3:0] alu_ctr; 
    output zero;
    output [instruction_width-1:0] y;

    wire set_less, ainvert, bnegate;
    wire [1:0] op;
    wire [instruction_width:0] carry; 
    
    assign carry[0] = bnegate;
    assign ainvert = alu_ctr[3];
    assign bnegate = alu_ctr[2];
    assign op = alu_ctr[1:0];
    
    //zero
    assign zero = ~(|y);
    
    //alu group (after improvement)
    
    genvar i;
    generate
        for (i=0; i<instruction_width; i=i+1) begin: alu_group
            if (i==0) begin: alu_bit0
                alu_1_bit inst_alu0(
                    .a(a[i]),
                    .b(b[i]),
                    .set_less(set_less),
                    .ainvert(ainvert),
                    .bnegate(bnegate),
                    .cin(carry[i]),
                    .cout(carry[i+1]),
                    .op(op),
                    .result(y[i])
                    );
            end
            else if (i==instruction_width-1) begin: alu_bit31
                alu_1_bit inst_alu31(
                    .a(a[i]),
                    .b(b[i]),
                    .set_less(1'b0),
                    .ainvert(ainvert),
                    .bnegate(bnegate),
                    .cin(carry[i]),
                    .cout(carry[i+1]),
                    .op(op),
                    .result(y[i]),
                    .set(set_less)
                    );
            end
            else begin: alu_bit1to30
                alu_1_bit inst_alu_group(
                    .a(a[i]),
                    .b(b[i]),
                    .set_less(1'b0),
                    .ainvert(ainvert),
                    .bnegate(bnegate),
                    .cin(carry[i]),
                    .cout(carry[i+1]),
                    .op(op),
                    .result(y[i])
                    );
            end
        end
    endgenerate
    

    //before improvement
    /*    
    reg [instruction_width-1:0] y_reg;
    
    assign y = y_reg;
    always @(*) begin
        case(alu_ctr)
            4'b0000: y_reg = a & b;    
            4'b0001: y_reg = a | b;
            4'b0010: y_reg = a + b;
            4'b0110: y_reg = a + (~b) + 1;
            4'b0111: y_reg = (a < b) ? 1 : 0;
            4'b1100: y_reg = ~(a | b);
            default: y_reg = 32'hzzzz_zzzz;
        endcase
    end
    */


endmodule
