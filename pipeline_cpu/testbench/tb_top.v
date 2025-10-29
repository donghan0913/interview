`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/14 11:41:49
// Design Name: 
// Module Name: tb_top
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


module tb_top;
    parameter PERIOD = `PERIOD;
    parameter BYTE = 8;
    parameter WIDTH_I = 32;
    parameter DEPTH_I = 256;
    parameter DEPTH_D = 256;
    parameter ADDR_RFILE = 5;
    parameter DEPTH_RFILE = 2**ADDR_RFILE;
        
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    reg                             clk;
    reg                             rst_n;
    wire    [WIDTH_I-1:0]           addr_out;               // pc address output for check correctness
    
    top inst_top(
        .clk(clk),
        .rst_n(rst_n),
        .addr_out(addr_out)
        );

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk
    always #(PERIOD/2) clk = ~clk;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    integer i;
    integer cycle;
    
    initial begin
        clk = 0;
        rst_n = 1; 
        cycle = 0;
        
        //reset test
        @(posedge clk);
        #(PERIOD/4);
        rst_n = 0;
        
        for (i = 0; i < DEPTH_RFILE; i = i + 1) @(posedge clk);
        #(PERIOD/4);
        rst_n = 1;
        
        @(posedge clk);
        while (addr_out != 32'h0000_0080) begin
            cycle = cycle + 1;
            @(posedge clk);
        end
        
        //wait(addr_out == 32'h0000_006c);
        $display("Pipeline CPU cycle number: %d", cycle);
        for (i=0 ; i< 5 ; i=i+1) @(posedge clk);
    
        $finish();
    end


    // --------------------------------------------------------------------------------------------------------------------------------------     
    // fsdb dump
   	initial begin
`ifdef GATE_SIM
		$sdf_annotate("./mapped/top_syn.sdf", inst_top);
		$fsdbDumpfile("./waveform/top_syn.fsdb");
`else
		$fsdbDumpfile("./waveform/top.fsdb");
`endif
		$fsdbDumpvars();
	end



endmodule

