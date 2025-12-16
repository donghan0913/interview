`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/08 11:17:56
// Design Name: 
// Module Name: rst_sync
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


module rst_sync(
    clk,
	rst_n,
	rst_sync_n
    );
    
    input               clk;
    input               rst_n;
    output              rst_sync_n;

	reg				rst_inter_n;
    reg             rst_sync_n_reg;

	always @(posedge clk, negedge rst_n) begin
		if ( ~rst_n) begin
			rst_inter_n <= 0;
			rst_sync_n_reg <= 0;	
		end
		else begin
			rst_inter_n <= 1;
			rst_sync_n_reg <= rst_inter_n;	
		end
	end
	
	assign rst_sync_n = rst_sync_n_reg;
    
    
endmodule

