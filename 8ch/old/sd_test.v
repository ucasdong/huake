`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:05:50 05/06/2017
// Design Name:   sdr_test
// Module Name:   D:/fpga daima/ise/sdram/sd_test.v
// Project Name:  sdram
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: sdr_test
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sd_test;

	// Inputs
	reg clk;

	// Outputs
	wire sdram_clk;
	wire sdram_cke;
	wire sdram_cs_n;
	wire sdram_ras_n;
	wire sdram_cas_n;
	wire sdram_we_n;
	wire [1:0] sdram_ba;
	wire [12:0] sdram_addr;
	wire sdram_udqm;
	wire sdram_ldqm;
	wire rs232_tx;
	wire [15:0] rdf_dout;

	// Bidirs
	wire [15:0] sdram_data;

	// Instantiate the Unit Under Test (UUT)
	sdr_test uut (
		.clk(clk), 
		.sdram_clk(sdram_clk), 
		.sdram_cke(sdram_cke), 
		.sdram_cs_n(sdram_cs_n), 
		.sdram_ras_n(sdram_ras_n), 
		.sdram_cas_n(sdram_cas_n), 
		.sdram_we_n(sdram_we_n), 
		.sdram_ba(sdram_ba), 
		.sdram_addr(sdram_addr), 
		.sdram_data(sdram_data), 
		.sdram_udqm(sdram_udqm), 
		.sdram_ldqm(sdram_ldqm), 
		.rs232_tx(rs232_tx), 
		.rdf_dout(rdf_dout)
	);

	initial begin
		// Initialize Inputs
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
     always#20 clk = ~clk; 
mt48lc32m16a2 instance_name (
    .Dq(sdram_data), 
    .Addr(sdram_addr), 
    .Ba(sdram_ba), 
    .Clk(sdram_clk), 
    .Cke(sdram_cke), 
    .Cs_n(sdram_cs_n), 
    .Ras_n(sdram_ras_n), 
    .Cas_n(sdram_cas_n), 
    .We_n(sdram_we_n), 
    .Dqm(1'b0)
    );	 
endmodule

