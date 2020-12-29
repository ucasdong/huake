//根据鉴相频率及上位机配置的信息产生AD采样频率控制信号 ======AD_START
module AD_CTL(
	input				clk				,
	input				rst_n			,
	input          Phase_valid ,
	input          reg_ad_enble,
		
	input		[15:0]	reg_freq1		,
	input		[15:0]	reg_freq2		,
	//input		[15:0]	reg_freq3		,
	//input		[15:0]	reg_freq4		,
	
	input		[31:0]	Phase_cnt_out	,
	
	output	reg [4:1]	ad_start,
	output  [31:00]     freq1_cnt
);

reg                  tans_latch = 'b0;
always@(posedge clk)
  if(!reg_ad_enble)
	   tans_latch <= 'b0;
  else if(Phase_valid)
     tans_latch  <= 'b1;
  else
     tans_latch  <= tans_latch;

reg			[31:0]	freq1_cnt =1'b0;
reg			[31:0]	freq2_cnt =1'b0;
reg			[31:0]	freq3_cnt =1'b0;
reg			[31:0]	freq4_cnt =1'b0;

wire		[35:0]	Phase_cnt;	

assign		Phase_cnt = {Phase_cnt_out[31:9],9'b0} * 32'd10;
always@(posedge clk,negedge rst_n)
	if(!rst_n) begin
			freq1_cnt <=1'b0;
			freq2_cnt <=1'b0;
			freq3_cnt <=1'b0;
			freq4_cnt <=1'b0;	end
	else if(tans_latch)
   	begin
		if((freq1_cnt * reg_freq1 >= Phase_cnt) || Phase_valid)
			freq1_cnt <= 1'b0;
		else
			freq1_cnt <= freq1_cnt + 1'b1;
		if((freq2_cnt * reg_freq2 >= Phase_cnt) || Phase_valid)
			freq2_cnt <= 1'b0;
		else
			freq2_cnt <= freq2_cnt + 1'b1;
		/*if((freq3_cnt * reg_freq3 >= Phase_cnt)|| Phase_valid)
			freq3_cnt <= 1'b0;
		else
			freq3_cnt <= freq3_cnt + 1'b1;
		if((freq4_cnt * reg_freq4 >= Phase_cnt) ||Phase_valid)
			freq4_cnt <= 1'b0;
		else
			freq4_cnt <= freq4_cnt + 1'b1;*/
	end	
	   else begin
			freq1_cnt <=1'b0;
			freq2_cnt <=1'b0;
			freq3_cnt <=1'b0;
			freq4_cnt <=1'b0;	end
		
		
		
		
		
always@(posedge clk) begin
		if(freq1_cnt == 32'd3 || freq1_cnt == 32'd4)
			ad_start[1]	<= 1'b1;
		else
			ad_start[1]	<= 1'b0;
			
		if(freq2_cnt == 32'd3 || freq2_cnt == 32'd4)
			ad_start[2]	<= 1'b1;
		else
			ad_start[2]	<= 1'b0;
		
		if(freq3_cnt == 32'd3 || freq3_cnt == 32'd4)
			ad_start[3]	<= 1'b1;
		else
			ad_start[3]	<= 1'b0;
			
		if(freq4_cnt == 32'd255 || freq4_cnt == 32'd256)
			ad_start[4]	<= 1'b1;
		else
			ad_start[4]	<= 1'b0;
	end	
		
		
endmodule
