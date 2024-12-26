module register_file(
    clk,
    rstn,
    w_data,
    w_en,
    w_addr,
    ra_addr,
    rb_addr,
    ra_data,
    rb_data
    );
    
    parameter instruction_width = 32;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;
    
    input clk, rstn, w_en;
    input [instruction_width-1:0] w_data;
    input [register_addr-1:0] w_addr, ra_addr, rb_addr;
    output reg [instruction_width-1:0] ra_data, rb_data;
    
    reg [instruction_width-1:0] regfile [register_file_depth-1:0];
    
    integer i;
    
    always @(*) begin
        ra_data = regfile[ra_addr];
    end
    
    always @(*) begin
        rb_data = regfile[rb_addr];
    end
    
    always @(posedge clk) begin
        if(~rstn) begin
            for(i=0 ; i<register_file_depth ; i=i+1) begin
                regfile[i] <= 0;
            end
        end
        else begin
            if (w_en) begin
                regfile[w_addr] <= w_data;
            end
        end
    end
    
    
endmodule
