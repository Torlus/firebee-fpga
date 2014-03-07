--Copyright (C) 1991-2010 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


FUNCTION altpll_reconfig1 
(
	clock,
	counter_param[2..0],
	counter_type[3..0],
	data_in[8..0],
	pll_areset_in,
	pll_scandataout,
	pll_scandone,
	read_param,
	reconfig,
	reset,
	write_param
)

RETURNS (
	busy,
	data_out[8..0],
	pll_areset,
	pll_configupdate,
	pll_scanclk,
	pll_scanclkena,
	pll_scandata
);
