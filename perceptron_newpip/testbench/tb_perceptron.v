/**************************************************************
 * Module name: tb_perceptron
 *
 * Features:
 *	1. Do only inference, the needed weights are done by training in C
 *    2. Use infer_ena to determine when to start inference
 *    3. Inference have total 20 (20%) dataset (address 400 ~ 500 in datamem.txt)
 *    4.Weights store in register file
 *    5. Floating point use IEEE-754 16-bit half precision format
 *
 * Descriptions:
 *	1. Use $readmemb to store inference dataset x0~x4 & yd from datamem.txt into memory before simulation start
 *    2. Use $readmemb to load w0~w4 from datamem.txt to testbench as test inputs
 * 
 * Author: Jason Wu, master's student, NTHU
 *
 * ***********************************************************/
`timescale 1ns / 100ps
//`define PERIOD 10.0                                         // Only used in Vivado, deleted in Linux


module tb_perceptron;
    parameter MEM_WIDTH_YDX = 17;                           // ydx memory width
    parameter MEM_ADDR_YDX  = 7;                            // ydx memory address width
    parameter MEM_DEPTH_YDX = 2 ** MEM_ADDR_YDX;            // ydx memory depth, for only inference dataset, and some spaces
    parameter MEM_ADDR_WGHT = 3;                            // wght memory address width
    parameter INFER_NUM     = 20;                           // inference dataset number
    parameter ATTR          = 5;                            // represent 5 attritibutes
    parameter FP_WIDTH      = 16;                           // width of fp data
    
    localparam PERIOD       = `PERIOD;                      // clock period
    localparam DELAY        = PERIOD/4.0;                   // small time interval used in stimulus
    localparam TXT_INFER    = 500;                          // total dataset number in datamem.txt
    localparam TXT_TOTAL    = TXT_INFER + 5;                // total inference dataset + weights number in datamem.txt
    
    reg     [MEM_WIDTH_YDX-1:0] tb_mem      [0:TXT_TOTAL-1];// for temporary store dataset, then write into percep_mem_ydx & percep_mem_wght
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // instantiate design
    reg                         clk;                        // clock
    reg                         rst_n;                      // asynchronous active low reset
    reg                         infer_ena;                  // determine whether to start inference
    reg     [MEM_WIDTH_YDX-1:0] d_txt_in;                   // data from datamem.txt store into memory
    wire    [MEM_WIDTH_YDX-1:0] d_mem_out;                  // data output of ydx memory, read yd when address %5 == 0 and xi at a time
    wire    [MEM_ADDR_YDX-1:0]  d_mem_addr;                 // ydx memory address
    wire                        infer_done;                 // active when inference done
    wire                        infer_fail;                 // active if all ya unequal to yd

    percep_top #(
        .MEM_WIDTH_YDX(MEM_WIDTH_YDX),
        .MEM_ADDR_YDX(MEM_ADDR_YDX),
        .MEM_DEPTH_YDX(MEM_DEPTH_YDX),
        .MEM_ADDR_WGHT(MEM_ADDR_WGHT),
        .INFER_NUM(INFER_NUM),
        .ATTR(ATTR),
        .FP_WIDTH(FP_WIDTH)
    ) inst_top(
        .clk(clk),
        .rst_n(rst_n),
        .infer_ena(infer_ena),
        .d_txt_in(d_txt_in),
        .d_mem_out(d_mem_out),
        .d_mem_addr(d_mem_addr),
        .infer_fail(infer_fail),
        .infer_done(infer_done)
        );
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // generate clk
    always #(PERIOD/2) clk = ~clk;
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // stimulus
    integer i;
    reg     [MEM_WIDTH_YDX-1:0] d_in_temp;                  // temporarily store value to write into percep_mem_ydx & percep_mem_wght
    
    initial begin
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // initialize
        clk = 0;
        rst_n = 1;
        infer_ena = 0;
        d_txt_in = 0;
    
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // load all dataset from datamem.txt
        $display();
        $display("Load training & inference dataset yd & x0~x4 from C >>>");
        $display("------------------------------------------------");
        $readmemb("/home/m110/m110063556/interview/perceptron_newpip/testbench/datamem.txt",tb_mem);
        //$readmemb("E:/interview/project/perceptron/perceptron.srcs/sim_1/new/datamem.txt",tb_mem);
        for (i = 0; i < TXT_INFER; i = i + 1) begin
            if ((i % ATTR) == 0) begin
                $display();
            end
            $display("address: %d, data: %b", i, tb_mem[i]);
        end
        $display();
        $display("Load dataset w0~w4 from C >>>");
        $display("------------------------------------------------");
        for (i = TXT_INFER; i < TXT_TOTAL; i = i + 1) begin
            $display("address: %d, data: %b", i, tb_mem[i]);
        end
        
        #(DELAY);
        @(posedge clk);
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
		// stimulus start
        $display();
        $display("Stimulus start >>>");
        $display("------------------------------------------------");
        @(posedge clk);
        
        //// reset test, then store yd & x0~x4 & w0~w4 from inference part of tb_mem into percep_mem_ydx & percep_mem_wght first    
        #(DELAY);
        rst_n = 0;
        @(posedge clk);
        
        #(DELAY);
        rst_n = 1;
        @(posedge clk);
        
        #(DELAY);
        infer_ena = 1;
        @(posedge clk);
        for (i = (TXT_INFER * 0.8); i < (TXT_TOTAL + 3); i = i + 1) begin
            #(DELAY);
            d_txt_in = tb_mem[i];
            @(posedge clk);
        end 
        
        //// do inference, and output every net and ya & yd per computation
        wait (infer_done);
        #(DELAY);
        
        // --------------------------------------------------------------------------------------------------------------------------------------------------------
        // display success message
        $display();
        if (infer_fail) $display("Inference fail !!");
        else            $display("Inference success !!");
        $display();
        
        for (i = 0; i < 5; i = i + 1) @(posedge clk);
        
        $finish();
    end
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // fsdb dump
    initial begin
`ifdef GATE_SIM
        $sdf_annotate("./mapped/percep_syn.sdf", inst_top);
        $fsdbDumpfile("./waveform/percep_top_syn.fsdb");
`else
        $fsdbDumpfile("./waveform/percep_top.fsdb");
`endif
        $fsdbDumpvars();
	  end

    
endmodule
