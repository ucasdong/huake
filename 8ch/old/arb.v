`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:26:57 11/28/2016 
// Design Name: 
// Module Name:    arb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module arb		(Gnt_out, Req_in, Clk, Reset_n,sdram_fifo_empty); 
 
output 			[15:0]					Gnt_out				; 
input 			[15:0]					Req_in				; 
input 									Clk					; 
input 									Reset_n				; 
input									sdram_fifo_empty	;//fifo空
			
wire count_reset, count_done, gnt_done						; 
 
	arb_fsm 		
		u0_arb_fsm	(	.Gnt		( Gnt_out				), 
					.count_reset	( count_reset			), 
					.Req			( Req_in				), 
					.Clk			( Clk					), 
					.Reset_l		( Reset_n				), 
					.count_done		( count_done			), 
					.gnt_done		( gnt_done				),
					.Up_done		( sdram_fifo_empty		)
				);                    		
	counter                           		
		u1_counter(	.count_done		( count_done			), 
					.gnt_done		( gnt_done				), 
					.count_reset	( count_reset			), 
					.Clk			( Clk					)		
				); 
 
endmodule 
