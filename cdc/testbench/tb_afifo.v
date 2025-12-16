`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/08 12:01:23
// Design Name: 
// Module Name: tb_afifo
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


module tb_afifo;
    
    parameter SEED          = 1;                            // seed for random pattern generation
    parameter PULSE_NUM     = 10;                            // input pulse number
    parameter SPACE         = 1;                            // clk_a cycles between input pulse
    parameter WIDTH         = 1;                            // width of data
    parameter DEPTH         = 4;                            // depth of FIFO
    parameter PTR_SIZE      = 3;                            // pointer size of FIFO

    parameter PERIOD_A        = `PERIOD_A;                           // clock period, to 7.5ns generate 133MHz system clock for UART_RX
    parameter DELAY_A         = PERIOD_A/4.0;                   // small time interval used in stimulus
    parameter PERIOD_B        = `PERIOD_B;                           // clock period, to 7.5ns generate 133MHz system clock for UART_RX
    parameter DELAY_B         = PERIOD_B/4.0;                   // small time interval used in stimulus

    localparam RAND_MAX = {1'b1, {WIDTH{1'b0}}};            // max value for random pattern generate
    
    reg                             clk_a;                  // source clock
    reg                             clk_b;                  // destination clock
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    reg                             rst_n;                  // negative triggered reset
    reg                             wr_en;                  // pull-up when writing
    reg                             rd_en;                  // pull-up when reading
    reg                             wr_data;                // write data
    wire                            rd_data;                // read data
    wire                            full;                   // indicate FIFO full
    wire                            empty;                  // indicate FIFO empty
    wire                            wr_data_in;
    
    //assign wr_data_in = (wr_en) ? ~wr_data : 0;
    
    afifo inst_afifo(
        .clk_a(clk_a),
        .clk_b(clk_b),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
        );

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk    
    always #(PERIOD_A/2) clk_a = ~clk_a;
    always #(PERIOD_B/2) clk_b = ~clk_b;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    reg             [31:0]              seed;               // for random pattern generation
    integer i;                                              // test loop count
    integer j;                                              // 
    initial begin
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // initialize
        clk_a = 0;
        clk_b = 0;
        rst_n = 1;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        i = 0;
        j = 0;
        seed = SEED;
    
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // stimulus start
        $display();
        $display("Stimulus start >>>");
        $display("------------------------------------------------");
        @(posedge clk_a);
        #(DELAY_A);
        rst_n = 0;
    
        @(posedge clk_a);
        #(DELAY_A);
        rst_n = 1;

        for (i = 0; i < 3; i = i + 1) @(posedge clk_a);

        //// read and write
         for (i = 0; i < PULSE_NUM; i = i + 1) begin
            #(DELAY_A);
            wr_en = 1;
            rd_en = 1;
            wr_data = 1;
            @(posedge clk_a);
            
            #(DELAY_A);
            wr_en = 0;
            rd_en = 1;
            wr_data = 0;
            for (j = 0 ; j < SPACE; j = j + 1) @(posedge clk_a);
        end
        
        
        
        for (i = 0; i < 20; i = i + 1) @(posedge clk_a);

        $finish();
    end

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
		// fsdb dump
		initial begin
`ifdef GATE_SIM
			$sdf_annotate("./mapped/afifo_syn.sdf", inst_afifo);
			$fsdbDumpfile("./waveform/afifo_syn.fsdb");
`else
			$fsdbDumpfile("./waveform/afifo.fsdb");
`endif
			$fsdbDumpvars();
		end


endmodule
