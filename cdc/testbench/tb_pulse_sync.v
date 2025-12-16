`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/03 14:26:21
// Design Name: 
// Module Name: tb_pulse_sync
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


module tb_pulse_sync;

    parameter PERIOD_SRC    = `P_SRC;                       // source domain clock period
    parameter PERIOD_DST    = `P_DST;                       // destination domain clock period
    parameter DELAY         = PERIOD_SRC/4.0;               // small time interval used in stimulus
    parameter PULSE_SPACE   = 1;                            // clk_src cycles between input pulse
    parameter PULSE_CNT     = 5;                            // input pulse number

    reg                                 clk_src;            // source domain clock
    reg                                 clk_dst;            // destination domain clock


    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate    
    localparam PEND_CNT = ((2 * PERIOD_SRC) + (2 * PERIOD_DST)) / PERIOD_SRC;
    localparam PEND_CNT_SIZE = 3;
    
    reg                                 rst_n;
    reg                                 d_in;
    wire                                d_out;

    pulse_sync #(
        .PEND_CNT_SIZE(PEND_CNT_SIZE)
    ) inst_pulse_sync(
        .clk_src(clk_src),
        .clk_dst(clk_dst),
        .rst_n(rst_n),
        .d_in(d_in),
        .d_out(d_out)
        );

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk
    always #(PERIOD_SRC/2) clk_src = ~clk_src;
    always #(PERIOD_DST/2) clk_dst = ~clk_dst;

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    integer i, j;
    initial begin
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // initialize
        clk_src = 0;
        clk_dst = 0;
        rst_n = 1;
        d_in = 0;
        i = 0;
        j = 0;

        #(DELAY);
        rst_n = 0;

        for (i = 0 ; i < 2; i = i + 1) @(posedge clk_src);
        #(DELAY);
        rst_n = 1;
        
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
		// stimulus start
        $display();
        $display("Stimulus start >>>");
        $display("------------------------------------------------");
        
        //// many single pulse data      
        for (i = 0 ; i < 3; i = i + 1) @(posedge clk_src);
        for (i = 0 ; i < PULSE_CNT; i = i + 1) begin
            #(DELAY*2);
            d_in = 1;
            @(posedge clk_src);
        
            #(DELAY*2);
            d_in = 0;
            for (j = 0 ; j < (PULSE_SPACE - 1); j = j + 1) @(posedge clk_src);
            @(posedge clk_src);
        end
        
        for (i = 0 ; i < 30; i = i + 1) @(posedge clk_src);


        $finish();
    end


    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
		// fsdb dump
		initial begin
`ifdef GATE_SIM
			$sdf_annotate("./mapped/pulse_sync_syn.sdf", inst_pulse_sync);
			$fsdbDumpfile("./waveform/pulse_sync_syn.fsdb");
`else
			$fsdbDumpfile("./waveform/pulse_sync.fsdb");
`endif
			$fsdbDumpvars();
		end


endmodule

