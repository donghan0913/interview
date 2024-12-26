`timescale 1ns / 1ps

////define for submodule simulation
    `define TOP_SIM
    //`define I_MEM_SIM
    //`define D_MEM_SIM
    //`define REG_FILE_SIM
    //`define ALU_SIM
    //`define ADDER_SIM

module single_cycle_cpu_tb;
    
    parameter period = 10;
    parameter byte = 8;
    parameter instruction_width = 32;
    parameter rom_depth = 256;
    parameter ram_depth = 256;
    parameter register_addr = 5;
    parameter register_file_depth = 2**register_addr;
    
    parameter DELAY = period/10;
    
    //================================================================
    // complete test.
    //================================================================
    `ifdef TOP_SIM
        reg clk, rstn;
        wire [instruction_width-1:0] addr_out;
        
        integer i;
        
        single_cycle_cpu inst_cpu(
            .clk(clk),
            .rstn(rstn),
            .addr_out(addr_out)
        );
        
        always #(period/2) clk = ~clk;
        
        initial begin
            clk = 0;
            rstn= 1; 
            
            //reset test
            @(posedge clk);
            #(period/4);
            rstn = 0;
            
            @(posedge clk);
            @(posedge clk);
            #(period/4);
            rstn = 1;
            
            wait(addr_out == 32'h0000_0064);
            for (i=0 ; i< 5 ; i=i+1) @(posedge clk);
        
            $finish();
        end    
    `endif
    
    //================================================================
    // instruction memory test. (success)
    //================================================================
    `ifdef I_MEM_SIM
        reg cs_rom;
        reg [instruction_width-1:0] pc_addr;
        wire [instruction_width-1:0] i_out;
        
        integer i;
        
        instruction_mem inst_rom(
            .cs_rom(cs_rom),
            .pc_addr(pc_addr),
            .i_out(i_out)
        );
        
        initial begin
            cs_rom = 0;
            pc_addr = 0;
        
            #(period);
            cs_rom = 1;
            for (i=0 ; i< 32'h0000_001f ; i=i+1) begin
                pc_addr = i*4;
                #(period/2);
                $display("pc_addr: %h, instruction: %h", pc_addr, i_out);
                #(period/2);
            end
            $display("test done");
            
            $finish();
        end
    `endif
    
    //================================================================
    // data memory test. (success)
    //================================================================
    `ifdef D_MEM_SIM
        reg clk, cs_ram, we, oe;
        reg [instruction_width-1:0] d_in, d_addr;
        wire [instruction_width-1:0] d_out;
        
        integer i;
        
        data_mem inst_ram(
            .clk(clk),
            .cs_ram(cs_ram),
            .we(we),
            .oe(oe),
            .d_addr(d_addr),
            .d_in(d_in),
            .d_out(d_out)
        );
        
        always #(period/2) clk = ~clk;
        
        initial begin
            clk = 0;
            cs_ram = 0;
            we = 0;
            oe = 0;
            d_addr = 0;
            d_in = 0;
            
            @(posedge clk);
            #(period/4);
            cs_ram = 1;
            we = 1;
            oe = 0;
            
            for (i=0 ; i< 32'h0000_001f ; i=i+1) begin
                @(posedge clk);
                #(period/4);
                d_addr = i*4;
                d_in = i;
            end
            
            @(posedge clk);
            #(period/4);
            cs_ram = 1;
            we = 0;
            oe = 1;
            d_addr = 0;
            
            for (i=0 ; i< 32'h0000_001f ; i=i+1) begin
                @(posedge clk);
                #(period/4);
                d_addr = i*4;
                #(period/4);
                $display("d_addr: %h, data: %h", d_addr, d_out);
            end
                    
            $display("test done");
            
            $finish();
        end
    `endif
    
    //================================================================
    // register file
    //================================================================
    `ifdef REG_FILE_SIM
        reg clk, rstn, w_en;
        reg [instruction_width-1:0] w_data;
        reg [register_addr-1:0] w_addr, ra_addr, rb_addr;
        wire [instruction_width-1:0] ra_data, rb_data;
        
        integer i;
    
        register_file inst_regfile(
            .clk(clk),
            .rstn(rstn),
            .w_data(w_data),
            .w_en(w_en),
            .w_addr(w_addr),
            .ra_addr(ra_addr),
            .rb_addr(rb_addr),
            .ra_data(ra_data),
            .rb_data(rb_data)
        );
        
        always #(period/2) clk = ~clk;
        
        initial begin
            clk = 0;
            rstn = 1;
            w_data = 0;
            w_en = 0;
            w_addr = 0;
            ra_addr = 0;
            rb_addr = 0;
            
            ////rstn test
            @(posedge clk);
            #(period/4);
            rstn = 0;
            
            //for (i=0 ; i<register_file_depth ; i=i+1) @(posedge clk);
            @(posedge clk);
            #(period/4);
            rstn = 1;
            
            /////read test
            @(posedge clk);
            #(period/4);
            ra_addr = 5'b0_0000;
            rb_addr = 5'b0_0001;
            #(period/4);
            $display("ra_addr: %b, rb_addr: %b, ra_data: %h, rb_data: %h", ra_addr, rb_addr, ra_data, rb_data);
        
            /////write test
            @(posedge clk);
            #(period/4);
            w_en = 1;
            
            for (i=0 ; i<register_file_depth ; i=i+1) begin
                w_addr = i;
                w_data = i;
                @(posedge clk);
                #(period/4);
            end
            
            /////read test
            @(posedge clk);
            #(period/4);
            w_en = 0;
            
            for (i=0 ; i<register_file_depth ; i=i+1) begin
                ra_addr = i;
                rb_addr = 31-i;
                #(period/4);
                $display("ra_addr: %b, rb_addr: %b, ra_data: %h, rb_data: %h", ra_addr, rb_addr, ra_data, rb_data);
                #(period/4);
            end
        
            $finish();
        end
    `endif
    
    //================================================================
    // alu test. (success)
    //================================================================
    `ifdef ALU_SIM
        reg [instruction_width-1:0] a, b;
        reg [3:0] alu_ctr;
        wire [instruction_width-1:0] y;
        wire zero;
    
        alu inst_alu(
            .a(a),
            .b(b),
            .alu_ctr(alu_ctr),
            .y(y),
            .zero(zero)
        );
        
        initial begin
            a = 0;
            b = 0;
            alu_ctr = 0;
            
            ////add test
            #(period);
            a = 0;
            b = 8;
            alu_ctr = 4'b0010;
            #(period/2);
            $display("operation: %b, a: %h, b: %h, y: %h, zero: %b", alu_ctr, a, b, y, zero);
            
            ////or test
            #(period/2);
            a = 0;
            b = 12;
            alu_ctr = 4'b0001;
            #(period/2);
            $display("operation: %b, a: %h, b: %h, y: %h, zero: %b", alu_ctr, a, b, y, zero);
        
            ////sub test
            #(period/2);
            a = 12;
            b = 8;
            alu_ctr = 4'b0110;
            #(period/2);
            $display("operation: %b, a: %h, b: %h, y: %h, zero: %b", alu_ctr, a, b, y, zero);
        
            ////and test
            #(period/2);
            a = 8;
            b = 12;
            alu_ctr = 4'b0000;
            #(period/2);
            $display("operation: %b, a: %h, b: %h, y: %h, zero: %b", alu_ctr, a, b, y, zero);
        
            ////slt tert
            #(period/2);
            a = 12;
            b = 12;
            alu_ctr = 4'b0111;
            #(period/2);
            $display("operation: %b, a: %h, b: %h, y: %h, zero: %b", alu_ctr, a, b, y, zero);
        
            ////nor test
            #(period/2);
            a = 8;
            b = 12;
            alu_ctr = 4'b1100;
            #(period/2);
            $display("operation: %b, a: %h, b: %h, y: %h, zero: %b", alu_ctr, a, b, y, zero);
        
            ////other alu_ctr
            #(period/2);
            a = 0;
            b = 12;
            alu_ctr = 4'b1111;
            #(period/2);
            $display("operation: %b, a: %h, b: %h, y: %h, zero: %b", alu_ctr, a, b, y, zero);
            
            $finish();
        end        
    `endif

    //================================================================
    // adder_32_bit test.
    //================================================================
    `ifdef ADDER_SIM
        reg [instruction_width-1:0] a, b, expect_sum;
        reg cin, expect_cout;
        wire [instruction_width-1:0] sum;
        wire cout;
        
        adder_32_bit inst_adder(
            .a(a),
            .b(b),
            .cin(cin),
            .sum(sum),
            .cout(cout)
            );

        initial begin
            a = 0;
            b = 0;
            cin = 0;
            
            //first test pattern
            #(period);
            a = 0;
            b = 32'hffff_ffff;
            cin = 0;
            {expect_cout, expect_sum} = a + b + cin;
            #(period);
            $display("a: %h, b: %h, cin: %b;    expect sum: %h, expect cout: %b, actual sum: %h, actual cout: %b", a, b, cin, expect_sum, expect_cout, sum, cout);
        
            //second test pattern
            #(period);
            a = 0;
            b = 32'hffff_ffff;
            cin = 1;
            {expect_cout, expect_sum} = a + b + cin;
            #(period);
            $display("a: %h, b: %h, cin: %b;    expect sum: %h, expect cout: %b, actual sum: %h, actual cout: %b", a, b, cin, expect_sum, expect_cout, sum, cout);
            
            //third test pattern
            #(period);
            a = 32'h7fff_ffff;
            b = 32'h7fff_ffff;
            cin = 0;
            {expect_cout, expect_sum} = a + b + cin;
            #(period);
            $display("a: %h, b: %h, cin: %b;    expect sum: %h, expect cout: %b, actual sum: %h, actual cout: %b", a, b, cin, expect_sum, expect_cout, sum, cout);
            
            //fourth test pattern
            #(period);
            a = 32'h0000_001c;
            b = 32'h0000_0008;
            cin = 0;
            {expect_cout, expect_sum} = a + b + cin;
            #(period);
            $display("a: %h, b: %h, cin: %b;    expect sum: %h, expect cout: %b, actual sum: %h, actual cout: %b", a, b, cin, expect_sum, expect_cout, sum, cout);
            
            #(period);
            
            $finish();
        end

    `endif

    //verdi waveform
    initial begin
        //$sdf_annotate("./bist_top_syn.sdf", single_cycle_cpu_syn);
        $fsdbDumpfile("../4.Simulation_Result/single_cycle_cpu.fsdb");
        $fsdbDumpvars();
    end


endmodule
