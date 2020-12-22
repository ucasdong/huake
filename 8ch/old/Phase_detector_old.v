
//������Ƶģ��
module Phase_detector(
			input				rst_n							,
			input				clk								,
			input				Phase_in						,
			output reg	[31:0]	Phase_cnt_out =1'b0
		);
			reg		[31:0]	Phase_cnt 	= 1'b0		;
			reg		[2:0]	state 		= 1'b0		;//״̬��
			reg				Phase_pos 	= 1'b0		;//�����ؼĴ���
			reg				Phase_inreg = 1'b0		;

			
			//消抖
			
			reg		Phase_in_reg,Phase_in_reg1,Phase_in_reg2,Phase_in_filter;
			
			always@(posedge clk)
			begin
				Phase_in_reg <= Phase_in;
				Phase_in_reg1 <= Phase_in_reg;
				Phase_in_reg2 <= Phase_in_reg1;
				Phase_in_filter <= Phase_in | Phase_in_reg; end 
				
			
	always@(posedge clk) begin
		Phase_inreg <= Phase_in_filter		;
		if(Phase_in_filter == 1'b1 & Phase_inreg == 1'b0 )
			Phase_pos <= 1'b1;
		else
			Phase_pos <= 1'b0; 
	end
	
	always@(posedge clk,negedge rst_n) 
		if(!rst_n) begin
			state 		<= 3'd0;
			Phase_cnt	<= 1'b0; end
		else begin
		case(state)
			3'd0: if(Phase_pos) state <= 3'd1;else ;
			3'd1: begin
					Phase_cnt <= Phase_cnt + 1'b1;
					if(Phase_pos)
					state <= 3'd2;
					else
					state <=3'd1;
					end
			3'd2:	begin
					Phase_cnt_out 	<= Phase_cnt;
					Phase_cnt 		<= 1'b0;
					state  			<= 3'd1;
					end
			default:begin
					state  			<= 3'd0;
					Phase_cnt 		<= 1'b0; end
			endcase
			end
	endmodule
					