`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: 	
// Create Date	: 2017.05.11
// Design Name	: 
// Module Name	: sdfifo_ctrl
// Project Name	: 
// Target Device: Cyclone 	
// Tool versions: Quartus 13.1
// Description	: SDRAM fifo����ģ��						
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sdfifo_ctrl(
				clk_40m			,
				clk_50m			,
				clk_100m		,
				rst_n			,
				wrf_din			,
				wrf_wrreq		,
				sdram_wr_ack	,
				wrf_empty		,
				/*sys_addr,*/
				sys_data_in		,
				sdram_wr_req	,
				
				
				sys_data_out	,
				rdf_rdreq		,
				sdram_rd_ack	,
				rdf_dout		,
				rd_en			,
				rd_ack			,
				sdram_rd_req	,
				sdram_busy		,
				rd_ack_falg		,
				rdempty_flag
				
			);

input clk_40m					;	//	PLL����40MHzʱ��
input clk_50m					;	//	PLL����50MHzʱ��
input clk_100m					;	// 	���߶�ʱ��
input rst_n						;

	//wrfifo
input[15:0] wrf_din;		//sdram����д�뻺��FIFO������������
input wrf_wrreq;			//sdram����д�뻺��FIFO�����������󣬸���Ч
input sdram_wr_ack;			//ϵͳдSDRAM��Ӧ�ź�,��ΪwrFIFO��������Ч�ź�
output wrf_empty	;		//дFIFO�ձ�־����FIFO��ʱ���ⲿ���ݿ�д��FIFO

output[15:0] sys_data_in;	//sdram����д�뻺��FIFO�����������ߣ���дSDRAMʱ�����ݴ���
output sdram_wr_req;		//ϵͳдSDRAM�����ź�

	//rdfifo
input[15:0] sys_data_out;	//sdram���ݶ���FIFO������������
input rdf_rdreq;			//sdram���ݶ���FIFO�����������󣬸���Ч
input sdram_rd_ack;			//ϵͳ��SDRAM��Ӧ�ź�,��ΪrdFIFO����д��Ч�ź�

input		 rd_en			;//���������ܣ������?
output	wire	 rd_ack			;//���ָ����������ķ���ֵ ����Ч ������
output[15:0] rdf_dout;		//sdram���ݶ���FIFO������������
output sdram_rd_req;		//ϵͳ��SDRAM�����ź�

input sdram_busy;			//SDRAMæ��־������Ч��SDRAM��æʱ��������д

output		rdempty_flag;//��FIFO�ձ�־�������rd_ad_stuts
output		rd_ack_falg		; 

wire		wrfull;
parameter rd_length = 1023;
//�ϵ�500us��ʱ�ȴ�sdram����
reg[15:0] delay;	//1ms��ʱ������

always @(posedge clk_40m or negedge rst_n)
	if(!rst_n) delay <= 16'd0;
	else if(delay < 16'd40000) delay <= delay+1'b1;

wire delay_done = (delay == 16'd40000);	//1ms��ʱ����


//------------------------------------------------
wire[5:0] wrf_use;			//sdram����д�뻺��FIFO���ô洢�ռ����?
(*keep*)wire[11:0] rdf_use;			//sdram���ݶ���FIFO���ô洢�ռ����?

//assign sys_addr = 22'h1a9e21;	//������
assign sdram_wr_req = ((wrf_use >= 6'd8)  & delay_done);	//FIFO��8��16bit���ݣ�������дSDRAM�����ź�
//assign sdram_rd_req = ((rdf_use <= rd_length)  & delay_done & rd_en);	//sdramд��������FIFO���գ�256��16bit���ݣ���������SDRAM�����ź�
//assign sdram_rd_req = ((!wrfull)  & delay_done & rd_en);	//sdramд��������FIFO���գ�256��16bit���ݣ���������SDRAM�����ź�
assign sdram_rd_req = ( delay_done & rd_en);	//sdramд��������FIFO���գ�256��16bit���ݣ���������SDRAM�����ź�


//assign	rd_ack_falg = (rdf_use >= rd_length)?1'b1:1'b0;//�������?k��־
assign	rd_ack_falg = wrfull;//�������?k��־
reg		rd_ack_reg;


wire	rd_ack_reg_clk40m;//40M ʱ������


//always@(posedge clk_40m)
	//rd_ack <= rd_ack_falg;
/* always@(posedge clk_40m)
	if(rd_ack_falg == 1'b1 && rd_ack_reg == 1'b0)
	rd_ack <= 1'b1;
	else
	rd_ack <= 1'b0; */
	//rd_ack <= rd_ack_falg  & ~rd_ack_reg;
	
assign	rd_ack = wrfull;




//------------------------------------------------
//����SDRAMд�����ݻ���FIFOģ��
 wrfifo	uut_wrfifo (
	.wrclk 		( clk_40m 		),
	.wrreq 		( wrf_wrreq 	),
	.data 		( wrf_din 		),	//[15:0]
	.wrempty 	( 			 	),
	.wrfull 	( 			 	),
	.wrusedw 	( 		 		),	//[15:0]
	
	.rdclk 		( clk_50m 		),
	.rdreq 		( sdram_wr_ack 	),	
	.q 			( sys_data_in 	),
	.rdempty 	( wrf_empty		),
	.rdfull 	( 			 	),
	.rdusedw 	( wrf_use		),

	);


//------------------------------------------------
//����SDRAM������ݻ���FIFOģ��
rdfifo	uut_rdfifo (
	.data 		( sys_data_out 	),
	.wrclk 		( clk_50m 		),
	.wrreq 		( sdram_rd_ack 	),
	.wrempty 	( 	 			),
	.wrfull 	( wrfull	 	),
	.wrusedw 	( rdf_use 		),//[11:0]	
	.q 			( rdf_dout 		),
	.rdclk 		( clk_100m 		),
	.rdreq 		( rdf_rdreq 	),	
	.rdempty 	( rdempty_flag 	),
	.rdfull 	( rdfull_sig 	),
	.rdusedw 	( rdusedw_sig 	)

	);

endmodule
