`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/24 11:02:29
// Design Name: 
// Module Name: mbist_ram
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


module mbist_ram #(
    parameter ADDR = 8                                      // width of {row addr, col addr}
) (    
    clk,
    we,
    oe,
    cs,
    cfid_en,
    addr,
    d_in,
    d_out
    );
    
    localparam ROW_ADDR         = ADDR / 2;                 // row address
    localparam COL_ADDR         = ADDR / 2;                 // column address
    localparam DEPTH            = 2 ** ROW_ADDR;            // memory depth
    localparam WIDTH            = 2 ** COL_ADDR;            // memory width
    localparam SA_0_ADDR        = 6'b000_100;               // stuck-at-0 fault's address 
    localparam CFID_0_ADDR_A    = 6'b010_001;               // CFid-at-0 fault's aggressor address
    localparam CFID_0_ADDR_VROW = 3'b010;                   // CFid-at-0 fault's victim row address 
    localparam CFID_0_ADDR_VCOL = 3'b010;                   // CFid-at-0 fault's victim col address 
    localparam CFID_1_ADDR_A    = 6'b000_110;               // CFid-at-1 fault's aggressor address
    localparam CFID_1_ADDR_VROW = 3'b000;                   // CFid-at-1 fault's victim row address 
    localparam CFID_1_ADDR_VCOL = 3'b111;                   // CFid-at-1 fault's victim col address 
    
    
    input                           clk;                    // clock
    input                           we;                     // write enable
    input                           oe;                     // read enable
    input                           cs;                     // chip select
    input                           cfid_en;                // enable CFid
    input                           d_in;                   // write data
    input   [ADDR-1:0]              addr;                   // address {row addr, col addr}
    output                          d_out;                  // read data
    
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    // read-write operation, with faults injection
    wire    [ROW_ADDR-1:0]          row;                    // row address
    wire    [COL_ADDR-1:0]          col;                    // col address
    reg                             cfid_act_a;             // indicate aggressor cell change or not
    reg                             d_out_reg; 
    
    assign row = addr[ADDR-1:ROW_ADDR];
    assign col = addr[COL_ADDR-1:0];
    
    always @(*) begin    
        if ((cfid_en == 1) && (we == 1) && ((addr == CFID_0_ADDR_A) || (addr == CFID_1_ADDR_A))) begin
            if ((mem[row][col] ^ d_in) == 1) begin
                    cfid_act_a = 1;
            end
            else    cfid_act_a = 0;
        end
        else        cfid_act_a = 0;
    end
    
    always @(posedge clk) begin
        if (cs & we) begin
            // idempotent coupling fault <up, 0/1> , <down, 0/1> , <up, 1/0> , <down, 1/0>
            if (addr == CFID_0_ADDR_A) begin
                if (cfid_act_a) begin
                        mem[2][2:1] <= {1'b0, d_in};
                end
                else    mem[row][col] <= d_in;
            end
            else if (addr == CFID_1_ADDR_A) begin
                if (cfid_act_a) begin
                        mem[0][7:6] <= {1'b1, d_in};
                end
                else    mem[row][col] <= d_in;
            end           
            // stuck-at-0 fault
            else if (addr == SA_0_ADDR) begin
                        mem[row][col] <= 1'b0;
            end
            // normal write
            else        mem[row][col] <= d_in;
        end
    end
    
    always @(negedge clk) begin
        if (cs & oe) begin
                    d_out_reg <= mem[row][col];
        end
        else        d_out_reg <= /*0*/1'bz;
    end
    assign d_out = d_out_reg;
    
    
endmodule
