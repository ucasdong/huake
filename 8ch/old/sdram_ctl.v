`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: by dong
// Create Date	: 2017.05.22
// Design Name	: 
// Module Name	: sdram_ctl
// Project Name	: 
// Target Device: Cyclone EP4CE10F17C8 
// Tool versions: Quartus II 13.1
// Description	:  SDRAM顶层控制器，包装成FIFO接口，写入FIFO的为8*8bit，读出FIFO的暂定为1024*8
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sdram_ctl(

				rst_n,//复位信号，低有效
				
				
				//clk
				//---------------时钟信号接口----------------
				
				clk_40m								,// 逻辑时钟40M
				clk_50m								,// SDRAM时钟 为50M
				clk_100m							,
				locked								,
				
				sdram_clk,
				sdram_cke,
				sdram_cs_n,
				sdram_ras_n,
				sdram_cas_n,
				sdram_we_n,
				sdram_ba,
				sdram_addr,
				sdram_data,
				sdram_udqm,
				sdram_ldqm,
				//写FIFO部分接口
				sys_addr,
				wrf_din,
                wrf_wrreq,
				wrf_empty,
				//读FIFO部分
				rd_en,
				rd_ack,
				sdram_rd_ack,
				rdf_rdreq,
				rdf_dout,
				rd_ack_falg,
				rdempty_flag
			);

//input clk;			//系统时钟，100MHz
input 	rst_n;		//复位信号，低电平有效
input	clk_40m	;	//逻辑时钟40M
input	clk_50m	; 	//SDRAM时钟 为50M
input	clk_100m;	//总线读时钟
input	locked	;	// PLL lock

	// FPGA与SDRAM硬件接口
output sdram_clk									;			//	SDRAM时钟信号
output sdram_cke									;			//  SDRAM时钟有效信号
output sdram_cs_n									;			//	SDRAM片选信号
output sdram_ras_n									;			//	SDRAM行地址选通脉冲
output sdram_cas_n									;			//	SDRAM列地址选通脉冲
output sdram_we_n									;			//	SDRAM写允许位
output[1:0] sdram_ba								;		//	SDRAM的L-Bank地址线
output[12:0] sdram_addr								;	//  SDRAM地址总线
output sdram_udqm									;			// SDRAM高字节屏蔽
output sdram_ldqm									;			// SDRAM低字节屏蔽
inout[15:0]  	sdram_data									;				// SDRAM数据总线

//SDRAM FIFO写
input	[23:0]	sys_addr;
input	[15:0]	wrf_din;
input			wrf_wrreq;
output			wrf_empty;
////////////////////////////////////////////////

input			rd_en;
output			rd_ack;
output 			sdram_rd_ack;
output[15:0] 	rdf_dout;		//sdram数据读出缓存FIFO输出数据总线	
input 			rdf_rdreq;			//sdram数据读出缓存FIFO数据输出请求，高有效

//
output			rd_ack_falg;//读通道标识
output			rdempty_flag;//用来清除读通道标识

////////////////////////////////////////////////
assign	sdram_udqm = 1'b0;	
assign	sdram_ldqm = 1'b0;	

	// SDRAM的封装接口
wire sdram_wr_req;			//系统写SDRAM请求信号
wire sdram_rd_req;			//系统读SDRAM请求信号
wire sdram_wr_ack;			//系统写SDRAM响应信号,作为wrFIFO的输出有效信号
wire sdram_rd_ack;			//系统读SDRAM响应信号,作为rdFIFO的输写有效信号	
//wire[23:0] sys_addr;		//读写SDRAM时地址暂存器，(bit23-22)L-Bank地址:(bit21-9)为行地址，(bit8-0)为列地址 
wire[15:0] sys_data_in;		//写SDRAM时数据暂存器

wire[15:0] sys_data_out;	//sdram数据读出缓存FIFO输入数据总线
wire sdram_busy;			// SDRAM忙标志，高表示SDRAM处于工作中
wire sys_dout_rdy;			// SDRAM数据输出完成标志

	//wrFIFO输入控制接口
//wire[15:0] wrf_din;		//sdram数据写入缓存FIFO输入数据总线
//wire wrf_wrreq;			//sdram数据写入缓存FIFO数据输入请求，高有效
	//rdFIFO输出控制接口
wire[15:0] rdf_dout;		//sdram数据读出缓存FIFO输出数据总线	
//wire rdf_rdreq;			//sdram数据读出缓存FIFO数据输出请求，高有效

	//系统控制相关信号接口
//wire clk_25m;	//PLL输出25MHz时钟
//wire clk_100m;	//PLL输出100MHz时钟
wire sys_rst_n;	//系统复位信号，低有效




//系统复位信号产生，低有效
//异步复位，同步释放
wire sysrst_nr0;
reg sysrst_nr1,sysrst_nr2;

assign sysrst_nr0 = rst_n & locked;	//系统复位直到PLL有效输出

always @(posedge clk_50m or negedge sysrst_nr0)
	if(!sysrst_nr0) sysrst_nr1 <= 1'b0;
	else sysrst_nr1 <= 1'b1;

always @(posedge clk_50m or negedge sysrst_nr0)
	if(!sysrst_nr0) sysrst_nr2 <= 1'b0;
	else sysrst_nr2 <= sysrst_nr1;

assign sys_rst_n = sysrst_nr2;
		

		

wire syswr_done;		//所有数据写入sdram完成标志位
wire tx_start;		//串口发送数据启动标志位，高有效
//------------------------------------------------


//------------------------------------------------
//例化SDRAM封装控制模块
sdram_top		uut_sdramtop(				// SDRAM
							.clk			(clk_50m		),
							.rst_n			(sys_rst_n		),
							.sdram_wr_req	(sdram_wr_req	),
							.sdram_rd_req	(sdram_rd_req	),
							.sdram_wr_ack	(sdram_wr_ack	),
							.sdram_rd_ack	(sdram_rd_ack	),	
							.sys_addr		(sys_addr		),
							.sys_data_in	(sys_data_in	),
							.sys_data_out	(sys_data_out	),
							.sys_dout_rdy	(sys_dout_rdy	),
							//.sdram_clk	(sdram_clk		),
							.sdram_busy		(sdram_busy		),
							.sdram_cke		(sdram_cke		),
							.sdram_cs_n		(sdram_cs_n		),
							.sdram_ras_n	(sdram_ras_n	),
							.sdram_cas_n	(sdram_cas_n	),
							.sdram_we_n		(sdram_we_n		),
							.sdram_ba		(sdram_ba		),
							.sdram_addr		(sdram_addr		),
							.sdram_data		(sdram_data																	)
					);
	

//------------------------------------------------

						 
						 
sdfifo_ctrl uut_sdffifoctrl(
							.clk_40m		(clk_40m		),
							.clk_50m		(clk_50m		),
							.clk_100m		(clk_100m		),
							.rst_n			(sys_rst_n		),
							.sdram_wr_req	(sdram_wr_req	),				
							.sdram_wr_ack	(sdram_wr_ack	),		
							.sys_data_in	(sys_data_in	),	
							
							.wrf_din		(wrf_din		),
							.wrf_wrreq		(wrf_wrreq		),
							.wrf_empty		(wrf_empty		),
			
							.sdram_rd_req	(sdram_rd_req	),
							.sdram_rd_ack	(sdram_rd_ack	),							
							.sys_data_out	(sys_data_out	),
							.rd_en			(rd_en			),
							.rd_ack			(rd_ack			),
							.rdf_rdreq		(rdf_rdreq		),
							.rdf_dout		(rdf_dout		),
							.sdram_busy		(sdram_busy		),
							.rd_ack_falg	(rd_ack_falg	),
							.rdempty_flag	(rdempty_flag	)
							
					);						 
//------------------------------------------------





endmodule
