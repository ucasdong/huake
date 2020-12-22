`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:27:32 11/28/2016 
// Design Name: 
// Module Name:    counter 
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
module counter(count_done, gnt_done, count_reset, Clk); 
 
output count_done; 
output gnt_done; 
input count_reset; 
input Clk; 
reg [3:0]cnt, d_cnt; 
 
wire gnt_done = (d_cnt < 4'b1001); 
wire count_done = (d_cnt == 4'b1001); 
 
 
always @(count_done or d_cnt) 
  if(count_done) 
    cnt <= 4'b0000; 
  else 
    cnt <= d_cnt + 4'b0001; 
 
always @(posedge count_reset or posedge Clk) 
  if(count_reset) 
    d_cnt <= 4'b0000; 
  else 
    d_cnt <= cnt; 
 
 
endmodule 
