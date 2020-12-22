module LED(
	Clk50M,
	Rst_n,
	FPGA_LEDG
	);

	input Clk50M;	//系统时钟，50M
	input Rst_n;	//全局复位，低电平复位
	
	output reg FPGA_LEDG;	//led输出
	
	reg [24:0]cnt;	//定义计数器寄存器

//计数器计数进程	
	always@(posedge Clk50M or negedge Rst_n)
	if(Rst_n == 1'b0)
		cnt <= 25'd0;
	//else if(cnt == 25'd24_999_999)
	else if(cnt == 25'd24_999)
		cnt <= 25'd0;
	else
		cnt <= cnt + 1'b1;

//led输出控制进程
	always@(posedge Clk50M or negedge Rst_n)
	if(Rst_n == 1'b0)
		FPGA_LEDG <= 1'b1;
	//else if(cnt == 25'd24_999_999)
	else if(cnt == 25'd24_999)
		FPGA_LEDG <= 1'd0;
	else
		FPGA_LEDG <= 1'd1;

endmodule
