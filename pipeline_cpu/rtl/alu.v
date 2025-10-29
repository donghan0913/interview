`timescale 1ns / 1ps

`define MODULAR

module alu #(
    parameter WIDTH_D = 32
) (
    a,
    b,
    alu_ctrl,
    y,
    zero
    );

    input   [WIDTH_D-1:0]           a;
    input   [WIDTH_D-1:0]           b;
    input   [3:0]                   alu_ctrl; 
    output                          zero;
    output  [WIDTH_D-1:0]           y;

    wire                            set_less;
    wire                            ainvert;
    wire                            bnegate;
    wire    [1:0]                   op;
    wire    [WIDTH_D:0]             carry; 
    
    assign carry[0] = bnegate;
    assign ainvert = alu_ctrl[3];
    assign bnegate = alu_ctrl[2];
    assign op = alu_ctrl[1:0];
    
    //zero
    assign zero = ~(|y);
    
    `ifdef MODULAR
        //alu group
        genvar i;
        generate
            for (i=0; i<WIDTH_D; i=i+1) begin: alu_group
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
                else if (i==WIDTH_D-1) begin: alu_bit31
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
    
    `else
        //before improvement
        reg     [WIDTH_D-1:0]           y_reg;
        
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
    `endif


endmodule
