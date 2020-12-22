sdr_test i1 (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.rdf_dout(rdf_dout),
	.rs232_tx(rs232_tx),
	.sdram_addr(sdram_addr),
	.sdram_ba(sdram_ba),
	.sdram_cas_n(sdram_cas_n),
	.sdram_cke(sdram_cke),
	.sdram_clk(sdram_clk),
	.sdram_cs_n(sdram_cs_n),
	.sdram_data(sdram_data),
	.sdram_ldqm(sdram_ldqm),
	.sdram_ras_n(sdram_ras_n),
	.sdram_udqm(sdram_udqm),
	.sdram_we_n(sdram_we_n)
);