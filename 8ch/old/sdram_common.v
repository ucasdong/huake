
module  sdram_common(clk,rst,cke,cs,ba,a,ras,cas,we,udqm,ldqm,dq,wr,rd,burst_length,addr_row,addr_column,data_in,over,bank,readable,writeable);  
input           clk;//sdram输入  
input           rst;//sdram复位  
input           wr;//sdram写使能  
input           rd;//sdram读使能，wr和rd一样时为无操作，当wr为1rd为0时为写反之为读  
input  [11:0]   addr_row;//sdram行地址  
input  [7:0]    addr_column;//sdram列地址  
input  [15:0]   data_in;//数据输入  
input  [2:0]    burst_length;//当为000时无突发，为001时突发为2，为010时突发为4，为011时突发为8，为100时为页突发（256）  
input  [1:0]    bank;//选择四片中哪一片 
 
inout  [15:0]   dq;//链接sdram的数据端口  
output          cke;//连接sdram的时钟使能端口  
output          cs;//连接sdram的片选端口  
output [1:0]    ba;//连接sdram的bank端口  
output [11:0]   a;//连接sdram的地址端口  
output          ras;//连接sdram的行地址选择端口  
output          cas;//连接sdram的列地址选择端口  
output          we;//连接sdram的写使能端口  
output          udqm;//  
output          ldqm;//数据掩码端口  
output          over;//操作结束指示信号，上升沿或高电平有效  
output          readable;//可读信号，高电平有效，高电平时在时钟上升沿获取读到的数据  
output          writeable;//突发写时在这个信号高电平时上升沿开始放着数据，单写时无需此信号  
  
reg [15:0]      dq_r;  
reg [1:0]   ba_r;     
reg             cke_r;  
reg             cs_r;  
reg [11:0]      a_r;  
reg             ras_r;  
reg             cas_r;  
reg             we_r;  
reg [15:0]      data_out_r;  
reg             over_r;  
reg             writeable_r;//10160904  
  
assign dq = wr?dq_r:16'bzzzzzzzzzzzzzzzz;  
assign ba = ba_r;  
assign cke = cke_r;  
assign cs = cs_r;  
assign a = a_r;  
assign ras = ras_r;  
assign cas = cas_r;  
assign we = we_r;  
assign over = over_r;  
assign udqm = 0;  
assign ldqm = 0;  
assign readable = readable_r;  
assign writeable = writeable_r;//10160904  
  
reg [7:0]       current_state;  
reg [7:0]       next_state;  
reg [8:0]       burst_length_num;  
wire [8:0]      burst_length_num_r;  
  
parameter init              = 8'b00000000;//初始化状态  
parameter precharge         = 8'b00000010;//预充电状态  
parameter auto_reflash      = 8'b00000100;//自动刷新状态  
parameter mr_confige        = 8'b00001000;//配置模式寄存器  
parameter idel              = 8'b00010000;//空闲状态  
parameter start_active_row  = 8'b00100000;//行激活状态  
parameter read              = 8'b01000000;//读状态  
parameter write             = 8'b10000000;//写状态  
parameter done              = 8'b00000001;//完成状态  
  
assign burst_length_num_r = wr?burst_length_num:(burst_length_num + 3);  
  
wire en;  
assign en = wr ^ rd;  
  
always@(posedge clk or negedge rst)  
begin  
    if(~rst)  
        current_state <= idel;  
    else  
        current_state <= next_state;  
end  
  
always@(negedge clk)  
begin  
    case(current_state)  
        init:  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 1;  
                cas_r <= 1;  
                we_r  <= 1;  
                over_r <= 0;  
                writeable_r <= 0;  
                if(init_ok)  
                    next_state <= precharge;  
                else      
                    next_state <= init;  
            end  
        precharge:  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 0;  
                cas_r <= 1;  
                we_r  <= 0;  
                a_r[10]   <= 1;  
                writeable_r <= 0;  
                if(precharge_done)  
                    next_state <= auto_reflash;  
                else  
                    next_state <= precharge;  
            end  
        auto_reflash:  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 0;  
                cas_r <= 0;  
                we_r  <= 1;  
                over_r <= 0;  
                writeable_r <= 0;  
                if(en)  
                    next_state <= mr_confige;  
                else   
                    next_state <= idel;  
            end  
        mr_confige:  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 0;  
                cas_r <= 0;  
                we_r  <= 0;  
                ba_r  <= 2'b00;  
                over_r <= 0;  
                writeable_r <= 0;  
                case(burst_length)//根据突发长度配着模式寄存器  
                    0:begin a_r <= 12'b000000110000; burst_length_num <= 0; end  
                    1:begin a_r <= 12'b000000110001; burst_length_num <= 1; end  
                    2:begin a_r <= 12'b000000110010; burst_length_num <= 3; end  
                    3:begin a_r <= 12'b000000110011; burst_length_num <= 7; end  
                    4:begin a_r <= 12'b000000110111; burst_length_num <= 255; end  
                    default:begin a_r <= 12'b000000110000; burst_length_num <= 0; end  
                endcase  
                if(en & mr_confige_done)  
                    next_state <= start_active_row;  
                else if(mr_confige_done)  
                    next_state <= idel;  
                else      
                    next_state <= mr_confige;  
            end  
        idel:  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 1;  
                cas_r <= 1;  
                we_r  <= 1;  
                over_r <= 0;  
                writeable_r <= 0;  
                if(en)  
                    next_state <= mr_confige;  
                else  
                    next_state <= auto_reflash;  
            end  
        start_active_row:  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 0;  
                cas_r <= 1;  
                we_r  <= 1;  
                ba_r  <= 2'b00;  
                a_r   <= addr_row;  
                over_r <= 0;  
                writeable_r <= 0;  
                if(addr_row_done)  
                begin  
                    if(en)  
                    begin  
                        if(wr)  
                        begin  
                            writeable_r <= 1;  
                            next_state <= write;  
                        end  
                        else  
                        begin  
                            writeable_r <= 0;  
                            next_state <= read;  
                        end  
                    end  
                    else  
                    begin  
                        writeable_r <= 0;  
                        next_state <= idel;  
                    end  
                end  
                else  
                begin  
                    writeable_r <= 0;  
                    next_state <= start_active_row;  
                end  
            end  
        read:  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 1;  
                cas_r <= 0;  
                we_r  <= 1;  
                ba_r  <= bank;  
                a_r   <= {4'd0,addr_column};  
                writeable_r <= 0;  
                next_state <= done;  
            end  
        write:  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 1;  
                cas_r <= 0;  
                we_r  <= 0;  
                ba_r  <= bank;  
                a_r   <= {4'd0,addr_column};  
                dq_r <= data_in;  
                next_state <= done;  
            end  
        done://完成状态，因为有突发的读和写状态，突发时要把cas和ras拉低  
            begin  
                cke_r <= 1;  
                cs_r  <= 0;  
                ras_r <= 0;  
                cas_r <= 0;  
                if(wr)  
                begin  
                    we_r  <= 0;  
                    dq_r <= data_in;  
                end  
                else  
                begin  
                    data_out_r <= dq;  
                    we_r  <= 1;  
                end  
                if(burst_length_done)//检测突发是否完成               
                begin  
                    over_r <= 1;  
                    writeable_r <= 0;  
                    next_state <= precharge;  
                end  
                else  
                begin  
                    over_r <= 0;  
                    writeable_r <= writeable_r;  
                    next_state <= done;  
                end  
            end  
        default:next_state <= idel;  
    endcase  
end    
    
    
//////////////////////////初始化计数器/////////////////////////////    
    
reg [13:0]      init_counter;  
reg             init_ok;  
  
always@(posedge clk)  
begin  
    if(init_counter < 15000)  
    begin  
        init_counter <= init_counter + 1;  
        init_ok <= 0;  
    end  
    else      
    begin  
        init_counter <= 15000;  
        init_ok <= 1;  
    end  
end  
  
////////////////////////////预充电计数器////////////////////////////  
  
reg [2:0]       precharge_counter;  
reg             precharge_done;  
  
always@(posedge clk or negedge rst)  
begin  
    if(~rst)  
    begin  
        precharge_counter <= 0;  
        precharge_done <= 0;  
    end  
    else if(current_state == precharge)  
    begin  
        precharge_counter <= precharge_counter +1;  
        if(precharge_counter == 7)  
            precharge_done <= 1;  
        else  
            precharge_done <= 0;  
    end  
    else  
    begin  
        precharge_counter <= 0;  
        precharge_done <= 0;  
    end  
end  
  
///////////////////////////配着模式寄存器计数器////////////////////  
reg [1:0]       mr_confige_counter;  
reg             mr_confige_done;  
  
always@(posedge clk or negedge rst)  
begin  
    if(~rst)  
    begin  
        mr_confige_counter <= 0;  
        mr_confige_done <= 0;  
    end  
    else if(current_state == mr_confige)  
    begin  
        mr_confige_counter <= mr_confige_counter + 1;  
        if(mr_confige_counter == 3)  
            mr_confige_done <= 1;  
        else  
            mr_confige_done <= 0;  
    end  
    else   
    begin  
        mr_confige_counter <=0;  
        mr_confige_done <=0;  
    end  
end  
  
/////////////////////////////行激活计数器//////////////////////////////  
reg [1:0]       addr_row_counter;  
reg             addr_row_done;  
  
always@(posedge clk or negedge rst)  
begin  
    if(~rst)  
    begin  
        addr_row_counter <= 0;  
        addr_row_done <=0;  
    end  
    else if(current_state == start_active_row)  
    begin  
        addr_row_counter <= addr_row_counter + 1;  
        if(addr_row_counter == 3)  
            addr_row_done <= 1;  
        else  
            addr_row_done <= 0;  
    end  
    else  
    begin  
        addr_row_counter <= 0;  
        addr_row_done <= 0;  
    end  
end  
  
////////////////////////////突发寄存器///////////////////////////////  
reg [8:0]       burst_length_counter;  
reg             burst_length_done;  
reg         readable_r;  
  
always@(posedge clk or negedge rst)  
begin     
    if(~rst)  
    begin  
        burst_length_counter <= 0;  
        burst_length_done <= 0;  
        readable_r <= 0;  
    end  
    else if(current_state == read || current_state == write || current_state == done)  
    begin  
        burst_length_counter <= burst_length_counter + 1;  
        if(burst_length_counter > 1 && burst_length_counter < burst_length_num_r && rd)  
            readable_r <= 1;  
        else  
            readable_r <= 0;  
        if(burst_length_counter == burst_length_num_r - 1)//10160904  
            burst_length_done <= 1;  
        else  
            burst_length_done <= 0;  
    end  
    else  
    begin  
        burst_length_counter <= 0;  
        burst_length_done <= 0;  
        readable_r <= 0;  
    end  
end  
  
endmodule  