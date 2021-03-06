//`define test
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
													
													
		input       [1:0]       adc_busy_i												,     	// ADC BUSY signal
		input       [1:0]       fastdata												,     	// ADC BUSY signal
		output      [1:0]       adc_range_o												,    	// ADC RANGE signal
		output  	[1:0]       adc_rd_n_o												,     	// ADC RD signal
		output  	[1:0]       adc_reset_o												,    	// ADC RESET signal
		output  	[1:0]       adc_convst_a_o											,    	// ADC CONVST signal
		output  	[1:0]       adc_convst_b_o											,   	// ADC CONVST signal
		output		[1:0]		adc_cs_n_o												,
		
		input					Phase_in												,
		
		output     reg  		key_ledg_o   = 'b0  									, //jianxxiang
		output     reg  		work_led = 'b0										,	//yaoshu
		output     reg  		trans_ledr_o  = 'b0											//caiyang zhishi

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
		parameter	ADDR_reg_datafull		=	ADDR_reg_BASE + 10'h36					;//所有通道数据采集满4096 
		//线网定义
		wire    	[15:0]  mcu_data_in;
		wire				detect_error;//鉴相故障指示
		reg    		[15:0]  mcu_data_out = 16'b0;
		//三态操作接口
		assign muc_data 	= !muc_rd_n ?mcu_data_out:16'hzzzz	;
		assign mcu_data_in 	= muc_data													;
		//FPGA的mcu总线接口寄存器定义
		wire		[15:0]	reg_version	 = 16'h1000		;//版本寄存器  
		reg 		[15:0]	reg_freq1 = 16'd10240           ;//频率位置寄存器
		reg         [15:0]  reg_freq2 = 16'h10240           ;//频率位置寄存器
		reg         [15:0]  reg_freq3 = 16'h1           ;//频率位置寄存器
		reg         [15:0]  reg_freq4 = 16'h1			;//频率位置寄存器
		reg			[15:0]	reg_freq_phase_l			;//鉴相频率寄存器
        reg			[15:0]	reg_freq_phase_h	        ;//鉴相频率寄存器
        reg					reg_ad_enble = 1'b0		    ;//AD使能/停止寄存器
        reg					reg_ad_reset		        ;//AD复位寄存器
        reg					reg_ad_fifo_clr = 'b0       ;//清FIFO寄存器
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
		
		reg 		[16:1]	rdsdram_fifo_req			;//ARM 读FIFO使能
		wire		[15:0]	rdf_dout					;//sdram_fifo输出数据
		reg 		[00:0]	fifo_rst ='b1   			;//wrfifo_16w_16r_128d复位信号
		reg					rdf_rdreq					;//sdram_fifo读使能
		reg                 ad_enble_r = 'b0			;
		reg                 work_en             = 'b0;
		//fifo full state
		wire        [07:00] full                        ;
		wire                locked                      ;
//-------------------------------------------------------
		wire			AD_CLK_40M							;// AD 时钟  40M 对应采样周期为6 us
		wire			FSMC_CLK_100M 						;//	FSMC总线处理时钟，读写命令宽度大约为30us
		//100M PLL
    PLL_ctrl PLL_ctrl_inst
   (
    .CLK_IN1	( clk_25M		),    
    .CLK_OUT1	( AD_CLK_40M	),     
    .CLK_OUT2	( FSMC_CLK_100M	),     
    .RESET		( 'b0			),
    .LOCKED		( locked		)
	);     		
//-------------------------------------------------------
//-------------------------------------------------------
reg   [31:00] work_led_cnt = 'b0;
always@(posedge AD_CLK_40M)
  if(work_led_cnt >= 32'd20000000)
   begin
     work_led_cnt <= 'b0;
	 work_led     <= ~work_led;
   end
   else 
   work_led_cnt   <= work_led_cnt + 32'b1;

     
//-------------------------------------------------------
  always@(posedge AD_CLK_40M)
    if(data_full)
      work_en <= 'b0;
    else if(~ad_enble_r && reg_ad_enble)//pos adenble
      work_en <= 'b1;
    else
      work_en <= work_en;
//-------------------------------------------------------
		
		
reg [31:00] key_led_cnt;
always@(posedge AD_CLK_40M)
  if(key_led_cnt >= Phase_cnt_out ) begin
     key_led_cnt <= #1 'b0;
     key_ledg_o <= #1 ~key_ledg_o ; end
  else
     key_led_cnt <= #1 key_led_cnt + 1'b1;		
always@(posedge AD_CLK_40M)
    trans_ledr_o <= data_full;	
//clear fifo 
always@(posedge AD_CLK_40M)	
     ad_enble_r <= #1 reg_ad_enble;

   
		
		//例化接口表
		reg				        data_full = 'b0  		    ;//所有通道数据采集满4096
		wire			[15:0]	adc_db_i	[1:0]			;
		wire			[2:0]	adc_os_o	[1:0]			;
		wire			[15:0]	data_i		[1:0]			;
		wire			[1:0]	wr_data_n_i					;
		
		assign		adc_db_i[0] = adc_db_i0					;
		assign		adc_db_i[1] = adc_db_i1					;
						
		assign      adc_os_o0 = adc_os_o[0]					;
		assign      adc_os_o1 = adc_os_o[1]					;
	
		//线网定义
		wire			[31:0]	Phase_cnt_out				;
		wire			[15:0]	data_oa		[3:0]			;
		wire			[15:0]	data_ob     [3:0]           ;
		wire			[15:0]	data_oc     [3:0]           ;
		wire			[15:0]	data_od     [3:0]           ;
		wire			[3:0]	dbg_adc_next_state     [1:0]           ;
		wire            [3:0]   next_state0;
		wire            [3:0]   next_state1;
		assign                  next_state0 = dbg_adc_next_state[0][3:0];
		assign                  next_state1 = dbg_adc_next_state[1][3:0];
		reg                     clr_fifo ='b0;
		//时钟部分


		
	   //     assign                  data_full = &full;	
		always@(posedge FSMC_CLK_100M)
              if(clr_fifo)
                 data_full <= 'b0;
              else if(&full)
                 data_full <= 'b1;
   			  
			
		assign			detect_error = (Phase_cnt_out == 32'b0)?1'b1:1'b0; //鉴相器错误指示
		// 复位部分

		reg				[11:0]	rst_ncnt;
		reg						rst_n_reg;
		always@(posedge AD_CLK_40M) 	
			if(rst_ncnt <=12'd3000) begin
				rst_ncnt <= rst_ncnt + 1'b1;
				rst_n_reg <= 1'b0;  end
			else begin
				rst_ncnt <= rst_ncnt;
				rst_n_reg <= 1'b1; end
		wire		rst_n;
		assign		rst_n = rst_n_reg;
// 上行包统计

	reg	[10:0]	ch1/* synthesis preserve = 1 */;
	reg	[10:0]  ch2/* synthesis preserve = 1 */;
	reg	[10:0]  ch3/* synthesis preserve = 1 */;
	reg	[15:0]	reg_ad_status_reg/* synthesis preserve = 1 */;
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

					


		
		
		////////////////////////////////////////////////////////////////////////////////////////		
		//总线读部分
		always @(*) 
		  if(!rst_n) 
		  mcu_data_out <= 'b0;
		  else
			begin if(!muc_rd_n)
				case(muc_addr)
				{ADDR_reg_version	}:     mcu_data_out <= reg_version			      		;
				{ADDR_reg_freq1     }:     mcu_data_out <= reg_freq1                  		;
				{ADDR_reg_freq2     }:     mcu_data_out <= reg_freq2                  		;
				{ADDR_reg_freq3     }:     mcu_data_out <= reg_freq3                  		;
				{ADDR_reg_freq4	    }:     mcu_data_out <= reg_freq4			      		;
				{ADDR_reg_freq_phase_l}:  mcu_data_out <= Phase_cnt_out[15:0]      		;
				{ADDR_reg_freq_phase_h}:  mcu_data_out <= Phase_cnt_out[31:16]      		;
				{ADDR_reg_ad_enble	}:     mcu_data_out <= {15'b0,reg_ad_enble}  			;//use pos  clear fifo
				{ADDR_reg_ad_reset	}:     mcu_data_out <= {15'b0,reg_ad_reset}	    		;
				{ADDR_reg_ad_fifo_clr}:   mcu_data_out <= {15'b0,clr_fifo}    		;
				{ADDR_reg_ad_status }:     mcu_data_out <= reg_ad_status	     			;
										                                         
				{ADDR_reg_ad1_data	}:     mcu_data_out <= q_data_oa[0]	      				;
				{ADDR_reg_ad2_data	}:     mcu_data_out <= q_data_ob[0]	      				;
				{ADDR_reg_ad3_data	}:     mcu_data_out <= q_data_oc[0]	      				;
				{ADDR_reg_ad4_data	}:     mcu_data_out <= q_data_od[0]	      				;
				{ADDR_reg_ad5_data	}:     mcu_data_out <= q_data_oa[1]	      				;
				{ADDR_reg_ad6_data	}:     mcu_data_out <= q_data_ob[1]	      				;
				{ADDR_reg_ad7_data	}:     mcu_data_out <= q_data_oc[1]	      				;
				{ADDR_reg_ad8_data	}:     mcu_data_out <= q_data_od[1]	      				;
				{ADDR_reg_datafull	}:     mcu_data_out <= {14'b0,detect_error,data_full}	;
				
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
				{2'b0,ADDR_reg_ad_fifo_clr}:  clr_fifo 		<=  mcu_data_in[0]			;							                                       
				default:   	;
				endcase
			end
		//------------------------------------------------------------------------------------------
		wire	[3:0]			ad_start			;
		wire	[3:0]			data_rd_ready_o		;
		
		wire	[23:0] 			sys_addr			;
		wire					rd_en				;
		wire					rd_ack		        ;
		wire					sdram_rd_ack        ;
	    wire    [15:00]         freq_w1             ;             
	    wire    [15:00]         freq_w2             ;
		assign   freq_w1 = (reg_freq1[1:0] == 'b00)?16'd1280 : (reg_freq1[1:0] == 'b01)? 16'd2560:(reg_freq1[1:0] == 'b10)?16'd5120 : 16'd10240 ;
		assign   freq_w2 = (reg_freq1[3:2] == 'b00)?16'd1280 : (reg_freq1[3:2] == 'b01)? 16'd2560:(reg_freq1[3:2] == 'b10)?16'd5120 : 16'd10240 ;
	
		

		
		////////////////////////////////////////////////////////////////////////////////////////////
		
		///AD 模块例化
		
		wire			[15:0]	q_data_oa	 	[1:0]		;
		wire			[15:0]	q_data_ob    	[1:0]       ;
		wire			[15:0]	q_data_oc    	[1:0]       ;
		wire			[15:0]	q_data_od    	[1:0]       ;	
		reg  			[7:0]	fifo_rd_req = 'b0  	 ;

		wire			[6:0]	wrusedw		[15:0]		;	
		wire			[15:0]	wrfifo_gnt_in				;
		wire			[15:0]	wrfull_flag					;
		wire					rd_ack_falg					;
		wire					rdempty_flag					;
		wire            [31:00] freq1_cnt;
		wire            [31:00] freq2_cnt;
		
 		generate	
		genvar	i;	
			for(i=0;i<2;i=i+1) begin	:	AD7606_DR	
AD7606 U1_AD7606 (
		.clk_40M		(AD_CLK_40M				), 
		.ad_start		(ad_start[i]     		), 
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
		.adc_convst_b_o	(adc_convst_b_o[i]		),
        .dbg_adc_next_state  (dbg_adc_next_state[i])		
		);
		wrfifo_16w_16r_2048d data_oa_wrfifo_16w_16r_2048d (
`ifdef test		
		.rst		   	( fifo_rst				), // input rst
`else		
		.rst		   	( clr_fifo				), // input rst
`endif		
		.wr_clk		   	( AD_CLK_40M			), // input wr_clk
		.rd_clk		   	( FSMC_CLK_100M			), // input rd_clk
		.din		   	( data_oa[i]			), // input [15 : 0] din
		.wr_en		   	( data_rd_ready_o[i] && !full[i*4 + 0]    ), // input wr_en
		.rd_en		   	( fifo_rd_req[i*4 + 0]	), // input rd_en
		.dout		   	( q_data_oa[i]			), // output [15 : 0] dout
		.full		   	( full[i*4 + 0]	     	) 
		);	
		wrfifo_16w_16r_2048d data_ob_wrfifo_16w_16r_2048d (
`ifdef test		
		.rst		   	( fifo_rst				), // input rst
`else		
		.rst		   	( clr_fifo				), // input rst
`endif		
		.wr_clk		   	( AD_CLK_40M			), // input wr_clk
		.rd_clk		   	( FSMC_CLK_100M			), // input rd_clk
		.din		   	( data_ob[i]			), // input [15 : 0] din
		.wr_en		   	( data_rd_ready_o[i] && !full[i*4 + 1]   ), // input wr_en
		.rd_en		   	( fifo_rd_req[i*4 + 1]	), // input rd_en
		.dout		   	( q_data_ob[i]			), // output [15 : 0] dout
		.full		   	( full[i*4 + 1]	     	) 
		);		
		wrfifo_16w_16r_2048d data_oc_wrfifo_16w_16r_2048d (
`ifdef test		
		.rst		   	( fifo_rst				), // input rst
`else		
		.rst		   	( clr_fifo				), // input rst
`endif				
        .wr_clk		   	( AD_CLK_40M			), // input wr_clk
		.rd_clk		   	( FSMC_CLK_100M			), // input rd_clk
		.din		   	( data_oc[i]			), // input [15 : 0] din
		.wr_en		   	( data_rd_ready_o[i] && !full[i*4 + 2]    ), // input wr_en
		.rd_en		   	( fifo_rd_req[i*4 + 2]	), // input rd_en
		.dout		   	( q_data_oc[i]			), // output [15 : 0] dout
		.full		   	( full[i*4 + 2]	     	) 
		);		
		wrfifo_16w_16r_2048d data_od_wrfifo_16w_16r_2048d (
`ifdef test		
		.rst		   	( fifo_rst				), // input rst
`else		
		.rst		   	( clr_fifo				), // input rst
`endif		
		.wr_clk		   	( AD_CLK_40M			), // input wr_clk
		.rd_clk		   	( FSMC_CLK_100M			), // input rd_clk
		.din		   	( data_od[i]			), // input [15 : 0] din
		.wr_en		   	( data_rd_ready_o[i] && !full[i*4 + 3]   ), // input wr_en
		.rd_en		   	( fifo_rd_req[i*4 + 3]	), // input rd_en
		.dout		   	( q_data_od[i]			), // output [15 : 0] dout
		.full		   	( full[i*4 + 3]	     	) 
		);		
		end             			
		endgenerate 	

///ARM读使能产生信号
   reg  [2:0] muc_rd_n_r;
   always@(posedge FSMC_CLK_100M) begin
		 muc_rd_n_r <= {muc_rd_n_r[1:0],muc_rd_n};
	 end
 
/*            assign fifo_rd_req[0] = {muc_addr} =={ADDR_reg_ad1_data} && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1);
           assign fifo_rd_req[1] = {muc_addr} =={ADDR_reg_ad2_data} && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1);
           assign fifo_rd_req[2] = {muc_addr} =={ADDR_reg_ad3_data} && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1);
           assign fifo_rd_req[3] = {muc_addr} =={ADDR_reg_ad4_data} && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1);
           assign fifo_rd_req[4] = {muc_addr} =={ADDR_reg_ad5_data} && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1);
           assign fifo_rd_req[5] = {muc_addr} =={ADDR_reg_ad6_data} && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1);
           assign fifo_rd_req[6] = {muc_addr} =={ADDR_reg_ad7_data} && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1);
           assign fifo_rd_req[7] = {muc_addr} =={ADDR_reg_ad8_data} && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1);  */
		   
		always@(posedge FSMC_CLK_100M) 
                   if((muc_addr ==ADDR_reg_ad1_data) && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1))	
				      fifo_rd_req[0] <= 'b1;
				   else
					  fifo_rd_req[0] <= 'b0;
		always@(posedge FSMC_CLK_100M) 
                   if((muc_addr ==ADDR_reg_ad2_data) && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1))	
				      fifo_rd_req[1] <= 'b1;
				   else
					  fifo_rd_req[1] <= 'b0;			   
		always@(posedge FSMC_CLK_100M) 
                   if((muc_addr ==ADDR_reg_ad3_data) && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1))	
				      fifo_rd_req[2] <= 'b1;
				   else
					  fifo_rd_req[2] <= 'b0;
		always@(posedge FSMC_CLK_100M) 
                   if((muc_addr ==ADDR_reg_ad4_data) && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1))	
				      fifo_rd_req[3] <= 'b1;
				   else
					  fifo_rd_req[3] <= 'b0;			   
		always@(posedge FSMC_CLK_100M) 
                   if((muc_addr ==ADDR_reg_ad5_data) && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1))	
				      fifo_rd_req[4] <= 'b1;
				   else
					  fifo_rd_req[4] <= 'b0;
		always@(posedge FSMC_CLK_100M) 
                   if((muc_addr ==ADDR_reg_ad6_data) && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1))	
				      fifo_rd_req[5] <= 'b1;
				   else
					  fifo_rd_req[5] <= 'b0;			   
		always@(posedge FSMC_CLK_100M) 
                   if((muc_addr ==ADDR_reg_ad7_data) && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1))	
				      fifo_rd_req[6] <= 'b1;
				   else
					  fifo_rd_req[6] <= 'b0;
		always@(posedge FSMC_CLK_100M) 
                   if((muc_addr ==ADDR_reg_ad8_data) && (muc_rd_n_r[1] == 'b0 && muc_rd_n_r[0] == 'b1))	
				      fifo_rd_req[7] <= 'b1;
				   else
					  fifo_rd_req[7] <= 'b0;		
                           				   
`ifdef test
    //      reg fifo_rst ='b0;
		  reg   [5:0]  delay_cnt= 'b0;
		  reg [31:00] test_cnt = 'b0;
		  reg        test_work_en = 'b0;
		  reg [8:0]  test_state_cnt = 'b0;
	always@(posedge FSMC_CLK_100M) 
	      if(ASYNC_OUT) begin
		        fifo_rd_req <= 'b0;
		        fifo_rst <= 'b1;
				test_state_cnt <= 'b0;end
		 else begin
	     case(test_state_cnt)
		 'd0:begin delay_cnt <= 'd0; fifo_rst <= 'b0; test_cnt <= 'b0; test_work_en <= 'b1;if(&full) test_state_cnt <= 'd1; end
		 'd1:begin  test_work_en <= 'b0; fifo_rd_req <= 'hff;
		            reg_ad1_data <= q_data_oa[0];
					reg_ad2_data <= q_data_ob[0];
					reg_ad3_data <= q_data_od[0];
					reg_ad4_data <= q_data_od[0];
					reg_ad5_data <= q_data_oa[1];
					reg_ad6_data <= q_data_ob[1];
					reg_ad7_data <= q_data_oc[1];
					reg_ad8_data <= q_data_od[1];
		              if(test_cnt == 'd2048) begin
					   test_state_cnt <= 'd2;end
					  else
					   test_cnt       <= test_cnt + 'b1;
			end
		 'd2: begin fifo_rd_req <= 'b0;
		            fifo_rst <= 'd1; 
		           if(delay_cnt >= 'd40) 
		             test_state_cnt <= 'd0;
				   else
				     delay_cnt <= delay_cnt + 'b1;
					 
					 end	
					  
		 endcase
		 end
		   
`else 		   
	/* always@(posedge FSMC_CLK_100M)begin
		   if({muc_cs_n,muc_addr} =={1'b0,ADDR_reg_ad1_data} && (muc_rd_n == 'b0 && muc_rd_n_r == 'b1)) begin
		     fifo_rd_req[0] <= 'b1;
			 reg_ad1_data <= q_data_oa[0];end
		   else
		      fifo_rd_req[0] <= 'b0;
		   if({muc_cs_n,muc_addr} =={1'b0,ADDR_reg_ad2_data	}&& (muc_rd_n == 'b0 && muc_rd_n_r == 'b1)) begin
		     fifo_rd_req[1] <= 'b1;
			 reg_ad2_data <= q_data_ob[0];end
		   else
		      fifo_rd_req[1] <= 'b0;	
		   if({muc_cs_n,muc_addr} =={1'b0,ADDR_reg_ad3_data	}&& (muc_rd_n == 'b0 && muc_rd_n_r == 'b1)) begin
		     fifo_rd_req[2] <= 'b1;
			 reg_ad3_data <= q_data_oc[0];end
		   else
		      fifo_rd_req[2] <= 'b0;
		   if({muc_cs_n,muc_addr} =={1'b0,ADDR_reg_ad4_data	}&& (muc_rd_n == 'b0 && muc_rd_n_r == 'b1)) begin
		     fifo_rd_req[3] <= 'b1;
			 reg_ad4_data <= q_data_od[0];end
		   else
		      fifo_rd_req[3] <= 'b0;	
		   if({muc_cs_n,muc_addr} =={1'b0,ADDR_reg_ad5_data	}&& (muc_rd_n == 'b0 && muc_rd_n_r == 'b1)) begin
		     fifo_rd_req[4] <= 'b1;
			 reg_ad5_data <= q_data_oa[1];end
		   else
		      fifo_rd_req[4] <= 'b0;
		   if({muc_cs_n,muc_addr} =={1'b0,ADDR_reg_ad6_data	}&& (muc_rd_n == 'b0 && muc_rd_n_r == 'b1)) begin
		     fifo_rd_req[5] <= 'b1;
			 reg_ad6_data <= q_data_ob[1];end
		   else
		      fifo_rd_req[5] <= 'b0;
		   if({muc_cs_n,muc_addr} =={1'b0,ADDR_reg_ad7_data	}&& (muc_rd_n == 'b0 && muc_rd_n_r == 'b1)) begin
		     fifo_rd_req[6] <= 'b1;
			 reg_ad7_data <= q_data_oc[1];end
		   else
		      fifo_rd_req[6] <= 'b0;	
		   if({muc_cs_n,muc_addr} =={1'b0,ADDR_reg_ad8_data	}&& (muc_rd_n == 'b0 && muc_rd_n_r == 'b1)) begin
		     fifo_rd_req[7] <= 'b1;
			 reg_ad8_data <= q_data_od[1];end
		   else
		      fifo_rd_req[7] <= 'b0;			  
		 end
	 */
`endif		


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
		if(Phase_in_cnt == 30'd20000000) begin
			Phase_in_cnt <= 1'b0;
			Phase_in_ceshi <= ~Phase_in_ceshi; end
		else begin
			Phase_in_cnt <= Phase_in_cnt +1'b1;
		 end
		 

Phase_detector U3_Phase_detector (
    .rst_n			(reg_ad_enble_ceshi		), //用AD使能来启动键相模块
    .clk			(AD_CLK_40M				), 
    .Phase_in		(Phase_in				), //(Phase_in    )//输入键相频率用Phase_in,内部模拟用Phase_in_ceshi
	 .Phase_valid   (Phase_valid			),
    .Phase_cnt_out	(Phase_cnt_out			)//31:0
    );	
	
/* 	reg [1:0] valid_ph;
	reg  [31:00] valid_ph_data0,valid_ph_data1;
	always@(FSMC_CLK_100M) begin
	    valid_ph <= {valid_ph[0],Phase_valid};
		valid_ph_data0 <= Phase_cnt_out
	end */
	
AD_CTL U4_AD_CTL 
	(
    .clk			(AD_CLK_40M				), 
    .rst_n			(reg_ad_enble_ceshi		), 
`ifdef test	
	.reg_ad_enble   (test_work_en    		),
`else	
	.reg_ad_enble   (work_en     		),
`endif	
	
	.Phase_valid    (Phase_valid			),	
    .reg_freq1		(freq_w1				),//(reg_freq1	16'd10000			), 用配置系数时用reg_freq1,用内部固定频率用10K即16'd10000
    .reg_freq2		(freq_w2					),//(reg_freq2	16'd10000			), 
    .Phase_cnt_out	(Phase_cnt_out			), 
    .freq1_cnt	    (freq1_cnt			    ), 
    .freq2_cnt	    (freq2_cnt			    ), 
    .ad_start		(ad_start				)//(ad_start)
    );
	wire   [35:00] CONTROL0;
	wire   [35:00] CONTROL1;
    wire	[211:0]  ila_data;
	wire     ASYNC_OUT;
icon_ny icon_ny_i (
    .CONTROL0(CONTROL0),
    .CONTROL1(CONTROL1)
);
vio_my YourInstanceName (
    .CONTROL(CONTROL1), // INOUT BUS [35:0]
    .ASYNC_OUT(ASYNC_OUT) // OUT BUS [0:0]
);
ila_my ila_my_inst (
    .CONTROL(CONTROL0), // INOUT BUS [35:0]
    .CLK(FSMC_CLK_100M), // IN
    .TRIG0(ila_data) // IN BUS [7:0]
);	


 assign ila_data[15:00] =  freq_w1[15:00];
 assign ila_data[31:16] =  freq_w2[15:00];
 assign ila_data[35:32] =  next_state0[3:00];
 assign ila_data[44:36] =  muc_addr[8:00];
 assign ila_data[45]    =  muc_we_n;
 assign ila_data[47:46] =  adc_reset_o[1:0];
 assign ila_data[55:48] =  fifo_rd_req[7:00];
 assign ila_data[58:56] =  muc_rd_n_r[2:0];
 assign ila_data[63:59] =  'b0;
 assign ila_data[79:64] =  mcu_data_out[15:00];
 assign ila_data[95:80] =  reg_freq1[15:00];
 assign ila_data[111:96] =  reg_freq2[15:00];
 assign ila_data[127:112] =  reg_ad8_data[15:00];
 assign ila_data[143:128] =  freq1_cnt[15:00];
 assign ila_data[159:144] =  freq2_cnt[15:00];
 assign ila_data[161:160] =  ad_start[1:0];
 assign ila_data[169:162] =  full[7:0];
 assign ila_data[170] =  work_en;
 assign ila_data[171] =  clr_fifo;
 assign ila_data[172] =  reg_ad_enble;
 assign ila_data[174:173] =  adc_convst_a_o[1:0];
 assign ila_data[176:175] =  adc_convst_b_o[1:0];
 assign ila_data[178:177] =  adc_busy_i[1:0];
 assign ila_data[179] =  muc_cs_n;
 assign ila_data[180] =  muc_rd_n;
 assign ila_data[182:181] =  fastdata[1:0];
 assign ila_data[186:183] =  next_state1[3:0];
 assign ila_data[188:187] =  adc_rd_n_o[1:0];
 assign ila_data[190:189] =  adc_cs_n_o[1:0];
 assign ila_data[211:191] =  'b0;



endmodule
