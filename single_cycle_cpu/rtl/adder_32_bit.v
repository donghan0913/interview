module adder_32_bit(
    a,
    b,
    cin,
    sum,
    cout
    );

    parameter instruction_width = 32;
    parameter cla_width = instruction_width/2;
    parameter block_num = cla_width/4;
    
    input [instruction_width-1:0] a, b;
    input cin; 
    output cout;
    output [instruction_width-1:0] sum;

    wire [cla_width-1:0] sum_high0, sum_high1, a_high, b_high, a_low, b_low, sum_low;
    wire cout_high0, cout_high1, cout_select;
    
    assign a_high = a[instruction_width-1:cla_width];
    assign a_low = a[cla_width-1:0];
    assign b_high = b[instruction_width-1:cla_width];
    assign b_low = b[cla_width-1:0];
    
    //carry select adder
    assign cout = (cout_select) ? cout_high1 : cout_high0;
    assign sum[instruction_width-1:cla_width] = (cout_select) ? sum_high1 : sum_high0;
    assign sum[cla_width-1:0] = sum_low;
    
    //instance 16-bit cla
    multilevel_cla inst_cla_high0(
        .a(a_high),
        .b(b_high),
        .cin(1'b0),
        .sum(sum_high0),
        .cout(cout_high0)
    );
    
    multilevel_cla inst_cla_high1(
        .a(a_high),
        .b(b_high),
        .cin(1'b1),
        .sum(sum_high1),
        .cout(cout_high1)
    );
    
    multilevel_cla inst_cla_low(
        .a(a_low),
        .b(b_low),
        .cin(cin),
        .sum(sum_low),
        .cout(cout_select)
    );


endmodule

