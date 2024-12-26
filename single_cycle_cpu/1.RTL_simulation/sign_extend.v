`timescale 1ns / 1ps

module sign_extend(
    imme_16,
    imme_32
    );

    parameter instruction_width = 32;
    
    input [instruction_width-17:0] imme_16;
    output reg [instruction_width-1:0] imme_32;

    always @(*) begin
        imme_32 = {{16{imme_16[15]}}, imme_16};
    end


endmodule
