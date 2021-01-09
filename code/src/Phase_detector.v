
//������Ƶģ��
module Phase_detector(
			input				rst_n							,
			input				clk								,
			input				Phase_in						,
		   output  reg       Phase_valid,
			output reg	[31:0]	Phase_cnt_out =32'd20000000
		);
			reg		[31:0]	Phase_cnt 	= 1'b0		;
			reg		[2:0]	state 		= 1'b0		;//״̬��
			reg				Phase_pos 	= 1'b0		;//�����ؼĴ���
			reg				Phase_inreg = 1'b0		;

			reg		[9:0]	count_high = 1'b0;
			//����
			
			
			reg		[99:0] Phase_in_shiftreg;
			always@(posedge clk)
				Phase_in_shiftreg <= {Phase_in_shiftreg[98:0],Phase_in};
				
/* 			parameter SAMPLE_TIME = 240;//������ȥ��240������----6us
			reg		Phase_in_reg,Phase_in_reg1,Phase_in_reg2,Phase_in_filter = 1'b0;
			
			always @(posedge clk)
				if(Phase_in ==1'b1 && (count_high < SAMPLE_TIME))
				count_high <= count_high + 1;
				else
				count_high <= 0;
			always @(posedge clk)
				if(count_high == SAMPLE_TIME)
				Phase_in_filter  <= Phase_in;
				else if(Phase_in ==1'b0)
				Phase_in_filter <= 1'b0;
				else
				Phase_in_filter <= Phase_in_filter;	 */
				
/* 			
			always@(posedge clk)
			begin
				Phase_in_reg <= Phase_in;
				Phase_in_reg1 <= Phase_in_reg;
				Phase_in_reg2 <= Phase_in_reg1;
				Phase_in_filter <= Phase_in | Phase_in_reg; end  */
				
	assign		Phase_inwire = &Phase_in_shiftreg		;		
	always@(posedge clk) begin
		Phase_inreg <= Phase_inwire	;
		if(Phase_inwire == 1'b1 && Phase_inreg == 1'b0 )
			Phase_pos <= 1'b1;
		else
			Phase_pos <= 1'b0; 
	end
	
	always@(posedge clk,negedge rst_n) 
		if(!rst_n) begin
		   Phase_valid <= 'b0;
			state 		<= 3'd0;
			Phase_cnt	<= 1'b0; end
		else begin
		case(state)
			3'd0: begin Phase_valid <= 'b0; if(Phase_pos) state <= 3'd1;else ;end
			3'd1: begin
			      Phase_valid  <= 'b0;
					Phase_cnt <= Phase_cnt + 1'b1;
					if(Phase_pos || (Phase_cnt >= 400000000))
					state <= 3'd2;
					else
					state <=3'd1;
					end
			3'd2:	begin
			      Phase_valid  <= 'b1;
					if(Phase_cnt >= 400000000) begin
					Phase_cnt_out 	<= 32'b0;
					Phase_cnt 		<= 1'b0;
					state  			<= 3'd1;end
					else begin
					Phase_cnt_out 	<= Phase_cnt;
					Phase_cnt 		<= 1'b0;
					state  			<= 3'd1; 
					end
					end
			default:begin
			      Phase_valid    <= 'b0;
					state  			<= 3'd0;
					Phase_cnt 		<= 1'b0; end
			endcase
			end
	endmodule
					