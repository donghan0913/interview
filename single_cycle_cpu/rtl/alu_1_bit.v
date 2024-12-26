module alu_1_bit(
    a,
    b,
    set_less,
    ainvert,
    bnegate,
    cin,
    cout,
    op,
    result,
    set
    );

    input a, b, set_less, ainvert, bnegate, cin;
    input [1:0] op;
    output wire cout, result, set;
    
    reg result_reg;
    wire a_wire, b_wire, sum;

    assign a_wire = (ainvert) ? ~a : a;    
    assign b_wire = (bnegate) ? ~b : b;

    //select result
    assign result = result_reg;
    always @(*) begin
        case(op)
            2'd0: result_reg = a_wire & b_wire;
            2'd1: result_reg = a_wire | b_wire;
            2'd2: result_reg = sum;
            2'd3: result_reg = set_less;
        endcase
    end
    
    //select set
    assign set = sum;
    
    
    //instance fa
    fa inst_fa(
        .a(a_wire),
        .b(b_wire),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    
    //assign {cout, sum} = a_wire + b_wire + cin; 
    


endmodule
