`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		
// Engineer: 		 
// 
// Create Date:		 
// Design Name: 
// Module Name:		 
// Project Name:	
// Target Devices: 	 
// Tool versions: 	 
// Description: 
//	读写控制及地址管理
//
// Dependencies: 
//
// Revision: 	
// Revision 0.01 - File Created
// Additional Comments: 
//g
//////////////////////////////////////////////////////////////////////////////////

module	WR_CTL	(
	//Common Signals
	input								sys_rst_n							,
	input								clk_40m								,
	input								wrf_empty							,
	input			[AD_NUM-1	:0]		wrfifo_gnt_in						,//仲裁结果输入
	input			[AD_NUM*16-1:0]		fifo_datain							,//
	output			[AD_NUM-1:0	  ]		fifo_rd_req							,
	//fifo requst signal
	output		reg	[AD_NUM-1:0	  ]		sdram_fifo_datain					,
	output								sdram_fifo_wr_req					,
	output		reg	[23		 :0	  ]		sdram_addr							,	
	output 		reg						rd_en = 1'b0						,
    input 								rd_ack								,
	input 								sdram_rd_ack						,
	output		reg	[15		  :0  ]		reg_ad_status						,
	output								flag								,
	input								rd_full_flag						,
	input								rdempty_flag						,//SDRAM输出数据fifo的标志，为高表示上位机已将数据读完
	output		reg						wr_done								,//一次写完成，下次仲裁写的启动信号
	output			[15		  :0  ]		fifo_rst							 ,//各个通道采集4096个数据后的fifo复位信号
	output		reg							data_full
	);
	assign	flag		= |cnt1 & |cnt2 & |cnt3;
	

	
		

//-------------------------------------------------------------------------------
	                                                                		
//----UP_S状态机参数定义                                               		
	localparam		UP_IDLE				= 6'd0								;
	localparam		UP_DATA0			= 6'd1								;
	localparam		UP_DATA1			= 6'd2								;
	localparam		UP_DATA2			= 6'd3								;
	localparam		UP_DATA3			= 6'd4								;
	localparam		UP_DATA4			= 6'd5								;
	localparam		UP_DATA5			= 6'd6								;
	localparam		UP_DATA6			= 6'd7								;
	localparam		UP_DATA7			= 6'd8								;
	localparam		UP_DATA8			= 6'd9								;
	localparam		UP_DATA9			= 6'd10								;	
	localparam		UP_DATA10			= 6'd11								;
	localparam		UP_DATA11			= 6'd12								;
	localparam		UP_DATA12			= 6'd13								;
	localparam		UP_DATA13			= 6'd14								;
	localparam		UP_DATA14			= 6'd15								;
	localparam		UP_DATA15			= 6'd16								;
	localparam		UP_DONE				= 6'd17								;
	localparam		WR_DONE_ST			= 6'd18								;
	localparam		RD_DATA0			= 6'd19								;
	localparam		RD_DATA0_DONE		= 6'd20								;
	localparam		RD_DATA1			= 6'd21								;
	localparam		RD_DATA1_DONE		= 6'd22								;
	localparam		RD_DATA2			= 6'd23								;
	localparam		RD_DATA2_DONE		= 6'd24								;
	localparam		RD_DATA3			= 6'd25								;
	localparam		RD_DATA3_DONE		= 6'd26								;
	localparam		RD_DATA4			= 6'd27								;
	localparam		RD_DATA4_DONE		= 6'd28								;
	localparam		RD_DATA5			= 6'd29								;
	localparam		RD_DATA5_DONE		= 6'd30								;
	localparam		RD_DATA6			= 6'd31								;
	localparam		RD_DATA6_DONE		= 6'd32								;
	localparam		RD_DATA7			= 6'd33								;
	localparam		RD_DATA7_DONE		= 6'd34								;
	localparam		RD_DATA8			= 6'd35								;
	localparam		RD_DATA8_DONE		= 6'd36								;
	localparam		RD_DATA9			= 6'd37								;
	localparam		RD_DATA9_DONE		= 6'd38								;
	localparam		RD_DATA10			= 6'd39								;
	localparam		RD_DATA10_DONE		= 6'd40								;
	localparam		RD_DATA11			= 6'd41								;
	localparam		RD_DATA11_DONE		= 6'd42								;
	localparam		RD_DATA12			= 6'd43								;
	localparam		RD_DATA12_DONE		= 6'd44								;
	localparam		RD_DATA13			= 6'd45								;
	localparam		RD_DATA13_DONE		= 6'd46								;
	localparam		RD_DATA14			= 6'd47								;
	localparam		RD_DATA14_DONE		= 6'd48								;
	localparam		RD_DATA15			= 6'd49								;
	localparam		RD_DATA15_DONE		= 6'd50								;
	localparam		RD_START_ST			= 6'd51								;
	
	//localparam		RD_DONE				= 6'd35								;
	localparam		WR_LEN				= 12'd1024								;
	localparam		RD_TIMES			= 8									;		//这里是FPGA读多少次1024，8192点时RD_TIMES＝8；2048点时RD_TIMES＝2
	
	
	//sdram基地址定义----讲sdram分为16个均匀的存储区
	localparam		sdram_addr0			= {4'h0,20'h8}						;
	localparam		sdram_addr1			= {4'h1,20'h8}						;
	localparam		sdram_addr2			= {4'h2,20'h8}						;
	localparam		sdram_addr3			= {4'h3,20'h8}						;
	localparam		sdram_addr4			= {4'h4,20'h8}						;
	localparam		sdram_addr5			= {4'h5,20'h8}						;
	localparam		sdram_addr6			= {4'h6,20'h8}						;
	localparam		sdram_addr7			= {4'h7,20'h8}						;
	localparam		sdram_addr8			= {4'h8,20'h8}						;
	localparam		sdram_addr9			= {4'h9,20'h8}						;
	localparam		sdram_addr10		= {4'hA,20'h8}						;
	localparam		sdram_addr11		= {4'hB,20'h8}						;
	localparam		sdram_addr12		= {4'hC,20'h8}						;
	localparam		sdram_addr13		= {4'hD,20'h8}						;
	localparam		sdram_addr14		= {4'hE,20'h8}						;
	localparam		sdram_addr15		= {4'hF,20'h8}						;
	localparam		rd_delay_data		= 20'd20000							;
	
	parameter		RD_LENTH			= 133								;
	parameter		AD_NUM 				= 16								;
	//写地址
	(*keep*)reg				[23:0]				current_wr_addr0					;
	reg				[23:0]				current_wr_addr1					;
	reg				[23:0]				current_wr_addr2					;
	reg				[23:0]				current_wr_addr3					;
	reg				[23:0]				current_wr_addr4					;
	reg				[23:0]				current_wr_addr5					;
	reg				[23:0]				current_wr_addr6					;
	reg				[23:0]				current_wr_addr7					;
	reg				[23:0]				current_wr_addr8					;
	reg				[23:0]				current_wr_addr9					;
	reg				[23:0]				current_wr_addr10					;
	reg				[23:0]				current_wr_addr11					;
	reg				[23:0]				current_wr_addr12					;
	reg				[23:0]				current_wr_addr13					;
	reg				[23:0]				current_wr_addr14					;
	reg				[23:0]				current_wr_addr15					;
	//读地址
	(*keep*)reg				[23:0]				current_rd_addr0					;
	reg				[23:0]				current_rd_addr1					;
	reg				[23:0]				current_rd_addr2					;
	reg				[23:0]				current_rd_addr3					;
	reg				[23:0]				current_rd_addr4					;
	reg				[23:0]				current_rd_addr5					;
	reg				[23:0]				current_rd_addr6					;
	reg				[23:0]				current_rd_addr7					;
	reg				[23:0]				current_rd_addr8					;
	reg				[23:0]				current_rd_addr9					;
	reg				[23:0]				current_rd_addr10					;
	reg				[23:0]				current_rd_addr11					;
	reg				[23:0]				current_rd_addr12					;
	reg				[23:0]				current_rd_addr13					;
	reg				[23:0]				current_rd_addr14					;
	reg				[23:0]				current_rd_addr15					;



	reg				[5			:0]			up_s/* synthesis preserve = 1 */							;
	(*keep*)reg				[9:0]	cnt1,cnt2,cnt3/* synthesis preserve = 1 */;
	
			
	reg				[10			:0]			up_cnt							;
	reg										up_fifo_wen						;
	reg				[12			:0]			wr_cnt		[AD_NUM-1:0]		;//写数据计数器
			

	reg		[19:0]	rd_delay												;	
	reg				[AD_NUM-1:0	  ]			ad_fifo_rd = 1'b0				;
	
	parameter								up_length_cnt_64bit = 8			;
	
	reg		[3:0]	rd_cnt_ad1;
	reg		[3:0]	rd_cnt_ad2	;
	reg		[3:0]	rd_cnt_ad3	;	
	reg		[3:0]	rd_cnt_ad4	;
	reg		[3:0]	rd_cnt_ad5	;
	reg		[3:0]	rd_cnt_ad6	;	
	reg		[3:0]	rd_cnt_ad7	;
	reg		[3:0]	rd_cnt_ad8	;
	reg		[3:0]	rd_cnt_ad9	;	
	reg		[3:0]	rd_cnt_ad10	;
	reg		[3:0]	rd_cnt_ad11	;
	reg		[3:0]	rd_cnt_ad12	;
	reg		[3:0]	rd_cnt_ad13	;
	reg		[3:0]	rd_cnt_ad14	;
	reg		[3:0]	rd_cnt_ad15	;
	reg		[3:0]	rd_cnt_ad16	;


	
reg sdr_rdackr1,sdr_rdackr2;
//------------------------------------------
//捕获sdram_rd_ack下降沿标志位
always @(posedge clk_40m or negedge sys_rst_n)		
		if(!sys_rst_n) begin
				sdr_rdackr1 <= 1'b0;
				sdr_rdackr2 <= 1'b0;
			end
		else begin
				sdr_rdackr1 <= sdram_rd_ack;
				sdr_rdackr2 <= sdr_rdackr1;				
			end

wire neg_rdack = ~sdr_rdackr1 & sdr_rdackr2;
	

			
	
//--------------------------------------------------------------------------------------
//--上行数据生成状态机
//--------------------------------------------------------------------------------------


//----DMA上行通道请求实现状态机
	always @(posedge clk_40m or negedge sys_rst_n) begin
		if(!sys_rst_n) begin
			up_s					<= UP_IDLE									;
			up_cnt					<= 11'b0									;
			up_fifo_wen				<= 1'b0									;
			ad_fifo_rd				<= 16'b0									;
			
			rd_cnt_ad1	 			<= 1'b0									;
			rd_cnt_ad2	 			<= 1'b0									;
			rd_cnt_ad3	 			<= 1'b0									;			
			rd_cnt_ad4	 			<= 1'b0									;
			rd_cnt_ad5	 			<= 1'b0									;
			rd_cnt_ad6	 			<= 1'b0									;			
			rd_cnt_ad7	 			<= 1'b0									;
			rd_cnt_ad8	 			<= 1'b0									;
			rd_cnt_ad9	 			<= 1'b0									;			
			rd_cnt_ad10 			<= 1'b0									;
			rd_cnt_ad11 			<= 1'b0									;
			rd_cnt_ad12 			<= 1'b0									;			
			rd_cnt_ad13 	 		<= 1'b0									;
			rd_cnt_ad14 			<= 1'b0									;
			rd_cnt_ad15 			<= 1'b0									;
			rd_cnt_ad16				<= 1'b0									;
			
		
			wr_cnt[0]				<= 1'b0									;
			wr_cnt[1]				<= 1'b0									;
			wr_cnt[2]				<= 1'b0									;
			wr_cnt[3]				<= 1'b0									;
			wr_cnt[4]				<= 1'b0									;
			wr_cnt[5]				<= 1'b0									;
			wr_cnt[6]				<= 1'b0									;
			wr_cnt[7]				<= 1'b0									;
			wr_cnt[8]				<= 1'b0									;
			wr_cnt[9]				<= 1'b0									;
			wr_cnt[10]				<= 1'b0									;
			wr_cnt[11]				<= 1'b0									;
			wr_cnt[12]				<= 1'b0									;
			wr_cnt[13]				<= 1'b0									;
			wr_cnt[14]				<= 1'b0									;
			wr_cnt[15]				<= 1'b0									;
			rd_en					<= 1'b0									;
			reg_ad_status			<= 16'b0								;
			wr_done					<= 1'b0									;
			data_full				<= 1'b0									;
			end 
		else begin
				
				if(rdempty_flag)
				reg_ad_status <= 16'b0;
				else
				reg_ad_status <= reg_ad_status;
			case(up_s)
				UP_IDLE: begin
/* 						if((rd_cnt_ad1 == 3'd4) && (rd_cnt_ad2 == 3'd4) && (rd_cnt_ad3 == 3'd4)&& (rd_cnt_ad4 == 3'd4)
							&& (rd_cnt_ad5 == 3'd4)&& (rd_cnt_ad6 == 3'd4)&& (rd_cnt_ad7 == 3'd4)&& (rd_cnt_ad8 == 3'd4)
							&& (rd_cnt_ad9 == 3'd4)&& (rd_cnt_ad10 == 3'd4)&& (rd_cnt_ad11 == 3'd4)&& (rd_cnt_ad12 == 3'd4)
							&& (rd_cnt_ad13 == 3'd4)&& (rd_cnt_ad14 == 3'd4)&& (rd_cnt_ad15 == 3'd4)&& (rd_cnt_ad16 == 3'd4)
						) 
																
						begin
							rd_cnt_ad1 	<= 1'b0;
							rd_cnt_ad2 	<= 1'b0;
							rd_cnt_ad3 	<= 1'b0;
							rd_cnt_ad4 	<= 1'b0;
							rd_cnt_ad5 	<= 1'b0;
							rd_cnt_ad6 	<= 1'b0;
							rd_cnt_ad7 	<= 1'b0;
							rd_cnt_ad8 	<= 1'b0;
							rd_cnt_ad9 	<= 1'b0;
							rd_cnt_ad10 <= 1'b0;
							rd_cnt_ad11 <= 1'b0;
							rd_cnt_ad12 <= 1'b0;
							rd_cnt_ad13 <= 1'b0;
							rd_cnt_ad14 <= 1'b0;
							rd_cnt_ad15 <= 1'b0;
							rd_cnt_ad16 <= 1'b0;														
							
							end
						else begin
						
							rd_cnt_ad1 	<= rd_cnt_ad1;
							rd_cnt_ad2 	<= rd_cnt_ad2;
							rd_cnt_ad3 	<= rd_cnt_ad3; 
							rd_cnt_ad4 	<= rd_cnt_ad4; 						
							rd_cnt_ad5 	<= rd_cnt_ad5;
							rd_cnt_ad6 	<= rd_cnt_ad6;
							rd_cnt_ad7 	<= rd_cnt_ad7; 
							rd_cnt_ad8 	<= rd_cnt_ad8; 
							rd_cnt_ad9 	<= rd_cnt_ad9 ;
							rd_cnt_ad10 <= rd_cnt_ad10;
							rd_cnt_ad11 <= rd_cnt_ad11;
							rd_cnt_ad12 <= rd_cnt_ad12;
							rd_cnt_ad13 <= rd_cnt_ad13 ;
							rd_cnt_ad14 <= rd_cnt_ad14;
							rd_cnt_ad15 <= rd_cnt_ad15;
							rd_cnt_ad16 <= rd_cnt_ad16;
							end */
						
						rd_delay 	<= 1'b0								;
						rd_en		<= 1'b0									;
						 if (wrfifo_gnt_in[0] & wrf_empty)
						up_s				<= UP_DATA0						;
					else if(wrfifo_gnt_in[1]& wrf_empty)
						up_s				<= UP_DATA1						;
					else if(wrfifo_gnt_in[2]& wrf_empty)
						up_s				<= UP_DATA2						;
					else if(wrfifo_gnt_in[3]& wrf_empty)
						up_s				<= UP_DATA3						;
					else if(wrfifo_gnt_in[4]& wrf_empty)
						up_s				<= UP_DATA4						;
					else if(wrfifo_gnt_in[5]& wrf_empty)
						up_s				<= UP_DATA5						;
					else if(wrfifo_gnt_in[6]& wrf_empty)
						up_s				<= UP_DATA6						;
					else if(wrfifo_gnt_in[7]& wrf_empty)
						up_s				<= UP_DATA7						;
					else if(wrfifo_gnt_in[8]& wrf_empty)
						up_s				<= UP_DATA8						;
					else if(wrfifo_gnt_in[9]& wrf_empty)
						up_s				<= UP_DATA9						;
					else if(wrfifo_gnt_in[10]& wrf_empty)
						up_s				<= UP_DATA10					;
					else if(wrfifo_gnt_in[11]& wrf_empty)
						up_s				<= UP_DATA11					;
					else if(wrfifo_gnt_in[12]& wrf_empty)
						up_s				<= UP_DATA12					;
					else if(wrfifo_gnt_in[13]& wrf_empty)
						up_s				<= UP_DATA13					;
					else if(wrfifo_gnt_in[14]& wrf_empty)
						up_s				<= UP_DATA14					;
					else if(wrfifo_gnt_in[15]& wrf_empty)
						up_s				<= UP_DATA15					;
					else
						up_s				<= UP_IDLE						; 
						up_cnt				<= 11'b0						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd			<= 16'b0						;
				end

				UP_DATA0: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr0				;
						wr_cnt[0]			<= wr_cnt[0] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[0]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[0*16+:16]		;
						up_s				<= UP_DATA0						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[0]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end 
				
				
				UP_DATA1: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr1				;
						wr_cnt[1]			<= wr_cnt[1] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[1]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[1*16+:16]		;
						up_s				<= UP_DATA1						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[1]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin     	                             		
						up_cnt				<= up_cnt						;
					end                                             		
				end 

				UP_DATA2: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr2				;
						wr_cnt[2]			<= wr_cnt[2] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[2]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[2*16+:16]		;
						up_s				<= UP_DATA2						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[2]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end 

				UP_DATA3: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr3				;
						wr_cnt[3]			<= wr_cnt[3] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[3]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[3*16+:16]		;
						up_s				<= UP_DATA3						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[3]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA4: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr4				;
						wr_cnt[4]			<= wr_cnt[4] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[4]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[4*16+:16]		;
						up_s				<= UP_DATA4						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[4]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA5: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr5				;
						wr_cnt[5]			<= wr_cnt[5] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[5]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[5*16+:16]		;
						up_s				<= UP_DATA5						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[5]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA6: begin
					
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr6				;
						wr_cnt[6]			<= wr_cnt[6] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[6]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[6*16+:16]		;
						up_s				<= UP_DATA6						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[6]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA7: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr7				;
						wr_cnt[7]			<= wr_cnt[7] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[7]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[7*16+:16]		;
						up_s				<= UP_DATA7						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[7]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA8: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr8				;
						wr_cnt[8]			<= wr_cnt[8] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[8]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[8*16+:16]		;
						up_s				<= UP_DATA8						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[8]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end
				
				UP_DATA9: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr9				;
						wr_cnt[9]			<= wr_cnt[9] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[9]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[9*16+:16]		;
						up_s				<= UP_DATA9						;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[9]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA10: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr10				;
						wr_cnt[10]			<= wr_cnt[10] + 1'b1			;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[10]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[10*16+:16]		;
						up_s				<= UP_DATA10					;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[10]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA11: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr11				;
						wr_cnt[11]			<= wr_cnt[11] + 1'b1				;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[11]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[11*16+:16]		;
						up_s				<= UP_DATA11					;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[11]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA12: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr12			;
						wr_cnt[12]			<= wr_cnt[12] + 1'b1			;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[12]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[12*16+:16]		;
						up_s				<= UP_DATA12					;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[12]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA13: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr13			;
						wr_cnt[13]			<= wr_cnt[13] + 1'b1			;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[13]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[13*16+:16]		;
						up_s				<= UP_DATA13					;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[13]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA14: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr14				;
						wr_cnt[14]			<= wr_cnt[14] + 1'b1			;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[14]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[14*16+:16]		;
						up_s				<= UP_DATA14					;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[14]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end

				UP_DATA15: begin
						
					if(up_cnt == up_length_cnt_64bit- 1'b1 && dma_up_fifo_wen ) begin
						wr_done				<= 1'b1							;
						sdram_addr			<= current_wr_addr15			;
						wr_cnt[15]			<= wr_cnt[15] + 1'b1			;
						up_s				<= UP_DONE						;
						up_fifo_wen			<= 1'b0							;
						ad_fifo_rd[15]		<= 1'b0							;
					end else begin
					//	sdram_fifo_datain	<= fifo_datain[15*16+:16]		;
						up_s				<= UP_DATA15					;
						up_fifo_wen			<= 1'b1							;
						ad_fifo_rd[15]		<= 1'b1							;
					end                                             		
					                                                		
					if(dma_up_fifo_wen ) begin                       		
						up_cnt				<= up_cnt + 1'b1				;
					end else begin                                  		
						up_cnt				<= up_cnt						;
					end                                             		
				end
                                               		
				UP_DONE: begin 
				//	rd_delay				<= rd_delay + 1'b1				;
					wr_done					<= 1'b0							;
					up_fifo_wen				<= 1'b0							;
					ad_fifo_rd 				<= 20'b0						;
					up_cnt					<= 11'b0						; 
				//	if(rd_delay >= 7'd60)
					if(wr_cnt[0] >=WR_LEN && wr_cnt[1] >=WR_LEN && wr_cnt[2] >=WR_LEN && wr_cnt[3] >=WR_LEN 
					   && wr_cnt[4] >=WR_LEN && wr_cnt[5] >=WR_LEN && wr_cnt[6] >=WR_LEN && wr_cnt[7] >=WR_LEN 
					   //&& wr_cnt[8] >=WR_LEN && wr_cnt[9] >=WR_LEN && wr_cnt[10]>=WR_LEN && wr_cnt[11]>=WR_LEN 
					   //&& wr_cnt[12]>=12'd511 && wr_cnt[13]>=12'd511 && wr_cnt[14]>=12'd511 && wr_cnt[15]>=12'd511
					   ) begin
					data_full				<= 1'b1							;
					//rd_delay				<= rd_delay + 1'b1				;
					//if(rd_delay>=20'd70)
					up_s					<= RD_START_ST					;end 
					//else
					//up_s					<= UP_DONE						;end
					//up_s					<= UP_IDLE						;
					else
					up_s					<= UP_IDLE						;
					
					end
				RD_START_ST:
					if(wrf_empty) begin
					
					up_s					<= WR_DONE_ST					; end
					else
					up_s					<= RD_START_ST					;
						
				WR_DONE_ST: begin
					rd_delay				<= 1'b0							;
					reg_ad_status		<= 16'b0							;
					//if(wr_cnt[0] >= 12'd1023) begin
					if(	rdempty_flag & (rd_cnt_ad1 <RD_TIMES))  
					up_s					<= RD_DATA0;
					//wr_cnt[0]				<= wr_cnt[0] - (RD_LENTH -1)			; end
					else if( rdempty_flag & (rd_cnt_ad2 <RD_TIMES))  
					up_s					<= RD_DATA1;
					//wr_cnt[1]				<= wr_cnt[1] - (RD_LENTH -1)			; end 
					else if(  rdempty_flag & (rd_cnt_ad3 <RD_TIMES))  
					up_s					<= RD_DATA2;
					//wr_cnt[2]				<= wr_cnt[2] - (RD_LENTH -1)			; end 
					else if(  rdempty_flag & (rd_cnt_ad4 <RD_TIMES))  
					up_s					<= RD_DATA3;
					//wr_cnt[3]				<= wr_cnt[3] - (RD_LENTH -1)			; end 
					else if(  rdempty_flag & (rd_cnt_ad5 <RD_TIMES))  
					up_s					<= RD_DATA4;
					//wr_cnt[4]				<= wr_cnt[4] - (RD_LENTH -1)			; end 
					else if( rdempty_flag & (rd_cnt_ad6 <RD_TIMES))  
					up_s					<= RD_DATA5;
					//wr_cnt[5]				<= wr_cnt[5] - (RD_LENTH -1)			; end 
					else if(  rdempty_flag & (rd_cnt_ad7 <RD_TIMES))  
					up_s					<= RD_DATA6;
					//wr_cnt[6]				<= wr_cnt[6] - (RD_LENTH -1)			; end 
					else if(  rdempty_flag & (rd_cnt_ad8 <RD_TIMES))  
					up_s					<= RD_DATA7;
					//wr_cnt[7]				<= wr_cnt[7] - (RD_LENTH -1)			; end */
					/*else if(  rdempty_flag & (rd_cnt_ad9 <RD_TIMES))  
					up_s					<= RD_DATA8;
					//wr_cnt[8]				<= wr_cnt[8] - (RD_LENTH -1)			; end 
					else if(  rdempty_flag & (rd_cnt_ad10 <RD_TIMES))  
					up_s					<= RD_DATA9;
					//wr_cnt[9]				<= wr_cnt[9] - (RD_LENTH -1)			; end 
					else if(  rdempty_flag& (rd_cnt_ad11 <RD_TIMES))  
					up_s					<= RD_DATA10;
					//wr_cnt[10]				<= wr_cnt[10] - (RD_LENTH -1)		; end 
					else if(  rdempty_flag& (rd_cnt_ad12 <RD_TIMES))  
					up_s					<= RD_DATA11;
					//wr_cnt[11]				<= wr_cnt[11] - (RD_LENTH -1)		; end 
					/*else if(  rdempty_flag& (rd_cnt_ad13 <4))  
					up_s					<= RD_DATA12;
					//wr_cnt[12]				<= wr_cnt[12] - (RD_LENTH -1)		; end 
					else if(  rdempty_flag& (rd_cnt_ad14 <4))  
					up_s					<= RD_DATA13;
					//wr_cnt[13]				<= wr_cnt[13] - (RD_LENTH -1)		; end 
					else if(  rdempty_flag& (rd_cnt_ad15 <4)) 
					up_s					<= RD_DATA14;
					//wr_cnt[14]				<= wr_cnt[14] - (RD_LENTH -1)		; end 
					else if(  rdempty_flag& (rd_cnt_ad16 <4)) 
					up_s					<= RD_DATA15;
					//wr_cnt[15]				<= wr_cnt[15] - (RD_LENTH -1)		; end  */
					else begin
						data_full				<= 1'b0								;
						wr_cnt[0]				<= 1'b0								;
						wr_cnt[1]				<= 1'b0								;
						wr_cnt[2]				<= 1'b0								;
						wr_cnt[3]				<= 1'b0								;
						wr_cnt[4]				<= 1'b0								;
						wr_cnt[5]				<= 1'b0								;
						wr_cnt[6]				<= 1'b0								;
						wr_cnt[7]				<= 1'b0								;
						wr_cnt[8]				<= 1'b0								;
						wr_cnt[9]				<= 1'b0								;
						wr_cnt[10]				<= 1'b0								;
						wr_cnt[11]				<= 1'b0								;
						wr_cnt[12]				<= 1'b0								;
						wr_cnt[13]				<= 1'b0								;
						wr_cnt[14]				<= 1'b0								;
						wr_cnt[15]				<= 1'b0								;
						
						rd_cnt_ad1 				<= 1'b0								;
						rd_cnt_ad2 				<= 1'b0								;
						rd_cnt_ad3 				<= 1'b0								;
						rd_cnt_ad4 				<= 1'b0								;
						rd_cnt_ad5 				<= 1'b0								;
						rd_cnt_ad6 				<= 1'b0								;
						rd_cnt_ad7 				<= 1'b0								;
						rd_cnt_ad8 				<= 1'b0								;
						rd_cnt_ad9 				<= 1'b0								;
						rd_cnt_ad10 			<= 1'b0								;
						rd_cnt_ad11 			<= 1'b0								;
						rd_cnt_ad12 			<= 1'b0								;
						rd_cnt_ad13 			<= 1'b0								;
						rd_cnt_ad14 			<= 1'b0								;
						rd_cnt_ad15 			<= 1'b0								;
						rd_cnt_ad16 			<= 1'b0								;	
					
						up_s					<= UP_IDLE							;
					end

				end   
				
				RD_DATA0: begin
							sdram_addr		<= current_rd_addr0			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							reg_ad_status[0]<= rd_full_flag					;
							rd_cnt_ad1		<= rd_cnt_ad1 + 1'b1;
							cnt1 			<= cnt1 + 1'b1;
							up_s			<= RD_DATA0_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA0						;end
				RD_DATA0_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA0_DONE						; end
									
				RD_DATA1: begin
							sdram_addr		<= current_rd_addr1			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad2		<= rd_cnt_ad2 + 1'b1;
							cnt2 			<= cnt2 + 1'b1;
							reg_ad_status[1]<= rd_full_flag					;
							up_s			<= RD_DATA1_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA1						;end
				RD_DATA1_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA1_DONE						; end
									
				RD_DATA2: begin
							sdram_addr		<= current_rd_addr2			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad3		<= rd_cnt_ad3 + 1'b1;
							cnt3 			<= cnt3 + 1'b1;
							reg_ad_status[2]<= rd_full_flag					;
							up_s			<= RD_DATA2_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA2						;end
				RD_DATA2_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA2_DONE						; end
									
				RD_DATA3: begin
							sdram_addr		<= current_rd_addr3			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad4		<= rd_cnt_ad4 + 1'b1;
							reg_ad_status[3]<= rd_full_flag					;
							up_s			<= RD_DATA3_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA3						;end
				RD_DATA3_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA3_DONE						; end									
				RD_DATA4: begin
							sdram_addr		<= current_rd_addr4			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad5		<= rd_cnt_ad5 + 1'b1;
							reg_ad_status[4]<= rd_full_flag					;
							up_s			<= RD_DATA4_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA4						;end
				RD_DATA4_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA4_DONE						; end									
				RD_DATA5: begin
							sdram_addr		<= current_rd_addr5			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad6		<= rd_cnt_ad6 + 1'b1;
							reg_ad_status[5]<= rd_full_flag					;
							up_s			<= RD_DATA5_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA5						;end
				RD_DATA5_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA5_DONE						; end									
				RD_DATA6: begin
							sdram_addr		<= current_rd_addr6			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad7		<= rd_cnt_ad7 + 1'b1;
							reg_ad_status[6]<= rd_full_flag					;
							up_s			<= RD_DATA6_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA6						;end
				RD_DATA6_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA6_DONE						; end	
							
				RD_DATA7: begin
							sdram_addr		<= current_rd_addr7			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad8		<= rd_cnt_ad8 + 1'b1;
							reg_ad_status[7]<= rd_full_flag					;
							up_s			<= RD_DATA7_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA7						;end
				RD_DATA7_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA7_DONE						; end
							
				RD_DATA8: begin
							sdram_addr		<= current_rd_addr8			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad9		<= rd_cnt_ad9 + 1'b1;
							reg_ad_status[8]<= rd_full_flag					;
							up_s			<= RD_DATA8_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA8						;end
				RD_DATA8_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA8_DONE						; end
							
				RD_DATA9: begin
							sdram_addr		<= current_rd_addr9			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad10		<= rd_cnt_ad10 + 1'b1;
							reg_ad_status[9]<= rd_full_flag					;
							up_s			<= RD_DATA9_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA9						;end
				RD_DATA9_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA9_DONE						; end
							
				RD_DATA10: begin
							sdram_addr		<= current_rd_addr10			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad11		<= rd_cnt_ad11 + 1'b1;
							reg_ad_status[10]<= rd_full_flag					;
							up_s			<= RD_DATA10_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA10						;end
				RD_DATA10_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA10_DONE						; end
							
				RD_DATA11: begin
							sdram_addr		<= current_rd_addr11			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad12		<= rd_cnt_ad12 + 1'b1;
							reg_ad_status[11]<= rd_full_flag					;
							up_s			<= RD_DATA11_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA11						;end
				RD_DATA11_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA11_DONE						; end
							
				RD_DATA12: begin
							sdram_addr		<= current_rd_addr12			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad13		<= rd_cnt_ad13 + 1'b1;
							reg_ad_status[12]<= rd_full_flag					;
							up_s			<= RD_DATA12_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA12						;end
				RD_DATA12_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA12_DONE						; end

				RD_DATA13: begin
							sdram_addr		<= current_rd_addr13			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad14		<= rd_cnt_ad14 + 1'b1;
							reg_ad_status[13]<= rd_full_flag					;
							up_s			<= RD_DATA13_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA13						;end
				RD_DATA13_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA13_DONE						; end

				RD_DATA14: begin
							sdram_addr		<= current_rd_addr14			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad15		<= rd_cnt_ad15 + 1'b1;
							reg_ad_status[14]<= rd_full_flag					;
							up_s			<= RD_DATA14_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA14						;end
				RD_DATA14_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA14_DONE						; end	
							
				RD_DATA15: begin
							sdram_addr		<= current_rd_addr15			;
							rd_en			<= 1'b1;
							if(rd_ack == 1'b1)begin//读1024 *8 数据完成
							rd_cnt_ad16		<= rd_cnt_ad16 + 1'b1;
							reg_ad_status[15]<= rd_full_flag					;
							up_s			<= RD_DATA15_DONE						;
							rd_en			<= 1'b0							;end
							else
							up_s			<= RD_DATA15						;end
				RD_DATA15_DONE: 
							begin
							//reg_ad_status		<= 16'b0							;
							//rd_delay		<= rd_delay + 1'b1				;
							if(rdempty_flag)
							up_s			<= WR_DONE_ST						;
							else
							up_s			<= RD_DATA15_DONE						; end	
					
				default: begin  
					
					up_s					<= UP_IDLE						;
					up_fifo_wen				<= 1'b0							;
					ad_fifo_rd 				<= 20'b0						;
					up_cnt					<= 11'b0						;
				end
			endcase
		end
	end	

	///===FIFO复位信号
	
	generate	
		genvar	k;	
			for(k=0;k<16;k=k+1) begin	:	fifo_rst_G	
		
			assign fifo_rst[k] 		= 	(wr_cnt[k] >=12'd1024)?1'b1:1'b0					;

	end             			
		endgenerate	
	always@(*) begin
		case(up_s)
		UP_DATA0:sdram_fifo_datain	<= fifo_datain[0*16+:16]		;
		UP_DATA1:sdram_fifo_datain	<= fifo_datain[1*16+:16]		;
		UP_DATA2:sdram_fifo_datain	<= fifo_datain[2*16+:16]		;
		UP_DATA3:sdram_fifo_datain	<= fifo_datain[3*16+:16]		;
		UP_DATA4:sdram_fifo_datain	<= fifo_datain[4*16+:16]		;
		UP_DATA5:sdram_fifo_datain	<= fifo_datain[5*16+:16]		;
		UP_DATA6:sdram_fifo_datain	<= fifo_datain[6*16+:16]		;
		UP_DATA7:sdram_fifo_datain	<= fifo_datain[7*16+:16]		;
		UP_DATA8:sdram_fifo_datain	<= fifo_datain[8*16+:16]		;
		UP_DATA9:sdram_fifo_datain	<= fifo_datain[9*16+:16]		;
		UP_DATA10:sdram_fifo_datain	<= fifo_datain[10*16+:16]		;
		UP_DATA11:sdram_fifo_datain	<= fifo_datain[11*16+:16]		;
		UP_DATA12:sdram_fifo_datain	<= fifo_datain[12*16+:16]		;
		UP_DATA13:sdram_fifo_datain	<= fifo_datain[13*16+:16]		;
		UP_DATA14:sdram_fifo_datain	<= fifo_datain[14*16+:16]		;
		UP_DATA15:sdram_fifo_datain	<= fifo_datain[15*16+:16]		;
		default sdram_fifo_datain <= 'd0 ;
		endcase
		end
		
		
		
		
		
		
		
			assign dma_up_fifo_wen		  	= 	up_fifo_wen					;
			
			assign sdram_fifo_wr_req 		= 	up_fifo_wen					;

	
			assign fifo_rd_req				= 	ad_fifo_rd					;

///写地址产生

	always@(posedge clk_40m,negedge sys_rst_n)
		if(!sys_rst_n) begin
			current_wr_addr0		<= sdram_addr0							;
			current_wr_addr1	    <= sdram_addr1	                        ;
			current_wr_addr2	    <= sdram_addr2	                        ;
			current_wr_addr3	    <= sdram_addr3	                        ;
			current_wr_addr4	    <= sdram_addr4	                        ;
			current_wr_addr5	    <= sdram_addr5	                        ;
			current_wr_addr6	    <= sdram_addr6	                        ;
			current_wr_addr7	    <= sdram_addr7	                        ;
			current_wr_addr8	    <= sdram_addr8	                        ;
			current_wr_addr9	    <= sdram_addr9	                        ;
			current_wr_addr10	    <= sdram_addr10                         ;
			current_wr_addr11	    <= sdram_addr11                         ;
			current_wr_addr12	    <= sdram_addr12                         ;
			current_wr_addr13	    <= sdram_addr13                         ;
			current_wr_addr14	    <= sdram_addr14                         ;
			current_wr_addr15	    <= sdram_addr15                         ;
		end
		else begin
			if(up_s == UP_DATA0 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/* 				if(current_wr_addr0[19:3] == 17'h1FFFF)
					current_wr_addr0[19:3] <= 17'b0;
				else */
					current_wr_addr0[19:3] <= current_wr_addr0[19:3] + 1'b1; end
					
			else if(up_s == UP_DATA1 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/* 				if(current_wr_addr1[19:3] == 17'h1FFFF)
					current_wr_addr1[19:3] <= 17'b0;
				else */
					current_wr_addr1[19:3] <= current_wr_addr1[19:3] + 1'b1; end
					
			else if(up_s == UP_DATA2 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/* 				if(current_wr_addr2[19:3] == 17'h1FFFF)
					current_wr_addr2[19:3] <= 17'b0;
				else */
					current_wr_addr2[19:3] <= current_wr_addr2[19:3] + 1'b1; end
					
			else if(up_s == UP_DATA3 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/* 				if(current_wr_addr3[19:3] == 17'h1FFFF)
					current_wr_addr3[19:3] <= 17'b0;
				else */
					current_wr_addr3[19:3] <= current_wr_addr3[19:3] + 1'b1; end	
					
			else if(up_s == UP_DATA4 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr4[19:3] == 17'h1FFFF)
					current_wr_addr4[19:3] <= 17'b0;
				else*/
					current_wr_addr4[19:3] <= current_wr_addr4[19:3] + 1'b1; end
									
			else if(up_s == UP_DATA5 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr5[19:3] == 17'h1FFFF)
					current_wr_addr5[19:3] <= 17'b0;
				else*/
					current_wr_addr5[19:3] <= current_wr_addr5[19:3] + 1'b1; end
													
			else if(up_s == UP_DATA6 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr6[19:3] == 17'h1FFFF)
					current_wr_addr6[19:3] <= 17'b0;
				else*/
					current_wr_addr6[19:3] <= current_wr_addr6[19:3] + 1'b1; end
																
			else if(up_s == UP_DATA7 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr7[19:3] == 17'h1FFFF)
					current_wr_addr7[19:3] <= 17'b0;
				else*/
					current_wr_addr7[19:3] <= current_wr_addr7[19:3] + 1'b1; end
																	
			else if(up_s == UP_DATA8 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr8[19:3] == 17'h1FFFF)
					current_wr_addr8[19:3] <= 17'b0;
				else*/
					current_wr_addr8[19:3] <= current_wr_addr8[19:3] + 1'b1; end
																		
			else if(up_s == UP_DATA9 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr9[19:3] == 17'h1FFFF)
					current_wr_addr9[19:3] <= 17'b0;
				else*/
					current_wr_addr9[19:3] <= current_wr_addr9[19:3] + 1'b1; end
																			
			else if(up_s == UP_DATA10 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr10[19:3] == 17'h1FFFF)
					current_wr_addr10[19:3] <= 17'b0;
				else*/
					current_wr_addr10[19:3] <= current_wr_addr10[19:3] + 1'b1; end
																				
			else if(up_s == UP_DATA11 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr11[19:3] == 17'h1FFFF)
					current_wr_addr11[19:3] <= 17'b0;
				else*/
					current_wr_addr11[19:3] <= current_wr_addr11[19:3] + 1'b1; end
																					
			else if(up_s == UP_DATA12 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr12[19:3] == 17'h1FFFF)
					current_wr_addr12[19:3] <= 17'b0;
				else*/
					current_wr_addr12[19:3] <= current_wr_addr12[19:3] + 1'b1; end
																						
			else if(up_s == UP_DATA13 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr13[19:3] == 17'h1FFFF)
					current_wr_addr13[19:3] <= 17'b0;
				else*/
					current_wr_addr13[19:3] <= current_wr_addr13[19:3] + 1'b1; end
																							
			else if(up_s == UP_DATA14 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*				if(current_wr_addr14[19:3] == 17'h1FFFF)
					current_wr_addr14[19:3] <= 17'b0;
				else*/
					current_wr_addr14[19:3] <= current_wr_addr14[19:3] + 1'b1; end
																								
			else if(up_s == UP_DATA15 && up_cnt == up_length_cnt_64bit- 1'b1) begin
/*			if(current_wr_addr15[19:3] == 17'h1FFFF)
					current_wr_addr15[19:3] <= 17'b0;
				else*/
					current_wr_addr15[19:3] <= current_wr_addr15[19:3] + 1'b1; end
			else begin
					
					current_wr_addr0		<=  current_wr_addr0              ;
					current_wr_addr1	    <=  current_wr_addr1              ;
					current_wr_addr2	    <=  current_wr_addr2              ;
					current_wr_addr3	    <=  current_wr_addr3              ;
					current_wr_addr4	    <=  current_wr_addr4              ;
					current_wr_addr5	    <=  current_wr_addr5              ;
					current_wr_addr6	    <=  current_wr_addr6              ;
					current_wr_addr7	    <=  current_wr_addr7              ;
					current_wr_addr8	    <=  current_wr_addr8              ;
					current_wr_addr9	    <=  current_wr_addr9              ;
					current_wr_addr10	    <=  current_wr_addr10             ;
					current_wr_addr11	    <=  current_wr_addr11             ;
					current_wr_addr12	    <=  current_wr_addr12             ;
					current_wr_addr13	    <=  current_wr_addr13             ;
					current_wr_addr14	    <=  current_wr_addr14             ;
					current_wr_addr15	    <=  current_wr_addr15             ;
				end
			end
					
	

		always@(posedge clk_40m,negedge sys_rst_n)
			if(!sys_rst_n) begin
					current_rd_addr0		<= sdram_addr0							;
					current_rd_addr1	    <= sdram_addr1	                        ;
					current_rd_addr2	    <= sdram_addr2	                        ;
					current_rd_addr3	    <= sdram_addr3	                        ;
					current_rd_addr4	    <= sdram_addr4	                        ;
					current_rd_addr5	    <= sdram_addr5	                        ;
					current_rd_addr6	    <= sdram_addr6	                        ;
					current_rd_addr7	    <= sdram_addr7	                        ;
					current_rd_addr8	    <= sdram_addr8	                        ;
					current_rd_addr9	    <= sdram_addr9	                        ;
					current_rd_addr10	    <= sdram_addr10                         ;
					current_rd_addr11	    <= sdram_addr11                         ;
					current_rd_addr12	    <= sdram_addr12                         ;
					current_rd_addr13	    <= sdram_addr13                         ;
					current_rd_addr14	    <= sdram_addr14                         ;
					current_rd_addr15	    <= sdram_addr15                         ;end
			else begin
			
				if(up_s == RD_DATA0 ||up_s == RD_DATA0_DONE) begin
/* 				if(current_rd_addr0[19:3] == 17'h1FFFF)
					current_rd_addr0[19:3] <= 17'b0; 
				else*/ if(neg_rdack)
					current_rd_addr0[19:3] <= current_rd_addr0[19:3] + 1'b1; 
				else
					current_rd_addr0[19:3] <= current_rd_addr0[19:3]				;end

				if(up_s == RD_DATA1 ||up_s == RD_DATA1_DONE) begin
/* 				if(current_rd_addr1[19:3] == 17'h1FFFF)
					current_rd_addr1[19:3] <= 17'b0;
				else  */if(neg_rdack)
					current_rd_addr1[19:3] <= current_rd_addr1[19:3] + 1'b1; 
				else
					current_rd_addr1[19:3] <= current_rd_addr1[19:3]				;end

				if(up_s == RD_DATA2 ||up_s == RD_DATA2_DONE) begin
/* 				if(current_rd_addr2[19:3] == 17'h1FFFF)
					current_rd_addr2[19:3] <= 17'b0;
				else  */if(neg_rdack)
					current_rd_addr2[19:3] <= current_rd_addr2[19:3] + 1'b1; 
				else
					current_rd_addr2[19:3] <= current_rd_addr2[19:3]				;end

				if(up_s == RD_DATA3 ||up_s == RD_DATA3_DONE) begin
/* 				if(current_rd_addr3[19:3] == 17'h1FFFF)
					current_rd_addr3[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr3[19:3] <= current_rd_addr3[19:3] + 1'b1; 
				else
					current_rd_addr3[19:3] <= current_rd_addr3[19:3]				;end

				if(up_s == RD_DATA4 ||up_s == RD_DATA4_DONE) begin
/*				if(current_rd_addr4[19:3] == 17'h1FFFF)
					current_rd_addr4[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr4[19:3] <= current_rd_addr4[19:3] + 1'b1; 
				else
					current_rd_addr4[19:3] <= current_rd_addr4[19:3]				;end

				if(up_s == RD_DATA5 ||up_s == RD_DATA5_DONE) begin
/*				if(current_rd_addr5[19:3] == 17'h1FFFF)
					current_rd_addr5[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr5[19:3] <= current_rd_addr5[19:3] + 1'b1; 
				else
					current_rd_addr5[19:3] <= current_rd_addr5[19:3]				;end

				if(up_s == RD_DATA6 ||up_s == RD_DATA6_DONE) begin
/*				if(current_rd_addr6[19:3] == 17'h1FFFF)
					current_rd_addr6[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr6[19:3] <= current_rd_addr6[19:3] + 1'b1; 
				else
					current_rd_addr6[19:3] <= current_rd_addr6[19:3]				;end

				if(up_s == RD_DATA7 ||up_s == RD_DATA7_DONE) begin
/*				if(current_rd_addr7[19:3] == 17'h1FFFF)
					current_rd_addr7[19:3] <= 17'b0;
				else */if(neg_rdack)
					current_rd_addr7[19:3] <= current_rd_addr7[19:3] + 1'b1; 
				else
					current_rd_addr7[19:3] <= current_rd_addr7[19:3]				;end

	
				if(up_s == RD_DATA8 ||up_s == RD_DATA8_DONE) begin
/*				if(current_rd_addr8[19:3] == 17'h1FFFF)
					current_rd_addr8[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr8[19:3] <= current_rd_addr8[19:3] + 1'b1; 
				else
					current_rd_addr8[19:3] <= current_rd_addr8[19:3]				;end

				if(up_s == RD_DATA9 ||up_s == RD_DATA9_DONE) begin
/*				if(current_rd_addr9[19:3] == 17'h1FFFF)
					current_rd_addr9[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr9[19:3] <= current_rd_addr9[19:3] + 1'b1; 
				else
					current_rd_addr9[19:3] <= current_rd_addr9[19:3]				;end

				if(up_s == RD_DATA10 ||up_s == RD_DATA10_DONE) begin
/*				if(current_rd_addr10[19:3] == 17'h1FFFF)
					current_rd_addr10[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr10[19:3] <= current_rd_addr10[19:3] + 1'b1; 
				else
					current_rd_addr10[19:3] <= current_rd_addr10[19:3]				;end

				if(up_s == RD_DATA11 ||up_s == RD_DATA11_DONE) begin
/*				if(current_rd_addr11[19:3] == 17'h1FFFF)
					current_rd_addr11[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr11[19:3] <= current_rd_addr11[19:3] + 1'b1; 
				else
					current_rd_addr11[19:3] <= current_rd_addr11[19:3]				;end

				if(up_s == RD_DATA12 ||up_s == RD_DATA12_DONE) begin
/*				if(current_rd_addr12[19:3] == 17'h1FFFF)
					current_rd_addr12[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr12[19:3] <= current_rd_addr12[19:3] + 1'b1; 
				else
					current_rd_addr12[19:3] <= current_rd_addr12[19:3]				;end

				if(up_s == RD_DATA13 ||up_s == RD_DATA13_DONE) begin
/*				if(current_rd_addr13[19:3] == 17'h1FFFF)
					current_rd_addr13[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr13[19:3] <= current_rd_addr13[19:3] + 1'b1; 
				else
					current_rd_addr13[19:3] <= current_rd_addr13[19:3]				;end

				if(up_s == RD_DATA14 ||up_s == RD_DATA14_DONE) begin
/*				if(current_rd_addr14[19:3] == 17'h1FFFF)
					current_rd_addr14[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr14[19:3] <= current_rd_addr14[19:3] + 1'b1; 
				else
					current_rd_addr14[19:3] <= current_rd_addr14[19:3]				;end

				if(up_s == RD_DATA15 ||up_s == RD_DATA15_DONE) begin
/*				if(current_rd_addr15[19:3] == 17'h1FFFF)
					current_rd_addr15[19:3] <= 17'b0;
				else */ if(neg_rdack)
					current_rd_addr15[19:3] <= current_rd_addr15[19:3] + 1'b1; 
				else
					current_rd_addr15[19:3] <= current_rd_addr15[19:3]				;end
			end
	
			
			
/* ///写地址产生

	always@(posedge clk_40m,negedge sys_rst_n)
		if(!sys_rst_n) begin
			current_wr_addr0		<= sdram_addr0							;
			current_wr_addr1	    <= sdram_addr1	                        ;
			current_wr_addr2	    <= sdram_addr2	                        ;
			current_wr_addr3	    <= sdram_addr3	                        ;
			current_wr_addr4	    <= sdram_addr4	                        ;
			current_wr_addr5	    <= sdram_addr5	                        ;
			current_wr_addr6	    <= sdram_addr6	                        ;
			current_wr_addr7	    <= sdram_addr7	                        ;
			current_wr_addr8	    <= sdram_addr8	                        ;
			current_wr_addr9	    <= sdram_addr9	                        ;
			current_wr_addr10	    <= sdram_addr10                         ;
			current_wr_addr11	    <= sdram_addr11                         ;
			current_wr_addr12	    <= sdram_addr12                         ;
			current_wr_addr13	    <= sdram_addr13                         ;
			current_wr_addr14	    <= sdram_addr14                         ;
			current_wr_addr15	    <= sdram_addr15                         ;
		end
		else begin
			if(up_s == UP_DATA0 && up_cnt == up_length_cnt_64bit- 1'b1) begin
 				if(current_wr_addr0[19:3] == 17'd513)
					current_wr_addr0[19:3] <= 17'd1;
				else 
					current_wr_addr0[19:3] <= current_wr_addr0[19:3] + 1'b1; end
					
			else if(up_s == UP_DATA1 && up_cnt == up_length_cnt_64bit- 1'b1) begin
 				if(current_wr_addr1[19:3] == 17'd513)
					current_wr_addr1[19:3] <= 17'd1;
				else 
					current_wr_addr1[19:3] <= current_wr_addr1[19:3] + 1'b1; end
					
			else if(up_s == UP_DATA2 && up_cnt == up_length_cnt_64bit- 1'b1) begin
 				if(current_wr_addr2[19:3] == 17'd513)
					current_wr_addr2[19:3] <= 17'd1;
				else 
					current_wr_addr2[19:3] <= current_wr_addr2[19:3] + 1'b1; end
					
			else if(up_s == UP_DATA3 && up_cnt == up_length_cnt_64bit- 1'b1) begin
 				if(current_wr_addr3[19:3] == 17'd513)
					current_wr_addr3[19:3] <= 17'd1;
				else 
					current_wr_addr3[19:3] <= current_wr_addr3[19:3] + 1'b1; end	
					
			else if(up_s == UP_DATA4 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr4[19:3] == 17'd513)
					current_wr_addr4[19:3] <= 17'd1;
				else
					current_wr_addr4[19:3] <= current_wr_addr4[19:3] + 1'b1; end
									
			else if(up_s == UP_DATA5 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr5[19:3] == 17'd513)
					current_wr_addr5[19:3] <= 17'd1;
				else
					current_wr_addr5[19:3] <= current_wr_addr5[19:3] + 1'b1; end
													
			else if(up_s == UP_DATA6 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr6[19:3] == 17'd513)
					current_wr_addr6[19:3] <= 17'd1;
				else
					current_wr_addr6[19:3] <= current_wr_addr6[19:3] + 1'b1; end
																
			else if(up_s == UP_DATA7 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr7[19:3] == 17'd513)
					current_wr_addr7[19:3] <= 17'd1;
				else
					current_wr_addr7[19:3] <= current_wr_addr7[19:3] + 1'b1; end
																	
			else if(up_s == UP_DATA8 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr8[19:3] == 17'd513)
					current_wr_addr8[19:3] <= 17'd1;
				else
					current_wr_addr8[19:3] <= current_wr_addr8[19:3] + 1'b1; end
																		
			else if(up_s == UP_DATA9 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr9[19:3] == 17'd513)
					current_wr_addr9[19:3] <= 17'd1;
				else
					current_wr_addr9[19:3] <= current_wr_addr9[19:3] + 1'b1; end
																			
			else if(up_s == UP_DATA10 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr10[19:3] == 17'd513)
					current_wr_addr10[19:3] <= 17'd1;
				else
					current_wr_addr10[19:3] <= current_wr_addr10[19:3] + 1'b1; end
																				
			else if(up_s == UP_DATA11 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr11[19:3] == 17'd513)
					current_wr_addr11[19:3] <= 17'd1;
				else
					current_wr_addr11[19:3] <= current_wr_addr11[19:3] + 1'b1; end
																					
			else if(up_s == UP_DATA12 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr12[19:3] == 17'd513)
					current_wr_addr12[19:3] <= 17'd1;
				else
					current_wr_addr12[19:3] <= current_wr_addr12[19:3] + 1'b1; end
																						
			else if(up_s == UP_DATA13 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr13[19:3] == 17'd513)
					current_wr_addr13[19:3] <= 17'd1;
				else
					current_wr_addr13[19:3] <= current_wr_addr13[19:3] + 1'b1; end
																							
			else if(up_s == UP_DATA14 && up_cnt == up_length_cnt_64bit- 1'b1) begin
				if(current_wr_addr14[19:3] == 17'd513)
					current_wr_addr14[19:3] <= 17'd1;
				else
					current_wr_addr14[19:3] <= current_wr_addr14[19:3] + 1'b1; end
																								
			else if(up_s == UP_DATA15 && up_cnt == up_length_cnt_64bit- 1'b1) begin
			if(current_wr_addr15[19:3] == 17'd513)
					current_wr_addr15[19:3] <= 17'd1;
				else
					current_wr_addr15[19:3] <= current_wr_addr15[19:3] + 1'b1; end
			else begin
					
					current_wr_addr0		<=  current_wr_addr0              ;
					current_wr_addr1	    <=  current_wr_addr1              ;
					current_wr_addr2	    <=  current_wr_addr2              ;
					current_wr_addr3	    <=  current_wr_addr3              ;
					current_wr_addr4	    <=  current_wr_addr4              ;
					current_wr_addr5	    <=  current_wr_addr5              ;
					current_wr_addr6	    <=  current_wr_addr6              ;
					current_wr_addr7	    <=  current_wr_addr7              ;
					current_wr_addr8	    <=  current_wr_addr8              ;
					current_wr_addr9	    <=  current_wr_addr9              ;
					current_wr_addr10	    <=  current_wr_addr10             ;
					current_wr_addr11	    <=  current_wr_addr11             ;
					current_wr_addr12	    <=  current_wr_addr12             ;
					current_wr_addr13	    <=  current_wr_addr13             ;
					current_wr_addr14	    <=  current_wr_addr14             ;
					current_wr_addr15	    <=  current_wr_addr15             ;
				end
			end
					
	

		always@(posedge clk_40m,negedge sys_rst_n)
			if(!sys_rst_n) begin
					current_rd_addr0		<= sdram_addr0							;
					current_rd_addr1	    <= sdram_addr1	                        ;
					current_rd_addr2	    <= sdram_addr2	                        ;
					current_rd_addr3	    <= sdram_addr3	                        ;
					current_rd_addr4	    <= sdram_addr4	                        ;
					current_rd_addr5	    <= sdram_addr5	                        ;
					current_rd_addr6	    <= sdram_addr6	                        ;
					current_rd_addr7	    <= sdram_addr7	                        ;
					current_rd_addr8	    <= sdram_addr8	                        ;
					current_rd_addr9	    <= sdram_addr9	                        ;
					current_rd_addr10	    <= sdram_addr10                         ;
					current_rd_addr11	    <= sdram_addr11                         ;
					current_rd_addr12	    <= sdram_addr12                         ;
					current_rd_addr13	    <= sdram_addr13                         ;
					current_rd_addr14	    <= sdram_addr14                         ;
					current_rd_addr15	    <= sdram_addr15                         ;end
			else begin
			
				if(up_s == RD_DATA0 ||up_s == RD_DATA0_DONE) begin
 				if(current_rd_addr0[19:3] == 17'd513)
					current_rd_addr0[19:3] <= 17'd1; 
				else if(neg_rdack)
					current_rd_addr0[19:3] <= current_rd_addr0[19:3] + 1'b1; 
				else
					current_rd_addr0[19:3] <= current_rd_addr0[19:3]				;end

				if(up_s == RD_DATA1 ||up_s == RD_DATA1_DONE) begin
 				if(current_rd_addr1[19:3] == 17'd513)
					current_rd_addr1[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr1[19:3] <= current_rd_addr1[19:3] + 1'b1; 
				else
					current_rd_addr1[19:3] <= current_rd_addr1[19:3]				;end

				if(up_s == RD_DATA2 ||up_s == RD_DATA2_DONE) begin
 				if(current_rd_addr2[19:3] == 17'd513)
					current_rd_addr2[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr2[19:3] <= current_rd_addr2[19:3] + 1'b1; 
				else
					current_rd_addr2[19:3] <= current_rd_addr2[19:3]				;end

				if(up_s == RD_DATA3 ||up_s == RD_DATA3_DONE) begin
 				if(current_rd_addr3[19:3] == 17'd513)
					current_rd_addr3[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr3[19:3] <= current_rd_addr3[19:3] + 1'b1; 
				else
					current_rd_addr3[19:3] <= current_rd_addr3[19:3]				;end

				if(up_s == RD_DATA4 ||up_s == RD_DATA4_DONE) begin
				if(current_rd_addr4[19:3] == 17'd513)
					current_rd_addr4[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr4[19:3] <= current_rd_addr4[19:3] + 1'b1; 
				else
					current_rd_addr4[19:3] <= current_rd_addr4[19:3]				;end

				if(up_s == RD_DATA5 ||up_s == RD_DATA5_DONE) begin
				if(current_rd_addr5[19:3] == 17'd513)
					current_rd_addr5[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr5[19:3] <= current_rd_addr5[19:3] + 1'b1; 
				else
					current_rd_addr5[19:3] <= current_rd_addr5[19:3]				;end

				if(up_s == RD_DATA6 ||up_s == RD_DATA6_DONE) begin
				if(current_rd_addr6[19:3] == 17'd513)
					current_rd_addr6[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr6[19:3] <= current_rd_addr6[19:3] + 1'b1; 
				else
					current_rd_addr6[19:3] <= current_rd_addr6[19:3]				;end

				if(up_s == RD_DATA7 ||up_s == RD_DATA7_DONE) begin
				if(current_rd_addr7[19:3] == 17'd513)
					current_rd_addr7[19:3] <= 17'd1;
				else if(neg_rdack)
					current_rd_addr7[19:3] <= current_rd_addr7[19:3] + 1'b1; 
				else
					current_rd_addr7[19:3] <= current_rd_addr7[19:3]				;end

	
				if(up_s == RD_DATA8 ||up_s == RD_DATA8_DONE) begin
				if(current_rd_addr8[19:3] == 17'd513)
					current_rd_addr8[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr8[19:3] <= current_rd_addr8[19:3] + 1'b1; 
				else
					current_rd_addr8[19:3] <= current_rd_addr8[19:3]				;end

				if(up_s == RD_DATA9 ||up_s == RD_DATA9_DONE) begin
				if(current_rd_addr9[19:3] == 17'd513)
					current_rd_addr9[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr9[19:3] <= current_rd_addr9[19:3] + 1'b1; 
				else
					current_rd_addr9[19:3] <= current_rd_addr9[19:3]				;end

				if(up_s == RD_DATA10 ||up_s == RD_DATA10_DONE) begin
				if(current_rd_addr10[19:3] == 17'd513)
					current_rd_addr10[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr10[19:3] <= current_rd_addr10[19:3] + 1'b1; 
				else
					current_rd_addr10[19:3] <= current_rd_addr10[19:3]				;end

				if(up_s == RD_DATA11 ||up_s == RD_DATA11_DONE) begin
				if(current_rd_addr11[19:3] == 17'd513)
					current_rd_addr11[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr11[19:3] <= current_rd_addr11[19:3] + 1'b1; 
				else
					current_rd_addr11[19:3] <= current_rd_addr11[19:3]				;end

				if(up_s == RD_DATA12 ||up_s == RD_DATA12_DONE) begin
				if(current_rd_addr12[19:3] == 17'd513)
					current_rd_addr12[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr12[19:3] <= current_rd_addr12[19:3] + 1'b1; 
				else
					current_rd_addr12[19:3] <= current_rd_addr12[19:3]				;end

				if(up_s == RD_DATA13 ||up_s == RD_DATA13_DONE) begin
				if(current_rd_addr13[19:3] == 17'd513)
					current_rd_addr13[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr13[19:3] <= current_rd_addr13[19:3] + 1'b1; 
				else
					current_rd_addr13[19:3] <= current_rd_addr13[19:3]				;end

				if(up_s == RD_DATA14 ||up_s == RD_DATA14_DONE) begin
				if(current_rd_addr14[19:3] == 17'd513)
					current_rd_addr14[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr14[19:3] <= current_rd_addr14[19:3] + 1'b1; 
				else
					current_rd_addr14[19:3] <= current_rd_addr14[19:3]				;end

				if(up_s == RD_DATA15 ||up_s == RD_DATA15_DONE) begin
				if(current_rd_addr15[19:3] == 17'd513)
					current_rd_addr15[19:3] <= 17'd1;
				else  if(neg_rdack)
					current_rd_addr15[19:3] <= current_rd_addr15[19:3] + 1'b1; 
				else
					current_rd_addr15[19:3] <= current_rd_addr15[19:3]				;end
			end */
					
endmodule
	