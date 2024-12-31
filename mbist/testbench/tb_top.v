`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/24 11:55:40
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
//`define LOPOW_ADDR_GEN
//`define FUNC_MODE


module tb_top;

    parameter SEED          = 2;                            // seed for random pattern generation
    parameter TEST_NUM      = 20;                           // total random pattern numbers of test
    parameter PERIOD        = 10;                           // clock period
    parameter DELAY         = PERIOD/4.0;                   // small time interval used in stimulus
    parameter ADDR          = 6;                            // width of {row addr, col addr}
    
    localparam ROW_ADDR         = ADDR / 2;                 // row address
    localparam COL_ADDR         = ADDR / 2;                 // column address
    localparam SIZE             = 2 ** ADDR;                // memory size
    
    reg                                 clk;                // system clock
`ifdef LOPOW_ADDR_GEN    
    wire                                clk_1;              // clock 1 for CLFSR
    wire                                clk_2;              // clock 2 for modified-LFSR
`endif

    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate
    wire                                we;                 // write enable
    wire                                oe;                 // write enable
    wire                                cs;                 // write enable
    wire                                d_in;               // write data
    wire    [ADDR-1:0]                  addr;               // address {row addr, col addr}
    wire                                d_out;              // read data
    reg                                 cfid_en;            // enable CFid
    reg                                 mode;
    
    reg                                 we_tb;              // write enable
    reg                                 oe_tb;              // read enable
    reg                                 cs_tb;              // chip select
    reg                                 d_in_tb;            // write data
    reg     [ADDR-1:0]                  addr_tb;            // address {row addr, col addr}
    
    reg                                 rst_n;
    wire                                we_bist;            // write enable
    wire                                oe_bist;            // write enable
    wire                                cs_bist;            // write enable
    wire                                d_in_bist;          // write data
    wire    [ADDR-1:0]                  addr_bist;          // address {row addr, col addr}
    wire                                fault_flag;         // read data
    wire                                bist_done;          // read data
    
    
    assign we = (mode == 1) ? we_bist : we_tb;
    assign oe = (mode == 1) ? oe_bist : oe_tb;
    assign cs = (mode == 1) ? cs_bist : cs_tb;
    assign d_in = (mode == 1) ? d_in_bist : d_in_tb;
    assign addr = (mode == 1) ? addr_bist : addr_tb;
    
    mbist_ram #(
        .ADDR(ADDR)
    ) inst_ram(    
        .clk(clk),
        .we(we),
        .oe(oe),
        .cs(cs),
        .cfid_en(cfid_en),
        .addr(addr),
        .d_in(d_in),
        .d_out(d_out)
        );
        
    mbist_top #(
        .ADDR(ADDR)
    ) inst_top(
        .clk(clk),
        .clk_1(clk_1),
        .clk_2(clk_2),
        .rst_n(rst_n),
        .mode(mode),
        .mem_d_out(d_out),
        .mem_addr(addr_bist),
        .mem_pattern(d_in_bist),
        .cs_bist(cs_bist),
        .we_bist(we_bist),
        .oe_bist(oe_bist),
        .fault_flag(fault_flag),
        .bist_done(bist_done)
        );        
    
    //// clock 1 & clock 2 generator
`ifdef LOPOW_ADDR_GEN   
    clk1_gen #(
        .CLK_DIV(4),
        .DUTY_CYCLE(0),
        .DUTY_NUM(3)
    ) inst_clk1_gen(
        .clk(clk),
        .rst_n(rst_n),
        .clk_div_num(clk_1)
        );
    
    clk2_gen #(
        .CLK_DIV(4),
        .DUTY_CYCLE(375),
        .DUTY_NUM(0)
    ) inst_clk2_gen(
        .clk(clk),
        .rst_n(rst_n),
        .clk_div_num(clk_2)
        );
`endif
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk
    always #(PERIOD/2) clk = ~clk;
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    reg     [31:0]                      seed;               // for random pattern generation      
    integer i;
    initial begin
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // initialize
        clk = 0;
        rst_n = 1;
        we_tb = 0;
        oe_tb = 0;
        cs_tb = 0;
        cfid_en = 0;
        d_in_tb = 0;
        addr_tb = 0;
        mode = 0;
        i = 0;
        seed = SEED;
        
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
		// normal functional stimulus start
        $display();
        $display("Normal functional Stimulus start >>>");
        $display("------------------------------------------------");
        @(posedge clk);

        //// initial write 0;
        //#(DELAY);
        cs_tb = 1;
        we_tb = 1;
        for (i = 0; i < SIZE; i = i + 1) begin
            //#(DELAY);
            //#(DELAY);
            addr_tb = i;
            d_in_tb = 0;
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);

        //================================================================
        // normal mode test
        //================================================================
`ifdef FUNC_MODE
        //// 1st: write 1 test;
        //#(DELAY);
        cs_tb = 1;
        we_tb = 1;
        cfid_en = 1;
        for (i = 0; i < 20; i = i + 1) begin
            //#(DELAY);
            //#(DELAY);
            addr_tb = i;
            d_in_tb = 1;
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);
        
        //// 1st: read 1 test;
        $display();
        $display("1st W1 all -> R1 all Test:");
        $display("------------------------------------------------");
        //#(DELAY);
        oe_tb = 1;
        we_tb = 0;
        for (i = 0; i < 20; i = i + 1) begin
            addr_tb = i;
            @(negedge clk);
            
            #(DELAY);
            $display("address: %h   data: %b", addr_tb, d_out);
            
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);

        //// 2nd: read 1 -> write 0 test;
        $display();
        $display("R1 -> W0 Test:");
        $display("------------------------------------------------");
        //#(DELAY);
        cfid_en = 1;
        for (i = 0; i < 20; i = i + 1) begin
            oe_tb = 1;
            we_tb = 0;
            addr_tb = i;
            @(negedge clk);
            #(DELAY);
           
            $display("address: %h   data: %b", addr_tb, d_out);
            //@(posedge clk);
            
            //#(DELAY);
            //#(DELAY);
            addr_tb = i;
            d_in_tb = 0;
            oe_tb = 0;
            we_tb = 1;
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);
        
        //// 2nd: read 0 test;
        $display();
        $display("  -> R0 Test:");
        $display("------------------------------------------------");
        #(DELAY);
        oe_tb = 1;
        we_tb = 0;
        for (i = 0; i < 20; i = i + 1) begin
            addr_tb = i;
            @(negedge clk);
            
            #(DELAY);
            $display("address: %h   data: %b", addr_tb, d_out);
            
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);

`else
        //================================================================
        // test mode test
        //================================================================

        // --------------------------------------------------------------------------------------------------------------------------------------------------------
		// test mode stimulus start
        $display();
        $display("Test Mode Stimulus start >>>");
        $display("------------------------------------------------");
        @(posedge clk);
        
        ////rst test
        @(posedge clk);
        #(DELAY);
        rst_n = 0;
        
        @(posedge clk);
        #(DELAY);
        rst_n = 1;
        
        @(posedge clk);
        
        @(posedge clk);
        @(posedge clk);
        #(DELAY);
        cfid_en = 1;
        mode = 1;

        wait (bist_done);
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk);
        end
`endif
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // display success message
        $display();
        $display("%d tests all success !!", TEST_NUM);
        $display();


        $finish();
    end

		
		// -------------------------------------------------------------------------------------------------------------------------------------------------------------
		// fsdb dump
		initial begin
`ifdef GATE_SIM
			$sdf_annotate("./mapped/mbist_syn.sdf", inst_top);
			$fsdbDumpfile("./waveform/mbist_syn.fsdb");
`else
			$fsdbDumpfile("./waveform/mbist.fsdb");
`endif
			$fsdbDumpvars();
		end


endmodule
