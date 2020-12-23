// -----------------------------------------------------------------------------
//
// Copyright 2011(c) Analog Devices, Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//  - Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//  - Neither the name of Analog Devices, Inc. nor the names of its
//    contributors may be used to endorse or promote products derived
//    from this software without specific prior written permission.
//  - The use of this software may or may not infringe the patent rights
//    of one or more patent holders.  This license does not release you
//    from the requirement that you obtain separate licenses from these
//    patent holders to use this software.
//  - Use of the software either in source or binary form, must be run
//    on or directly connected to an Analog Devices Inc. component.
//
// THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY
// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// INTELLECTUAL PROPERTY RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// -----------------------------------------------------------------------------
// FILE NAME : AD7606.v
// MODULE NAME : AD7606
// AUTHOR : acostina
// AUTHOR锟絊 EMAIL : adrian.costina@analog.com
// -----------------------------------------------------------------------------
// SVN REVISION: 1420
// -----------------------------------------------------------------------------
// KEYWORDS : AD7606
// -----------------------------------------------------------------------------
// PURPOSE : Driver for the AD7606 8-Channel, 200 KSPS, 16-Bit Parallel ADCs
// -----------------------------------------------------------------------------
// REUSE ISSUES
// Reset Strategy      : Active low reset signal
// Clock Domains       : The design considered an 48 MHz input clock. The
// FPGA_CLOCK_FREQ parameter must be adjusted if the input clock is changed.
// Critical Timing     : N/A
// Test Features       : N/A
// Asynchronous I/F    : N/A
// Instantiations      : N/A
// Synthesizable (y/n) : Y
// Target Device       : AD7606
// Other               : The driver reads data from the ADC in word mode.The
//                      result is forwarded to the upper module.The upper
//                      module or the software needs to know what channels are
//                      forwarded.
//                      If more than one channel is acquired, the upper module
//                      must be able to support the activation of data_rd_ready_o 
//                      signal every 4 clock cycles
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps //Use a timescale that is best for simulation.

//------------------------------------------------------------------------------
//----------- Module Declaration -----------------------------------------------
//------------------------------------------------------------------------------

module AD7606
//----------- Ports Declarations -----------------------------------------------
(
    //clock and reset signals
    input               	clk_40M			,      		//system clock
//    input               	reset_n_i		,      		//active low reset signal
    input               	ad_start		,       	//active low reset signal

    //IP control and data interface
    input               	wr_data_n_i		,     		// active low signal to initiate a data write to the ADC
    input       	[15:0]  data_i			,          	// channel[7:5], os[4:2],standby[1],range[0]
    output 	reg		[15:0]  data_oa			,          	// data read from the ADC
    output 	reg		[15:0]  data_ob			,          	// data read from the ADC
    output 	reg  	[15:0]  data_oc			,          	// data read from the ADC
    output 	reg  	[15:0]  data_od			,          	// data read from the ADC
    output 	reg          	data_rd_ready_o	, 			// when set to high the data read from the ADC is available on the data_o bus
    output 	reg          	data_wr_ready_o	, 			// used to signal the status of an ADC write: 0 - write in progress, 1 - write complete
    output 	reg          	sync_o			,          	// used to signal the first channel

    //AD7606 control and data interface
    input       	[15:0]  adc_db_i		,       	// ADC parallel data bus
    input              		adc_busy_i		,     		// ADC BUSY signal
    output      	[2:0]   adc_os_o		,       	// ADC OVERSAMPLING signals
    output              	adc_range_o		,    		// ADC RANGE signal
    output  reg         	adc_cs_n_o		,     		// ADC CS signal
    output  reg         	adc_rd_n_o		,     		// ADC RD signal
    output  reg         	adc_reset_o		,    		// ADC RESET signal
 //   output              	adc_stdby_o		,    		// 硬锟斤拷为锟斤拷锟
    output  	        	adc_convst_a_o	,    		// ADC CONVST signal
    output  	        	adc_convst_b_o   			// ADC CONVST signal
	
);
reg     [9:00]  delay_cov;
wire 	fpga_clk_i							;
assign 	fpga_clk_i = clk_40M				;
	
assign	adc_convst_a_o = adc_convst_o		;

assign	adc_convst_b_o = delay_cov[9]		;
always@(posedge fpga_clk_i)
    delay_cov  <= {delay_cov[8:0],adc_convst_o};






//------------------------------------------------------------------------------
//----------- Wire Declarations ------------------------------------------------
//------------------------------------------------------------------------------
wire 	[2:0] channel						;     			// used to configure the number of channels to be read

//----------reg-----------
reg        	 adc_convst_o					;

//------------------------------------------------------------------------------
//----------- Registers Declarations -------------------------------------------
//------------------------------------------------------------------------------

reg [3:0]   adc_state						;             	// current state for the ADC control state machine
reg [3:0]   adc_next_state					;         		// next state for the ADC control state machine
reg [15:0]  data_i_s 						;              	// ADC write data;
reg [31:0]  cycle_cnt						;              	// cycle time
reg [2:0]   channel_read					;           	// used to count the number of channels already read
reg         delay_cs						;               // used for increasing the time between CS Low and reading data


//锟斤拷锟捷寄达拷锟斤拷
(*keep*)reg  [15:0] data_oareg						;
(*keep*)reg  [15:0] data_obreg						;
(*keep*)reg  [15:0] data_ocreg						;
(*keep*)reg  [15:0] data_odreg						;
//					
(*keep*)reg	[15:0]  data_o							;
reg			data_rd_ready_oreg1				;
reg			data_rd_ready_oreg2				;
//------------------------------------------------------------------------------
//----------- Local Parameters -------------------------------------------------
//------------------------------------------------------------------------------

//ADC states
parameter 	ADC_IDLE_STATE            = 4'd0, // Default state
			ADC_START_CONV_STATE      = 4'd1, // Togle conversion signal
			ADC_START_CONV_STATE_W    = 4'd2, // Togle conversion signal
			ADC_WAIT_BUSY_HIGH_STATE  = 4'd3, // Wait for the Busy signal to go High
			ADC_WAIT_BUSY_LOW_STATE   = 4'd4, // Wait for the Busy signal to go Low
			ADC_CS_RD_LOW_STATE       = 4'd5, // Bring CS and RD signals Low
			ADC_READDATA_STATE        = 4'd6, // Reads data from the ADC
			ADC_TRANSFER_DATA_STATE   = 4'd7, // Sends data to the upper module
			ADC_WAIT_END_STATE        = 4'd8; // Waits for the cycle time to end

//ADC timing
parameter real FPGA_CLOCK_FREQ      = 48;   // FPGA clock frequency [MHz]
parameter real ADC_CYCLE_TIME       = 5;    // minimum time between two ADC conversions (Tcyc) [us]

parameter [31:0] ADC_CYCLE_CNT_NO_OS= FPGA_CLOCK_FREQ * ADC_CYCLE_TIME - 2;
parameter [31:0] ADC_CYCLE_CNT_OS2  = 2 * FPGA_CLOCK_FREQ * ADC_CYCLE_TIME - 2;
parameter [31:0] ADC_CYCLE_CNT_OS4  = 4 * FPGA_CLOCK_FREQ * ADC_CYCLE_TIME - 2;
parameter [31:0] ADC_CYCLE_CNT_OS8  = 8 * FPGA_CLOCK_FREQ * ADC_CYCLE_TIME - 2;
parameter [31:0] ADC_CYCLE_CNT_OS16 = 16 * FPGA_CLOCK_FREQ * ADC_CYCLE_TIME - 2;
parameter [31:0] ADC_CYCLE_CNT_OS32 = 32 * FPGA_CLOCK_FREQ * ADC_CYCLE_TIME - 2;
parameter [31:0] ADC_CYCLE_CNT_OS64 = 64 * FPGA_CLOCK_FREQ * ADC_CYCLE_TIME - 2;

//------------------------------------------------------------------------------
//----------- Assign/Always Blocks ---------------------------------------------
//------------------------------------------------------------------------------

assign adc_range_o  = 1'b1;//data_i_s[0];
assign adc_stdby_o  = 1'b1;//data_i_s[1];
assign adc_os_o     = data_i_s[4:2];
assign channel      = 3'd4;//data_i_s[7:5];


 reg reset_n_i ;

reg		[7:0] cnt_rst;

always@(posedge fpga_clk_i)
	if(cnt_rst <8'hFE) begin
		reset_n_i <= 1'b0;
		cnt_rst <= cnt_rst + 1'b1; end
	else begin
		cnt_rst <= cnt_rst ;
		reset_n_i <= 1'b1; end 




//update the ADC timing counters count
always @(posedge fpga_clk_i)
begin
    if(reset_n_i == 0)
    begin
        cycle_cnt       <= ADC_CYCLE_CNT_NO_OS;
    end
    else
    begin
        //update the cycle timer
        if(adc_state == ADC_IDLE_STATE)
        begin
            case(adc_os_o)
                3'h0:
                begin
                    cycle_cnt   <= ADC_CYCLE_CNT_NO_OS;
                end
                3'h1:
                begin
                    cycle_cnt   <= ADC_CYCLE_CNT_OS2;
                end
                3'h2:
                begin
                    cycle_cnt   <= ADC_CYCLE_CNT_OS4;
                end
                3'h3:
                begin
                    cycle_cnt   <= ADC_CYCLE_CNT_OS8;
                end
                3'h4:
                begin
                    cycle_cnt   <= ADC_CYCLE_CNT_OS16;
                end
                3'h5:
                begin
                    cycle_cnt   <= ADC_CYCLE_CNT_OS32;
                end
                3'h6:
                begin
                    cycle_cnt   <= ADC_CYCLE_CNT_OS64;
                end
                default:
                begin
                    cycle_cnt   <= ADC_CYCLE_CNT_NO_OS;
                end
            endcase
        end
        else if (cycle_cnt != 0)
        begin
            cycle_cnt   <= cycle_cnt - 32'h1;
        end
    end
end
////状态锟斤拷为锟斤拷锟斤拷式锟斤拷锟斤拷锟斤拷毛锟教的诧拷锟斤拷
//update the ADC current state and the control signals
//-----------锟斤拷一锟斤拷------------------------

always@(posedge fpga_clk_i)
	if(reset_n_i == 0)
		adc_state <= ADC_IDLE_STATE;
	else
		adc_state <= adc_next_state;
		
//-----------锟节讹拷锟斤拷---状态锟斤拷转-------------

always @(*)
begin
    case (adc_state)
    //ADC IDLE state
        ADC_IDLE_STATE:
        begin
            if(ad_start == 1'b1)
                adc_next_state = ADC_START_CONV_STATE;
			else
				 adc_next_state = ADC_IDLE_STATE;

        end
    //ADC write states
        ADC_START_CONV_STATE:
        begin
            adc_next_state = ADC_START_CONV_STATE_W;
        end
	
        ADC_START_CONV_STATE_W:
        begin
            adc_next_state = ADC_WAIT_BUSY_HIGH_STATE;
        end
	
        ADC_WAIT_BUSY_HIGH_STATE:
        begin
            if (adc_busy_i == 1'b1)
                adc_next_state = ADC_WAIT_BUSY_LOW_STATE;
			else
				adc_next_state = ADC_WAIT_BUSY_HIGH_STATE;
        end
        ADC_WAIT_BUSY_LOW_STATE:
        begin
            if ( adc_busy_i == 1'b0 )
                adc_next_state = ADC_CS_RD_LOW_STATE;
			else
				 adc_next_state = ADC_WAIT_BUSY_LOW_STATE;
        end
        ADC_CS_RD_LOW_STATE:
        begin
            if( delay_cs == 1'h1 ) // extend the delay between CS and data read with one clock cycle
            begin
                adc_next_state = ADC_READDATA_STATE;
            end
        end
        ADC_READDATA_STATE:
        begin
            adc_next_state = ADC_TRANSFER_DATA_STATE;
        end
        ADC_TRANSFER_DATA_STATE:
        begin
             if( channel_read <channel )
                adc_next_state = ADC_CS_RD_LOW_STATE;
            else 
                adc_next_state  = ADC_WAIT_END_STATE;
        end
        ADC_WAIT_END_STATE:
		begin
            if ( cycle_cnt == 32'b0 )
                adc_next_state = ADC_IDLE_STATE;
			else
				adc_next_state = ADC_WAIT_END_STATE;
        end
    //default action
        default:
        begin
            adc_next_state = ADC_IDLE_STATE;
        end
    endcase
end
//------------------状态锟斤拷锟斤拷锟斤拷锟斤拷------------------	
always @(posedge fpga_clk_i,negedge reset_n_i)
begin
    if(reset_n_i == 0)
    begin
        adc_reset_o <= 1'b1;
        data_i_s    <= 16'h83;//16'h2;       // By default, the ADC is not in standby
    end
    
   else begin
        case (adc_next_state)
            ADC_IDLE_STATE:
            begin
                 if(wr_data_n_i == 1'b0)
                begin
                    data_i_s        <= data_i;
                    data_wr_ready_o <= 1'b1;
                end 
                adc_cs_n_o      <= 1'b1;
                adc_rd_n_o      <= 1'b1;
                adc_convst_o    <= 1'b1;
//                data_rd_ready_o <= 1'b0;
                adc_reset_o     <= 1'b0;
                channel_read    <= 3'h0;
                sync_o          <= 1'h1;
                delay_cs        <= 1'h0;
            end
        //ADC write states
            ADC_START_CONV_STATE:
            begin
                adc_cs_n_o      <= 1'b1;
                adc_rd_n_o      <= 1'b1;
                adc_convst_o    <= 1'b0;
                data_wr_ready_o <= 1'b0;
 //               data_rd_ready_o <= 1'b0;
                adc_reset_o     <= 1'b0;
                sync_o          <= 1'h1;
                delay_cs        <= 1'h0;
            end
            ADC_WAIT_BUSY_HIGH_STATE:
            begin
                adc_cs_n_o      <= 1'b1;
                adc_rd_n_o      <= 1'b1;
                adc_convst_o    <= 1'b1;
                data_wr_ready_o <= 1'b0;
//                data_rd_ready_o <= 1'b0;
                adc_reset_o     <= 1'b0;
                sync_o          <= 1'h0;
                delay_cs        <= 1'h0;
            end
            ADC_WAIT_BUSY_LOW_STATE:
            begin
                adc_cs_n_o      <= 1'b1;
                adc_rd_n_o      <= 1'b1;
                adc_convst_o    <= 1'b1;
                data_wr_ready_o <= 1'b0;
 //               data_rd_ready_o <= 1'b0;
                adc_reset_o     <= 1'b0;
                sync_o          <= 1'h0;
                delay_cs        <= 1'h0;
            end
            ADC_CS_RD_LOW_STATE:
            begin
                adc_cs_n_o      <= 1'b0;
                adc_rd_n_o      <= 1'b0;
                adc_convst_o    <= 1'b1;
                data_wr_ready_o <= 1'b0;
 //               data_rd_ready_o <= 1'b0;
                adc_reset_o     <= 1'b0;
                sync_o          <= 1'h0;
                delay_cs        <= 1'h1;
            end
            ADC_READDATA_STATE:
            begin
                adc_cs_n_o      <= 1'b0;
                adc_rd_n_o      <= 1'b0;
                adc_convst_o    <= 1'b1;
                data_o          <= adc_db_i +16'h7fff;
                data_wr_ready_o <= 1'b0;
 //               data_rd_ready_o <= 1'b0;
                adc_reset_o     <= 1'b0;
                sync_o          <= 1'h0;
                delay_cs        <= 1'h0;
            end
            ADC_TRANSFER_DATA_STATE:
            begin
                adc_cs_n_o      <= 1'b0;
                adc_rd_n_o      <= 1'b1;
                adc_convst_o    <= 1'b1;
                data_wr_ready_o <= 1'b0;
//                data_rd_ready_o <= 1'b1;
                adc_reset_o     <= 1'b0;
                sync_o          <= 1'h0;
                channel_read    <= channel_read + 3'h1;
                delay_cs        <= 1'h0;
            end
            ADC_WAIT_END_STATE:
            begin
                adc_cs_n_o      <= 1'b1;
                adc_rd_n_o      <= 1'b1;
                adc_convst_o    <= 1'b1;
                data_wr_ready_o <= 1'b0;
//                data_rd_ready_o <= 1'b0;
                adc_reset_o     <= 1'b0;
                sync_o          <= 1'h0;
                delay_cs        <= 1'h0;
            end
        endcase
    end
end

//update the ADC next state
//AD 值锟斤拷锟斤拷

always@(posedge fpga_clk_i)
	if	(channel_read == 3'h0 && adc_rd_n_o ==1'b0)
		data_oareg <=	data_o;
	else if(channel_read == 3'h1 && adc_rd_n_o ==1'b0)
		data_obreg <=	data_o;
	else if(channel_read == 3'h2 && adc_rd_n_o ==1'b0)
		data_ocreg <=	data_o;
	else if(channel_read == 3'h3 && adc_rd_n_o ==1'b0)
		data_odreg <=	data_o;
	else begin
		data_oareg	<= data_oareg;
		data_obreg	<= data_obreg;
		data_ocreg	<= data_ocreg;
		data_odreg	<= data_odreg;end
always@(posedge fpga_clk_i) 
	if(channel_read == 3'h4)
	data_rd_ready_oreg1 <= 1'b1;
	else
	data_rd_ready_oreg1 <= 1'b0;
always@(posedge fpga_clk_i) begin
	data_rd_ready_oreg2 <= data_rd_ready_oreg1;
	if(data_rd_ready_oreg1 == 1'b1 && data_rd_ready_oreg2 == 1'b0)
		data_rd_ready_o <= 1'b1;
	else
		data_rd_ready_o <= 1'b0;
	end
always@(posedge fpga_clk_i) 
	if(data_rd_ready_o)begin
	data_oa		<= data_oareg;
	data_ob		<= data_obreg;
	data_oc		<= data_ocreg;
	data_od		<= data_odreg; end
	else begin
	data_oa		<= 	data_oa;
	data_ob		<= 	data_ob;
	data_oc		<= 	data_oc;
	data_od		<= 	data_od; end
	
	


endmodule
