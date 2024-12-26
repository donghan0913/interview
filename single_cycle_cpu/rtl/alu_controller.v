module alu_controller(
    funct,
    alu_op,
    alu_ctr
    );
    
    input [5:0] funct;
    input [2:0] alu_op;
    output reg [3:0] alu_ctr;
    
    always @(*) begin
        alu_ctr[3] = ~alu_op[2] & alu_op[1] & funct[1] & funct[0];
    end
    
    always @(*) begin
        alu_ctr[2] = (~alu_op[2] & alu_op[1] & funct[1]) | (~alu_op[1] & alu_op[0]);
    end
    
    always @(*) begin
        alu_ctr[1] = (~alu_op[2] & alu_op[1] & ~funct[2]) | (~alu_op[2] & ~alu_op[1]) | (alu_op[2] & alu_op[1] & ~alu_op[0]) | (~alu_op[1] & alu_op[0]);
    end
    
    always @(*) begin
        alu_ctr[0] = (~alu_op[2] & alu_op[1] & ~funct[1] & funct[0]) | (alu_op[2] & ~alu_op[1] & ~alu_op[0]);
    end

    
endmodule
