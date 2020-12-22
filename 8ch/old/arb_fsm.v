`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:39:08 11/28/2016 
// Design Name: 
// Module Name:    arb_fsm 
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
/*module arb_fsm(
    );
*/

module arb_fsm(Gnt, count_reset, Req, Clk, Reset_l, count_done, gnt_done,Up_done); 
 
output [15:0]Gnt; 
output count_reset; 
input [15:0]Req; 
input Clk; 
input Reset_l; 
input count_done, gnt_done,Up_done; 
 
parameter 		IDLE_ST		= 5'd0				, 
				Gnt0_ST		= 5'd1				, 
				Gnt1_ST		= 5'd2				, 
				Gnt2_ST		= 5'd3				, 
				Gnt3_ST		= 5'd4				, 
				Gnt4_ST		= 5'd5				,
				Gnt5_ST		= 5'd6				,
				Gnt6_ST		= 5'd7				,
				Gnt7_ST		= 5'd8				,
				Gnt8_ST		= 5'd9				,
				Gnt9_ST		= 5'd10				,
				Gnt10_ST	= 5'd11				,
				Gnt11_ST	= 5'd12				,
				Gnt12_ST	= 5'd13				,
				Gnt13_ST	= 5'd14				,
				Gnt14_ST	= 5'd15				,
				Gnt15_ST	= 5'd16				;

				
(*keep*)reg [4:0] CurrentState, NextState; 
 
wire count_reset = (CurrentState == IDLE_ST); 
 
always @(Reset_l or Req or count_done or CurrentState or Up_done) 
begin 
  if(~Reset_l) 
    NextState <= IDLE_ST; 
  else 
    case(CurrentState) 
    IDLE_ST: begin 
               if (Req[0]) 
                  NextState <= Gnt0_ST; 
               else if (Req[1]) 
                  NextState <= Gnt1_ST; 
               else if (Req[2]) 
                  NextState <= Gnt2_ST; 
               else if (Req[3]) 
                  NextState <= Gnt3_ST; 
               else if (Req[4]) 
                  NextState <= Gnt4_ST; 
               else if (Req[5]) 
                  NextState <= Gnt5_ST; 
               else if (Req[6]) 
                  NextState <= Gnt6_ST; 
               else if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */				  
               else 
                  NextState <= IDLE_ST;                          
             end 
 
    Gnt0_ST: if ( Up_done) 
               begin                 
				if (Req[1]) 
                  NextState <= Gnt1_ST; 
               else if (Req[2]) 
                  NextState <= Gnt2_ST; 
               else if (Req[3]) 
                  NextState <= Gnt3_ST; 
               else if (Req[4]) 
                  NextState <= Gnt4_ST; 
               else if (Req[5]) 
                  NextState <= Gnt5_ST; 
               else if (Req[6]) 
                  NextState <= Gnt6_ST; 
               else if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
               else
				  NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt0_ST; 
 
    Gnt1_ST: if ( Up_done) 
               begin                 
				if (Req[2]) 
                  NextState <= Gnt2_ST; 
               else if (Req[3]) 
                  NextState <= Gnt3_ST; 
               else if (Req[4]) 
                  NextState <= Gnt4_ST; 
               else if (Req[5]) 
                  NextState <= Gnt5_ST; 
               else if (Req[6]) 
                  NextState <= Gnt6_ST; 
               else if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
                 else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt1_ST; 
 
    Gnt2_ST: if ( Up_done) 
               begin                 
               if (Req[3]) 
                  NextState <= Gnt3_ST; 
               else if (Req[4]) 
                  NextState <= Gnt4_ST; 
               else if (Req[5]) 
                  NextState <= Gnt5_ST; 
               else if (Req[6]) 
                  NextState <= Gnt6_ST; 
               else if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
                 else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt2_ST; 
               
    Gnt3_ST: if ( Up_done) 
               begin                 
                if (Req[4]) 
                  NextState <= Gnt4_ST; 
               else if (Req[5]) 
                  NextState <= Gnt5_ST; 
               else if (Req[6]) 
                  NextState <= Gnt6_ST; 
               else if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt3_ST; 
    Gnt4_ST: if ( Up_done) 
               begin                 
               if (Req[5]) 
                  NextState <= Gnt5_ST; 
               else if (Req[6]) 
                  NextState <= Gnt6_ST; 
               else if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt4_ST;  
 Gnt5_ST: if ( Up_done) 
               begin                 
               if (Req[6]) 
                  NextState <= Gnt6_ST; 
               else if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt5_ST;  
Gnt6_ST: if ( Up_done) 
               begin                 
                 if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt6_ST; 
Gnt7_ST: if ( Up_done) 
               begin                 
                if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt7_ST; 
Gnt8_ST: if ( Up_done) 
               begin                 

                if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt8_ST; 
Gnt9_ST: if ( Up_done) 
               begin                 
                 if (Req[10]) 
                  NextState <= Gnt10_ST; 
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt9_ST; 
Gnt10_ST: if ( Up_done) 
               begin                 
			     if (Req[11]) 
                  NextState <= Gnt11_ST;
               else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt10_ST; 
Gnt11_ST: if ( Up_done) 
               begin                 
                 if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt11_ST; 
Gnt12_ST: if ( Up_done) 
               begin                 
                 if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
			   else if (Req[12]) 
                  NextState <= Gnt12_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt12_ST; 
Gnt13_ST: if ( Up_done) 
               begin                 
                 if (Req[14]) 
                  NextState <= Gnt14_ST;
               else if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
			   else if (Req[12]) 
                  NextState <= Gnt12_ST; 
			   else if (Req[13]) 
                  NextState <= Gnt13_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt13_ST; 
Gnt14_ST: if ( Up_done)  
               begin                 
                 if (Req[15]) 
                  NextState <= Gnt15_ST;  	
/*                else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST;  */
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
			   else if (Req[12]) 
                  NextState <= Gnt12_ST; 
			   else if (Req[13]) 
                  NextState <= Gnt13_ST;
			   else if (Req[14]) 
                  NextState <= Gnt14_ST;
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt14_ST; 
Gnt15_ST: if ( Up_done) 
               begin                 	
/*                  if (Req[16]) 
                  NextState <= Gnt16_ST;
               else if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST; 
			   else */ if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
			   else if (Req[12]) 
                  NextState <= Gnt12_ST; 
			   else if (Req[13]) 
                  NextState <= Gnt13_ST;
			   else if (Req[14]) 
                  NextState <= Gnt14_ST;
			   else if (Req[15]) 
                  NextState <= Gnt15_ST;  
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt15_ST; 
/* Gnt16_ST: if ( Up_done)  
               begin                 	
                 if (Req[17]) 
                  NextState <= Gnt17_ST;  
               else if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST; 
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
			   else if (Req[12]) 
                  NextState <= Gnt12_ST; 
			   else if (Req[13]) 
                  NextState <= Gnt13_ST;
			   else if (Req[14]) 
                  NextState <= Gnt14_ST;
			   else if (Req[15]) 
                  NextState <= Gnt15_ST;  
			   else if (Req[16]) 
                  NextState <= Gnt16_ST;
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt16_ST; 
Gnt17_ST: if ( Up_done) 
               begin                 	  
                 if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else if (Req[19]) 
                  NextState <= Gnt19_ST; 
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
			   else if (Req[12]) 
                  NextState <= Gnt12_ST; 
			   else if (Req[13]) 
                  NextState <= Gnt13_ST;
			   else if (Req[14]) 
                  NextState <= Gnt14_ST;
			   else if (Req[15]) 
                  NextState <= Gnt15_ST;  
			   else if (Req[16]) 
                  NextState <= Gnt16_ST;
			   else if (Req[17]) 
                  NextState <= Gnt17_ST;
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt17_ST; 
Gnt18_ST: if (	Up_done)  
               begin                 	  
                 if (Req[19]) 
                  NextState <= Gnt19_ST; 
			   else if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
			   else if (Req[12]) 
                  NextState <= Gnt12_ST; 
			   else if (Req[13]) 
                  NextState <= Gnt13_ST;
			   else if (Req[14]) 
                  NextState <= Gnt14_ST;
			   else if (Req[15]) 
                  NextState <= Gnt15_ST;  
			   else if (Req[16]) 
                  NextState <= Gnt16_ST;
			   else if (Req[17]) 
                  NextState <= Gnt17_ST;
			   else  if (Req[18]) 
                  NextState <= Gnt18_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt18_ST; 
Gnt19_ST: if (	Up_done) 
               begin                 	  
			   if (Req[0]) 
                  NextState <= Gnt0_ST; 
			   else if (Req[1]) 
                  NextState <= Gnt1_ST; 
			   else	if (Req[2]) 
                  NextState <= Gnt2_ST; 
			   else if (Req[3]) 
                  NextState <= Gnt3_ST; 
			   else if (Req[4]) 
                  NextState <= Gnt4_ST; 
			   else if (Req[5]) 
                  NextState <= Gnt5_ST; 
			   else if (Req[6]) 
                  NextState <= Gnt6_ST; 
			   else if (Req[7]) 
                  NextState <= Gnt7_ST; 
			   else if (Req[8]) 
                  NextState <= Gnt8_ST; 
			   else if (Req[9]) 
                  NextState <= Gnt9_ST; 
			   else if (Req[10]) 
                  NextState <= Gnt10_ST;
			   else if (Req[11]) 
                  NextState <= Gnt11_ST;
			   else if (Req[12]) 
                  NextState <= Gnt12_ST; 
			   else if (Req[13]) 
                  NextState <= Gnt13_ST;
			   else if (Req[14]) 
                  NextState <= Gnt14_ST;
			   else if (Req[15]) 
                  NextState <= Gnt15_ST;  
			   else if (Req[16]) 
                  NextState <= Gnt16_ST;
			   else if (Req[17]) 
                  NextState <= Gnt17_ST;
			   else  if (Req[18]) 
                  NextState <= Gnt18_ST;
			   else if (Req[19]) 
                  NextState <= Gnt19_ST; 
               else 
                   NextState <= IDLE_ST; 
               end 
             else 
                NextState <= Gnt19_ST;  */
    default: NextState <= IDLE_ST; 
             
 
    endcase 
end 
 
     
always @(posedge Clk or negedge Reset_l) 
  begin 
    if(~Reset_l) 
      CurrentState <= IDLE_ST; 
    else 
      CurrentState <= NextState; 
  end 

 
 /* always@(posedge Clk)
	if(CurrentState == Gnt0_ST) begin
		if(arb_cnt[0] < 5'd15)
			arb_cnt[0] <= arb_cnt[0] + 1'b1;
		else if(!Up_busy)
			arb_cnt[0] <= 5'd0;
		else
			arb_cnt[0] <= arb_cnt[0];
		end
	else
		arb_cnt[0] <= 5'd0;

 always@(posedge Clk)
	if(CurrentState == Gnt1_ST) begin
		if(arb_cnt[1] < 5'd15)
			arb_cnt[1] <= arb_cnt[1] + 1'b1;
		else if(!Up_busy)
			arb_cnt[1] <= 5'd0;
		else
			arb_cnt[1] <= arb_cnt[1];
		end
	else
		arb_cnt[1] <= 5'd0;

 always@(posedge Clk)
	if(CurrentState == Gnt2_ST) begin
		if(arb_cnt[2] < 5'd15)
			arb_cnt[2] <= arb_cnt[2] + 1'b1;
		else if(!Up_busy)
			arb_cnt[2] <= 5'd0;
		else
			arb_cnt[2] <= arb_cnt[2];
		end
	else
		arb_cnt[2] <= 5'd0;
		
  always@(posedge Clk)
	if(CurrentState == Gnt3_ST) begin
		if(arb_cnt[3] < 5'd15)
			arb_cnt[3] <= arb_cnt[3] + 1'b1;
		else if(!Up_busy)
			arb_cnt[3] <= 5'd0;
		else
			arb_cnt[3] <= arb_cnt[3];
		end
	else
		arb_cnt[3] <= 5'd0; */
		
	wire	[4:0] State_ms [19:0];

	assign		State_ms[0] 	= Gnt0_ST;
	assign		State_ms[1] 	= Gnt1_ST;
	assign		State_ms[2] 	= Gnt2_ST;
	assign		State_ms[3] 	= Gnt3_ST;
	assign		State_ms[4] 	= Gnt4_ST;
	assign		State_ms[5] 	= Gnt5_ST;
	assign		State_ms[6] 	= Gnt6_ST;
	assign		State_ms[7] 	= Gnt7_ST;
	assign		State_ms[8] 	= Gnt8_ST;
	assign		State_ms[9] 	= Gnt9_ST;
	assign		State_ms[10] 	= Gnt10_ST;
	assign		State_ms[11] 	= Gnt11_ST;
	assign		State_ms[12] 	= Gnt12_ST;
	assign		State_ms[13] 	= Gnt13_ST;
	assign		State_ms[14] 	= Gnt14_ST;
	assign		State_ms[15] 	= Gnt15_ST;
 

	
	
	
	
	
	
/*  	generate	
	genvar	k;	
		for(k=0;k<20;k=k+1) begin	:	fsm_cntt	
		
			always@(posedge Clk)
				if(CurrentState == State_ms[k]) begin
					if(arb_cnt[k] < 5'd15)
						arb_cnt[k] <= arb_cnt[k] + 1'b1;
					else if(!Up_busy)
						arb_cnt[k] <= 5'd0;
					else
						arb_cnt[k] <= arb_cnt[k];
					end
				else
					arb_cnt[k] <= 5'd0;		
			
	end             			
	endgenerate	 */		


 
assign Gnt[0]  = 	(CurrentState == Gnt0_ST); 
assign Gnt[1]  = 	(CurrentState == Gnt1_ST); 
assign Gnt[2]  = 	(CurrentState == Gnt2_ST); 
assign Gnt[3]  = 	(CurrentState == Gnt3_ST); 
assign Gnt[4]  = 	(CurrentState == Gnt4_ST); 
assign Gnt[5]  = 	(CurrentState == Gnt5_ST); 
assign Gnt[6]  = 	(CurrentState == Gnt6_ST); 
assign Gnt[7]  = 	(CurrentState == Gnt7_ST); 
assign Gnt[8]  = 	(CurrentState == Gnt8_ST); 
assign Gnt[9]  = 	(CurrentState == Gnt9_ST); 
assign Gnt[10] =  	(CurrentState == Gnt10_ST); 
assign Gnt[11] =  	(CurrentState == Gnt11_ST); 
assign Gnt[12] =  	(CurrentState == Gnt12_ST); 
assign Gnt[13] =  	(CurrentState == Gnt13_ST); 
assign Gnt[14] =  	(CurrentState == Gnt14_ST); 
assign Gnt[15] =  	(CurrentState == Gnt15_ST);  


endmodule 
