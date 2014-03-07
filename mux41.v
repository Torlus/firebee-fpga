// Copyright (C) 1991-2009 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 9.1 Build 222 10/21/2009 SJ Full Version"
// CREATED		"Sat Mar 01 09:17:14 2014"

module mux41(
	S0,
	D2,
	INH,
	D0,
	D1,
	D3,
	S1,
	Q
);


input	S0;
input	D2;
input	INH;
input	D0;
input	D1;
input	D3;
input	S1;
output	Q;

wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;




assign	SYNTHESIZED_WIRE_18 =  ~S0;

assign	SYNTHESIZED_WIRE_21 =  ~SYNTHESIZED_WIRE_18;

assign	SYNTHESIZED_WIRE_13 = SYNTHESIZED_WIRE_19 & SYNTHESIZED_WIRE_20 & SYNTHESIZED_WIRE_18 & D0;

assign	SYNTHESIZED_WIRE_14 = SYNTHESIZED_WIRE_19 & SYNTHESIZED_WIRE_20 & SYNTHESIZED_WIRE_21 & D1;

assign	SYNTHESIZED_WIRE_15 = SYNTHESIZED_WIRE_19 & SYNTHESIZED_WIRE_22 & SYNTHESIZED_WIRE_18 & D2;

assign	SYNTHESIZED_WIRE_16 = SYNTHESIZED_WIRE_19 & SYNTHESIZED_WIRE_22 & SYNTHESIZED_WIRE_21 & D3;

assign	Q = SYNTHESIZED_WIRE_13 | SYNTHESIZED_WIRE_14 | SYNTHESIZED_WIRE_15 | SYNTHESIZED_WIRE_16;

assign	SYNTHESIZED_WIRE_19 =  ~INH;

assign	SYNTHESIZED_WIRE_20 =  ~S1;

assign	SYNTHESIZED_WIRE_22 =  ~SYNTHESIZED_WIRE_20;


endmodule
