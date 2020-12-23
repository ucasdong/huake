module top#(
			ADDR_reg_BASE   = 10'h000
		)(
		input					clk_25M													,
//		input					rst_n													,
		//MCU moudle
		input              	 	muc_cs_n												,//使能
		inout   	[15:0]      muc_data												,//数据线
		input   	[8:0]       muc_addr												,//地址线
		input               	muc_we_n												,//写使能
		input              		muc_rd_n												, //读使能
		
		// AD 接口
		input       [15:0]  	adc_db_i0												,       // ADC parallel data bus
		input       [15:0]  	adc_db_i1												,       // ADC parallel data bus

		output      [2:0]   	adc_os_o0												,       // ADC OVERSAMPLING signals
		output      [2:0]   	adc_os_o1												,       // ADC OVERSAMPLING signals
		output      [2:0]   	adc_os_o2												,       // ADC OVERSAMPLING signals
		output      [2:0]   	adc_os_o3												,       // ADC OVERSAMPLING signals
													
													
		input       [3:0]       adc_busy_i												,     	// ADC BUSY signal
		output      [3:0]       adc_range_o												,    	// ADC RANGE signal
		output  	[3:0]       adc_rd_n_o												,     	// ADC RD signal
		output  	[3:0]       adc_reset_o												,    	// ADC RESET signal
		output  	[3:0]       adc_convst_a_o											,    	// ADC CONVST signal
		output  	[3:0]       adc_convst_b_o											,   	// ADC CONVST signal
		output		[3:0]		adc_cs_n_o												,
		
		input					Phase_in												,
		
		// FPGA与SDRAM硬件接口
	/*	output 					sdram_clk												,		//	SDRAM时钟信号
		output 					sdram_cke												,		//  SDRAM时钟有效信号
		output 					sdram_cs_n												,		//	SDRAM片选信号
		output 					sdram_ras_n												,		//	SDRAM行地址选通脉冲
		output 					sdram_cas_n												,		//	SDRAM列地址选通脉冲
		output 					sdram_we_n												,		//	SDRAM写允许位
		output		[1:0] 		sdram_ba												,		//	SDRAM的L-Bank地址线
		output		[12:0] 		sdram_addr												,		//  SDRAM地址总线
		output 					sdram_udqm												,		//  SDRAM高字节屏蔽
		output 					sdram_ldqm												,		//  SDRAM低字节屏蔽
		inout		[15:0]  	sdram_data												,		//  SDRAM数据总线
	*/	
		output     reg  key_ledg_o  ='b0  , //jianxxiang
		output     reg  trans_ledr_o = 'b0,	//yaoshu
		output     reg  samp_ledy_o ='b0		//caiyang zhishi

);
	//assign	rst_n = 1'b1;				
			
		//FPGA的mcu总线接口寄存器地址定义   				
					
		parameter	ADDR_reg_version		=	ADDR_reg_BASE + 10'h00					;//版本寄存器  
		parameter	ADDR_reg_freq1			=	ADDR_reg_BASE + 10'h02					;//频率配置寄存器1  
		parameter	ADDR_reg_freq2			=	ADDR_reg_BASE + 10'h04					;//频率配置寄存器2  
		parameter	ADDR_reg_freq3			=	ADDR_reg_BASE + 10'h06					;//频率配置寄存器3  
		parameter	ADDR_reg_freq4			=	ADDR_reg_BASE + 10'h08					;//频率配置寄存器4  
		parameter	ADDR_reg_freq_phase_l	=	ADDR_reg_BASE + 10'h0A					;//鉴相周期低16位计数器  
		parameter	ADDR_reg_freq_phase_h	=	ADDR_reg_BASE + 10'h0C					;//鉴相周期高16位计数器  
		parameter	ADDR_reg_ad_enble		=	ADDR_reg_BASE + 10'h0E					;//AD开始/停止位  
		parameter	ADDR_reg_ad_reset		=	ADDR_reg_BASE + 10'h10					;//AD复位  
		parameter	ADDR_reg_ad_fifo_clr	=	ADDR_reg_BASE + 10'h12					;//清ad fifo  
		parameter	ADDR_reg_ad_status		=	ADDR_reg_BASE + 10'h14					;//ad fifo状态寄存器 
						
		parameter	ADDR_reg_ad1_data		=	ADDR_reg_BASE + 10'h16					;//第1通道AD数据寄存器 
		parameter	ADDR_reg_ad2_data		=	ADDR_reg_BASE + 10'h18					;//第2通道AD数据寄存器 
		parameter	ADDR_reg_ad3_data		=	ADDR_reg_BASE + 10'h1A					;//第3通道AD数据寄存器 
		parameter	ADDR_reg_ad4_data		=	ADDR_reg_BASE + 10'h1C					;//第4通道AD数据寄存器 
		parameter	ADDR_reg_ad5_data		=	ADDR_reg_BASE + 10'h1E					;//第5通道AD数据寄存器 
		parameter	ADDR_reg_ad6_data		=	ADDR_reg_BASE + 10'h20					;//第6通道AD数据寄存器 
		parameter	ADDR_reg_ad7_data		=	ADDR_reg_BASE + 10'h22					;//第7通道AD数据寄存器 
		parameter	ADDR_reg_ad8_data		=	ADDR_reg_BASE + 10'h24					;//第8通道AD数据寄存器 
		parameter	ADDR_reg_ad9_data		=	ADDR_reg_BASE + 10'h26					;//第9通道AD数据寄存器 
		parameter	ADDR_reg_ad10_data		=	ADDR_reg_BASE + 10'h28					;//第10通道AD数据寄存器 
		parameter	ADDR_reg_ad11_data		=	ADDR_reg_BASE + 10'h2A					;//第11通道AD数据寄存器 
		parameter	ADDR_reg_ad12_data		=	ADDR_reg_BASE + 10'h2C					;//第12通道AD数据寄存器 
		parameter	ADDR_reg_ad13_data		=	ADDR_reg_BASE + 10'h2E					;//第13通道AD数据寄存器 
		parameter	ADDR_reg_ad14_data		=	ADDR_reg_BASE + 10'h30					;//第14通道AD数据寄存器 
		parameter	ADDR_reg_ad15_data		=	ADDR_reg_BASE + 10'h32					;//第15通道AD数据寄存器 
		parameter	ADDR_reg_ad16_data		=	ADDR_reg_BASE + 10'h34					;//第16通道AD数据寄存器 
		parameter	ADDR_reg_datafull			=	ADDR_reg_BASE + 10'h36					;//所有通道数据采集满4096 
		//线网定义
		wire    	[15:0]  mcu_data_in;
		wire				detect_error;//鉴相故障指示
		(*keep*)reg    		[15:0]  mcu_data_out = 16'b0;
		//三态操作接口
		assign muc_data 	= ((muc_cs_n || muc_rd_n) == 1'b0)?mcu_data_out:16'hzzzz	;
		assign mcu_data_in 	= muc_data													;
		//FPGA的mcu总线接口寄存器定义
		wire		[15:0]	reg_version	 = 16'h1000					;//版本寄存器  
		reg 		[15:0]	reg_freq1 = 16'h1                      ;//频率位置寄存器
		reg         [15:0]  reg_freq2 = 16'h1                      ;//频率位置寄存器
		reg         [15:0]  reg_freq3 = 16'h1                       ;//频率位置寄存器
		reg         [15:0]  reg_freq4 = 16'h1						;//频率位置寄存器
		reg			[15:0]	reg_freq_phase_l			;//鉴相频率寄存器
        reg			[15:0]	reg_freq_phase_h	        ;//鉴相频率寄存器
        reg					reg_ad_enble = 1'b0		     ;//AD使能/停止寄存器
        reg					reg_ad_reset		        ;//AD复位寄存器
        reg					reg_ad_fifo_clr	        ;//清FIFO寄存器
        wire		[15:0]	reg_ad_status		        ;//AD 状态机寄存器
		wire		[15:0]	reg_ad_fullflag				;
	                                                 
        reg			[15:0]	reg_ad1_data		        ;//第1通道AD数据寄存器
        reg			[15:0]	reg_ad2_data		        ;//第2通道AD数据寄存器
        reg			[15:0]	reg_ad3_data		        ;//第3通道AD数据寄存器
        reg			[15:0]	reg_ad4_data		        ;//第4通道AD数据寄存器
        reg			[15:0]	reg_ad5_data		        ;//第5通道AD数据寄存器
        reg			[15:0]	reg_ad6_data		        ;//第6通道AD数据寄存器
        reg			[15:0]	reg_ad7_data		        ;//第7通道AD数据寄存器
        reg			[15:0]	reg_ad8_data		        ;//第8通道AD数据寄存器
        reg			[15:0]	reg_ad9_data		        ;//第9通道AD数据寄存器
        reg			[15:0]	reg_ad10_data		        ;//第10通道AD数据寄存器
        reg			[15:0]	reg_ad11_data		        ;//第11通道AD数据寄存器
        reg			[15:0]	reg_ad12_data		        ;//第12通道AD数据寄存器
        reg			[15:0]	reg_ad13_data		        ;//第13通道AD数据寄存器
        reg			[15:0]	reg_ad14_data		        ;//第14通道AD数据寄存器
        reg			[15:0]	reg_ad15_data		        ;//第15通道AD数据寄存器
        reg			[15:0]	reg_ad16_data		        ;//第16通道AD数据寄存器
		
		reg 		[16:1]	rdsdram_fifo_req			;//ARM 读FIFO使能
		(*keep*)wire		[15:0]	rdf_dout					;//sdram_fifo输出数据
		(*keep*)wire		[15:0]	fifo_rst					;//wrfifo_16w_16r_128d复位信号
		(*keep*)reg					rdf_rdreq					;//sdram_fifo读使能
		
reg [31:00] key_led_cnt;
reg [4:0]   samp_led_cnt = 'd0; 
reg cs_r = 'b1;
always@(posedge clk_25M)
  if(key_led_cnt >= Phase_cnt_out ) begin
     key_led_cnt <= #1 'b0;
     key_ledg_o <= #1 ~key_ledg_o ; end
  else
     key_led_cnt <= #1 key_led_cnt + 1'b1;		
always@(posedge clk_25M)
    trans_ledr_o <= data_full;			
		
		//例化接口表
		wire						data_full				;//所有通道数据采集满4096
		wire			[15:0]	adc_db_i	[3:0]			;
		wire			[2:0]	adc_os_o	[3:0]			;
		wire			[15:0]	data_i		[3:0]			;
		wire			[3:0]	wr_data_n_i					;
		
		assign		adc_db_i[0] = adc_db_i0					;
		assign		adc_db_i[1] = adc_db_i0					;
		assign		adc_db_i[2] = adc_db_i1					;
		assign		adc_db_i[3] = adc_db_i1					;
						
		assign      adc_os_o0 = adc_os_o[0]					;
		assign      adc_os_o1 = adc_os_o[1]					;
		assign      adc_os_o2 = adc_os_o[2]					;
		assign      adc_os_o3 = adc_os_o[3]					;
		//线网定义
		wire			[31:0]	Phase_cnt_out				;
		(*keep*)wire			[15:0]	data_oa		[3:0]			;
		wire			[15:0]	data_ob     [3:0]           ;
		wire			[15:0]	data_oc     [3:0]           ;
		wire			[15:0]	data_od     [3:0]           ;
		//时钟部分
		wire			AD_CLK_40M							;// AD 时钟  40M 对应采样周期为6 us
		wire			SDRAM_CLK_50M						;// SDRAM时钟 为50M
		(*keep*)wire			FSMC_CLK_100M 						;//	FSMC总线处理时钟，读写命令宽度大约为30us
		wire			locked								;
		
		
		assign			detect_error = (Phase_cnt_out == 32'b0)?1'b1:1'b0; //鉴相器错误指示
		// 复位部分

		reg				[11:0]	rst_ncnt;
		reg						rst_n_reg;
		always@(posedge clk_25M) 	
			if(rst_ncnt <=12'd3000) begin
				rst_ncnt <= rst_ncnt + 1'b1;
				rst_n_reg <= 1'b0;  end
			else begin
				rst_ncnt <= rst_ncnt;
				rst_n_reg <= 1'b1; end
		wire		rst_n;
		assign		rst_n = rst_n_reg;
// 上行包统计

	(*keep*)reg	[10:0]	ch1/* synthesis preserve = 1 */;
	(*keep*)reg	[10:0]  ch2/* synthesis preserve = 1 */;
	(*keep*)reg	[10:0]  ch3/* synthesis preserve = 1 */;
	(*keep*)reg	[15:0]	reg_ad_status_reg/* synthesis preserve = 1 */;
 	always@(posedge AD_CLK_40M)
		reg_ad_status_reg <= reg_ad_status;
	always@(posedge AD_CLK_40M) 
	
		if((reg_ad_status == 16'h1) & (reg_ad_status_reg == 16'b0))
			ch1 <= ch1 + 1'b1;
			
	always@(posedge AD_CLK_40M) 
	
		 if((reg_ad_status == 16'h2) & (reg_ad_status_reg == 16'b0))
			ch2 <= ch2 + 1'b1;
			
	always@(posedge AD_CLK_40M) 			
		 if((reg_ad_status == 16'h4) & (reg_ad_status_reg == 16'b0))
			ch3 <= ch3 + 1'b1;

					

		//100M PLL
	PLL_ctrl	PLL_ctrl_inst (
		.areset (1'b0				),
		.inclk0 ( clk_25M 			),
		.c0 	( AD_CLK_40M		),
		.c1 	( SDRAM_CLK_50M 	),
		.c2 	( FSMC_CLK_100M 	),
		.c3 	( sdram_clk 		),
		.locked ( locked			)
		);
		
		////////////////////////////////////////////////////////////////////////////////////////		
		//总线读部分
		always @(*) 
			begin
				case({muc_cs_n,muc_rd_n,muc_addr})
				{2'b0,ADDR_reg_version	}:     mcu_data_out <= reg_version			      		;
				{2'b0,ADDR_reg_freq1    }:     mcu_data_out <= reg_freq1                  		;
				{2'b0,ADDR_reg_freq2    }:     mcu_data_out <= reg_freq2                  		;
				{2'b0,ADDR_reg_freq3    }:     mcu_data_out <= reg_freq3                  		;
				{2'b0,ADDR_reg_freq4	}:     mcu_data_out <= reg_freq4			      		;
				{2'b0,ADDR_reg_freq_phase_l}:  mcu_data_out <= Phase_cnt_out[15:0]      		;
				{2'b0,ADDR_reg_freq_phase_h}:  mcu_data_out <= Phase_cnt_out[31:16]      		;
				{2'b0,ADDR_reg_ad_enble	}:     mcu_data_out <= {15'b0,reg_ad_enble}  			;
				{2'b0,ADDR_reg_ad_reset	}:     mcu_data_out <= {15'b0,reg_ad_reset}	    		;
				{2'b0,ADDR_reg_ad_fifo_clr}:   mcu_data_out <= {15'b0,reg_ad_fifo_clr}    		;
				{2'b0,ADDR_reg_ad_status}:     mcu_data_out <= reg_ad_status	     			;
												                                         
				{2'b0,ADDR_reg_ad1_data	}:     mcu_data_out <= reg_ad1_data	      				;
				{2'b0,ADDR_reg_ad2_data	}:     mcu_data_out <= reg_ad2_data	      				;
				{2'b0,ADDR_reg_ad3_data	}:     mcu_data_out <= reg_ad3_data	      				;
				{2'b0,ADDR_reg_ad4_data	}:     mcu_data_out <= reg_ad4_data	      				;
				{2'b0,ADDR_reg_ad5_data	}:     mcu_data_out <= reg_ad5_data	      				;
				{2'b0,ADDR_reg_ad6_data	}:     mcu_data_out <= reg_ad6_data	      				;
				{2'b0,ADDR_reg_ad7_data	}:     mcu_data_out <= reg_ad7_data	      				;
				{2'b0,ADDR_reg_ad8_data	}:     mcu_data_out <= reg_ad8_data	      				;
				{2'b0,ADDR_reg_ad9_data	}:     mcu_data_out <= reg_ad9_data	      				;
				{2'b0,ADDR_reg_ad10_data}:     mcu_data_out <= reg_ad10_data	      			;
				{2'b0,ADDR_reg_ad11_data}:     mcu_data_out <= reg_ad11_data	      			;
				{2'b0,ADDR_reg_ad12_data}:     mcu_data_out <= reg_ad12_data	      			;
				{2'b0,ADDR_reg_ad13_data}:     mcu_data_out <= reg_ad13_data	      			;
				{2'b0,ADDR_reg_ad14_data}:     mcu_data_out <= reg_ad14_data	      			;
				{2'b0,ADDR_reg_ad15_data}:     mcu_data_out <= reg_ad15_data	      			;
				{2'b0,ADDR_reg_ad16_data}:     mcu_data_out <= reg_ad16_data	      			;
				{2'b0,ADDR_reg_datafull	}:     mcu_data_out <= {14'b0,detect_error,data_full}	      		;
				
				default:    				   mcu_data_out <= 16'b0;
				endcase
			end

		/////////////////////////////////////////////////////////////////////////////////////////////
		//总线写部分
		always @(posedge FSMC_CLK_100M) 
			begin
				case({muc_cs_n,muc_we_n,muc_addr})
				{2'b0,ADDR_reg_freq1   	}:    reg_freq1             <= 	mcu_data_in				;
				{2'b0,ADDR_reg_freq2   	}:    reg_freq2             <= 	mcu_data_in				;
				{2'b0,ADDR_reg_freq3    }:    reg_freq3             <= 	mcu_data_in				;
				{2'b0,ADDR_reg_freq4	}:    reg_freq4		    	<= 	mcu_data_in				;
				{2'b0,ADDR_reg_ad_enble	}:    reg_ad_enble  	 	<= 	mcu_data_in[0]			;
				{2'b0,ADDR_reg_ad_reset	}:    reg_ad_reset		 	<=  mcu_data_in[0]			;
				{2'b0,ADDR_reg_ad_fifo_clr}:  reg_ad_fifo_clr 		<=  mcu_data_in[0]			;							                                       
				default:   	;
				endcase
			end
			
/*		//--------------------------数据配置部分	
 		assign	wr_data_n_i[0] =({muc_cs_n,muc_we_n,muc_addr} == {2'b0,ADDR_reg_freq1 })?1'b0:1'b1;	
		assign	wr_data_n_i[1] =({muc_cs_n,muc_we_n,muc_addr} == {2'b0,ADDR_reg_freq2 })?1'b0:1'b1;	
		assign	wr_data_n_i[2] =({muc_cs_n,muc_we_n,muc_addr} == {2'b0,ADDR_reg_freq3 })?1'b0:1'b1;	
		assign	wr_data_n_i[3] =({muc_cs_n,muc_we_n,muc_addr} == {2'b0,ADDR_reg_freq4 })?1'b0:1'b1;	
		//用来配置AD的参数 暂时无定义
		assign	data_i[0]	   = reg_freq1;
		assign	data_i[1]	   = reg_freq2;
		assign	data_i[2]	   = reg_freq3;
		assign	data_i[3]	   = reg_freq4; */
		//------------------------------------------------------------------------------------------
		wire	[3:0]			ad_start			;
		(*keep*)wire	[3:0]			data_rd_ready_o		;
		
		wire	[23:0] 			sys_addr			;
		wire					rd_en				;
		wire					rd_ack		        ;
		wire					sdram_rd_ack        ;
		
		//assign	ad_start = 4'b1001;
		
		////////////////////////////////////////////////////////////////////////////////////////////
		
		///AD 模块例化
		
		(*keep*)wire			[15:0]	q_data_oa	 	[3:0]		;
		wire			[15:0]	q_data_ob    	[3:0]       ;
		wire			[15:0]	q_data_oc    	[3:0]       ;
		wire			[15:0]	q_data_od    	[3:0]       ;	
		wire			[255:0]	fifo_datain					;
		(*keep*)wire			[15:0]	fifo_rd_req					;
		assign			fifo_datain = {	q_data_od[3],q_data_oc[3],q_data_ob[3],q_data_oa[3],
										q_data_od[2],q_data_oc[2],q_data_ob[2],q_data_oa[2],
										q_data_od[1],q_data_oc[1],q_data_ob[1],q_data_oa[1],
										q_data_od[0],q_data_oc[0],q_data_ob[0],q_data_oa[0]};
		(*keep*)wire			[6:0]	wrusedw		[15:0]		;	
		(*keep*)wire			[15:0]	wrusedw_flag				;
		wire			[15:0]	wrfifo_gnt_in				;
		(*keep*)wire			[15:0]	wrfull_flag					;
		wire					rd_ack_falg					;
		wire					rdempty_flag					;
		
	generate	
		genvar	k;	
			for(k=0;k<16;k=k+1) begin	:	wrusedw_G	
		
			assign wrusedw_flag[k] 		= 	(wrusedw[k] >=8'd7)?1'b1:1'b0					;

	end             			
		endgenerate				
		
		
 		generate	
		genvar	i;	
			for(i=0;i<4;i=i+1) begin	:	AD7606_DR	
AD7606 U1_AD7606 (
		.clk_40M		(AD_CLK_40M				), 
		.ad_start		(ad_start[i]      ), 
		.wr_data_n_i	(wr_data_n_i[i]			), 
		.data_i			(data_i[i]				), //参数配置
		.data_oa		(data_oa[i]				), 
		.data_ob		(data_ob[i]				), 
		.data_oc		(data_oc[i]				), 
		.data_od		(data_od[i]				), 
		.data_rd_ready_o(data_rd_ready_o[i]		), 
		.data_wr_ready_o(						), 
		.sync_o			(						), 
		.adc_db_i		(adc_db_i[i]			), 
		.adc_busy_i		(adc_busy_i[i]			), 
		.adc_os_o		(adc_os_o[i]			), 
		.adc_range_o	(adc_range_o[i]			), 
		.adc_cs_n_o		(adc_cs_n_o[i]			), 
		.adc_rd_n_o		(adc_rd_n_o[i]			), 
		.adc_reset_o	(adc_reset_o[i]			), 
		.adc_convst_a_o	(adc_convst_a_o[i]		), 
		.adc_convst_b_o	(adc_convst_b_o[i]		) 
		);
	wrfifo_16w_16r_128d	data_oa_wrfifo_8w_8r_128d (
		.aclr 			( fifo_rst[i*4 + 0] 	),
		.data 			( data_oa[i] 			),
		.wrclk 			( AD_CLK_40M	 		),
		.wrreq 			( data_rd_ready_o[i] & (wrusedw[i*4 + 0]<= 7'd120) 	),
		.rdclk 			( AD_CLK_40M 			),
		.rdreq 			( fifo_rd_req[i*4 + 0] 	),	
		.q 				( q_data_oa[i] 			),
		.rdempty 		( rdempty_sig 			),
		.rdusedw 		( rdusedw_sig 			),
		.wrfull 		( wrfull_flag[i*4 + 0] 	),
		.wrusedw 		( wrusedw[i*4 + 0] 		)
	);	
		wrfifo_16w_16r_128d	data_ob_wrfifo_8w_8r_128d (
		.aclr 			( fifo_rst[i*4 + 1]		),
		.data 			( data_ob[i] 			),
		.wrclk 			( AD_CLK_40M	 		),
		.wrreq 			( data_rd_ready_o[i] & (wrusedw[i*4 + 1]<= 7'd120) 	),
		.rdclk 			( AD_CLK_40M 			),
		.rdreq 			( fifo_rd_req[i*4 + 1]	),	
		.q 				( q_data_ob[i] 			),
		.rdempty 		( rdempty_sig 			),
		.rdusedw 		( rdusedw_sig 			),
		.wrfull 		( wrfull_flag[i*4 + 1] 	),
		.wrusedw 		( wrusedw[i*4 + 1] 		)
	);	
		wrfifo_16w_16r_128d	data_oc_wrfifo_8w_8r_128d (
		.aclr 			( fifo_rst[i*4 + 2]		),
		.data 			( data_oc[i] 			),
		.wrclk 			( AD_CLK_40M	 		),
		.wrreq 			( data_rd_ready_o[i] & (wrusedw[i*4 + 2]<= 7'd120) 	),
		.rdclk 			( AD_CLK_40M 			),
		.rdreq 			( fifo_rd_req[i*4 + 2]	),	
		.q 				( q_data_oc[i] 			),
		.rdempty 		( rdempty_sig 			),
		.rdusedw 		( rdusedw_sig 			),
		.wrfull 		( wrfull_flag[i*4 + 2] 	),
		.wrusedw 		( wrusedw[i*4 + 2] 		)
	);	
		wrfifo_16w_16r_128d	data_od_wrfifo_8w_8r_128d (
		.aclr 			( fifo_rst[i*4 + 3] 	),
		.data 			( data_od[i] 			),
		.wrclk 			( AD_CLK_40M	 		),
		.wrreq 			( data_rd_ready_o[i] & (wrusedw[i*4 + 3]<= 7'd120) 	),
		.rdclk 			( AD_CLK_40M 			),
		.rdreq 			( fifo_rd_req[i*4 + 3]	),	
		.q 				( q_data_od[i] 			),
		.rdempty 		( rdempty_sig 			),
		.rdusedw 		( rdusedw_sig 			),
		.wrfull 		( wrfull_flag[i*4 + 3] 	),
		.wrusedw 		( wrusedw[i*4 + 3] 		)
	);	
	
		end             			
		endgenerate 	
//写仲裁部分
wire		wrf_empty;
wire		wr_done;
wire		flag;

arb U_arb (
 
	.Clk				(AD_CLK_40M				),
	.Gnt_out			(wrfifo_gnt_in			),
	.Req_in				(wrusedw_flag[15:0]		),
	.Reset_n			(rst_n					),
	.sdram_fifo_empty	(wr_done				)
);

//写控制部分
wire	[15:0]	sdram_fifo_datain;
wire			sdram_fifo_wr_req;
WR_CTL U_WR_CTL (
 
	.clk_40m			(AD_CLK_40M			),
	.fifo_datain		(fifo_datain		),
	.fifo_rd_req		(fifo_rd_req		),
	.sdram_fifo_datain	(sdram_fifo_datain	),
	.sdram_fifo_wr_req	(sdram_fifo_wr_req	),
	.sys_rst_n			(rst_n				),
	.wrf_empty			(wrf_empty			),
	.wrfifo_gnt_in		(wrfifo_gnt_in		),
	.sdram_addr			(sys_addr			),
	.rd_en				(rd_en				),
	.rd_ack				(rd_ack				),
	.sdram_rd_ack		(sdram_rd_ack		),
	.reg_ad_status		(reg_ad_status		),
	.rd_full_flag		(rd_ack_falg		),
	.rdempty_flag		(rdempty_flag		),
	.flag				(flag				),
	.wr_done			(wr_done			),
	.fifo_rst			(fifo_rst			),
	.data_full			(data_full			)
	
);

///ARM读使能产生信号
	reg			[16:1]				rd_sdram_fifo_req;
	always@(posedge FSMC_CLK_100M) begin
	
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad1_data	})
			rd_sdram_fifo_req[1] <= 1'b1;
		else
			rd_sdram_fifo_req[1] <= 1'b0;
			
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad2_data	})
			rd_sdram_fifo_req[2] <= 1'b1;
		else
			rd_sdram_fifo_req[2] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad3_data	})
			rd_sdram_fifo_req[3] <= 1'b1;
		else
			rd_sdram_fifo_req[3] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad4_data	})
			rd_sdram_fifo_req[4] <= 1'b1;
		else
			rd_sdram_fifo_req[4] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad5_data	})
			rd_sdram_fifo_req[5] <= 1'b1;
		else
			rd_sdram_fifo_req[5] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad6_data	})
			rd_sdram_fifo_req[6] <= 1'b1;
		else
			rd_sdram_fifo_req[6] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad7_data	})
			rd_sdram_fifo_req[7] <= 1'b1;
		else
			rd_sdram_fifo_req[7] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad8_data	})
			rd_sdram_fifo_req[8] <= 1'b1;
		else
			rd_sdram_fifo_req[8] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad9_data	})
			rd_sdram_fifo_req[9] <= 1'b1;
		else
			rd_sdram_fifo_req[9] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad10_data	})
			rd_sdram_fifo_req[10] <= 1'b1;
		else
			rd_sdram_fifo_req[10] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad11_data	})
			rd_sdram_fifo_req[11] <= 1'b1;
		else
			rd_sdram_fifo_req[11] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad12_data	})
			rd_sdram_fifo_req[12] <= 1'b1;
		else
			rd_sdram_fifo_req[12] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad13_data	})
			rd_sdram_fifo_req[13] <= 1'b1;
		else
			rd_sdram_fifo_req[13] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad14_data	})
			rd_sdram_fifo_req[14] <= 1'b1;
		else
			rd_sdram_fifo_req[14] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad15_data	})
			rd_sdram_fifo_req[15] <= 1'b1;
		else
			rd_sdram_fifo_req[15] <= 1'b0;
			
						
		if({muc_cs_n,muc_rd_n,muc_addr} =={2'b0,ADDR_reg_ad16_data	})
			rd_sdram_fifo_req[16] <= 1'b1;
		else
			rd_sdram_fifo_req[16] <= 1'b0;
		end

	always@(posedge FSMC_CLK_100M)
		rdsdram_fifo_req <= rd_sdram_fifo_req;
	reg	[16:1]		rd_sdram_fifo_req_flag;
	generate	
		genvar	n;	
			for(n=1;n<17;n=n+1) begin	:	rd_sdram_fifo_req_flag_G	
			always@(posedge FSMC_CLK_100M)
		//	assign rd_sdram_fifo_req_flag[n] 		= 	rd_sdram_fifo_req[n] & !rdsdram_fifo_req[n];
			 rd_sdram_fifo_req_flag[n] 		<= 	rd_sdram_fifo_req[n] & !rdsdram_fifo_req[n];

	end  
endgenerate	

// arm 读使能及数据路由
 	always@(posedge FSMC_CLK_100M) begin
	case(reg_ad_status)
		16'h0001: begin rdf_rdreq <= rd_sdram_fifo_req_flag[1 ];reg_ad1_data <= rdf_dout;  end
		16'h0002: begin rdf_rdreq <= rd_sdram_fifo_req_flag[2 ];reg_ad2_data <= rdf_dout;  end
		16'h0004: begin rdf_rdreq <= rd_sdram_fifo_req_flag[3 ];reg_ad3_data <= rdf_dout;  end
		16'h0008: begin rdf_rdreq <= rd_sdram_fifo_req_flag[4 ];reg_ad4_data <= rdf_dout;  end
		16'h0010: begin rdf_rdreq <= rd_sdram_fifo_req_flag[5 ];reg_ad5_data <= rdf_dout;  end
		16'h0020: begin rdf_rdreq <= rd_sdram_fifo_req_flag[6 ];reg_ad6_data <= rdf_dout;  end
		16'h0040: begin rdf_rdreq <= rd_sdram_fifo_req_flag[7 ];reg_ad7_data <= rdf_dout;  end
		16'h0080: begin rdf_rdreq <= rd_sdram_fifo_req_flag[8 ];reg_ad8_data <= rdf_dout;  end
		16'h0100: begin rdf_rdreq <= rd_sdram_fifo_req_flag[9 ];reg_ad9_data <= rdf_dout;  end
		16'h0200: begin rdf_rdreq <= rd_sdram_fifo_req_flag[10];reg_ad10_data <= rdf_dout;  end
		16'h0400: begin rdf_rdreq <= rd_sdram_fifo_req_flag[11];reg_ad11_data <= rdf_dout;  end
		16'h0800: begin rdf_rdreq <= rd_sdram_fifo_req_flag[12];reg_ad12_data <= rdf_dout;  end
		16'h1000: begin rdf_rdreq <= rd_sdram_fifo_req_flag[13];reg_ad13_data <= rdf_dout;  end
		16'h2000: begin rdf_rdreq <= rd_sdram_fifo_req_flag[14];reg_ad14_data <= rdf_dout;  end
		16'h4000: begin rdf_rdreq <= rd_sdram_fifo_req_flag[15];reg_ad15_data <= rdf_dout;  end
		16'h8000: begin rdf_rdreq <= rd_sdram_fifo_req_flag[16];reg_ad16_data <= rdf_dout;  end
		default:  ;
	endcase
end	 
////ceshi yong

reg		rdf_rdreq_ceshi;
reg		[16:1]	fifo_wr		;
reg		[16:1]	data_in [16:1];



/*sdram_ctl U2_sdram_ctl (

	.clk_40m		(AD_CLK_40M				),
	.clk_50m		(AD_CLK_40M),//(SDRAM_CLK_50M			),
	.clk_100m		(FSMC_CLK_100M			),
	.locked			(locked					),
			
	.rst_n			(rst_n					),
	.sdram_addr		(sdram_addr				),
	.sdram_ba		(sdram_ba				),
	.sdram_cas_n	(sdram_cas_n			),
	.sdram_cke		(sdram_cke				),
	.sdram_clk		(						),
	.sdram_cs_n		(sdram_cs_n				),
	.sdram_data		(sdram_data				),
	.sdram_ldqm		(sdram_ldqm				),
	.sdram_ras_n	(sdram_ras_n			),
	.sdram_udqm		(sdram_udqm				),
	.sdram_we_n		(sdram_we_n				),
	.sys_addr		(sys_addr				),
	.wrf_din		(sdram_fifo_datain		),
	.wrf_empty		(wrf_empty				),
	.wrf_wrreq		(sdram_fifo_wr_req		),
	.rd_en			(rd_en					),
	.rd_ack			(rd_ack					),
	.sdram_rd_ack	(sdram_rd_ack			),
	.rdf_rdreq		(rdf_rdreq				),//(	rdf_rdreq_ceshi			),		
	.rdf_dout		(rdf_dout				),
	.rd_ack_falg	(rd_ack_falg			),
	.rdempty_flag	(rdempty_flag			),
);*/		

 // ceshi 
   wire     Phase_valid;
	reg		reg_ad_enble_ceshi;
	reg		Phase_in_ceshi;
	reg		[9:0]	ad_en_cnt;
	reg		[29:0]	Phase_in_cnt;
	always@(posedge AD_CLK_40M)
		if(ad_en_cnt<10'd500) begin
			ad_en_cnt <= ad_en_cnt + 1'b1;
			reg_ad_enble_ceshi <= 1'b0;
			end
		else begin
			ad_en_cnt <= ad_en_cnt ;
			reg_ad_enble_ceshi <= 1'b1;
			end
	always@(posedge AD_CLK_40M)	
		if(Phase_in_cnt == 30'd40000000) begin
			Phase_in_cnt <= 1'b0;
			Phase_in_ceshi <= 1'b1; end
		else begin
			Phase_in_cnt <= Phase_in_cnt +1'b1;
			Phase_in_ceshi <= 1'b0; end
		 

Phase_detector U3_Phase_detector (
    .rst_n			(reg_ad_enble_ceshi			), //用AD使能来启动键相模块
    .clk			(AD_CLK_40M				), 
    .Phase_in		(	Phase_in		), //(Phase_in    )//输入键相频率用Phase_in,内部模拟用Phase_in_ceshi
	 .Phase_valid   (Phase_valid),
    .Phase_cnt_out	(Phase_cnt_out			)//31:0
    );	
AD_CTL U4_AD_CTL 
	(
    .clk			(AD_CLK_40M				), 
    .rst_n			(reg_ad_enble_ceshi		), 
	 .reg_ad_enble (reg_ad_enble     ),
	 .Phase_valid  (Phase_valid),
    .reg_freq1		(reg_freq1),//(reg_freq1	16'd10000			), 用配置系数时用reg_freq1,用内部固定频率用10K即16'd10000
    .reg_freq2		(reg_freq2),//(reg_freq2	16'd10000			), 
    .reg_freq3		(reg_freq3),//(reg_freq3	16'd10000			), 
    .reg_freq4		(reg_freq4),//(reg_freq4				), 
    .Phase_cnt_out	(Phase_cnt_out			), 
    .ad_start		(ad_start				)//(ad_start)
    );

	
	//上行 4096 fifo
	wire	wrfull_sig1,wrfull_sig2,wrfull_sig3;	
	reg		[16:1]	fifo_wr_reg1;
	reg		[16:1]	fifo_wr_reg2;
	reg		[11:0]	wrfull_cnt1;
	reg		[11:0]	wrfull_cnt2;
	reg		[11:0]	wrfull_cnt3;
	wire	[11:0]	wrusedw1;
	wire	[11:0]	wrusedw2;
	
	
	
endmodule
