// Xilinx XPort Language Converter, Version 4.1 (110)
// 
// AHDL    Design Source: lpm_bustri_BYT.tdf
// Verilog Design Output: lpm_bustri_BYT.v
// Created 03-Mar-2014 09:18 PM
//
// Copyright (c) 2014, Xilinx, Inc.  All Rights Reserved.
// Xilinx Inc makes no warranty, expressed or implied, with respect to
// the operation and/or functionality of the converted output files.
// 


// ------------------------------------------------------------------
//   LPM_BUSTRI Parameterized Megafunction
//   Copyright (C) 1991-2013 Altera Corporation
//   Your use of Altera Corporation's design tools, logic functions
//   and other software and tools, and its AMPP partner logic
//   functions, and any output files from any of the foregoing
//   (including device programming or simulation files), and any
//   associated documentation or information are expressly subject
//   to the terms and conditions of the Altera Program License
//   Subscription Agreement, Altera MegaCore Function License
//   Agreement, or other applicable license agreement, including,
//   without limitation, that your use is for the sole purpose of
//   programming logic devices manufactured by Altera and sold by
//   Altera or its authorized distributors.  Please refer to the
//   applicable agreement for further details.
//   Quartus II 13.1.0 Build 162 10/23/2013
//   Version 2.0
// ------------------------------------------------------------------
module lpm_bustri_BYT(tridata, data, enabletr, enabledt, result);
   input [7:0] data;
   input enabletr, enabledt;
   output [7:0] result;
   inout [7:0] tridata;

//  Are the enable inputs used? 
   wire [7:0] dout;
   wire [7:0] dout_in;
   wire gnd, result0_1, result0_2, result1_1, result1_2, result2_1, result2_2,
	 result3_1, result3_2, result4_1, result4_2, result5_1, result5_2,
	 result6_1, result6_2, result7_1, result7_2, dout0_oe_ctrl;

   assign dout[0] = (dout0_oe_ctrl) ? dout_in[0] : 1'bz;
   assign dout[1] = (dout0_oe_ctrl) ? dout_in[1] : 1'bz;
   assign dout[2] = (dout0_oe_ctrl) ? dout_in[2] : 1'bz;
   assign dout[3] = (dout0_oe_ctrl) ? dout_in[3] : 1'bz;
   assign dout[4] = (dout0_oe_ctrl) ? dout_in[4] : 1'bz;
   assign dout[5] = (dout0_oe_ctrl) ? dout_in[5] : 1'bz;
   assign dout[6] = (dout0_oe_ctrl) ? dout_in[6] : 1'bz;
   assign dout[7] = (dout0_oe_ctrl) ? dout_in[7] : 1'bz;

// Start of original equations

//  Connect buffers if they are used 
   assign dout0_oe_ctrl = enabledt;
   assign dout_in = data;
   assign tridata = dout;
   assign {result7_1, result6_1, result5_1, result4_1, result3_1, result2_1,
	 result1_1, result0_1} = tridata;
   assign {result7_2, result6_2, result5_2, result4_2, result3_2, result2_2,
	 result1_2, result0_2} = {8{gnd}};


// Assignments added to explicitly combine the
// effects of multiple drivers in the source
   assign result[0] = result0_1 | result0_2;
   assign result[1] = result1_1 | result1_2;
   assign result[2] = result2_1 | result2_2;
   assign result[3] = result3_1 | result3_2;
   assign result[4] = result4_1 | result4_2;
   assign result[5] = result5_1 | result5_2;
   assign result[6] = result6_1 | result6_2;
   assign result[7] = result7_1 | result7_2;

// Define power signal(s)
   assign gnd = 1'b0;
endmodule
