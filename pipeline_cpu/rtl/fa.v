`timescale 1ns / 1ps

module fa(
    a,
    b,
    cin,
    sum,
    cout
    );

    input a, b, cin;
    output sum, cout;
    
    assign sum = (a ^ b) ^ cin;
    assign cout = (cin & (a ^ b)) | (a & b);


endmodule
