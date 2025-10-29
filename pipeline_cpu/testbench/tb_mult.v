`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/15 12:02:50
// Design Name: 
// Module Name: tb_mult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_mult;
    parameter PERIOD = 2;
    parameter WIDTH_D = 4;
    parameter WIDTH_P = 2 * WIDTH_D;
    parameter MAX = 2 ** WIDTH_D;
    
    reg     [WIDTH_P-1:0]           p_gold;                 // 64-bit product gold answer

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    reg                             clk;
    reg                             rst_n;
    reg     [WIDTH_D-1:0]           a;
    reg     [WIDTH_D-1:0]           b;
    wire    [WIDTH_P-1:0]           p;                      // 64-bit product
    
    mult_array #(
        .WIDTH_D(WIDTH_D)
    ) inst_mult(
        /*.clk(clk),
        .rst_n(rst_n),*/
        .a(a),
        .b(b),
        .p(p)
        );
    

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk
    always #(PERIOD/2) clk = ~clk;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // task
    task fail_display;
		begin
			$display();
			$display("------------------------------------------------");
			$display("Fail !!");
			$display("gold p: %d,    actual p: %d", p_gold, p);
			$display("------------------------------------------------");
			$display();
		end
	endtask    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    integer i, j_row, j_col;
    initial begin
        clk = 0;
        rst_n = 1;
        a = 0;
        b = 0;
        p_gold = 0;
        
        $display();
		$display("Stimulus start >>>");
		$display("------------------------------------------------");
        @(posedge clk);
        for (j_row = 0; j_row < MAX; j_row = j_row + 1) begin
            for (j_col = 0; j_col < MAX; j_col = j_col + 1) begin
                //// display
                $display("a = %d,   b = %d, gold p: %d, actual p: %d", a, b, p_gold, p);
            
                //// compare output
                if (p != p_gold) begin
                    fail_display();
                    $finish();
                end                

                //// generate deterministic inputs
                #(PERIOD/2);
                a = j_row;
                b = j_col;
                p_gold = a * b;
                @(posedge clk);     
            end        
        
        end
        
        //// display
        $display("a = %d,   b = %d, gold p: %d, actual p: %d", a, b, p_gold, p);
            
        //// compare output
        if (p != p_gold) begin
            fail_display();
            $finish();
        end    
    
    
        $display();
		$display("Test finish !!");
    
        for (i=0 ; i< 5 ; i=i+1) @(posedge clk);    
        $finish();
    
    
    end


endmodule

