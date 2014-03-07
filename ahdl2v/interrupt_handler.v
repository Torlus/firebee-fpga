// Xilinx XPort Language Converter, Version 4.1 (110)
// 
// AHDL    Design Source: interrupt_handler.tdf
// Verilog Design Output: interrupt_handler.v
// Created 23-Feb-2014 10:34 AM
//
// Copyright (c) 2014, Xilinx, Inc.  All Rights Reserved.
// Xilinx Inc makes no warranty, expressed or implied, with respect to
// the operation and/or functionality of the converted output files.
// 

// INTERRUPT HANDLER UND C1287


//  CREATED BY FREDI ASCHWANDEN
//   Parameters Statement (optional)
//  {{ALTERA_PARAMETERS_BEGIN}} DO NOT REMOVE THIS LINE!
//  {{ALTERA_PARAMETERS_END}} DO NOT REMOVE THIS LINE!
//   Subdesign Section
module interrupt_handler(MAIN_CLK, nFB_WR, nFB_CS1, nFB_CS2, FB_SIZE0,
      FB_SIZE1, FB_ADR, PIC_INT, E0_INT, DVI_INT, nPCI_INTA, nPCI_INTB,
      nPCI_INTC, nPCI_INTD, nMFP_INT, nFB_OE, DSP_INT, VSYNC, HSYNC, DMA_DRQ,
      nIRQ, INT_HANDLER_TA, ACP_CONF, TIN0, FB_AD);

//  {{ALTERA_IO_BEGIN}} DO NOT REMOVE THIS LINE!
//  {{ALTERA_IO_END}} DO NOT REMOVE THIS LINE!
   input MAIN_CLK, nFB_WR, nFB_CS1, nFB_CS2, FB_SIZE0, FB_SIZE1;
   input [31:0] FB_ADR;
   input PIC_INT, E0_INT, DVI_INT, nPCI_INTA, nPCI_INTB, nPCI_INTC, nPCI_INTD,
	 nMFP_INT, nFB_OE, DSP_INT, VSYNC, HSYNC, DMA_DRQ;
   output [7:2] nIRQ;
   output INT_HANDLER_TA;
   output [31:0] ACP_CONF;
   output TIN0;
   inout [31:0] FB_AD;

//  WERTE REGISTER 0-63
   wire [3:0] FB_B;
   wire [31:0] INT_CTR;
   wire [31:0] INT_CTR_d;
   wire INT_CTR_CS;
   wire [31:0] INT_LATCH;
   wire [31:0] INT_LATCH_d;
   wire [31:0] INT_LATCH_clk;
   wire INT_LATCH31_clrn, INT_LATCH30_clrn, INT_LATCH29_clrn, INT_LATCH28_clrn,
	 INT_LATCH27_clrn, INT_LATCH26_clrn, INT_LATCH25_clrn,
	 INT_LATCH24_clrn, INT_LATCH23_clrn, INT_LATCH22_clrn,
	 INT_LATCH21_clrn, INT_LATCH20_clrn, INT_LATCH19_clrn,
	 INT_LATCH18_clrn, INT_LATCH17_clrn, INT_LATCH16_clrn,
	 INT_LATCH15_clrn, INT_LATCH14_clrn, INT_LATCH13_clrn,
	 INT_LATCH12_clrn, INT_LATCH11_clrn, INT_LATCH10_clrn, INT_LATCH9_clrn,
	 INT_LATCH8_clrn, INT_LATCH7_clrn, INT_LATCH6_clrn, INT_LATCH5_clrn,
	 INT_LATCH4_clrn, INT_LATCH3_clrn, INT_LATCH2_clrn, INT_LATCH1_clrn,
	 INT_LATCH0_clrn, INT_LATCH_CS;
   wire [31:0] INT_CLEAR;
   wire [31:0] INT_CLEAR_d;
   wire INT_CLEAR_CS;
   wire [31:0] INT_IN;
   wire [31:0] INT_ENA;
   wire [31:0] INT_ENA_d;
   wire INT_ENA_CS;
   wire [31:0] ACP_CONF_d;
   wire ACP_CONF_CS, PSEUDO_BUS_ERROR, UHR_AS, UHR_DS;
   wire [5:0] RTC_ADR;
   wire [5:0] RTC_ADR_d;
   wire [2:0] ACHTELSEKUNDEN;
   wire [2:0] ACHTELSEKUNDEN_d;
   wire [63:0] WERTE7_;
   wire [63:0] WERTE7__d;
   wire WERTE7_13_ena, WERTE7_9_ena, WERTE7_8_ena, WERTE7_7_ena, WERTE7_6_ena,
	 WERTE7_4_ena, WERTE7_2_ena, WERTE7_0_ena;
   wire [63:0] WERTE6_;
   wire [63:0] WERTE6__d;
   wire WERTE6_10_clrn, WERTE6_13_ena, WERTE6_9_ena, WERTE6_8_ena,
	 WERTE6_7_ena, WERTE6_6_ena, WERTE6_4_ena, WERTE6_2_ena, WERTE6_0_ena;
   wire [63:0] WERTE5_;
   wire [63:0] WERTE5__d;
   wire WERTE5_13_ena, WERTE5_9_ena, WERTE5_8_ena, WERTE5_7_ena, WERTE5_6_ena,
	 WERTE5_4_ena, WERTE5_2_ena, WERTE5_0_ena;
   wire [63:0] WERTE4_;
   wire [63:0] WERTE4__d;
   wire WERTE4_13_ena, WERTE4_9_ena, WERTE4_8_ena, WERTE4_7_ena, WERTE4_6_ena,
	 WERTE4_4_ena, WERTE4_2_ena, WERTE4_0_ena;
   wire [63:0] WERTE3_;
   wire [63:0] WERTE3__d;
   wire WERTE3_13_ena, WERTE3_9_ena, WERTE3_8_ena, WERTE3_7_ena, WERTE3_6_ena,
	 WERTE3_4_ena, WERTE3_2_ena, WERTE3_0_ena;
   wire [63:0] WERTE2_;
   wire [63:0] WERTE2__d;
   wire WERTE2_13_ena, WERTE2_9_ena, WERTE2_8_ena, WERTE2_7_ena, WERTE2_6_ena,
	 WERTE2_4_ena, WERTE2_2_ena, WERTE2_0_ena;
   wire [63:0] WERTE1_;
   wire [63:0] WERTE1__d;
   wire WERTE1_13_ena, WERTE1_9_ena, WERTE1_8_ena, WERTE1_7_ena, WERTE1_6_ena,
	 WERTE1_4_ena, WERTE1_2_ena, WERTE1_0_ena;
   wire [63:0] WERTE0_;
   wire [63:0] WERTE0__d;
   wire WERTE0_13_ena, WERTE0_9_ena, WERTE0_8_ena, WERTE0_7_ena, WERTE0_6_ena,
	 WERTE0_4_ena, WERTE0_2_ena, WERTE0_0_ena;
   wire [2:0] PIC_INT_SYNC;
   wire [2:0] PIC_INT_SYNC_d;
   wire INC_SEC, INC_MIN, INC_STD, INC_TAG;
   wire [7:0] ANZAHL_TAGE_DES_MONATS;
   wire WINTERZEIT, SOMMERZEIT, INC_MONAT, INC_JAHR, UPDATE_ON, gnd, vcc;
   wire [7:0] u0_data;
   wire u0_enabledt;
   wire [7:0] u0_tridata;
   wire [7:0] u1_data;
   wire u1_enabledt;
   wire [7:0] u1_tridata;
   wire [7:0] u2_data;
   wire u2_enabledt;
   wire [7:0] u2_tridata;
   wire [7:0] u3_data;
   wire u3_enabledt;
   wire [7:0] u3_tridata;
   wire UPDATE_ON_1, UPDATE_ON_2, WERTE0_0_ena_1, WERTE0_0_ena_2,
	 WERTE0_2_ena_1, WERTE0_2_ena_2, WERTE0_4_ena_1, WERTE0_4_ena_2,
	 WERTE0_6_ena_1, WERTE0_6_ena_2, WERTE0_7_ena_1, WERTE0_7_ena_2,
	 WERTE0_8_ena_1, WERTE0_8_ena_2, WERTE0_9_ena_1, WERTE0_9_ena_2,
	 WERTE0_13_ena_1, WERTE0_13_ena_2, WERTE0_0_d_1, WERTE0_0_d_2,
	 WERTE0_2_d_1, WERTE0_2_d_2, WERTE0_4_d_1, WERTE0_4_d_2, WERTE0_6_d_1,
	 WERTE0_6_d_2, WERTE0_7_d_1, WERTE0_7_d_2, WERTE0_8_d_1, WERTE0_8_d_2,
	 WERTE0_9_d_1, WERTE0_9_d_2, WERTE0_11_d_1, WERTE0_11_d_2,
	 WERTE0_13_d_1, WERTE0_13_d_2, WERTE1_0_ena_1, WERTE1_0_ena_2,
	 WERTE1_2_ena_1, WERTE1_2_ena_2, WERTE1_4_ena_1, WERTE1_4_ena_2,
	 WERTE1_6_ena_1, WERTE1_6_ena_2, WERTE1_7_ena_1, WERTE1_7_ena_2,
	 WERTE1_8_ena_1, WERTE1_8_ena_2, WERTE1_9_ena_1, WERTE1_9_ena_2,
	 WERTE1_0_d_1, WERTE1_0_d_2, WERTE1_2_d_1, WERTE1_2_d_2, WERTE1_4_d_1,
	 WERTE1_4_d_2, WERTE1_6_d_1, WERTE1_6_d_2, WERTE1_7_d_1, WERTE1_7_d_2,
	 WERTE1_8_d_1, WERTE1_8_d_2, WERTE1_9_d_1, WERTE1_9_d_2, WERTE1_11_d_1,
	 WERTE1_11_d_2, WERTE2_0_ena_1, WERTE2_0_ena_2, WERTE2_2_ena_1,
	 WERTE2_2_ena_2, WERTE2_4_ena_1, WERTE2_4_ena_2, WERTE2_6_ena_1,
	 WERTE2_6_ena_2, WERTE2_7_ena_1, WERTE2_7_ena_2, WERTE2_8_ena_1,
	 WERTE2_8_ena_2, WERTE2_9_ena_1, WERTE2_9_ena_2, WERTE2_0_d_1,
	 WERTE2_0_d_2, WERTE2_2_d_1, WERTE2_2_d_2, WERTE2_4_d_1, WERTE2_4_d_2,
	 WERTE2_6_d_1, WERTE2_6_d_2, WERTE2_7_d_1, WERTE2_7_d_2, WERTE2_8_d_1,
	 WERTE2_8_d_2, WERTE2_9_d_1, WERTE2_9_d_2, WERTE2_11_d_1,
	 WERTE2_11_d_2, WERTE3_0_ena_1, WERTE3_0_ena_2, WERTE3_2_ena_1,
	 WERTE3_2_ena_2, WERTE3_4_ena_1, WERTE3_4_ena_2, WERTE3_6_ena_1,
	 WERTE3_6_ena_2, WERTE3_7_ena_1, WERTE3_7_ena_2, WERTE3_8_ena_1,
	 WERTE3_8_ena_2, WERTE3_9_ena_1, WERTE3_9_ena_2, WERTE3_0_d_1,
	 WERTE3_0_d_2, WERTE3_2_d_1, WERTE3_2_d_2, WERTE3_4_d_1, WERTE3_4_d_2,
	 WERTE3_6_d_1, WERTE3_6_d_2, WERTE3_7_d_1, WERTE3_7_d_2, WERTE3_8_d_1,
	 WERTE3_8_d_2, WERTE3_9_d_1, WERTE3_9_d_2, WERTE4_0_ena_1,
	 WERTE4_0_ena_2, WERTE4_2_ena_1, WERTE4_2_ena_2, WERTE4_4_ena_1,
	 WERTE4_4_ena_2, WERTE4_6_ena_1, WERTE4_6_ena_2, WERTE4_7_ena_1,
	 WERTE4_7_ena_2, WERTE4_8_ena_1, WERTE4_8_ena_2, WERTE4_9_ena_1,
	 WERTE4_9_ena_2, WERTE4_0_d_1, WERTE4_0_d_2, WERTE4_2_d_1,
	 WERTE4_2_d_2, WERTE4_4_d_1, WERTE4_4_d_2, WERTE4_6_d_1, WERTE4_6_d_2,
	 WERTE4_7_d_1, WERTE4_7_d_2, WERTE4_8_d_1, WERTE4_8_d_2, WERTE4_9_d_1,
	 WERTE4_9_d_2, WERTE5_0_ena_1, WERTE5_0_ena_2, WERTE5_2_ena_1,
	 WERTE5_2_ena_2, WERTE5_4_ena_1, WERTE5_4_ena_2, WERTE5_6_ena_1,
	 WERTE5_6_ena_2, WERTE5_7_ena_1, WERTE5_7_ena_2, WERTE5_8_ena_1,
	 WERTE5_8_ena_2, WERTE5_9_ena_1, WERTE5_9_ena_2, WERTE5_0_d_1,
	 WERTE5_0_d_2, WERTE5_2_d_1, WERTE5_2_d_2, WERTE5_4_d_1, WERTE5_4_d_2,
	 WERTE5_6_d_1, WERTE5_6_d_2, WERTE5_7_d_1, WERTE5_7_d_2, WERTE5_8_d_1,
	 WERTE5_8_d_2, WERTE5_9_d_1, WERTE5_9_d_2, WERTE6_0_ena_1,
	 WERTE6_0_ena_2, WERTE6_2_ena_1, WERTE6_2_ena_2, WERTE6_4_ena_1,
	 WERTE6_4_ena_2, WERTE6_6_ena_1, WERTE6_6_ena_2, WERTE6_7_ena_1,
	 WERTE6_7_ena_2, WERTE6_8_ena_1, WERTE6_8_ena_2, WERTE6_9_ena_1,
	 WERTE6_9_ena_2, WERTE6_0_d_1, WERTE6_0_d_2, WERTE6_2_d_1,
	 WERTE6_2_d_2, WERTE6_4_d_1, WERTE6_4_d_2, WERTE6_6_d_1, WERTE6_6_d_2,
	 WERTE6_7_d_1, WERTE6_7_d_2, WERTE6_8_d_1, WERTE6_8_d_2, WERTE6_9_d_1,
	 WERTE6_9_d_2, WERTE7_0_ena_1, WERTE7_0_ena_2, WERTE7_2_ena_1,
	 WERTE7_2_ena_2, WERTE7_4_ena_1, WERTE7_4_ena_2, WERTE7_6_ena_1,
	 WERTE7_6_ena_2, WERTE7_7_ena_1, WERTE7_7_ena_2, WERTE7_8_ena_1,
	 WERTE7_8_ena_2, WERTE7_9_ena_1, WERTE7_9_ena_2, WERTE7_0_d_1,
	 WERTE7_0_d_2, WERTE7_2_d_1, WERTE7_2_d_2, WERTE7_4_d_1, WERTE7_4_d_2,
	 WERTE7_6_d_1, WERTE7_6_d_2, WERTE7_7_d_1, WERTE7_7_d_2, WERTE7_8_d_1,
	 WERTE7_8_d_2, WERTE7_9_d_1, WERTE7_9_d_2, WERTE7_13_d_1,
	 WERTE7_13_d_2, ACHTELSEKUNDEN0_ena_ctrl, ACHTELSEKUNDEN0_clk_ctrl,
	 PIC_INT_SYNC0_clk_ctrl, WERTE0_63_ena_ctrl, WERTE0_62_ena_ctrl,
	 WERTE0_61_ena_ctrl, WERTE0_60_ena_ctrl, WERTE0_59_ena_ctrl,
	 WERTE0_58_ena_ctrl, WERTE0_57_ena_ctrl, WERTE0_56_ena_ctrl,
	 WERTE0_55_ena_ctrl, WERTE0_54_ena_ctrl, WERTE0_53_ena_ctrl,
	 WERTE0_52_ena_ctrl, WERTE0_51_ena_ctrl, WERTE0_50_ena_ctrl,
	 WERTE0_49_ena_ctrl, WERTE0_48_ena_ctrl, WERTE0_47_ena_ctrl,
	 WERTE0_46_ena_ctrl, WERTE0_45_ena_ctrl, WERTE0_44_ena_ctrl,
	 WERTE0_43_ena_ctrl, WERTE0_42_ena_ctrl, WERTE0_41_ena_ctrl,
	 WERTE0_40_ena_ctrl, WERTE0_39_ena_ctrl, WERTE0_38_ena_ctrl,
	 WERTE0_37_ena_ctrl, WERTE0_36_ena_ctrl, WERTE0_35_ena_ctrl,
	 WERTE0_34_ena_ctrl, WERTE0_33_ena_ctrl, WERTE0_32_ena_ctrl,
	 WERTE0_31_ena_ctrl, WERTE0_30_ena_ctrl, WERTE0_29_ena_ctrl,
	 WERTE0_28_ena_ctrl, WERTE0_27_ena_ctrl, WERTE0_26_ena_ctrl,
	 WERTE0_25_ena_ctrl, WERTE0_24_ena_ctrl, WERTE0_23_ena_ctrl,
	 WERTE0_22_ena_ctrl, WERTE0_21_ena_ctrl, WERTE0_20_ena_ctrl,
	 WERTE0_19_ena_ctrl, WERTE0_18_ena_ctrl, WERTE0_17_ena_ctrl,
	 WERTE0_16_ena_ctrl, WERTE0_15_ena_ctrl, WERTE0_14_ena_ctrl,
	 WERTE0_12_ena_ctrl, WERTE0_11_ena_ctrl, WERTE0_10_ena_ctrl,
	 WERTE0_5_ena_ctrl, WERTE0_3_ena_ctrl, WERTE0_1_ena_ctrl,
	 WERTE0_0_clk_ctrl, WERTE1_0_clk_ctrl, WERTE2_0_clk_ctrl,
	 WERTE3_0_clk_ctrl, WERTE4_0_clk_ctrl, WERTE5_0_clk_ctrl,
	 WERTE6_0_clk_ctrl, WERTE7_0_clk_ctrl, RTC_ADR0_ena_ctrl,
	 RTC_ADR0_clk_ctrl, ACP_CONF0_ena_ctrl, ACP_CONF8_ena_ctrl,
	 ACP_CONF16_ena_ctrl, ACP_CONF24_ena_ctrl, ACP_CONF0_clk_ctrl,
	 INT_CLEAR0_clk_ctrl, INT_ENA0_ena_ctrl, INT_ENA8_ena_ctrl,
	 INT_ENA16_ena_ctrl, INT_ENA24_ena_ctrl, INT_ENA0_clk_ctrl,
	 INT_CTR0_ena_ctrl, INT_CTR8_ena_ctrl, INT_CTR16_ena_ctrl,
	 INT_CTR24_ena_ctrl, INT_CTR0_clk_ctrl, INT_LATCH9_clk_1,
	 INT_LATCH8_clk_1, INT_LATCH7_clk_1, INT_LATCH6_clk_1,
	 INT_LATCH5_clk_1, INT_LATCH4_clk_1, INT_LATCH3_clk_1,
	 INT_LATCH2_clk_1, INT_LATCH1_clk_1, INT_LATCH0_clk_1;
   reg [31:0] INT_CTR_q;
   reg [31:0] INT_LATCH_q;
   reg [31:0] INT_CLEAR_q;
   reg [31:0] INT_ENA_q;
   reg [31:0] ACP_CONF_q;
   reg [5:0] RTC_ADR_q;
   reg [2:0] ACHTELSEKUNDEN_q;
   reg [63:0] WERTE7__q;
   reg [63:0] WERTE6__q;
   reg [63:0] WERTE5__q;
   reg [63:0] WERTE4__q;
   reg [63:0] WERTE3__q;
   reg [63:0] WERTE2__q;
   reg [63:0] WERTE1__q;
   reg [63:0] WERTE0__q;
   reg [2:0] PIC_INT_SYNC_q;


// Sub Module Section
   lpm_bustri_BYT  u0 (.data(u0_data), .enabledt(u0_enabledt),
	 .tridata(u0_tridata));

   lpm_bustri_BYT  u1 (.data(u1_data), .enabledt(u1_enabledt),
	 .tridata(u1_tridata));

   lpm_bustri_BYT  u2 (.data(u2_data), .enabledt(u2_enabledt),
	 .tridata(u2_tridata));

   lpm_bustri_BYT  u3 (.data(u3_data), .enabledt(u3_enabledt),
	 .tridata(u3_tridata));


   assign ACP_CONF[31:24] = ACP_CONF_q[31:24];
   always @(posedge ACP_CONF0_clk_ctrl)
      if (ACP_CONF24_ena_ctrl)
	 {ACP_CONF_q[31], ACP_CONF_q[30], ACP_CONF_q[29], ACP_CONF_q[28],
	       ACP_CONF_q[27], ACP_CONF_q[26], ACP_CONF_q[25], ACP_CONF_q[24]}
	       <= ACP_CONF_d[31:24];

   assign ACP_CONF[23:16] = ACP_CONF_q[23:16];
   always @(posedge ACP_CONF0_clk_ctrl)
      if (ACP_CONF16_ena_ctrl)
	 {ACP_CONF_q[23], ACP_CONF_q[22], ACP_CONF_q[21], ACP_CONF_q[20],
	       ACP_CONF_q[19], ACP_CONF_q[18], ACP_CONF_q[17], ACP_CONF_q[16]}
	       <= ACP_CONF_d[23:16];

   assign ACP_CONF[15:8] = ACP_CONF_q[15:8];
   always @(posedge ACP_CONF0_clk_ctrl)
      if (ACP_CONF8_ena_ctrl)
	 {ACP_CONF_q[15], ACP_CONF_q[14], ACP_CONF_q[13], ACP_CONF_q[12],
	       ACP_CONF_q[11], ACP_CONF_q[10], ACP_CONF_q[9], ACP_CONF_q[8]} <=
	       ACP_CONF_d[15:8];

   assign ACP_CONF[7:0] = ACP_CONF_q[7:0];
   always @(posedge ACP_CONF0_clk_ctrl)
      if (ACP_CONF0_ena_ctrl)
	 {ACP_CONF_q[7], ACP_CONF_q[6], ACP_CONF_q[5], ACP_CONF_q[4],
	       ACP_CONF_q[3], ACP_CONF_q[2], ACP_CONF_q[1], ACP_CONF_q[0]} <=
	       ACP_CONF_d[7:0];

   always @(posedge INT_CTR0_clk_ctrl)
      if (INT_CTR24_ena_ctrl)
	 {INT_CTR_q[31], INT_CTR_q[30], INT_CTR_q[29], INT_CTR_q[28],
	       INT_CTR_q[27], INT_CTR_q[26], INT_CTR_q[25], INT_CTR_q[24]} <=
	       INT_CTR_d[31:24];

   always @(posedge INT_CTR0_clk_ctrl)
      if (INT_CTR16_ena_ctrl)
	 {INT_CTR_q[23], INT_CTR_q[22], INT_CTR_q[21], INT_CTR_q[20],
	       INT_CTR_q[19], INT_CTR_q[18], INT_CTR_q[17], INT_CTR_q[16]} <=
	       INT_CTR_d[23:16];

   always @(posedge INT_CTR0_clk_ctrl)
      if (INT_CTR8_ena_ctrl)
	 {INT_CTR_q[15], INT_CTR_q[14], INT_CTR_q[13], INT_CTR_q[12],
	       INT_CTR_q[11], INT_CTR_q[10], INT_CTR_q[9], INT_CTR_q[8]} <=
	       INT_CTR_d[15:8];

   always @(posedge INT_CTR0_clk_ctrl)
      if (INT_CTR0_ena_ctrl)
	 {INT_CTR_q[7], INT_CTR_q[6], INT_CTR_q[5], INT_CTR_q[4], INT_CTR_q[3],
	       INT_CTR_q[2], INT_CTR_q[1], INT_CTR_q[0]} <= INT_CTR_d[7:0];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH31_clrn)
      if (!INT_LATCH31_clrn)
	 INT_LATCH_q[31] <= 1'h0;
      else
	 INT_LATCH_q[31] <= INT_LATCH_d[31];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH30_clrn)
      if (!INT_LATCH30_clrn)
	 INT_LATCH_q[30] <= 1'h0;
      else
	 INT_LATCH_q[30] <= INT_LATCH_d[30];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH29_clrn)
      if (!INT_LATCH29_clrn)
	 INT_LATCH_q[29] <= 1'h0;
      else
	 INT_LATCH_q[29] <= INT_LATCH_d[29];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH28_clrn)
      if (!INT_LATCH28_clrn)
	 INT_LATCH_q[28] <= 1'h0;
      else
	 INT_LATCH_q[28] <= INT_LATCH_d[28];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH27_clrn)
      if (!INT_LATCH27_clrn)
	 INT_LATCH_q[27] <= 1'h0;
      else
	 INT_LATCH_q[27] <= INT_LATCH_d[27];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH26_clrn)
      if (!INT_LATCH26_clrn)
	 INT_LATCH_q[26] <= 1'h0;
      else
	 INT_LATCH_q[26] <= INT_LATCH_d[26];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH25_clrn)
      if (!INT_LATCH25_clrn)
	 INT_LATCH_q[25] <= 1'h0;
      else
	 INT_LATCH_q[25] <= INT_LATCH_d[25];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH24_clrn)
      if (!INT_LATCH24_clrn)
	 INT_LATCH_q[24] <= 1'h0;
      else
	 INT_LATCH_q[24] <= INT_LATCH_d[24];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH23_clrn)
      if (!INT_LATCH23_clrn)
	 INT_LATCH_q[23] <= 1'h0;
      else
	 INT_LATCH_q[23] <= INT_LATCH_d[23];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH22_clrn)
      if (!INT_LATCH22_clrn)
	 INT_LATCH_q[22] <= 1'h0;
      else
	 INT_LATCH_q[22] <= INT_LATCH_d[22];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH21_clrn)
      if (!INT_LATCH21_clrn)
	 INT_LATCH_q[21] <= 1'h0;
      else
	 INT_LATCH_q[21] <= INT_LATCH_d[21];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH20_clrn)
      if (!INT_LATCH20_clrn)
	 INT_LATCH_q[20] <= 1'h0;
      else
	 INT_LATCH_q[20] <= INT_LATCH_d[20];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH19_clrn)
      if (!INT_LATCH19_clrn)
	 INT_LATCH_q[19] <= 1'h0;
      else
	 INT_LATCH_q[19] <= INT_LATCH_d[19];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH18_clrn)
      if (!INT_LATCH18_clrn)
	 INT_LATCH_q[18] <= 1'h0;
      else
	 INT_LATCH_q[18] <= INT_LATCH_d[18];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH17_clrn)
      if (!INT_LATCH17_clrn)
	 INT_LATCH_q[17] <= 1'h0;
      else
	 INT_LATCH_q[17] <= INT_LATCH_d[17];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH16_clrn)
      if (!INT_LATCH16_clrn)
	 INT_LATCH_q[16] <= 1'h0;
      else
	 INT_LATCH_q[16] <= INT_LATCH_d[16];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH15_clrn)
      if (!INT_LATCH15_clrn)
	 INT_LATCH_q[15] <= 1'h0;
      else
	 INT_LATCH_q[15] <= INT_LATCH_d[15];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH14_clrn)
      if (!INT_LATCH14_clrn)
	 INT_LATCH_q[14] <= 1'h0;
      else
	 INT_LATCH_q[14] <= INT_LATCH_d[14];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH13_clrn)
      if (!INT_LATCH13_clrn)
	 INT_LATCH_q[13] <= 1'h0;
      else
	 INT_LATCH_q[13] <= INT_LATCH_d[13];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH12_clrn)
      if (!INT_LATCH12_clrn)
	 INT_LATCH_q[12] <= 1'h0;
      else
	 INT_LATCH_q[12] <= INT_LATCH_d[12];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH11_clrn)
      if (!INT_LATCH11_clrn)
	 INT_LATCH_q[11] <= 1'h0;
      else
	 INT_LATCH_q[11] <= INT_LATCH_d[11];

   always @(posedge INT_LATCH_clk or negedge INT_LATCH10_clrn)
      if (!INT_LATCH10_clrn)
	 INT_LATCH_q[10] <= 1'h0;
      else
	 INT_LATCH_q[10] <= INT_LATCH_d[10];

   always @(posedge INT_LATCH9_clk_1 or negedge INT_LATCH9_clrn)
      if (!INT_LATCH9_clrn)
	 INT_LATCH_q[9] <= 1'h0;
      else
	 INT_LATCH_q[9] <= INT_LATCH_d[9];

   always @(posedge INT_LATCH8_clk_1 or negedge INT_LATCH8_clrn)
      if (!INT_LATCH8_clrn)
	 INT_LATCH_q[8] <= 1'h0;
      else
	 INT_LATCH_q[8] <= INT_LATCH_d[8];

   always @(posedge INT_LATCH7_clk_1 or negedge INT_LATCH7_clrn)
      if (!INT_LATCH7_clrn)
	 INT_LATCH_q[7] <= 1'h0;
      else
	 INT_LATCH_q[7] <= INT_LATCH_d[7];

   always @(posedge INT_LATCH6_clk_1 or negedge INT_LATCH6_clrn)
      if (!INT_LATCH6_clrn)
	 INT_LATCH_q[6] <= 1'h0;
      else
	 INT_LATCH_q[6] <= INT_LATCH_d[6];

   always @(posedge INT_LATCH5_clk_1 or negedge INT_LATCH5_clrn)
      if (!INT_LATCH5_clrn)
	 INT_LATCH_q[5] <= 1'h0;
      else
	 INT_LATCH_q[5] <= INT_LATCH_d[5];

   always @(posedge INT_LATCH4_clk_1 or negedge INT_LATCH4_clrn)
      if (!INT_LATCH4_clrn)
	 INT_LATCH_q[4] <= 1'h0;
      else
	 INT_LATCH_q[4] <= INT_LATCH_d[4];

   always @(posedge INT_LATCH3_clk_1 or negedge INT_LATCH3_clrn)
      if (!INT_LATCH3_clrn)
	 INT_LATCH_q[3] <= 1'h0;
      else
	 INT_LATCH_q[3] <= INT_LATCH_d[3];

   always @(posedge INT_LATCH2_clk_1 or negedge INT_LATCH2_clrn)
      if (!INT_LATCH2_clrn)
	 INT_LATCH_q[2] <= 1'h0;
      else
	 INT_LATCH_q[2] <= INT_LATCH_d[2];

   always @(posedge INT_LATCH1_clk_1 or negedge INT_LATCH1_clrn)
      if (!INT_LATCH1_clrn)
	 INT_LATCH_q[1] <= 1'h0;
      else
	 INT_LATCH_q[1] <= INT_LATCH_d[1];

   always @(posedge INT_LATCH0_clk_1 or negedge INT_LATCH0_clrn)
      if (!INT_LATCH0_clrn)
	 INT_LATCH_q[0] <= 1'h0;
      else
	 INT_LATCH_q[0] <= INT_LATCH_d[0];

   always @(posedge INT_CLEAR0_clk_ctrl)
      INT_CLEAR_q <= INT_CLEAR_d;

   always @(posedge INT_ENA0_clk_ctrl)
      if (INT_ENA24_ena_ctrl)
	 {INT_ENA_q[31], INT_ENA_q[30], INT_ENA_q[29], INT_ENA_q[28],
	       INT_ENA_q[27], INT_ENA_q[26], INT_ENA_q[25], INT_ENA_q[24]} <=
	       INT_ENA_d[31:24];

   always @(posedge INT_ENA0_clk_ctrl)
      if (INT_ENA16_ena_ctrl)
	 {INT_ENA_q[23], INT_ENA_q[22], INT_ENA_q[21], INT_ENA_q[20],
	       INT_ENA_q[19], INT_ENA_q[18], INT_ENA_q[17], INT_ENA_q[16]} <=
	       INT_ENA_d[23:16];

   always @(posedge INT_ENA0_clk_ctrl)
      if (INT_ENA8_ena_ctrl)
	 {INT_ENA_q[15], INT_ENA_q[14], INT_ENA_q[13], INT_ENA_q[12],
	       INT_ENA_q[11], INT_ENA_q[10], INT_ENA_q[9], INT_ENA_q[8]} <=
	       INT_ENA_d[15:8];

   always @(posedge INT_ENA0_clk_ctrl)
      if (INT_ENA0_ena_ctrl)
	 {INT_ENA_q[7], INT_ENA_q[6], INT_ENA_q[5], INT_ENA_q[4], INT_ENA_q[3],
	       INT_ENA_q[2], INT_ENA_q[1], INT_ENA_q[0]} <= INT_ENA_d[7:0];

   always @(posedge RTC_ADR0_clk_ctrl)
      if (RTC_ADR0_ena_ctrl)
	 RTC_ADR_q <= RTC_ADR_d;

   always @(posedge ACHTELSEKUNDEN0_clk_ctrl)
      if (ACHTELSEKUNDEN0_ena_ctrl)
	 ACHTELSEKUNDEN_q <= ACHTELSEKUNDEN_d;

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_63_ena_ctrl)
	 WERTE7__q[63] <= WERTE7__d[63];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_62_ena_ctrl)
	 WERTE7__q[62] <= WERTE7__d[62];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_61_ena_ctrl)
	 WERTE7__q[61] <= WERTE7__d[61];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_60_ena_ctrl)
	 WERTE7__q[60] <= WERTE7__d[60];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_59_ena_ctrl)
	 WERTE7__q[59] <= WERTE7__d[59];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_58_ena_ctrl)
	 WERTE7__q[58] <= WERTE7__d[58];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_57_ena_ctrl)
	 WERTE7__q[57] <= WERTE7__d[57];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_56_ena_ctrl)
	 WERTE7__q[56] <= WERTE7__d[56];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_55_ena_ctrl)
	 WERTE7__q[55] <= WERTE7__d[55];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_54_ena_ctrl)
	 WERTE7__q[54] <= WERTE7__d[54];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_53_ena_ctrl)
	 WERTE7__q[53] <= WERTE7__d[53];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_52_ena_ctrl)
	 WERTE7__q[52] <= WERTE7__d[52];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_51_ena_ctrl)
	 WERTE7__q[51] <= WERTE7__d[51];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_50_ena_ctrl)
	 WERTE7__q[50] <= WERTE7__d[50];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_49_ena_ctrl)
	 WERTE7__q[49] <= WERTE7__d[49];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_48_ena_ctrl)
	 WERTE7__q[48] <= WERTE7__d[48];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_47_ena_ctrl)
	 WERTE7__q[47] <= WERTE7__d[47];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_46_ena_ctrl)
	 WERTE7__q[46] <= WERTE7__d[46];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_45_ena_ctrl)
	 WERTE7__q[45] <= WERTE7__d[45];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_44_ena_ctrl)
	 WERTE7__q[44] <= WERTE7__d[44];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_43_ena_ctrl)
	 WERTE7__q[43] <= WERTE7__d[43];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_42_ena_ctrl)
	 WERTE7__q[42] <= WERTE7__d[42];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_41_ena_ctrl)
	 WERTE7__q[41] <= WERTE7__d[41];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_40_ena_ctrl)
	 WERTE7__q[40] <= WERTE7__d[40];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_39_ena_ctrl)
	 WERTE7__q[39] <= WERTE7__d[39];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_38_ena_ctrl)
	 WERTE7__q[38] <= WERTE7__d[38];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_37_ena_ctrl)
	 WERTE7__q[37] <= WERTE7__d[37];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_36_ena_ctrl)
	 WERTE7__q[36] <= WERTE7__d[36];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_35_ena_ctrl)
	 WERTE7__q[35] <= WERTE7__d[35];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_34_ena_ctrl)
	 WERTE7__q[34] <= WERTE7__d[34];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_33_ena_ctrl)
	 WERTE7__q[33] <= WERTE7__d[33];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_32_ena_ctrl)
	 WERTE7__q[32] <= WERTE7__d[32];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_31_ena_ctrl)
	 WERTE7__q[31] <= WERTE7__d[31];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_30_ena_ctrl)
	 WERTE7__q[30] <= WERTE7__d[30];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_29_ena_ctrl)
	 WERTE7__q[29] <= WERTE7__d[29];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_28_ena_ctrl)
	 WERTE7__q[28] <= WERTE7__d[28];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_27_ena_ctrl)
	 WERTE7__q[27] <= WERTE7__d[27];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_26_ena_ctrl)
	 WERTE7__q[26] <= WERTE7__d[26];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_25_ena_ctrl)
	 WERTE7__q[25] <= WERTE7__d[25];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_24_ena_ctrl)
	 WERTE7__q[24] <= WERTE7__d[24];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_23_ena_ctrl)
	 WERTE7__q[23] <= WERTE7__d[23];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_22_ena_ctrl)
	 WERTE7__q[22] <= WERTE7__d[22];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_21_ena_ctrl)
	 WERTE7__q[21] <= WERTE7__d[21];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_20_ena_ctrl)
	 WERTE7__q[20] <= WERTE7__d[20];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_19_ena_ctrl)
	 WERTE7__q[19] <= WERTE7__d[19];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_18_ena_ctrl)
	 WERTE7__q[18] <= WERTE7__d[18];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_17_ena_ctrl)
	 WERTE7__q[17] <= WERTE7__d[17];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_16_ena_ctrl)
	 WERTE7__q[16] <= WERTE7__d[16];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_15_ena_ctrl)
	 WERTE7__q[15] <= WERTE7__d[15];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_14_ena_ctrl)
	 WERTE7__q[14] <= WERTE7__d[14];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE7_13_ena)
	 WERTE7__q[13] <= WERTE7__d[13];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_12_ena_ctrl)
	 WERTE7__q[12] <= WERTE7__d[12];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_11_ena_ctrl)
	 WERTE7__q[11] <= WERTE7__d[11];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_10_ena_ctrl)
	 WERTE7__q[10] <= WERTE7__d[10];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE7_9_ena)
	 WERTE7__q[9] <= WERTE7__d[9];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE7_8_ena)
	 WERTE7__q[8] <= WERTE7__d[8];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE7_7_ena)
	 WERTE7__q[7] <= WERTE7__d[7];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE7_6_ena)
	 WERTE7__q[6] <= WERTE7__d[6];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_5_ena_ctrl)
	 WERTE7__q[5] <= WERTE7__d[5];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE7_4_ena)
	 WERTE7__q[4] <= WERTE7__d[4];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_3_ena_ctrl)
	 WERTE7__q[3] <= WERTE7__d[3];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE7_2_ena)
	 WERTE7__q[2] <= WERTE7__d[2];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE0_1_ena_ctrl)
	 WERTE7__q[1] <= WERTE7__d[1];

   always @(posedge WERTE7_0_clk_ctrl)
      if (WERTE7_0_ena)
	 WERTE7__q[0] <= WERTE7__d[0];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_63_ena_ctrl)
	 WERTE6__q[63] <= WERTE6__d[63];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_62_ena_ctrl)
	 WERTE6__q[62] <= WERTE6__d[62];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_61_ena_ctrl)
	 WERTE6__q[61] <= WERTE6__d[61];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_60_ena_ctrl)
	 WERTE6__q[60] <= WERTE6__d[60];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_59_ena_ctrl)
	 WERTE6__q[59] <= WERTE6__d[59];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_58_ena_ctrl)
	 WERTE6__q[58] <= WERTE6__d[58];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_57_ena_ctrl)
	 WERTE6__q[57] <= WERTE6__d[57];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_56_ena_ctrl)
	 WERTE6__q[56] <= WERTE6__d[56];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_55_ena_ctrl)
	 WERTE6__q[55] <= WERTE6__d[55];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_54_ena_ctrl)
	 WERTE6__q[54] <= WERTE6__d[54];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_53_ena_ctrl)
	 WERTE6__q[53] <= WERTE6__d[53];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_52_ena_ctrl)
	 WERTE6__q[52] <= WERTE6__d[52];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_51_ena_ctrl)
	 WERTE6__q[51] <= WERTE6__d[51];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_50_ena_ctrl)
	 WERTE6__q[50] <= WERTE6__d[50];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_49_ena_ctrl)
	 WERTE6__q[49] <= WERTE6__d[49];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_48_ena_ctrl)
	 WERTE6__q[48] <= WERTE6__d[48];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_47_ena_ctrl)
	 WERTE6__q[47] <= WERTE6__d[47];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_46_ena_ctrl)
	 WERTE6__q[46] <= WERTE6__d[46];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_45_ena_ctrl)
	 WERTE6__q[45] <= WERTE6__d[45];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_44_ena_ctrl)
	 WERTE6__q[44] <= WERTE6__d[44];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_43_ena_ctrl)
	 WERTE6__q[43] <= WERTE6__d[43];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_42_ena_ctrl)
	 WERTE6__q[42] <= WERTE6__d[42];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_41_ena_ctrl)
	 WERTE6__q[41] <= WERTE6__d[41];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_40_ena_ctrl)
	 WERTE6__q[40] <= WERTE6__d[40];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_39_ena_ctrl)
	 WERTE6__q[39] <= WERTE6__d[39];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_38_ena_ctrl)
	 WERTE6__q[38] <= WERTE6__d[38];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_37_ena_ctrl)
	 WERTE6__q[37] <= WERTE6__d[37];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_36_ena_ctrl)
	 WERTE6__q[36] <= WERTE6__d[36];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_35_ena_ctrl)
	 WERTE6__q[35] <= WERTE6__d[35];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_34_ena_ctrl)
	 WERTE6__q[34] <= WERTE6__d[34];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_33_ena_ctrl)
	 WERTE6__q[33] <= WERTE6__d[33];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_32_ena_ctrl)
	 WERTE6__q[32] <= WERTE6__d[32];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_31_ena_ctrl)
	 WERTE6__q[31] <= WERTE6__d[31];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_30_ena_ctrl)
	 WERTE6__q[30] <= WERTE6__d[30];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_29_ena_ctrl)
	 WERTE6__q[29] <= WERTE6__d[29];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_28_ena_ctrl)
	 WERTE6__q[28] <= WERTE6__d[28];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_27_ena_ctrl)
	 WERTE6__q[27] <= WERTE6__d[27];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_26_ena_ctrl)
	 WERTE6__q[26] <= WERTE6__d[26];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_25_ena_ctrl)
	 WERTE6__q[25] <= WERTE6__d[25];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_24_ena_ctrl)
	 WERTE6__q[24] <= WERTE6__d[24];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_23_ena_ctrl)
	 WERTE6__q[23] <= WERTE6__d[23];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_22_ena_ctrl)
	 WERTE6__q[22] <= WERTE6__d[22];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_21_ena_ctrl)
	 WERTE6__q[21] <= WERTE6__d[21];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_20_ena_ctrl)
	 WERTE6__q[20] <= WERTE6__d[20];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_19_ena_ctrl)
	 WERTE6__q[19] <= WERTE6__d[19];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_18_ena_ctrl)
	 WERTE6__q[18] <= WERTE6__d[18];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_17_ena_ctrl)
	 WERTE6__q[17] <= WERTE6__d[17];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_16_ena_ctrl)
	 WERTE6__q[16] <= WERTE6__d[16];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_15_ena_ctrl)
	 WERTE6__q[15] <= WERTE6__d[15];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_14_ena_ctrl)
	 WERTE6__q[14] <= WERTE6__d[14];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE6_13_ena)
	 WERTE6__q[13] <= WERTE6__d[13];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_12_ena_ctrl)
	 WERTE6__q[12] <= WERTE6__d[12];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_11_ena_ctrl)
	 WERTE6__q[11] <= WERTE6__d[11];

   always @(posedge WERTE6_0_clk_ctrl or negedge WERTE6_10_clrn)
      if (!WERTE6_10_clrn)
	 WERTE6__q[10] <= 1'h0;
      else
	 if (WERTE0_10_ena_ctrl)
	    WERTE6__q[10] <= WERTE6__d[10];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE6_9_ena)
	 WERTE6__q[9] <= WERTE6__d[9];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE6_8_ena)
	 WERTE6__q[8] <= WERTE6__d[8];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE6_7_ena)
	 WERTE6__q[7] <= WERTE6__d[7];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE6_6_ena)
	 WERTE6__q[6] <= WERTE6__d[6];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_5_ena_ctrl)
	 WERTE6__q[5] <= WERTE6__d[5];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE6_4_ena)
	 WERTE6__q[4] <= WERTE6__d[4];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_3_ena_ctrl)
	 WERTE6__q[3] <= WERTE6__d[3];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE6_2_ena)
	 WERTE6__q[2] <= WERTE6__d[2];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE0_1_ena_ctrl)
	 WERTE6__q[1] <= WERTE6__d[1];

   always @(posedge WERTE6_0_clk_ctrl)
      if (WERTE6_0_ena)
	 WERTE6__q[0] <= WERTE6__d[0];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_63_ena_ctrl)
	 WERTE5__q[63] <= WERTE5__d[63];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_62_ena_ctrl)
	 WERTE5__q[62] <= WERTE5__d[62];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_61_ena_ctrl)
	 WERTE5__q[61] <= WERTE5__d[61];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_60_ena_ctrl)
	 WERTE5__q[60] <= WERTE5__d[60];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_59_ena_ctrl)
	 WERTE5__q[59] <= WERTE5__d[59];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_58_ena_ctrl)
	 WERTE5__q[58] <= WERTE5__d[58];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_57_ena_ctrl)
	 WERTE5__q[57] <= WERTE5__d[57];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_56_ena_ctrl)
	 WERTE5__q[56] <= WERTE5__d[56];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_55_ena_ctrl)
	 WERTE5__q[55] <= WERTE5__d[55];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_54_ena_ctrl)
	 WERTE5__q[54] <= WERTE5__d[54];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_53_ena_ctrl)
	 WERTE5__q[53] <= WERTE5__d[53];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_52_ena_ctrl)
	 WERTE5__q[52] <= WERTE5__d[52];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_51_ena_ctrl)
	 WERTE5__q[51] <= WERTE5__d[51];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_50_ena_ctrl)
	 WERTE5__q[50] <= WERTE5__d[50];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_49_ena_ctrl)
	 WERTE5__q[49] <= WERTE5__d[49];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_48_ena_ctrl)
	 WERTE5__q[48] <= WERTE5__d[48];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_47_ena_ctrl)
	 WERTE5__q[47] <= WERTE5__d[47];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_46_ena_ctrl)
	 WERTE5__q[46] <= WERTE5__d[46];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_45_ena_ctrl)
	 WERTE5__q[45] <= WERTE5__d[45];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_44_ena_ctrl)
	 WERTE5__q[44] <= WERTE5__d[44];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_43_ena_ctrl)
	 WERTE5__q[43] <= WERTE5__d[43];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_42_ena_ctrl)
	 WERTE5__q[42] <= WERTE5__d[42];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_41_ena_ctrl)
	 WERTE5__q[41] <= WERTE5__d[41];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_40_ena_ctrl)
	 WERTE5__q[40] <= WERTE5__d[40];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_39_ena_ctrl)
	 WERTE5__q[39] <= WERTE5__d[39];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_38_ena_ctrl)
	 WERTE5__q[38] <= WERTE5__d[38];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_37_ena_ctrl)
	 WERTE5__q[37] <= WERTE5__d[37];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_36_ena_ctrl)
	 WERTE5__q[36] <= WERTE5__d[36];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_35_ena_ctrl)
	 WERTE5__q[35] <= WERTE5__d[35];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_34_ena_ctrl)
	 WERTE5__q[34] <= WERTE5__d[34];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_33_ena_ctrl)
	 WERTE5__q[33] <= WERTE5__d[33];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_32_ena_ctrl)
	 WERTE5__q[32] <= WERTE5__d[32];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_31_ena_ctrl)
	 WERTE5__q[31] <= WERTE5__d[31];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_30_ena_ctrl)
	 WERTE5__q[30] <= WERTE5__d[30];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_29_ena_ctrl)
	 WERTE5__q[29] <= WERTE5__d[29];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_28_ena_ctrl)
	 WERTE5__q[28] <= WERTE5__d[28];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_27_ena_ctrl)
	 WERTE5__q[27] <= WERTE5__d[27];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_26_ena_ctrl)
	 WERTE5__q[26] <= WERTE5__d[26];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_25_ena_ctrl)
	 WERTE5__q[25] <= WERTE5__d[25];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_24_ena_ctrl)
	 WERTE5__q[24] <= WERTE5__d[24];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_23_ena_ctrl)
	 WERTE5__q[23] <= WERTE5__d[23];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_22_ena_ctrl)
	 WERTE5__q[22] <= WERTE5__d[22];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_21_ena_ctrl)
	 WERTE5__q[21] <= WERTE5__d[21];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_20_ena_ctrl)
	 WERTE5__q[20] <= WERTE5__d[20];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_19_ena_ctrl)
	 WERTE5__q[19] <= WERTE5__d[19];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_18_ena_ctrl)
	 WERTE5__q[18] <= WERTE5__d[18];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_17_ena_ctrl)
	 WERTE5__q[17] <= WERTE5__d[17];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_16_ena_ctrl)
	 WERTE5__q[16] <= WERTE5__d[16];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_15_ena_ctrl)
	 WERTE5__q[15] <= WERTE5__d[15];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_14_ena_ctrl)
	 WERTE5__q[14] <= WERTE5__d[14];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE5_13_ena)
	 WERTE5__q[13] <= WERTE5__d[13];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_12_ena_ctrl)
	 WERTE5__q[12] <= WERTE5__d[12];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_11_ena_ctrl)
	 WERTE5__q[11] <= WERTE5__d[11];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_10_ena_ctrl)
	 WERTE5__q[10] <= WERTE5__d[10];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE5_9_ena)
	 WERTE5__q[9] <= WERTE5__d[9];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE5_8_ena)
	 WERTE5__q[8] <= WERTE5__d[8];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE5_7_ena)
	 WERTE5__q[7] <= WERTE5__d[7];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE5_6_ena)
	 WERTE5__q[6] <= WERTE5__d[6];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_5_ena_ctrl)
	 WERTE5__q[5] <= WERTE5__d[5];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE5_4_ena)
	 WERTE5__q[4] <= WERTE5__d[4];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_3_ena_ctrl)
	 WERTE5__q[3] <= WERTE5__d[3];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE5_2_ena)
	 WERTE5__q[2] <= WERTE5__d[2];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE0_1_ena_ctrl)
	 WERTE5__q[1] <= WERTE5__d[1];

   always @(posedge WERTE5_0_clk_ctrl)
      if (WERTE5_0_ena)
	 WERTE5__q[0] <= WERTE5__d[0];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_63_ena_ctrl)
	 WERTE4__q[63] <= WERTE4__d[63];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_62_ena_ctrl)
	 WERTE4__q[62] <= WERTE4__d[62];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_61_ena_ctrl)
	 WERTE4__q[61] <= WERTE4__d[61];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_60_ena_ctrl)
	 WERTE4__q[60] <= WERTE4__d[60];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_59_ena_ctrl)
	 WERTE4__q[59] <= WERTE4__d[59];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_58_ena_ctrl)
	 WERTE4__q[58] <= WERTE4__d[58];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_57_ena_ctrl)
	 WERTE4__q[57] <= WERTE4__d[57];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_56_ena_ctrl)
	 WERTE4__q[56] <= WERTE4__d[56];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_55_ena_ctrl)
	 WERTE4__q[55] <= WERTE4__d[55];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_54_ena_ctrl)
	 WERTE4__q[54] <= WERTE4__d[54];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_53_ena_ctrl)
	 WERTE4__q[53] <= WERTE4__d[53];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_52_ena_ctrl)
	 WERTE4__q[52] <= WERTE4__d[52];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_51_ena_ctrl)
	 WERTE4__q[51] <= WERTE4__d[51];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_50_ena_ctrl)
	 WERTE4__q[50] <= WERTE4__d[50];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_49_ena_ctrl)
	 WERTE4__q[49] <= WERTE4__d[49];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_48_ena_ctrl)
	 WERTE4__q[48] <= WERTE4__d[48];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_47_ena_ctrl)
	 WERTE4__q[47] <= WERTE4__d[47];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_46_ena_ctrl)
	 WERTE4__q[46] <= WERTE4__d[46];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_45_ena_ctrl)
	 WERTE4__q[45] <= WERTE4__d[45];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_44_ena_ctrl)
	 WERTE4__q[44] <= WERTE4__d[44];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_43_ena_ctrl)
	 WERTE4__q[43] <= WERTE4__d[43];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_42_ena_ctrl)
	 WERTE4__q[42] <= WERTE4__d[42];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_41_ena_ctrl)
	 WERTE4__q[41] <= WERTE4__d[41];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_40_ena_ctrl)
	 WERTE4__q[40] <= WERTE4__d[40];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_39_ena_ctrl)
	 WERTE4__q[39] <= WERTE4__d[39];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_38_ena_ctrl)
	 WERTE4__q[38] <= WERTE4__d[38];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_37_ena_ctrl)
	 WERTE4__q[37] <= WERTE4__d[37];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_36_ena_ctrl)
	 WERTE4__q[36] <= WERTE4__d[36];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_35_ena_ctrl)
	 WERTE4__q[35] <= WERTE4__d[35];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_34_ena_ctrl)
	 WERTE4__q[34] <= WERTE4__d[34];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_33_ena_ctrl)
	 WERTE4__q[33] <= WERTE4__d[33];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_32_ena_ctrl)
	 WERTE4__q[32] <= WERTE4__d[32];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_31_ena_ctrl)
	 WERTE4__q[31] <= WERTE4__d[31];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_30_ena_ctrl)
	 WERTE4__q[30] <= WERTE4__d[30];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_29_ena_ctrl)
	 WERTE4__q[29] <= WERTE4__d[29];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_28_ena_ctrl)
	 WERTE4__q[28] <= WERTE4__d[28];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_27_ena_ctrl)
	 WERTE4__q[27] <= WERTE4__d[27];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_26_ena_ctrl)
	 WERTE4__q[26] <= WERTE4__d[26];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_25_ena_ctrl)
	 WERTE4__q[25] <= WERTE4__d[25];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_24_ena_ctrl)
	 WERTE4__q[24] <= WERTE4__d[24];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_23_ena_ctrl)
	 WERTE4__q[23] <= WERTE4__d[23];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_22_ena_ctrl)
	 WERTE4__q[22] <= WERTE4__d[22];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_21_ena_ctrl)
	 WERTE4__q[21] <= WERTE4__d[21];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_20_ena_ctrl)
	 WERTE4__q[20] <= WERTE4__d[20];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_19_ena_ctrl)
	 WERTE4__q[19] <= WERTE4__d[19];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_18_ena_ctrl)
	 WERTE4__q[18] <= WERTE4__d[18];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_17_ena_ctrl)
	 WERTE4__q[17] <= WERTE4__d[17];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_16_ena_ctrl)
	 WERTE4__q[16] <= WERTE4__d[16];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_15_ena_ctrl)
	 WERTE4__q[15] <= WERTE4__d[15];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_14_ena_ctrl)
	 WERTE4__q[14] <= WERTE4__d[14];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE4_13_ena)
	 WERTE4__q[13] <= WERTE4__d[13];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_12_ena_ctrl)
	 WERTE4__q[12] <= WERTE4__d[12];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_11_ena_ctrl)
	 WERTE4__q[11] <= WERTE4__d[11];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_10_ena_ctrl)
	 WERTE4__q[10] <= WERTE4__d[10];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE4_9_ena)
	 WERTE4__q[9] <= WERTE4__d[9];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE4_8_ena)
	 WERTE4__q[8] <= WERTE4__d[8];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE4_7_ena)
	 WERTE4__q[7] <= WERTE4__d[7];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE4_6_ena)
	 WERTE4__q[6] <= WERTE4__d[6];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_5_ena_ctrl)
	 WERTE4__q[5] <= WERTE4__d[5];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE4_4_ena)
	 WERTE4__q[4] <= WERTE4__d[4];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_3_ena_ctrl)
	 WERTE4__q[3] <= WERTE4__d[3];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE4_2_ena)
	 WERTE4__q[2] <= WERTE4__d[2];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE0_1_ena_ctrl)
	 WERTE4__q[1] <= WERTE4__d[1];

   always @(posedge WERTE4_0_clk_ctrl)
      if (WERTE4_0_ena)
	 WERTE4__q[0] <= WERTE4__d[0];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_63_ena_ctrl)
	 WERTE3__q[63] <= WERTE3__d[63];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_62_ena_ctrl)
	 WERTE3__q[62] <= WERTE3__d[62];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_61_ena_ctrl)
	 WERTE3__q[61] <= WERTE3__d[61];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_60_ena_ctrl)
	 WERTE3__q[60] <= WERTE3__d[60];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_59_ena_ctrl)
	 WERTE3__q[59] <= WERTE3__d[59];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_58_ena_ctrl)
	 WERTE3__q[58] <= WERTE3__d[58];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_57_ena_ctrl)
	 WERTE3__q[57] <= WERTE3__d[57];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_56_ena_ctrl)
	 WERTE3__q[56] <= WERTE3__d[56];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_55_ena_ctrl)
	 WERTE3__q[55] <= WERTE3__d[55];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_54_ena_ctrl)
	 WERTE3__q[54] <= WERTE3__d[54];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_53_ena_ctrl)
	 WERTE3__q[53] <= WERTE3__d[53];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_52_ena_ctrl)
	 WERTE3__q[52] <= WERTE3__d[52];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_51_ena_ctrl)
	 WERTE3__q[51] <= WERTE3__d[51];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_50_ena_ctrl)
	 WERTE3__q[50] <= WERTE3__d[50];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_49_ena_ctrl)
	 WERTE3__q[49] <= WERTE3__d[49];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_48_ena_ctrl)
	 WERTE3__q[48] <= WERTE3__d[48];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_47_ena_ctrl)
	 WERTE3__q[47] <= WERTE3__d[47];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_46_ena_ctrl)
	 WERTE3__q[46] <= WERTE3__d[46];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_45_ena_ctrl)
	 WERTE3__q[45] <= WERTE3__d[45];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_44_ena_ctrl)
	 WERTE3__q[44] <= WERTE3__d[44];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_43_ena_ctrl)
	 WERTE3__q[43] <= WERTE3__d[43];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_42_ena_ctrl)
	 WERTE3__q[42] <= WERTE3__d[42];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_41_ena_ctrl)
	 WERTE3__q[41] <= WERTE3__d[41];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_40_ena_ctrl)
	 WERTE3__q[40] <= WERTE3__d[40];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_39_ena_ctrl)
	 WERTE3__q[39] <= WERTE3__d[39];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_38_ena_ctrl)
	 WERTE3__q[38] <= WERTE3__d[38];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_37_ena_ctrl)
	 WERTE3__q[37] <= WERTE3__d[37];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_36_ena_ctrl)
	 WERTE3__q[36] <= WERTE3__d[36];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_35_ena_ctrl)
	 WERTE3__q[35] <= WERTE3__d[35];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_34_ena_ctrl)
	 WERTE3__q[34] <= WERTE3__d[34];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_33_ena_ctrl)
	 WERTE3__q[33] <= WERTE3__d[33];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_32_ena_ctrl)
	 WERTE3__q[32] <= WERTE3__d[32];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_31_ena_ctrl)
	 WERTE3__q[31] <= WERTE3__d[31];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_30_ena_ctrl)
	 WERTE3__q[30] <= WERTE3__d[30];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_29_ena_ctrl)
	 WERTE3__q[29] <= WERTE3__d[29];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_28_ena_ctrl)
	 WERTE3__q[28] <= WERTE3__d[28];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_27_ena_ctrl)
	 WERTE3__q[27] <= WERTE3__d[27];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_26_ena_ctrl)
	 WERTE3__q[26] <= WERTE3__d[26];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_25_ena_ctrl)
	 WERTE3__q[25] <= WERTE3__d[25];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_24_ena_ctrl)
	 WERTE3__q[24] <= WERTE3__d[24];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_23_ena_ctrl)
	 WERTE3__q[23] <= WERTE3__d[23];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_22_ena_ctrl)
	 WERTE3__q[22] <= WERTE3__d[22];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_21_ena_ctrl)
	 WERTE3__q[21] <= WERTE3__d[21];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_20_ena_ctrl)
	 WERTE3__q[20] <= WERTE3__d[20];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_19_ena_ctrl)
	 WERTE3__q[19] <= WERTE3__d[19];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_18_ena_ctrl)
	 WERTE3__q[18] <= WERTE3__d[18];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_17_ena_ctrl)
	 WERTE3__q[17] <= WERTE3__d[17];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_16_ena_ctrl)
	 WERTE3__q[16] <= WERTE3__d[16];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_15_ena_ctrl)
	 WERTE3__q[15] <= WERTE3__d[15];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_14_ena_ctrl)
	 WERTE3__q[14] <= WERTE3__d[14];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE3_13_ena)
	 WERTE3__q[13] <= WERTE3__d[13];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_12_ena_ctrl)
	 WERTE3__q[12] <= WERTE3__d[12];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_11_ena_ctrl)
	 WERTE3__q[11] <= WERTE3__d[11];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_10_ena_ctrl)
	 WERTE3__q[10] <= WERTE3__d[10];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE3_9_ena)
	 WERTE3__q[9] <= WERTE3__d[9];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE3_8_ena)
	 WERTE3__q[8] <= WERTE3__d[8];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE3_7_ena)
	 WERTE3__q[7] <= WERTE3__d[7];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE3_6_ena)
	 WERTE3__q[6] <= WERTE3__d[6];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_5_ena_ctrl)
	 WERTE3__q[5] <= WERTE3__d[5];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE3_4_ena)
	 WERTE3__q[4] <= WERTE3__d[4];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_3_ena_ctrl)
	 WERTE3__q[3] <= WERTE3__d[3];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE3_2_ena)
	 WERTE3__q[2] <= WERTE3__d[2];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE0_1_ena_ctrl)
	 WERTE3__q[1] <= WERTE3__d[1];

   always @(posedge WERTE3_0_clk_ctrl)
      if (WERTE3_0_ena)
	 WERTE3__q[0] <= WERTE3__d[0];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_63_ena_ctrl)
	 WERTE2__q[63] <= WERTE2__d[63];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_62_ena_ctrl)
	 WERTE2__q[62] <= WERTE2__d[62];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_61_ena_ctrl)
	 WERTE2__q[61] <= WERTE2__d[61];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_60_ena_ctrl)
	 WERTE2__q[60] <= WERTE2__d[60];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_59_ena_ctrl)
	 WERTE2__q[59] <= WERTE2__d[59];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_58_ena_ctrl)
	 WERTE2__q[58] <= WERTE2__d[58];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_57_ena_ctrl)
	 WERTE2__q[57] <= WERTE2__d[57];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_56_ena_ctrl)
	 WERTE2__q[56] <= WERTE2__d[56];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_55_ena_ctrl)
	 WERTE2__q[55] <= WERTE2__d[55];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_54_ena_ctrl)
	 WERTE2__q[54] <= WERTE2__d[54];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_53_ena_ctrl)
	 WERTE2__q[53] <= WERTE2__d[53];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_52_ena_ctrl)
	 WERTE2__q[52] <= WERTE2__d[52];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_51_ena_ctrl)
	 WERTE2__q[51] <= WERTE2__d[51];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_50_ena_ctrl)
	 WERTE2__q[50] <= WERTE2__d[50];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_49_ena_ctrl)
	 WERTE2__q[49] <= WERTE2__d[49];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_48_ena_ctrl)
	 WERTE2__q[48] <= WERTE2__d[48];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_47_ena_ctrl)
	 WERTE2__q[47] <= WERTE2__d[47];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_46_ena_ctrl)
	 WERTE2__q[46] <= WERTE2__d[46];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_45_ena_ctrl)
	 WERTE2__q[45] <= WERTE2__d[45];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_44_ena_ctrl)
	 WERTE2__q[44] <= WERTE2__d[44];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_43_ena_ctrl)
	 WERTE2__q[43] <= WERTE2__d[43];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_42_ena_ctrl)
	 WERTE2__q[42] <= WERTE2__d[42];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_41_ena_ctrl)
	 WERTE2__q[41] <= WERTE2__d[41];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_40_ena_ctrl)
	 WERTE2__q[40] <= WERTE2__d[40];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_39_ena_ctrl)
	 WERTE2__q[39] <= WERTE2__d[39];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_38_ena_ctrl)
	 WERTE2__q[38] <= WERTE2__d[38];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_37_ena_ctrl)
	 WERTE2__q[37] <= WERTE2__d[37];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_36_ena_ctrl)
	 WERTE2__q[36] <= WERTE2__d[36];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_35_ena_ctrl)
	 WERTE2__q[35] <= WERTE2__d[35];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_34_ena_ctrl)
	 WERTE2__q[34] <= WERTE2__d[34];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_33_ena_ctrl)
	 WERTE2__q[33] <= WERTE2__d[33];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_32_ena_ctrl)
	 WERTE2__q[32] <= WERTE2__d[32];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_31_ena_ctrl)
	 WERTE2__q[31] <= WERTE2__d[31];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_30_ena_ctrl)
	 WERTE2__q[30] <= WERTE2__d[30];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_29_ena_ctrl)
	 WERTE2__q[29] <= WERTE2__d[29];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_28_ena_ctrl)
	 WERTE2__q[28] <= WERTE2__d[28];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_27_ena_ctrl)
	 WERTE2__q[27] <= WERTE2__d[27];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_26_ena_ctrl)
	 WERTE2__q[26] <= WERTE2__d[26];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_25_ena_ctrl)
	 WERTE2__q[25] <= WERTE2__d[25];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_24_ena_ctrl)
	 WERTE2__q[24] <= WERTE2__d[24];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_23_ena_ctrl)
	 WERTE2__q[23] <= WERTE2__d[23];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_22_ena_ctrl)
	 WERTE2__q[22] <= WERTE2__d[22];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_21_ena_ctrl)
	 WERTE2__q[21] <= WERTE2__d[21];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_20_ena_ctrl)
	 WERTE2__q[20] <= WERTE2__d[20];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_19_ena_ctrl)
	 WERTE2__q[19] <= WERTE2__d[19];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_18_ena_ctrl)
	 WERTE2__q[18] <= WERTE2__d[18];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_17_ena_ctrl)
	 WERTE2__q[17] <= WERTE2__d[17];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_16_ena_ctrl)
	 WERTE2__q[16] <= WERTE2__d[16];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_15_ena_ctrl)
	 WERTE2__q[15] <= WERTE2__d[15];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_14_ena_ctrl)
	 WERTE2__q[14] <= WERTE2__d[14];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE2_13_ena)
	 WERTE2__q[13] <= WERTE2__d[13];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_12_ena_ctrl)
	 WERTE2__q[12] <= WERTE2__d[12];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_11_ena_ctrl)
	 WERTE2__q[11] <= WERTE2__d[11];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_10_ena_ctrl)
	 WERTE2__q[10] <= WERTE2__d[10];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE2_9_ena)
	 WERTE2__q[9] <= WERTE2__d[9];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE2_8_ena)
	 WERTE2__q[8] <= WERTE2__d[8];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE2_7_ena)
	 WERTE2__q[7] <= WERTE2__d[7];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE2_6_ena)
	 WERTE2__q[6] <= WERTE2__d[6];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_5_ena_ctrl)
	 WERTE2__q[5] <= WERTE2__d[5];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE2_4_ena)
	 WERTE2__q[4] <= WERTE2__d[4];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_3_ena_ctrl)
	 WERTE2__q[3] <= WERTE2__d[3];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE2_2_ena)
	 WERTE2__q[2] <= WERTE2__d[2];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE0_1_ena_ctrl)
	 WERTE2__q[1] <= WERTE2__d[1];

   always @(posedge WERTE2_0_clk_ctrl)
      if (WERTE2_0_ena)
	 WERTE2__q[0] <= WERTE2__d[0];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_63_ena_ctrl)
	 WERTE1__q[63] <= WERTE1__d[63];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_62_ena_ctrl)
	 WERTE1__q[62] <= WERTE1__d[62];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_61_ena_ctrl)
	 WERTE1__q[61] <= WERTE1__d[61];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_60_ena_ctrl)
	 WERTE1__q[60] <= WERTE1__d[60];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_59_ena_ctrl)
	 WERTE1__q[59] <= WERTE1__d[59];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_58_ena_ctrl)
	 WERTE1__q[58] <= WERTE1__d[58];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_57_ena_ctrl)
	 WERTE1__q[57] <= WERTE1__d[57];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_56_ena_ctrl)
	 WERTE1__q[56] <= WERTE1__d[56];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_55_ena_ctrl)
	 WERTE1__q[55] <= WERTE1__d[55];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_54_ena_ctrl)
	 WERTE1__q[54] <= WERTE1__d[54];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_53_ena_ctrl)
	 WERTE1__q[53] <= WERTE1__d[53];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_52_ena_ctrl)
	 WERTE1__q[52] <= WERTE1__d[52];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_51_ena_ctrl)
	 WERTE1__q[51] <= WERTE1__d[51];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_50_ena_ctrl)
	 WERTE1__q[50] <= WERTE1__d[50];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_49_ena_ctrl)
	 WERTE1__q[49] <= WERTE1__d[49];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_48_ena_ctrl)
	 WERTE1__q[48] <= WERTE1__d[48];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_47_ena_ctrl)
	 WERTE1__q[47] <= WERTE1__d[47];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_46_ena_ctrl)
	 WERTE1__q[46] <= WERTE1__d[46];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_45_ena_ctrl)
	 WERTE1__q[45] <= WERTE1__d[45];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_44_ena_ctrl)
	 WERTE1__q[44] <= WERTE1__d[44];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_43_ena_ctrl)
	 WERTE1__q[43] <= WERTE1__d[43];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_42_ena_ctrl)
	 WERTE1__q[42] <= WERTE1__d[42];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_41_ena_ctrl)
	 WERTE1__q[41] <= WERTE1__d[41];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_40_ena_ctrl)
	 WERTE1__q[40] <= WERTE1__d[40];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_39_ena_ctrl)
	 WERTE1__q[39] <= WERTE1__d[39];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_38_ena_ctrl)
	 WERTE1__q[38] <= WERTE1__d[38];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_37_ena_ctrl)
	 WERTE1__q[37] <= WERTE1__d[37];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_36_ena_ctrl)
	 WERTE1__q[36] <= WERTE1__d[36];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_35_ena_ctrl)
	 WERTE1__q[35] <= WERTE1__d[35];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_34_ena_ctrl)
	 WERTE1__q[34] <= WERTE1__d[34];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_33_ena_ctrl)
	 WERTE1__q[33] <= WERTE1__d[33];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_32_ena_ctrl)
	 WERTE1__q[32] <= WERTE1__d[32];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_31_ena_ctrl)
	 WERTE1__q[31] <= WERTE1__d[31];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_30_ena_ctrl)
	 WERTE1__q[30] <= WERTE1__d[30];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_29_ena_ctrl)
	 WERTE1__q[29] <= WERTE1__d[29];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_28_ena_ctrl)
	 WERTE1__q[28] <= WERTE1__d[28];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_27_ena_ctrl)
	 WERTE1__q[27] <= WERTE1__d[27];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_26_ena_ctrl)
	 WERTE1__q[26] <= WERTE1__d[26];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_25_ena_ctrl)
	 WERTE1__q[25] <= WERTE1__d[25];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_24_ena_ctrl)
	 WERTE1__q[24] <= WERTE1__d[24];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_23_ena_ctrl)
	 WERTE1__q[23] <= WERTE1__d[23];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_22_ena_ctrl)
	 WERTE1__q[22] <= WERTE1__d[22];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_21_ena_ctrl)
	 WERTE1__q[21] <= WERTE1__d[21];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_20_ena_ctrl)
	 WERTE1__q[20] <= WERTE1__d[20];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_19_ena_ctrl)
	 WERTE1__q[19] <= WERTE1__d[19];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_18_ena_ctrl)
	 WERTE1__q[18] <= WERTE1__d[18];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_17_ena_ctrl)
	 WERTE1__q[17] <= WERTE1__d[17];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_16_ena_ctrl)
	 WERTE1__q[16] <= WERTE1__d[16];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_15_ena_ctrl)
	 WERTE1__q[15] <= WERTE1__d[15];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_14_ena_ctrl)
	 WERTE1__q[14] <= WERTE1__d[14];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE1_13_ena)
	 WERTE1__q[13] <= WERTE1__d[13];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_12_ena_ctrl)
	 WERTE1__q[12] <= WERTE1__d[12];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_11_ena_ctrl)
	 WERTE1__q[11] <= WERTE1__d[11];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_10_ena_ctrl)
	 WERTE1__q[10] <= WERTE1__d[10];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE1_9_ena)
	 WERTE1__q[9] <= WERTE1__d[9];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE1_8_ena)
	 WERTE1__q[8] <= WERTE1__d[8];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE1_7_ena)
	 WERTE1__q[7] <= WERTE1__d[7];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE1_6_ena)
	 WERTE1__q[6] <= WERTE1__d[6];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_5_ena_ctrl)
	 WERTE1__q[5] <= WERTE1__d[5];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE1_4_ena)
	 WERTE1__q[4] <= WERTE1__d[4];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_3_ena_ctrl)
	 WERTE1__q[3] <= WERTE1__d[3];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE1_2_ena)
	 WERTE1__q[2] <= WERTE1__d[2];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE0_1_ena_ctrl)
	 WERTE1__q[1] <= WERTE1__d[1];

   always @(posedge WERTE1_0_clk_ctrl)
      if (WERTE1_0_ena)
	 WERTE1__q[0] <= WERTE1__d[0];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_63_ena_ctrl)
	 WERTE0__q[63] <= WERTE0__d[63];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_62_ena_ctrl)
	 WERTE0__q[62] <= WERTE0__d[62];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_61_ena_ctrl)
	 WERTE0__q[61] <= WERTE0__d[61];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_60_ena_ctrl)
	 WERTE0__q[60] <= WERTE0__d[60];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_59_ena_ctrl)
	 WERTE0__q[59] <= WERTE0__d[59];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_58_ena_ctrl)
	 WERTE0__q[58] <= WERTE0__d[58];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_57_ena_ctrl)
	 WERTE0__q[57] <= WERTE0__d[57];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_56_ena_ctrl)
	 WERTE0__q[56] <= WERTE0__d[56];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_55_ena_ctrl)
	 WERTE0__q[55] <= WERTE0__d[55];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_54_ena_ctrl)
	 WERTE0__q[54] <= WERTE0__d[54];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_53_ena_ctrl)
	 WERTE0__q[53] <= WERTE0__d[53];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_52_ena_ctrl)
	 WERTE0__q[52] <= WERTE0__d[52];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_51_ena_ctrl)
	 WERTE0__q[51] <= WERTE0__d[51];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_50_ena_ctrl)
	 WERTE0__q[50] <= WERTE0__d[50];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_49_ena_ctrl)
	 WERTE0__q[49] <= WERTE0__d[49];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_48_ena_ctrl)
	 WERTE0__q[48] <= WERTE0__d[48];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_47_ena_ctrl)
	 WERTE0__q[47] <= WERTE0__d[47];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_46_ena_ctrl)
	 WERTE0__q[46] <= WERTE0__d[46];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_45_ena_ctrl)
	 WERTE0__q[45] <= WERTE0__d[45];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_44_ena_ctrl)
	 WERTE0__q[44] <= WERTE0__d[44];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_43_ena_ctrl)
	 WERTE0__q[43] <= WERTE0__d[43];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_42_ena_ctrl)
	 WERTE0__q[42] <= WERTE0__d[42];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_41_ena_ctrl)
	 WERTE0__q[41] <= WERTE0__d[41];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_40_ena_ctrl)
	 WERTE0__q[40] <= WERTE0__d[40];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_39_ena_ctrl)
	 WERTE0__q[39] <= WERTE0__d[39];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_38_ena_ctrl)
	 WERTE0__q[38] <= WERTE0__d[38];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_37_ena_ctrl)
	 WERTE0__q[37] <= WERTE0__d[37];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_36_ena_ctrl)
	 WERTE0__q[36] <= WERTE0__d[36];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_35_ena_ctrl)
	 WERTE0__q[35] <= WERTE0__d[35];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_34_ena_ctrl)
	 WERTE0__q[34] <= WERTE0__d[34];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_33_ena_ctrl)
	 WERTE0__q[33] <= WERTE0__d[33];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_32_ena_ctrl)
	 WERTE0__q[32] <= WERTE0__d[32];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_31_ena_ctrl)
	 WERTE0__q[31] <= WERTE0__d[31];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_30_ena_ctrl)
	 WERTE0__q[30] <= WERTE0__d[30];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_29_ena_ctrl)
	 WERTE0__q[29] <= WERTE0__d[29];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_28_ena_ctrl)
	 WERTE0__q[28] <= WERTE0__d[28];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_27_ena_ctrl)
	 WERTE0__q[27] <= WERTE0__d[27];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_26_ena_ctrl)
	 WERTE0__q[26] <= WERTE0__d[26];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_25_ena_ctrl)
	 WERTE0__q[25] <= WERTE0__d[25];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_24_ena_ctrl)
	 WERTE0__q[24] <= WERTE0__d[24];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_23_ena_ctrl)
	 WERTE0__q[23] <= WERTE0__d[23];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_22_ena_ctrl)
	 WERTE0__q[22] <= WERTE0__d[22];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_21_ena_ctrl)
	 WERTE0__q[21] <= WERTE0__d[21];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_20_ena_ctrl)
	 WERTE0__q[20] <= WERTE0__d[20];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_19_ena_ctrl)
	 WERTE0__q[19] <= WERTE0__d[19];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_18_ena_ctrl)
	 WERTE0__q[18] <= WERTE0__d[18];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_17_ena_ctrl)
	 WERTE0__q[17] <= WERTE0__d[17];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_16_ena_ctrl)
	 WERTE0__q[16] <= WERTE0__d[16];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_15_ena_ctrl)
	 WERTE0__q[15] <= WERTE0__d[15];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_14_ena_ctrl)
	 WERTE0__q[14] <= WERTE0__d[14];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_13_ena)
	 WERTE0__q[13] <= WERTE0__d[13];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_12_ena_ctrl)
	 WERTE0__q[12] <= WERTE0__d[12];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_11_ena_ctrl)
	 WERTE0__q[11] <= WERTE0__d[11];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_10_ena_ctrl)
	 WERTE0__q[10] <= WERTE0__d[10];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_9_ena)
	 WERTE0__q[9] <= WERTE0__d[9];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_8_ena)
	 WERTE0__q[8] <= WERTE0__d[8];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_7_ena)
	 WERTE0__q[7] <= WERTE0__d[7];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_6_ena)
	 WERTE0__q[6] <= WERTE0__d[6];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_5_ena_ctrl)
	 WERTE0__q[5] <= WERTE0__d[5];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_4_ena)
	 WERTE0__q[4] <= WERTE0__d[4];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_3_ena_ctrl)
	 WERTE0__q[3] <= WERTE0__d[3];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_2_ena)
	 WERTE0__q[2] <= WERTE0__d[2];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_1_ena_ctrl)
	 WERTE0__q[1] <= WERTE0__d[1];

   always @(posedge WERTE0_0_clk_ctrl)
      if (WERTE0_0_ena)
	 WERTE0__q[0] <= WERTE0__d[0];

   always @(posedge PIC_INT_SYNC0_clk_ctrl)
      PIC_INT_SYNC_q <= PIC_INT_SYNC_d;

// Start of original equations

//  BYT SELECT
//  HWORD
//  HHBYT
//  LONG UND LINE
   assign FB_B[0] = (FB_SIZE1 & (!FB_SIZE0) & (!FB_ADR[1])) | ((!FB_SIZE1) &
	 FB_SIZE0 & (!FB_ADR[1]) & (!FB_ADR[0])) | ((!FB_SIZE1) & (!FB_SIZE0))
	 | (FB_SIZE1 & FB_SIZE0);

//  HWORD
//  HLBYT
//  LONG UND LINE
   assign FB_B[1] = (FB_SIZE1 & (!FB_SIZE0) & (!FB_ADR[1])) | ((!FB_SIZE1) &
	 FB_SIZE0 & (!FB_ADR[1]) & FB_ADR[0]) | ((!FB_SIZE1) & (!FB_SIZE0)) |
	 (FB_SIZE1 & FB_SIZE0);

//  LWORD
//  LHBYT
//  LONG UND LINE
   assign FB_B[2] = (FB_SIZE1 & (!FB_SIZE0) & FB_ADR[1]) | ((!FB_SIZE1) &
	 FB_SIZE0 & FB_ADR[1] & (!FB_ADR[0])) | ((!FB_SIZE1) & (!FB_SIZE0)) |
	 (FB_SIZE1 & FB_SIZE0);

//  LWORD
//  LLBYT
//  LONG UND LINE
   assign FB_B[3] = (FB_SIZE1 & (!FB_SIZE0) & FB_ADR[1]) | ((!FB_SIZE1) &
	 FB_SIZE0 & FB_ADR[1] & FB_ADR[0]) | ((!FB_SIZE1) & (!FB_SIZE0)) |
	 (FB_SIZE1 & FB_SIZE0);

//  INTERRUPT CONTROL REGISTER: BIT0=INT5 AUSLÖSEN, 1=INT7 AUSLÖSEN
   assign INT_CTR0_clk_ctrl = MAIN_CLK;

//  $10000/4
   assign INT_CTR_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h4000;
   assign INT_CTR_d = FB_AD;
   assign INT_CTR24_ena_ctrl = INT_CTR_CS & FB_B[0] & (!nFB_WR);
   assign INT_CTR16_ena_ctrl = INT_CTR_CS & FB_B[1] & (!nFB_WR);
   assign INT_CTR8_ena_ctrl = INT_CTR_CS & FB_B[2] & (!nFB_WR);
   assign INT_CTR0_ena_ctrl = INT_CTR_CS & FB_B[3] & (!nFB_WR);

//  INTERRUPT ENABLE REGISTER BIT31=INT7,30=INT6,29=INT5,28=INT4,27=INT3,26=INT2
   assign INT_ENA0_clk_ctrl = MAIN_CLK;

//  $10004/4
   assign INT_ENA_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h4001;
   assign INT_ENA_d = FB_AD;
   assign INT_ENA24_ena_ctrl = INT_ENA_CS & FB_B[0] & (!nFB_WR);
   assign INT_ENA16_ena_ctrl = INT_ENA_CS & FB_B[1] & (!nFB_WR);
   assign INT_ENA8_ena_ctrl = INT_ENA_CS & FB_B[2] & (!nFB_WR);
   assign INT_ENA0_ena_ctrl = INT_ENA_CS & FB_B[3] & (!nFB_WR);

//  INTERRUPT CLEAR REGISTER WRITE ONLY 1=INTERRUPT CLEAR
   assign INT_CLEAR0_clk_ctrl = MAIN_CLK;

//  $10008/4
   assign INT_CLEAR_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h4002;
   assign INT_CLEAR_d[31:24] = FB_AD[31:24] & {8{INT_CLEAR_CS}} & {8{FB_B[0]}}
	 & {8{!nFB_WR}};
   assign INT_CLEAR_d[23:16] = FB_AD[23:16] & {8{INT_CLEAR_CS}} & {8{FB_B[1]}}
	 & {8{!nFB_WR}};
   assign INT_CLEAR_d[15:8] = FB_AD[15:8] & {8{INT_CLEAR_CS}} & {8{FB_B[2]}} &
	 {8{!nFB_WR}};
   assign INT_CLEAR_d[7:0] = FB_AD[7:0] & {8{INT_CLEAR_CS}} & {8{FB_B[3]}} &
	 {8{!nFB_WR}};

//  INTERRUPT LATCH REGISTER READ ONLY
//  $1000C/4
   assign INT_LATCH_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h4003;

//  INTERRUPT
   assign nIRQ[2] = !(HSYNC & INT_ENA_q[26]);
   assign nIRQ[3] = !(INT_CTR_q[0] & INT_ENA_q[27]);
   assign nIRQ[4] = !(VSYNC & INT_ENA_q[28]);
   assign nIRQ[5] = INT_LATCH_q == 32'h0 & INT_ENA_q[29];
   assign nIRQ[6] = !((!nMFP_INT) & INT_ENA_q[30]);
   assign nIRQ[7] = !(PSEUDO_BUS_ERROR & INT_ENA_q[31]);

//  SCC
//  VME
//  PADDLE
//  PADDLE
//  PADDLE
//  MFP2
//  MFP2
//  MFP2
//  MFP2
//  TT SCSI
//  ST UHR
//  ST UHR
//  DMA SOUND
//  DMA SOUND
//  DMA SOUND
   assign PSEUDO_BUS_ERROR = (!nFB_CS1) & (FB_ADR[19:4] == 16'hF8C8 |
	 FB_ADR[19:4] == 16'hF8E0 | FB_ADR[19:4] == 16'hF920 | FB_ADR[19:4] ==
	 16'hF921 | FB_ADR[19:4] == 16'hF922 | FB_ADR[19:4] == 16'hFFA8 |
	 FB_ADR[19:4] == 16'hFFA9 | FB_ADR[19:4] == 16'hFFAA | FB_ADR[19:4] ==
	 16'hFFA8 | FB_ADR[19:8] == 12'b1111_1000_0111 | FB_ADR[19:4] ==
	 16'hFFC2 | FB_ADR[19:4] == 16'hFFC3 | FB_ADR[19:4] == 16'hF890 |
	 FB_ADR[19:4] == 16'hF891 | FB_ADR[19:4] == 16'hF892);

//  IF VIDEO ADR CHANGE
//  WRITE VIDEO BASE ADR HIGH 0xFFFF8201/2
   assign TIN0 = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C100 & (!nFB_WR);

//  INTERRUPT LATCH
   assign INT_LATCH_d = 32'hFFFF_FFFF;
   assign INT_LATCH0_clk_1 = PIC_INT & INT_ENA_q[0];
   assign INT_LATCH1_clk_1 = E0_INT & INT_ENA_q[1];
   assign INT_LATCH2_clk_1 = DVI_INT & INT_ENA_q[2];
   assign INT_LATCH3_clk_1 = (!nPCI_INTA) & INT_ENA_q[3];
   assign INT_LATCH4_clk_1 = (!nPCI_INTB) & INT_ENA_q[4];
   assign INT_LATCH5_clk_1 = (!nPCI_INTC) & INT_ENA_q[5];
   assign INT_LATCH6_clk_1 = (!nPCI_INTD) & INT_ENA_q[6];
   assign INT_LATCH7_clk_1 = DSP_INT & INT_ENA_q[7];
   assign INT_LATCH8_clk_1 = VSYNC & INT_ENA_q[8];
   assign INT_LATCH9_clk_1 = HSYNC & INT_ENA_q[9];

//  INTERRUPT CLEAR
   assign {INT_LATCH31_clrn, INT_LATCH30_clrn, INT_LATCH29_clrn,
	 INT_LATCH28_clrn, INT_LATCH27_clrn, INT_LATCH26_clrn,
	 INT_LATCH25_clrn, INT_LATCH24_clrn, INT_LATCH23_clrn,
	 INT_LATCH22_clrn, INT_LATCH21_clrn, INT_LATCH20_clrn,
	 INT_LATCH19_clrn, INT_LATCH18_clrn, INT_LATCH17_clrn,
	 INT_LATCH16_clrn, INT_LATCH15_clrn, INT_LATCH14_clrn,
	 INT_LATCH13_clrn, INT_LATCH12_clrn, INT_LATCH11_clrn,
	 INT_LATCH10_clrn, INT_LATCH9_clrn, INT_LATCH8_clrn, INT_LATCH7_clrn,
	 INT_LATCH6_clrn, INT_LATCH5_clrn, INT_LATCH4_clrn, INT_LATCH3_clrn,
	 INT_LATCH2_clrn, INT_LATCH1_clrn, INT_LATCH0_clrn} = ~INT_CLEAR_q;

//  INT_IN
   assign INT_IN[0] = PIC_INT;
   assign INT_IN[1] = E0_INT;
   assign INT_IN[2] = DVI_INT;
   assign INT_IN[3] = !nPCI_INTA;
   assign INT_IN[4] = !nPCI_INTB;
   assign INT_IN[5] = !nPCI_INTC;
   assign INT_IN[6] = !nPCI_INTD;
   assign INT_IN[7] = DSP_INT;
   assign INT_IN[8] = VSYNC;
   assign INT_IN[9] = HSYNC;
   assign INT_IN[25:10] = 16'h0;
   assign INT_IN[26] = HSYNC;
   assign INT_IN[27] = INT_CTR_q[0];
   assign INT_IN[28] = VSYNC;
   assign INT_IN[29] = INT_LATCH_q != 32'h0;
   assign INT_IN[30] = !nMFP_INT;
   assign INT_IN[31] = DMA_DRQ;

// ***************************************************************************************
//  ACP CONFIG REGISTER: BIT 31-> 0=CF 1=IDE
   assign ACP_CONF0_clk_ctrl = MAIN_CLK;

//  $4'0000/4
   assign ACP_CONF_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h1_0000;
   assign ACP_CONF_d = FB_AD;
   assign ACP_CONF24_ena_ctrl = ACP_CONF_CS & FB_B[0] & (!nFB_WR);
   assign ACP_CONF16_ena_ctrl = ACP_CONF_CS & FB_B[1] & (!nFB_WR);
   assign ACP_CONF8_ena_ctrl = ACP_CONF_CS & FB_B[2] & (!nFB_WR);
   assign ACP_CONF0_ena_ctrl = ACP_CONF_CS & FB_B[3] & (!nFB_WR);

// ***************************************************************************************
// ------------------------------------------------------------
//  C1287   0=SEK 2=MIN 4=STD 6=WOCHENTAG 7=TAG 8=MONAT 9=JAHR
// --------------------------------------------------------
   assign RTC_ADR0_clk_ctrl = MAIN_CLK;
   assign RTC_ADR_d = FB_AD[21:16];

//  FFFF8961
   assign UHR_AS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C4B0 & FB_B[1];

//  FFFF8963
   assign UHR_DS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C4B1 & FB_B[3];
   assign RTC_ADR0_ena_ctrl = UHR_AS & (!nFB_WR);
   assign WERTE7_0_clk_ctrl = MAIN_CLK;
   assign WERTE6_0_clk_ctrl = MAIN_CLK;
   assign WERTE5_0_clk_ctrl = MAIN_CLK;
   assign WERTE4_0_clk_ctrl = MAIN_CLK;
   assign WERTE3_0_clk_ctrl = MAIN_CLK;
   assign WERTE2_0_clk_ctrl = MAIN_CLK;
   assign WERTE1_0_clk_ctrl = MAIN_CLK;
   assign WERTE0_0_clk_ctrl = MAIN_CLK;
   assign {WERTE7_0_d_1, WERTE6_0_d_1, WERTE5_0_d_1, WERTE4_0_d_1,
	 WERTE3_0_d_1, WERTE2_0_d_1, WERTE1_0_d_1, WERTE0_0_d_1} = FB_AD[23:16]
	 & {8{RTC_ADR_q == 6'b00_0000}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7__d[1], WERTE6__d[1], WERTE5__d[1], WERTE4__d[1],
	 WERTE3__d[1], WERTE2__d[1], WERTE1__d[1], WERTE0__d[1]} =
	 FB_AD[23:16];
   assign {WERTE7_2_d_1, WERTE6_2_d_1, WERTE5_2_d_1, WERTE4_2_d_1,
	 WERTE3_2_d_1, WERTE2_2_d_1, WERTE1_2_d_1, WERTE0_2_d_1} = FB_AD[23:16]
	 & {8{RTC_ADR_q == 6'b00_0010}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7__d[3], WERTE6__d[3], WERTE5__d[3], WERTE4__d[3],
	 WERTE3__d[3], WERTE2__d[3], WERTE1__d[3], WERTE0__d[3]} =
	 FB_AD[23:16];
   assign {WERTE7_4_d_1, WERTE6_4_d_1, WERTE5_4_d_1, WERTE4_4_d_1,
	 WERTE3_4_d_1, WERTE2_4_d_1, WERTE1_4_d_1, WERTE0_4_d_1} = FB_AD[23:16]
	 & {8{RTC_ADR_q == 6'b00_0100}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7__d[5], WERTE6__d[5], WERTE5__d[5], WERTE4__d[5],
	 WERTE3__d[5], WERTE2__d[5], WERTE1__d[5], WERTE0__d[5]} =
	 FB_AD[23:16];
   assign {WERTE7_6_d_1, WERTE6_6_d_1, WERTE5_6_d_1, WERTE4_6_d_1,
	 WERTE3_6_d_1, WERTE2_6_d_1, WERTE1_6_d_1, WERTE0_6_d_1} = FB_AD[23:16]
	 & {8{RTC_ADR_q == 6'b00_0110}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7_7_d_1, WERTE6_7_d_1, WERTE5_7_d_1, WERTE4_7_d_1,
	 WERTE3_7_d_1, WERTE2_7_d_1, WERTE1_7_d_1, WERTE0_7_d_1} = FB_AD[23:16]
	 & {8{RTC_ADR_q == 6'b00_0111}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7_8_d_1, WERTE6_8_d_1, WERTE5_8_d_1, WERTE4_8_d_1,
	 WERTE3_8_d_1, WERTE2_8_d_1, WERTE1_8_d_1, WERTE0_8_d_1} = FB_AD[23:16]
	 & {8{RTC_ADR_q == 6'b00_1000}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7_9_d_1, WERTE6_9_d_1, WERTE5_9_d_1, WERTE4_9_d_1,
	 WERTE3_9_d_1, WERTE2_9_d_1, WERTE1_9_d_1, WERTE0_9_d_1} = FB_AD[23:16]
	 & {8{RTC_ADR_q == 6'b00_1001}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7__d[10], WERTE6__d[10], WERTE5__d[10], WERTE4__d[10],
	 WERTE3__d[10], WERTE2__d[10], WERTE1__d[10], WERTE0__d[10]} =
	 FB_AD[23:16];
   assign {WERTE7__d[11], WERTE6__d[11], WERTE5__d[11], WERTE4__d[11],
	 WERTE3__d[11], WERTE2_11_d_1, WERTE1_11_d_1, WERTE0_11_d_1} =
	 FB_AD[23:16];
   assign {WERTE7__d[12], WERTE6__d[12], WERTE5__d[12], WERTE4__d[12],
	 WERTE3__d[12], WERTE2__d[12], WERTE1__d[12], WERTE0__d[12]} =
	 FB_AD[23:16];
   assign {WERTE7_13_d_1, WERTE6__d[13], WERTE5__d[13], WERTE4__d[13],
	 WERTE3__d[13], WERTE2__d[13], WERTE1__d[13], WERTE0_13_d_1} =
	 FB_AD[23:16];
   assign {WERTE7__d[14], WERTE6__d[14], WERTE5__d[14], WERTE4__d[14],
	 WERTE3__d[14], WERTE2__d[14], WERTE1__d[14], WERTE0__d[14]} =
	 FB_AD[23:16];
   assign {WERTE7__d[15], WERTE6__d[15], WERTE5__d[15], WERTE4__d[15],
	 WERTE3__d[15], WERTE2__d[15], WERTE1__d[15], WERTE0__d[15]} =
	 FB_AD[23:16];
   assign {WERTE7__d[16], WERTE6__d[16], WERTE5__d[16], WERTE4__d[16],
	 WERTE3__d[16], WERTE2__d[16], WERTE1__d[16], WERTE0__d[16]} =
	 FB_AD[23:16];
   assign {WERTE7__d[17], WERTE6__d[17], WERTE5__d[17], WERTE4__d[17],
	 WERTE3__d[17], WERTE2__d[17], WERTE1__d[17], WERTE0__d[17]} =
	 FB_AD[23:16];
   assign {WERTE7__d[18], WERTE6__d[18], WERTE5__d[18], WERTE4__d[18],
	 WERTE3__d[18], WERTE2__d[18], WERTE1__d[18], WERTE0__d[18]} =
	 FB_AD[23:16];
   assign {WERTE7__d[19], WERTE6__d[19], WERTE5__d[19], WERTE4__d[19],
	 WERTE3__d[19], WERTE2__d[19], WERTE1__d[19], WERTE0__d[19]} =
	 FB_AD[23:16];
   assign {WERTE7__d[20], WERTE6__d[20], WERTE5__d[20], WERTE4__d[20],
	 WERTE3__d[20], WERTE2__d[20], WERTE1__d[20], WERTE0__d[20]} =
	 FB_AD[23:16];
   assign {WERTE7__d[21], WERTE6__d[21], WERTE5__d[21], WERTE4__d[21],
	 WERTE3__d[21], WERTE2__d[21], WERTE1__d[21], WERTE0__d[21]} =
	 FB_AD[23:16];
   assign {WERTE7__d[22], WERTE6__d[22], WERTE5__d[22], WERTE4__d[22],
	 WERTE3__d[22], WERTE2__d[22], WERTE1__d[22], WERTE0__d[22]} =
	 FB_AD[23:16];
   assign {WERTE7__d[23], WERTE6__d[23], WERTE5__d[23], WERTE4__d[23],
	 WERTE3__d[23], WERTE2__d[23], WERTE1__d[23], WERTE0__d[23]} =
	 FB_AD[23:16];
   assign {WERTE7__d[24], WERTE6__d[24], WERTE5__d[24], WERTE4__d[24],
	 WERTE3__d[24], WERTE2__d[24], WERTE1__d[24], WERTE0__d[24]} =
	 FB_AD[23:16];
   assign {WERTE7__d[25], WERTE6__d[25], WERTE5__d[25], WERTE4__d[25],
	 WERTE3__d[25], WERTE2__d[25], WERTE1__d[25], WERTE0__d[25]} =
	 FB_AD[23:16];
   assign {WERTE7__d[26], WERTE6__d[26], WERTE5__d[26], WERTE4__d[26],
	 WERTE3__d[26], WERTE2__d[26], WERTE1__d[26], WERTE0__d[26]} =
	 FB_AD[23:16];
   assign {WERTE7__d[27], WERTE6__d[27], WERTE5__d[27], WERTE4__d[27],
	 WERTE3__d[27], WERTE2__d[27], WERTE1__d[27], WERTE0__d[27]} =
	 FB_AD[23:16];
   assign {WERTE7__d[28], WERTE6__d[28], WERTE5__d[28], WERTE4__d[28],
	 WERTE3__d[28], WERTE2__d[28], WERTE1__d[28], WERTE0__d[28]} =
	 FB_AD[23:16];
   assign {WERTE7__d[29], WERTE6__d[29], WERTE5__d[29], WERTE4__d[29],
	 WERTE3__d[29], WERTE2__d[29], WERTE1__d[29], WERTE0__d[29]} =
	 FB_AD[23:16];
   assign {WERTE7__d[30], WERTE6__d[30], WERTE5__d[30], WERTE4__d[30],
	 WERTE3__d[30], WERTE2__d[30], WERTE1__d[30], WERTE0__d[30]} =
	 FB_AD[23:16];
   assign {WERTE7__d[31], WERTE6__d[31], WERTE5__d[31], WERTE4__d[31],
	 WERTE3__d[31], WERTE2__d[31], WERTE1__d[31], WERTE0__d[31]} =
	 FB_AD[23:16];
   assign {WERTE7__d[32], WERTE6__d[32], WERTE5__d[32], WERTE4__d[32],
	 WERTE3__d[32], WERTE2__d[32], WERTE1__d[32], WERTE0__d[32]} =
	 FB_AD[23:16];
   assign {WERTE7__d[33], WERTE6__d[33], WERTE5__d[33], WERTE4__d[33],
	 WERTE3__d[33], WERTE2__d[33], WERTE1__d[33], WERTE0__d[33]} =
	 FB_AD[23:16];
   assign {WERTE7__d[34], WERTE6__d[34], WERTE5__d[34], WERTE4__d[34],
	 WERTE3__d[34], WERTE2__d[34], WERTE1__d[34], WERTE0__d[34]} =
	 FB_AD[23:16];
   assign {WERTE7__d[35], WERTE6__d[35], WERTE5__d[35], WERTE4__d[35],
	 WERTE3__d[35], WERTE2__d[35], WERTE1__d[35], WERTE0__d[35]} =
	 FB_AD[23:16];
   assign {WERTE7__d[36], WERTE6__d[36], WERTE5__d[36], WERTE4__d[36],
	 WERTE3__d[36], WERTE2__d[36], WERTE1__d[36], WERTE0__d[36]} =
	 FB_AD[23:16];
   assign {WERTE7__d[37], WERTE6__d[37], WERTE5__d[37], WERTE4__d[37],
	 WERTE3__d[37], WERTE2__d[37], WERTE1__d[37], WERTE0__d[37]} =
	 FB_AD[23:16];
   assign {WERTE7__d[38], WERTE6__d[38], WERTE5__d[38], WERTE4__d[38],
	 WERTE3__d[38], WERTE2__d[38], WERTE1__d[38], WERTE0__d[38]} =
	 FB_AD[23:16];
   assign {WERTE7__d[39], WERTE6__d[39], WERTE5__d[39], WERTE4__d[39],
	 WERTE3__d[39], WERTE2__d[39], WERTE1__d[39], WERTE0__d[39]} =
	 FB_AD[23:16];
   assign {WERTE7__d[40], WERTE6__d[40], WERTE5__d[40], WERTE4__d[40],
	 WERTE3__d[40], WERTE2__d[40], WERTE1__d[40], WERTE0__d[40]} =
	 FB_AD[23:16];
   assign {WERTE7__d[41], WERTE6__d[41], WERTE5__d[41], WERTE4__d[41],
	 WERTE3__d[41], WERTE2__d[41], WERTE1__d[41], WERTE0__d[41]} =
	 FB_AD[23:16];
   assign {WERTE7__d[42], WERTE6__d[42], WERTE5__d[42], WERTE4__d[42],
	 WERTE3__d[42], WERTE2__d[42], WERTE1__d[42], WERTE0__d[42]} =
	 FB_AD[23:16];
   assign {WERTE7__d[43], WERTE6__d[43], WERTE5__d[43], WERTE4__d[43],
	 WERTE3__d[43], WERTE2__d[43], WERTE1__d[43], WERTE0__d[43]} =
	 FB_AD[23:16];
   assign {WERTE7__d[44], WERTE6__d[44], WERTE5__d[44], WERTE4__d[44],
	 WERTE3__d[44], WERTE2__d[44], WERTE1__d[44], WERTE0__d[44]} =
	 FB_AD[23:16];
   assign {WERTE7__d[45], WERTE6__d[45], WERTE5__d[45], WERTE4__d[45],
	 WERTE3__d[45], WERTE2__d[45], WERTE1__d[45], WERTE0__d[45]} =
	 FB_AD[23:16];
   assign {WERTE7__d[46], WERTE6__d[46], WERTE5__d[46], WERTE4__d[46],
	 WERTE3__d[46], WERTE2__d[46], WERTE1__d[46], WERTE0__d[46]} =
	 FB_AD[23:16];
   assign {WERTE7__d[47], WERTE6__d[47], WERTE5__d[47], WERTE4__d[47],
	 WERTE3__d[47], WERTE2__d[47], WERTE1__d[47], WERTE0__d[47]} =
	 FB_AD[23:16];
   assign {WERTE7__d[48], WERTE6__d[48], WERTE5__d[48], WERTE4__d[48],
	 WERTE3__d[48], WERTE2__d[48], WERTE1__d[48], WERTE0__d[48]} =
	 FB_AD[23:16];
   assign {WERTE7__d[49], WERTE6__d[49], WERTE5__d[49], WERTE4__d[49],
	 WERTE3__d[49], WERTE2__d[49], WERTE1__d[49], WERTE0__d[49]} =
	 FB_AD[23:16];
   assign {WERTE7__d[50], WERTE6__d[50], WERTE5__d[50], WERTE4__d[50],
	 WERTE3__d[50], WERTE2__d[50], WERTE1__d[50], WERTE0__d[50]} =
	 FB_AD[23:16];
   assign {WERTE7__d[51], WERTE6__d[51], WERTE5__d[51], WERTE4__d[51],
	 WERTE3__d[51], WERTE2__d[51], WERTE1__d[51], WERTE0__d[51]} =
	 FB_AD[23:16];
   assign {WERTE7__d[52], WERTE6__d[52], WERTE5__d[52], WERTE4__d[52],
	 WERTE3__d[52], WERTE2__d[52], WERTE1__d[52], WERTE0__d[52]} =
	 FB_AD[23:16];
   assign {WERTE7__d[53], WERTE6__d[53], WERTE5__d[53], WERTE4__d[53],
	 WERTE3__d[53], WERTE2__d[53], WERTE1__d[53], WERTE0__d[53]} =
	 FB_AD[23:16];
   assign {WERTE7__d[54], WERTE6__d[54], WERTE5__d[54], WERTE4__d[54],
	 WERTE3__d[54], WERTE2__d[54], WERTE1__d[54], WERTE0__d[54]} =
	 FB_AD[23:16];
   assign {WERTE7__d[55], WERTE6__d[55], WERTE5__d[55], WERTE4__d[55],
	 WERTE3__d[55], WERTE2__d[55], WERTE1__d[55], WERTE0__d[55]} =
	 FB_AD[23:16];
   assign {WERTE7__d[56], WERTE6__d[56], WERTE5__d[56], WERTE4__d[56],
	 WERTE3__d[56], WERTE2__d[56], WERTE1__d[56], WERTE0__d[56]} =
	 FB_AD[23:16];
   assign {WERTE7__d[57], WERTE6__d[57], WERTE5__d[57], WERTE4__d[57],
	 WERTE3__d[57], WERTE2__d[57], WERTE1__d[57], WERTE0__d[57]} =
	 FB_AD[23:16];
   assign {WERTE7__d[58], WERTE6__d[58], WERTE5__d[58], WERTE4__d[58],
	 WERTE3__d[58], WERTE2__d[58], WERTE1__d[58], WERTE0__d[58]} =
	 FB_AD[23:16];
   assign {WERTE7__d[59], WERTE6__d[59], WERTE5__d[59], WERTE4__d[59],
	 WERTE3__d[59], WERTE2__d[59], WERTE1__d[59], WERTE0__d[59]} =
	 FB_AD[23:16];
   assign {WERTE7__d[60], WERTE6__d[60], WERTE5__d[60], WERTE4__d[60],
	 WERTE3__d[60], WERTE2__d[60], WERTE1__d[60], WERTE0__d[60]} =
	 FB_AD[23:16];
   assign {WERTE7__d[61], WERTE6__d[61], WERTE5__d[61], WERTE4__d[61],
	 WERTE3__d[61], WERTE2__d[61], WERTE1__d[61], WERTE0__d[61]} =
	 FB_AD[23:16];
   assign {WERTE7__d[62], WERTE6__d[62], WERTE5__d[62], WERTE4__d[62],
	 WERTE3__d[62], WERTE2__d[62], WERTE1__d[62], WERTE0__d[62]} =
	 FB_AD[23:16];
   assign {WERTE7__d[63], WERTE6__d[63], WERTE5__d[63], WERTE4__d[63],
	 WERTE3__d[63], WERTE2__d[63], WERTE1__d[63], WERTE0__d[63]} =
	 FB_AD[23:16];
   assign {WERTE7_0_ena_1, WERTE6_0_ena_1, WERTE5_0_ena_1, WERTE4_0_ena_1,
	 WERTE3_0_ena_1, WERTE2_0_ena_1, WERTE1_0_ena_1, WERTE0_0_ena_1} =
	 {8{RTC_ADR_q == 6'b00_0000}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign WERTE0_1_ena_ctrl = RTC_ADR_q == 6'b00_0001 & UHR_DS & (!nFB_WR);
   assign {WERTE7_2_ena_1, WERTE6_2_ena_1, WERTE5_2_ena_1, WERTE4_2_ena_1,
	 WERTE3_2_ena_1, WERTE2_2_ena_1, WERTE1_2_ena_1, WERTE0_2_ena_1} =
	 {8{RTC_ADR_q == 6'b00_0010}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign WERTE0_3_ena_ctrl = RTC_ADR_q == 6'b00_0011 & UHR_DS & (!nFB_WR);
   assign {WERTE7_4_ena_1, WERTE6_4_ena_1, WERTE5_4_ena_1, WERTE4_4_ena_1,
	 WERTE3_4_ena_1, WERTE2_4_ena_1, WERTE1_4_ena_1, WERTE0_4_ena_1} =
	 {8{RTC_ADR_q == 6'b00_0100}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign WERTE0_5_ena_ctrl = RTC_ADR_q == 6'b00_0101 & UHR_DS & (!nFB_WR);
   assign {WERTE7_6_ena_1, WERTE6_6_ena_1, WERTE5_6_ena_1, WERTE4_6_ena_1,
	 WERTE3_6_ena_1, WERTE2_6_ena_1, WERTE1_6_ena_1, WERTE0_6_ena_1} =
	 {8{RTC_ADR_q == 6'b00_0110}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7_7_ena_1, WERTE6_7_ena_1, WERTE5_7_ena_1, WERTE4_7_ena_1,
	 WERTE3_7_ena_1, WERTE2_7_ena_1, WERTE1_7_ena_1, WERTE0_7_ena_1} =
	 {8{RTC_ADR_q == 6'b00_0111}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7_8_ena_1, WERTE6_8_ena_1, WERTE5_8_ena_1, WERTE4_8_ena_1,
	 WERTE3_8_ena_1, WERTE2_8_ena_1, WERTE1_8_ena_1, WERTE0_8_ena_1} =
	 {8{RTC_ADR_q == 6'b00_1000}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign {WERTE7_9_ena_1, WERTE6_9_ena_1, WERTE5_9_ena_1, WERTE4_9_ena_1,
	 WERTE3_9_ena_1, WERTE2_9_ena_1, WERTE1_9_ena_1, WERTE0_9_ena_1} =
	 {8{RTC_ADR_q == 6'b00_1001}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign WERTE0_10_ena_ctrl = RTC_ADR_q == 6'b00_1010 & UHR_DS & (!nFB_WR);
   assign WERTE0_11_ena_ctrl = RTC_ADR_q == 6'b00_1011 & UHR_DS & (!nFB_WR);
   assign WERTE0_12_ena_ctrl = RTC_ADR_q == 6'b00_1100 & UHR_DS & (!nFB_WR);
   assign {WERTE7_13_ena, WERTE6_13_ena, WERTE5_13_ena, WERTE4_13_ena,
	 WERTE3_13_ena, WERTE2_13_ena, WERTE1_13_ena, WERTE0_13_ena_1} =
	 {8{RTC_ADR_q == 6'b00_1101}} & {8{UHR_DS}} & {8{!nFB_WR}};
   assign WERTE0_14_ena_ctrl = RTC_ADR_q == 6'b00_1110 & UHR_DS & (!nFB_WR);
   assign WERTE0_15_ena_ctrl = RTC_ADR_q == 6'b00_1111 & UHR_DS & (!nFB_WR);
   assign WERTE0_16_ena_ctrl = RTC_ADR_q == 6'b01_0000 & UHR_DS & (!nFB_WR);
   assign WERTE0_17_ena_ctrl = RTC_ADR_q == 6'b01_0001 & UHR_DS & (!nFB_WR);
   assign WERTE0_18_ena_ctrl = RTC_ADR_q == 6'b01_0010 & UHR_DS & (!nFB_WR);
   assign WERTE0_19_ena_ctrl = RTC_ADR_q == 6'b01_0011 & UHR_DS & (!nFB_WR);
   assign WERTE0_20_ena_ctrl = RTC_ADR_q == 6'b01_0100 & UHR_DS & (!nFB_WR);
   assign WERTE0_21_ena_ctrl = RTC_ADR_q == 6'b01_0101 & UHR_DS & (!nFB_WR);
   assign WERTE0_22_ena_ctrl = RTC_ADR_q == 6'b01_0110 & UHR_DS & (!nFB_WR);
   assign WERTE0_23_ena_ctrl = RTC_ADR_q == 6'b01_0111 & UHR_DS & (!nFB_WR);
   assign WERTE0_24_ena_ctrl = RTC_ADR_q == 6'b01_1000 & UHR_DS & (!nFB_WR);
   assign WERTE0_25_ena_ctrl = RTC_ADR_q == 6'b01_1001 & UHR_DS & (!nFB_WR);
   assign WERTE0_26_ena_ctrl = RTC_ADR_q == 6'b01_1010 & UHR_DS & (!nFB_WR);
   assign WERTE0_27_ena_ctrl = RTC_ADR_q == 6'b01_1011 & UHR_DS & (!nFB_WR);
   assign WERTE0_28_ena_ctrl = RTC_ADR_q == 6'b01_1100 & UHR_DS & (!nFB_WR);
   assign WERTE0_29_ena_ctrl = RTC_ADR_q == 6'b01_1101 & UHR_DS & (!nFB_WR);
   assign WERTE0_30_ena_ctrl = RTC_ADR_q == 6'b01_1110 & UHR_DS & (!nFB_WR);
   assign WERTE0_31_ena_ctrl = RTC_ADR_q == 6'b01_1111 & UHR_DS & (!nFB_WR);
   assign WERTE0_32_ena_ctrl = RTC_ADR_q == 6'b10_0000 & UHR_DS & (!nFB_WR);
   assign WERTE0_33_ena_ctrl = RTC_ADR_q == 6'b10_0001 & UHR_DS & (!nFB_WR);
   assign WERTE0_34_ena_ctrl = RTC_ADR_q == 6'b10_0010 & UHR_DS & (!nFB_WR);
   assign WERTE0_35_ena_ctrl = RTC_ADR_q == 6'b10_0011 & UHR_DS & (!nFB_WR);
   assign WERTE0_36_ena_ctrl = RTC_ADR_q == 6'b10_0100 & UHR_DS & (!nFB_WR);
   assign WERTE0_37_ena_ctrl = RTC_ADR_q == 6'b10_0101 & UHR_DS & (!nFB_WR);
   assign WERTE0_38_ena_ctrl = RTC_ADR_q == 6'b10_0110 & UHR_DS & (!nFB_WR);
   assign WERTE0_39_ena_ctrl = RTC_ADR_q == 6'b10_0111 & UHR_DS & (!nFB_WR);
   assign WERTE0_40_ena_ctrl = RTC_ADR_q == 6'b10_1000 & UHR_DS & (!nFB_WR);
   assign WERTE0_41_ena_ctrl = RTC_ADR_q == 6'b10_1001 & UHR_DS & (!nFB_WR);
   assign WERTE0_42_ena_ctrl = RTC_ADR_q == 6'b10_1010 & UHR_DS & (!nFB_WR);
   assign WERTE0_43_ena_ctrl = RTC_ADR_q == 6'b10_1011 & UHR_DS & (!nFB_WR);
   assign WERTE0_44_ena_ctrl = RTC_ADR_q == 6'b10_1100 & UHR_DS & (!nFB_WR);
   assign WERTE0_45_ena_ctrl = RTC_ADR_q == 6'b10_1101 & UHR_DS & (!nFB_WR);
   assign WERTE0_46_ena_ctrl = RTC_ADR_q == 6'b10_1110 & UHR_DS & (!nFB_WR);
   assign WERTE0_47_ena_ctrl = RTC_ADR_q == 6'b10_1111 & UHR_DS & (!nFB_WR);
   assign WERTE0_48_ena_ctrl = RTC_ADR_q == 6'b11_0000 & UHR_DS & (!nFB_WR);
   assign WERTE0_49_ena_ctrl = RTC_ADR_q == 6'b11_0001 & UHR_DS & (!nFB_WR);
   assign WERTE0_50_ena_ctrl = RTC_ADR_q == 6'b11_0010 & UHR_DS & (!nFB_WR);
   assign WERTE0_51_ena_ctrl = RTC_ADR_q == 6'b11_0011 & UHR_DS & (!nFB_WR);
   assign WERTE0_52_ena_ctrl = RTC_ADR_q == 6'b11_0100 & UHR_DS & (!nFB_WR);
   assign WERTE0_53_ena_ctrl = RTC_ADR_q == 6'b11_0101 & UHR_DS & (!nFB_WR);
   assign WERTE0_54_ena_ctrl = RTC_ADR_q == 6'b11_0110 & UHR_DS & (!nFB_WR);
   assign WERTE0_55_ena_ctrl = RTC_ADR_q == 6'b11_0111 & UHR_DS & (!nFB_WR);
   assign WERTE0_56_ena_ctrl = RTC_ADR_q == 6'b11_1000 & UHR_DS & (!nFB_WR);
   assign WERTE0_57_ena_ctrl = RTC_ADR_q == 6'b11_1001 & UHR_DS & (!nFB_WR);
   assign WERTE0_58_ena_ctrl = RTC_ADR_q == 6'b11_1010 & UHR_DS & (!nFB_WR);
   assign WERTE0_59_ena_ctrl = RTC_ADR_q == 6'b11_1011 & UHR_DS & (!nFB_WR);
   assign WERTE0_60_ena_ctrl = RTC_ADR_q == 6'b11_1100 & UHR_DS & (!nFB_WR);
   assign WERTE0_61_ena_ctrl = RTC_ADR_q == 6'b11_1101 & UHR_DS & (!nFB_WR);
   assign WERTE0_62_ena_ctrl = RTC_ADR_q == 6'b11_1110 & UHR_DS & (!nFB_WR);
   assign WERTE0_63_ena_ctrl = RTC_ADR_q == 6'b11_1111 & UHR_DS & (!nFB_WR);
   assign PIC_INT_SYNC0_clk_ctrl = MAIN_CLK;
   assign PIC_INT_SYNC_d[0] = PIC_INT;
   assign PIC_INT_SYNC_d[1] = PIC_INT_SYNC_q[0];
   assign PIC_INT_SYNC_d[2] = (!PIC_INT_SYNC_q[1]) & PIC_INT_SYNC_q[0];
   assign UPDATE_ON_1 = !WERTE7__q[11];

//  KEIN UIP
   assign WERTE6_10_clrn = gnd;

//  UPDATE ON OFF
   assign UPDATE_ON_2 = !WERTE7__q[11];

//  IMMER BINARY
   assign WERTE2_11_d_2 = vcc;

//  IMMER 24H FORMAT
   assign WERTE1_11_d_2 = vcc;

//  IMMER SOMMERZEITKORREKTUR
   assign WERTE0_11_d_2 = vcc;

//  IMMER RICHTIG
   assign WERTE7_13_d_2 = vcc;

//  SOMMER WINTERZEIT: BIT 0 IM REGISTER D IST DIE INFORMATION OB SOMMERZEIT IST (BRAUCHT MAN FÜR RÜCKSCHALTUNG)
// LETZTER SONNTAG IM APRIL
   assign SOMMERZEIT = {WERTE7__q[6], WERTE6__q[6], WERTE5__q[6], WERTE4__q[6],
	 WERTE3__q[6], WERTE2__q[6], WERTE1__q[6], WERTE0__q[6]} ==
	 8'b0000_0001 & {WERTE7__q[4], WERTE6__q[4], WERTE5__q[4],
	 WERTE4__q[4], WERTE3__q[4], WERTE2__q[4], WERTE1__q[4], WERTE0__q[4]}
	 == 8'b0000_0001 & {WERTE7__q[8], WERTE6__q[8], WERTE5__q[8],
	 WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]}
	 == 8'b0000_0100 & {WERTE7__q[7], WERTE6__q[7], WERTE5__q[7],
	 WERTE4__q[7], WERTE3__q[7], WERTE2__q[7], WERTE1__q[7], WERTE0__q[7]}
	 > 8'b0001_0111;
   assign WERTE0_13_d_2 = SOMMERZEIT;
   assign WERTE0_13_ena_2 = INC_STD & (SOMMERZEIT | WINTERZEIT);

// LETZTER SONNTAG IM OKTOBER
   assign WINTERZEIT = {WERTE7__q[6], WERTE6__q[6], WERTE5__q[6], WERTE4__q[6],
	 WERTE3__q[6], WERTE2__q[6], WERTE1__q[6], WERTE0__q[6]} ==
	 8'b0000_0001 & {WERTE7__q[4], WERTE6__q[4], WERTE5__q[4],
	 WERTE4__q[4], WERTE3__q[4], WERTE2__q[4], WERTE1__q[4], WERTE0__q[4]}
	 == 8'b0000_0001 & {WERTE7__q[8], WERTE6__q[8], WERTE5__q[8],
	 WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]}
	 == 8'b0000_1010 & {WERTE7__q[7], WERTE6__q[7], WERTE5__q[7],
	 WERTE4__q[7], WERTE3__q[7], WERTE2__q[7], WERTE1__q[7], WERTE0__q[7]}
	 > 8'b0001_1000 & WERTE0__q[13];

//  ACHTELSEKUNDEN
   assign ACHTELSEKUNDEN0_clk_ctrl = MAIN_CLK;
   assign ACHTELSEKUNDEN_d = ACHTELSEKUNDEN_q + 3'b001;
   assign ACHTELSEKUNDEN0_ena_ctrl = PIC_INT_SYNC_q[2] & UPDATE_ON;

//  SEKUNDEN
   assign INC_SEC = ACHTELSEKUNDEN_q == 3'b111 & PIC_INT_SYNC_q[2] & UPDATE_ON;

//  SEKUNDEN ZÄHLEN BIS 59
   assign {WERTE7_0_d_2, WERTE6_0_d_2, WERTE5_0_d_2, WERTE4_0_d_2,
	 WERTE3_0_d_2, WERTE2_0_d_2, WERTE1_0_d_2, WERTE0_0_d_2} =
	 ({WERTE7__q[0], WERTE6__q[0], WERTE5__q[0], WERTE4__q[0],
	 WERTE3__q[0], WERTE2__q[0], WERTE1__q[0], WERTE0__q[0]} +
	 8'b0000_0001) & {8{{WERTE7__q[0], WERTE6__q[0], WERTE5__q[0],
	 WERTE4__q[0], WERTE3__q[0], WERTE2__q[0], WERTE1__q[0], WERTE0__q[0]}
	 != 8'b0011_1011}} & (~({8{RTC_ADR_q == 6'b00_0000}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));
   assign {WERTE7_0_ena_2, WERTE6_0_ena_2, WERTE5_0_ena_2, WERTE4_0_ena_2,
	 WERTE3_0_ena_2, WERTE2_0_ena_2, WERTE1_0_ena_2, WERTE0_0_ena_2} =
	 {8{INC_SEC}} & (~({8{RTC_ADR_q == 6'b00_0000}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));

//  MINUTEN
   assign INC_MIN = INC_SEC & {WERTE7__q[0], WERTE6__q[0], WERTE5__q[0],
	 WERTE4__q[0], WERTE3__q[0], WERTE2__q[0], WERTE1__q[0], WERTE0__q[0]}
	 == 8'b0011_1011;

//  MINUTEN ZÄHLEN BIS 59
   assign {WERTE7_2_d_2, WERTE6_2_d_2, WERTE5_2_d_2, WERTE4_2_d_2,
	 WERTE3_2_d_2, WERTE2_2_d_2, WERTE1_2_d_2, WERTE0_2_d_2} =
	 ({WERTE7__q[2], WERTE6__q[2], WERTE5__q[2], WERTE4__q[2],
	 WERTE3__q[2], WERTE2__q[2], WERTE1__q[2], WERTE0__q[2]} +
	 8'b0000_0001) & {8{{WERTE7__q[2], WERTE6__q[2], WERTE5__q[2],
	 WERTE4__q[2], WERTE3__q[2], WERTE2__q[2], WERTE1__q[2], WERTE0__q[2]}
	 != 8'b0011_1011}} & (~({8{RTC_ADR_q == 6'b00_0010}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));
   assign {WERTE7_2_ena_2, WERTE6_2_ena_2, WERTE5_2_ena_2, WERTE4_2_ena_2,
	 WERTE3_2_ena_2, WERTE2_2_ena_2, WERTE1_2_ena_2, WERTE0_2_ena_2} =
	 {8{INC_MIN}} & (~({8{RTC_ADR_q == 6'b00_0010}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));

//  STUNDEN
   assign INC_STD = INC_MIN & {WERTE7__q[2], WERTE6__q[2], WERTE5__q[2],
	 WERTE4__q[2], WERTE3__q[2], WERTE2__q[2], WERTE1__q[2], WERTE0__q[2]}
	 == 8'b0011_1011;

//  STUNDEN ZÄHLEN BIS 23
   assign {WERTE7_4_d_2, WERTE6_4_d_2, WERTE5_4_d_2, WERTE4_4_d_2,
	 WERTE3_4_d_2, WERTE2_4_d_2, WERTE1_4_d_2, WERTE0_4_d_2} =
	 (({WERTE7__q[4], WERTE6__q[4], WERTE5__q[4], WERTE4__q[4],
	 WERTE3__q[4], WERTE2__q[4], WERTE1__q[4], WERTE0__q[4]} +
	 8'b0000_0001) + (8'b0000_0001 & {8{SOMMERZEIT}})) & {8{{WERTE7__q[4],
	 WERTE6__q[4], WERTE5__q[4], WERTE4__q[4], WERTE3__q[4], WERTE2__q[4],
	 WERTE1__q[4], WERTE0__q[4]} != 8'b0001_0111}} & (~({8{RTC_ADR_q ==
	 6'b00_0100}} & {8{UHR_DS}} & {8{!nFB_WR}}));

//  EINE STUNDE AUSLASSEN WENN WINTERZEITUMSCHALTUNG UND NOCH SOMMERZEIT
   assign {WERTE7_4_ena_2, WERTE6_4_ena_2, WERTE5_4_ena_2, WERTE4_4_ena_2,
	 WERTE3_4_ena_2, WERTE2_4_ena_2, WERTE1_4_ena_2, WERTE0_4_ena_2} =
	 {8{INC_STD}} & (~({8{WINTERZEIT}} & {8{WERTE0__q[12]}})) &
	 (~({8{RTC_ADR_q == 6'b00_0100}} & {8{UHR_DS}} & {8{!nFB_WR}}));

//  WOCHENTAG UND TAG
   assign INC_TAG = INC_STD & {WERTE7__q[2], WERTE6__q[2], WERTE5__q[2],
	 WERTE4__q[2], WERTE3__q[2], WERTE2__q[2], WERTE1__q[2], WERTE0__q[2]}
	 == 8'b0001_0111;

//  WOCHENTAG ZÄHLEN BIS 7
//  DANN BEI 1 WEITER
   assign {WERTE7_6_d_2, WERTE6_6_d_2, WERTE5_6_d_2, WERTE4_6_d_2,
	 WERTE3_6_d_2, WERTE2_6_d_2, WERTE1_6_d_2, WERTE0_6_d_2} =
	 (({WERTE7__q[6], WERTE6__q[6], WERTE5__q[6], WERTE4__q[6],
	 WERTE3__q[6], WERTE2__q[6], WERTE1__q[6], WERTE0__q[6]} +
	 8'b0000_0001) & {8{{WERTE7__q[6], WERTE6__q[6], WERTE5__q[6],
	 WERTE4__q[6], WERTE3__q[6], WERTE2__q[6], WERTE1__q[6], WERTE0__q[6]}
	 != 8'b0000_0111}} & (~({8{RTC_ADR_q == 6'b00_0110}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}))) | (8'b0000_0001 & {8{{WERTE7__q[6], WERTE6__q[6],
	 WERTE5__q[6], WERTE4__q[6], WERTE3__q[6], WERTE2__q[6], WERTE1__q[6],
	 WERTE0__q[6]} == 8'b0000_0111}} & (~({8{RTC_ADR_q == 6'b00_0110}} &
	 {8{UHR_DS}} & {8{!nFB_WR}})));
   assign {WERTE7_6_ena_2, WERTE6_6_ena_2, WERTE5_6_ena_2, WERTE4_6_ena_2,
	 WERTE3_6_ena_2, WERTE2_6_ena_2, WERTE1_6_ena_2, WERTE0_6_ena_2} =
	 {8{INC_TAG}} & (~({8{RTC_ADR_q == 6'b00_0110}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));
   assign ANZAHL_TAGE_DES_MONATS = (8'b0001_1111 & ({8{{WERTE7__q[8],
	 WERTE6__q[8], WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8],
	 WERTE1__q[8], WERTE0__q[8]} == 8'b0000_0001}} | {8{{WERTE7__q[8],
	 WERTE6__q[8], WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8],
	 WERTE1__q[8], WERTE0__q[8]} == 8'b0000_0011}} | {8{{WERTE7__q[8],
	 WERTE6__q[8], WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8],
	 WERTE1__q[8], WERTE0__q[8]} == 8'b0000_0101}} | {8{{WERTE7__q[8],
	 WERTE6__q[8], WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8],
	 WERTE1__q[8], WERTE0__q[8]} == 8'b0000_0111}} | {8{{WERTE7__q[8],
	 WERTE6__q[8], WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8],
	 WERTE1__q[8], WERTE0__q[8]} == 8'b0000_1000}} | {8{{WERTE7__q[8],
	 WERTE6__q[8], WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8],
	 WERTE1__q[8], WERTE0__q[8]} == 8'b0000_1010}} | {8{{WERTE7__q[8],
	 WERTE6__q[8], WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8],
	 WERTE1__q[8], WERTE0__q[8]} == 8'b0000_1100}})) | (8'b0001_1110 &
	 ({8{{WERTE7__q[8], WERTE6__q[8], WERTE5__q[8], WERTE4__q[8],
	 WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]} ==
	 8'b0000_0100}} | {8{{WERTE7__q[8], WERTE6__q[8], WERTE5__q[8],
	 WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]}
	 == 8'b0000_0110}} | {8{{WERTE7__q[8], WERTE6__q[8], WERTE5__q[8],
	 WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]}
	 == 8'b0000_1001}} | {8{{WERTE7__q[8], WERTE6__q[8], WERTE5__q[8],
	 WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]}
	 == 8'b0000_1011}})) | (8'b0001_1101 & {8{{WERTE7__q[8], WERTE6__q[8],
	 WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8],
	 WERTE0__q[8]} == 8'b0000_0010}} & {8{{WERTE1__q[9], WERTE0__q[9]} ==
	 2'b00}}) | (8'b0001_1100 & {8{{WERTE7__q[8], WERTE6__q[8],
	 WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8],
	 WERTE0__q[8]} == 8'b0000_0010}} & {8{{WERTE1__q[9], WERTE0__q[9]} !=
	 2'b00}});

//  TAG ZÄHLEN BIS MONATSENDE
//  DANN BEI 1 WEITER
   assign {WERTE7_7_d_2, WERTE6_7_d_2, WERTE5_7_d_2, WERTE4_7_d_2,
	 WERTE3_7_d_2, WERTE2_7_d_2, WERTE1_7_d_2, WERTE0_7_d_2} =
	 (({WERTE7__q[7], WERTE6__q[7], WERTE5__q[7], WERTE4__q[7],
	 WERTE3__q[7], WERTE2__q[7], WERTE1__q[7], WERTE0__q[7]} +
	 8'b0000_0001) & {8{{WERTE7__q[7], WERTE6__q[7], WERTE5__q[7],
	 WERTE4__q[7], WERTE3__q[7], WERTE2__q[7], WERTE1__q[7], WERTE0__q[7]}
	 != ANZAHL_TAGE_DES_MONATS}} & (~({8{RTC_ADR_q == 6'b00_0111}} &
	 {8{UHR_DS}} & {8{!nFB_WR}}))) | (8'b0000_0001 & {8{{WERTE7__q[7],
	 WERTE6__q[7], WERTE5__q[7], WERTE4__q[7], WERTE3__q[7], WERTE2__q[7],
	 WERTE1__q[7], WERTE0__q[7]} == ANZAHL_TAGE_DES_MONATS}} &
	 (~({8{RTC_ADR_q == 6'b00_0111}} & {8{UHR_DS}} & {8{!nFB_WR}})));
   assign {WERTE7_7_ena_2, WERTE6_7_ena_2, WERTE5_7_ena_2, WERTE4_7_ena_2,
	 WERTE3_7_ena_2, WERTE2_7_ena_2, WERTE1_7_ena_2, WERTE0_7_ena_2} =
	 {8{INC_TAG}} & (~({8{RTC_ADR_q == 6'b00_0111}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));

//  MONATE
   assign INC_MONAT = INC_TAG & {WERTE7__q[7], WERTE6__q[7], WERTE5__q[7],
	 WERTE4__q[7], WERTE3__q[7], WERTE2__q[7], WERTE1__q[7], WERTE0__q[7]}
	 == ANZAHL_TAGE_DES_MONATS;

//  MONATE ZÄHLEN BIS 12
//  DANN BEI 1 WEITER
   assign {WERTE7_8_d_2, WERTE6_8_d_2, WERTE5_8_d_2, WERTE4_8_d_2,
	 WERTE3_8_d_2, WERTE2_8_d_2, WERTE1_8_d_2, WERTE0_8_d_2} =
	 (({WERTE7__q[8], WERTE6__q[8], WERTE5__q[8], WERTE4__q[8],
	 WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]} +
	 8'b0000_0001) & {8{{WERTE7__q[8], WERTE6__q[8], WERTE5__q[8],
	 WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]}
	 != 8'b0000_1100}} & (~({8{RTC_ADR_q == 6'b00_1000}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}))) | (8'b0000_0001 & {8{{WERTE7__q[8], WERTE6__q[8],
	 WERTE5__q[8], WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8],
	 WERTE0__q[8]} == 8'b0000_1100}} & (~({8{RTC_ADR_q == 6'b00_1000}} &
	 {8{UHR_DS}} & {8{!nFB_WR}})));
   assign {WERTE7_8_ena_2, WERTE6_8_ena_2, WERTE5_8_ena_2, WERTE4_8_ena_2,
	 WERTE3_8_ena_2, WERTE2_8_ena_2, WERTE1_8_ena_2, WERTE0_8_ena_2} =
	 {8{INC_MONAT}} & (~({8{RTC_ADR_q == 6'b00_1000}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));

//  JAHR
   assign INC_JAHR = INC_MONAT & {WERTE7__q[8], WERTE6__q[8], WERTE5__q[8],
	 WERTE4__q[8], WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]}
	 == 8'b0000_1100;

//  JAHRE ZÄHLEN BIS 99
   assign {WERTE7_9_d_2, WERTE6_9_d_2, WERTE5_9_d_2, WERTE4_9_d_2,
	 WERTE3_9_d_2, WERTE2_9_d_2, WERTE1_9_d_2, WERTE0_9_d_2} =
	 ({WERTE7__q[9], WERTE6__q[9], WERTE5__q[9], WERTE4__q[9],
	 WERTE3__q[9], WERTE2__q[9], WERTE1__q[9], WERTE0__q[9]} +
	 8'b0000_0001) & {8{{WERTE7__q[9], WERTE6__q[9], WERTE5__q[9],
	 WERTE4__q[9], WERTE3__q[9], WERTE2__q[9], WERTE1__q[9], WERTE0__q[9]}
	 != 8'b0110_0011}} & (~({8{RTC_ADR_q == 6'b00_1001}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));
   assign {WERTE7_9_ena_2, WERTE6_9_ena_2, WERTE5_9_ena_2, WERTE4_9_ena_2,
	 WERTE3_9_ena_2, WERTE2_9_ena_2, WERTE1_9_ena_2, WERTE0_9_ena_2} =
	 {8{INC_JAHR}} & (~({8{RTC_ADR_q == 6'b00_1001}} & {8{UHR_DS}} &
	 {8{!nFB_WR}}));

//  TRISTATE OUTPUT
   assign u0_data = ({8{INT_CTR_CS}} & INT_CTR_q[31:24]) | ({8{INT_ENA_CS}} &
	 INT_ENA_q[31:24]) | ({8{INT_LATCH_CS}} & INT_LATCH_q[31:24]) |
	 ({8{INT_CLEAR_CS}} & INT_IN[31:24]) | ({8{ACP_CONF_CS}} &
	 ACP_CONF_q[31:24]);
   assign u0_enabledt = (INT_CTR_CS | INT_ENA_CS | INT_LATCH_CS | INT_CLEAR_CS
	 | ACP_CONF_CS) & (!nFB_OE);
   assign FB_AD[31:24] = u0_tridata;
   assign u1_data = ({WERTE7__q[0], WERTE6__q[0], WERTE5__q[0], WERTE4__q[0],
	 WERTE3__q[0], WERTE2__q[0], WERTE1__q[0], WERTE0__q[0]} & {8{RTC_ADR_q
	 == 6'b00_0000}} & {8{UHR_DS}}) | ({WERTE7__q[1], WERTE6__q[1],
	 WERTE5__q[1], WERTE4__q[1], WERTE3__q[1], WERTE2__q[1], WERTE1__q[1],
	 WERTE0__q[1]} & {8{RTC_ADR_q == 6'b00_0001}} & {8{UHR_DS}}) |
	 ({WERTE7__q[2], WERTE6__q[2], WERTE5__q[2], WERTE4__q[2],
	 WERTE3__q[2], WERTE2__q[2], WERTE1__q[2], WERTE0__q[2]} & {8{RTC_ADR_q
	 == 6'b00_0010}} & {8{UHR_DS}}) | ({WERTE7__q[3], WERTE6__q[3],
	 WERTE5__q[3], WERTE4__q[3], WERTE3__q[3], WERTE2__q[3], WERTE1__q[3],
	 WERTE0__q[3]} & {8{RTC_ADR_q == 6'b00_0011}} & {8{UHR_DS}}) |
	 ({WERTE7__q[4], WERTE6__q[4], WERTE5__q[4], WERTE4__q[4],
	 WERTE3__q[4], WERTE2__q[4], WERTE1__q[4], WERTE0__q[4]} & {8{RTC_ADR_q
	 == 6'b00_0100}} & {8{UHR_DS}}) | ({WERTE7__q[5], WERTE6__q[5],
	 WERTE5__q[5], WERTE4__q[5], WERTE3__q[5], WERTE2__q[5], WERTE1__q[5],
	 WERTE0__q[5]} & {8{RTC_ADR_q == 6'b00_0101}} & {8{UHR_DS}}) |
	 ({WERTE7__q[6], WERTE6__q[6], WERTE5__q[6], WERTE4__q[6],
	 WERTE3__q[6], WERTE2__q[6], WERTE1__q[6], WERTE0__q[6]} & {8{RTC_ADR_q
	 == 6'b00_0110}} & {8{UHR_DS}}) | ({WERTE7__q[7], WERTE6__q[7],
	 WERTE5__q[7], WERTE4__q[7], WERTE3__q[7], WERTE2__q[7], WERTE1__q[7],
	 WERTE0__q[7]} & {8{RTC_ADR_q == 6'b00_0111}} & {8{UHR_DS}}) |
	 ({WERTE7__q[8], WERTE6__q[8], WERTE5__q[8], WERTE4__q[8],
	 WERTE3__q[8], WERTE2__q[8], WERTE1__q[8], WERTE0__q[8]} & {8{RTC_ADR_q
	 == 6'b00_1000}} & {8{UHR_DS}}) | ({WERTE7__q[9], WERTE6__q[9],
	 WERTE5__q[9], WERTE4__q[9], WERTE3__q[9], WERTE2__q[9], WERTE1__q[9],
	 WERTE0__q[9]} & {8{RTC_ADR_q == 6'b00_1001}} & {8{UHR_DS}}) |
	 ({WERTE7__q[10], WERTE6__q[10], WERTE5__q[10], WERTE4__q[10],
	 WERTE3__q[10], WERTE2__q[10], WERTE1__q[10], WERTE0__q[10]} &
	 {8{RTC_ADR_q == 6'b00_1010}} & {8{UHR_DS}}) | ({WERTE7__q[11],
	 WERTE6__q[11], WERTE5__q[11], WERTE4__q[11], WERTE3__q[11],
	 WERTE2__q[11], WERTE1__q[11], WERTE0__q[11]} & {8{RTC_ADR_q ==
	 6'b00_1011}} & {8{UHR_DS}}) | ({WERTE7__q[12], WERTE6__q[12],
	 WERTE5__q[12], WERTE4__q[12], WERTE3__q[12], WERTE2__q[12],
	 WERTE1__q[12], WERTE0__q[12]} & {8{RTC_ADR_q == 6'b00_1100}} &
	 {8{UHR_DS}}) | ({WERTE7__q[13], WERTE6__q[13], WERTE5__q[13],
	 WERTE4__q[13], WERTE3__q[13], WERTE2__q[13], WERTE1__q[13],
	 WERTE0__q[13]} & {8{RTC_ADR_q == 6'b00_1101}} & {8{UHR_DS}}) |
	 ({WERTE7__q[14], WERTE6__q[14], WERTE5__q[14], WERTE4__q[14],
	 WERTE3__q[14], WERTE2__q[14], WERTE1__q[14], WERTE0__q[14]} &
	 {8{RTC_ADR_q == 6'b00_1110}} & {8{UHR_DS}}) | ({WERTE7__q[15],
	 WERTE6__q[15], WERTE5__q[15], WERTE4__q[15], WERTE3__q[15],
	 WERTE2__q[15], WERTE1__q[15], WERTE0__q[15]} & {8{RTC_ADR_q ==
	 6'b00_1111}} & {8{UHR_DS}}) | ({WERTE7__q[16], WERTE6__q[16],
	 WERTE5__q[16], WERTE4__q[16], WERTE3__q[16], WERTE2__q[16],
	 WERTE1__q[16], WERTE0__q[16]} & {8{RTC_ADR_q == 6'b01_0000}} &
	 {8{UHR_DS}}) | ({WERTE7__q[17], WERTE6__q[17], WERTE5__q[17],
	 WERTE4__q[17], WERTE3__q[17], WERTE2__q[17], WERTE1__q[17],
	 WERTE0__q[17]} & {8{RTC_ADR_q == 6'b01_0001}} & {8{UHR_DS}}) |
	 ({WERTE7__q[18], WERTE6__q[18], WERTE5__q[18], WERTE4__q[18],
	 WERTE3__q[18], WERTE2__q[18], WERTE1__q[18], WERTE0__q[18]} &
	 {8{RTC_ADR_q == 6'b01_0010}} & {8{UHR_DS}}) | ({WERTE7__q[19],
	 WERTE6__q[19], WERTE5__q[19], WERTE4__q[19], WERTE3__q[19],
	 WERTE2__q[19], WERTE1__q[19], WERTE0__q[19]} & {8{RTC_ADR_q ==
	 6'b01_0011}} & {8{UHR_DS}}) | ({WERTE7__q[20], WERTE6__q[20],
	 WERTE5__q[20], WERTE4__q[20], WERTE3__q[20], WERTE2__q[20],
	 WERTE1__q[20], WERTE0__q[20]} & {8{RTC_ADR_q == 6'b01_0100}} &
	 {8{UHR_DS}}) | ({WERTE7__q[21], WERTE6__q[21], WERTE5__q[21],
	 WERTE4__q[21], WERTE3__q[21], WERTE2__q[21], WERTE1__q[21],
	 WERTE0__q[21]} & {8{RTC_ADR_q == 6'b01_0101}} & {8{UHR_DS}}) |
	 ({WERTE7__q[22], WERTE6__q[22], WERTE5__q[22], WERTE4__q[22],
	 WERTE3__q[22], WERTE2__q[22], WERTE1__q[22], WERTE0__q[22]} &
	 {8{RTC_ADR_q == 6'b01_0110}} & {8{UHR_DS}}) | ({WERTE7__q[23],
	 WERTE6__q[23], WERTE5__q[23], WERTE4__q[23], WERTE3__q[23],
	 WERTE2__q[23], WERTE1__q[23], WERTE0__q[23]} & {8{RTC_ADR_q ==
	 6'b01_0111}} & {8{UHR_DS}}) | ({WERTE7__q[24], WERTE6__q[24],
	 WERTE5__q[24], WERTE4__q[24], WERTE3__q[24], WERTE2__q[24],
	 WERTE1__q[24], WERTE0__q[24]} & {8{RTC_ADR_q == 6'b01_1000}} &
	 {8{UHR_DS}}) | ({WERTE7__q[25], WERTE6__q[25], WERTE5__q[25],
	 WERTE4__q[25], WERTE3__q[25], WERTE2__q[25], WERTE1__q[25],
	 WERTE0__q[25]} & {8{RTC_ADR_q == 6'b01_1001}} & {8{UHR_DS}}) |
	 ({WERTE7__q[26], WERTE6__q[26], WERTE5__q[26], WERTE4__q[26],
	 WERTE3__q[26], WERTE2__q[26], WERTE1__q[26], WERTE0__q[26]} &
	 {8{RTC_ADR_q == 6'b01_1010}} & {8{UHR_DS}}) | ({WERTE7__q[27],
	 WERTE6__q[27], WERTE5__q[27], WERTE4__q[27], WERTE3__q[27],
	 WERTE2__q[27], WERTE1__q[27], WERTE0__q[27]} & {8{RTC_ADR_q ==
	 6'b01_1011}} & {8{UHR_DS}}) | ({WERTE7__q[28], WERTE6__q[28],
	 WERTE5__q[28], WERTE4__q[28], WERTE3__q[28], WERTE2__q[28],
	 WERTE1__q[28], WERTE0__q[28]} & {8{RTC_ADR_q == 6'b01_1100}} &
	 {8{UHR_DS}}) | ({WERTE7__q[29], WERTE6__q[29], WERTE5__q[29],
	 WERTE4__q[29], WERTE3__q[29], WERTE2__q[29], WERTE1__q[29],
	 WERTE0__q[29]} & {8{RTC_ADR_q == 6'b01_1101}} & {8{UHR_DS}}) |
	 ({WERTE7__q[30], WERTE6__q[30], WERTE5__q[30], WERTE4__q[30],
	 WERTE3__q[30], WERTE2__q[30], WERTE1__q[30], WERTE0__q[30]} &
	 {8{RTC_ADR_q == 6'b01_1110}} & {8{UHR_DS}}) | ({WERTE7__q[31],
	 WERTE6__q[31], WERTE5__q[31], WERTE4__q[31], WERTE3__q[31],
	 WERTE2__q[31], WERTE1__q[31], WERTE0__q[31]} & {8{RTC_ADR_q ==
	 6'b01_1111}} & {8{UHR_DS}}) | ({WERTE7__q[32], WERTE6__q[32],
	 WERTE5__q[32], WERTE4__q[32], WERTE3__q[32], WERTE2__q[32],
	 WERTE1__q[32], WERTE0__q[32]} & {8{RTC_ADR_q == 6'b10_0000}} &
	 {8{UHR_DS}}) | ({WERTE7__q[33], WERTE6__q[33], WERTE5__q[33],
	 WERTE4__q[33], WERTE3__q[33], WERTE2__q[33], WERTE1__q[33],
	 WERTE0__q[33]} & {8{RTC_ADR_q == 6'b10_0001}} & {8{UHR_DS}}) |
	 ({WERTE7__q[34], WERTE6__q[34], WERTE5__q[34], WERTE4__q[34],
	 WERTE3__q[34], WERTE2__q[34], WERTE1__q[34], WERTE0__q[34]} &
	 {8{RTC_ADR_q == 6'b10_0010}} & {8{UHR_DS}}) | ({WERTE7__q[35],
	 WERTE6__q[35], WERTE5__q[35], WERTE4__q[35], WERTE3__q[35],
	 WERTE2__q[35], WERTE1__q[35], WERTE0__q[35]} & {8{RTC_ADR_q ==
	 6'b10_0011}} & {8{UHR_DS}}) | ({WERTE7__q[36], WERTE6__q[36],
	 WERTE5__q[36], WERTE4__q[36], WERTE3__q[36], WERTE2__q[36],
	 WERTE1__q[36], WERTE0__q[36]} & {8{RTC_ADR_q == 6'b10_0100}} &
	 {8{UHR_DS}}) | ({WERTE7__q[37], WERTE6__q[37], WERTE5__q[37],
	 WERTE4__q[37], WERTE3__q[37], WERTE2__q[37], WERTE1__q[37],
	 WERTE0__q[37]} & {8{RTC_ADR_q == 6'b10_0101}} & {8{UHR_DS}}) |
	 ({WERTE7__q[38], WERTE6__q[38], WERTE5__q[38], WERTE4__q[38],
	 WERTE3__q[38], WERTE2__q[38], WERTE1__q[38], WERTE0__q[38]} &
	 {8{RTC_ADR_q == 6'b10_0110}} & {8{UHR_DS}}) | ({WERTE7__q[39],
	 WERTE6__q[39], WERTE5__q[39], WERTE4__q[39], WERTE3__q[39],
	 WERTE2__q[39], WERTE1__q[39], WERTE0__q[39]} & {8{RTC_ADR_q ==
	 6'b10_0111}} & {8{UHR_DS}}) | ({WERTE7__q[40], WERTE6__q[40],
	 WERTE5__q[40], WERTE4__q[40], WERTE3__q[40], WERTE2__q[40],
	 WERTE1__q[40], WERTE0__q[40]} & {8{RTC_ADR_q == 6'b10_1000}} &
	 {8{UHR_DS}}) | ({WERTE7__q[41], WERTE6__q[41], WERTE5__q[41],
	 WERTE4__q[41], WERTE3__q[41], WERTE2__q[41], WERTE1__q[41],
	 WERTE0__q[41]} & {8{RTC_ADR_q == 6'b10_1001}} & {8{UHR_DS}}) |
	 ({WERTE7__q[42], WERTE6__q[42], WERTE5__q[42], WERTE4__q[42],
	 WERTE3__q[42], WERTE2__q[42], WERTE1__q[42], WERTE0__q[42]} &
	 {8{RTC_ADR_q == 6'b10_1010}} & {8{UHR_DS}}) | ({WERTE7__q[43],
	 WERTE6__q[43], WERTE5__q[43], WERTE4__q[43], WERTE3__q[43],
	 WERTE2__q[43], WERTE1__q[43], WERTE0__q[43]} & {8{RTC_ADR_q ==
	 6'b10_1011}} & {8{UHR_DS}}) | ({WERTE7__q[44], WERTE6__q[44],
	 WERTE5__q[44], WERTE4__q[44], WERTE3__q[44], WERTE2__q[44],
	 WERTE1__q[44], WERTE0__q[44]} & {8{RTC_ADR_q == 6'b10_1100}} &
	 {8{UHR_DS}}) | ({WERTE7__q[45], WERTE6__q[45], WERTE5__q[45],
	 WERTE4__q[45], WERTE3__q[45], WERTE2__q[45], WERTE1__q[45],
	 WERTE0__q[45]} & {8{RTC_ADR_q == 6'b10_1101}} & {8{UHR_DS}}) |
	 ({WERTE7__q[46], WERTE6__q[46], WERTE5__q[46], WERTE4__q[46],
	 WERTE3__q[46], WERTE2__q[46], WERTE1__q[46], WERTE0__q[46]} &
	 {8{RTC_ADR_q == 6'b10_1110}} & {8{UHR_DS}}) | ({WERTE7__q[47],
	 WERTE6__q[47], WERTE5__q[47], WERTE4__q[47], WERTE3__q[47],
	 WERTE2__q[47], WERTE1__q[47], WERTE0__q[47]} & {8{RTC_ADR_q ==
	 6'b10_1111}} & {8{UHR_DS}}) | ({WERTE7__q[48], WERTE6__q[48],
	 WERTE5__q[48], WERTE4__q[48], WERTE3__q[48], WERTE2__q[48],
	 WERTE1__q[48], WERTE0__q[48]} & {8{RTC_ADR_q == 6'b11_0000}} &
	 {8{UHR_DS}}) | ({WERTE7__q[49], WERTE6__q[49], WERTE5__q[49],
	 WERTE4__q[49], WERTE3__q[49], WERTE2__q[49], WERTE1__q[49],
	 WERTE0__q[49]} & {8{RTC_ADR_q == 6'b11_0001}} & {8{UHR_DS}}) |
	 ({WERTE7__q[50], WERTE6__q[50], WERTE5__q[50], WERTE4__q[50],
	 WERTE3__q[50], WERTE2__q[50], WERTE1__q[50], WERTE0__q[50]} &
	 {8{RTC_ADR_q == 6'b11_0010}} & {8{UHR_DS}}) | ({WERTE7__q[51],
	 WERTE6__q[51], WERTE5__q[51], WERTE4__q[51], WERTE3__q[51],
	 WERTE2__q[51], WERTE1__q[51], WERTE0__q[51]} & {8{RTC_ADR_q ==
	 6'b11_0011}} & {8{UHR_DS}}) | ({WERTE7__q[52], WERTE6__q[52],
	 WERTE5__q[52], WERTE4__q[52], WERTE3__q[52], WERTE2__q[52],
	 WERTE1__q[52], WERTE0__q[52]} & {8{RTC_ADR_q == 6'b11_0100}} &
	 {8{UHR_DS}}) | ({WERTE7__q[53], WERTE6__q[53], WERTE5__q[53],
	 WERTE4__q[53], WERTE3__q[53], WERTE2__q[53], WERTE1__q[53],
	 WERTE0__q[53]} & {8{RTC_ADR_q == 6'b11_0101}} & {8{UHR_DS}}) |
	 ({WERTE7__q[54], WERTE6__q[54], WERTE5__q[54], WERTE4__q[54],
	 WERTE3__q[54], WERTE2__q[54], WERTE1__q[54], WERTE0__q[54]} &
	 {8{RTC_ADR_q == 6'b11_0110}} & {8{UHR_DS}}) | ({WERTE7__q[55],
	 WERTE6__q[55], WERTE5__q[55], WERTE4__q[55], WERTE3__q[55],
	 WERTE2__q[55], WERTE1__q[55], WERTE0__q[55]} & {8{RTC_ADR_q ==
	 6'b11_0111}} & {8{UHR_DS}}) | ({WERTE7__q[56], WERTE6__q[56],
	 WERTE5__q[56], WERTE4__q[56], WERTE3__q[56], WERTE2__q[56],
	 WERTE1__q[56], WERTE0__q[56]} & {8{RTC_ADR_q == 6'b11_1000}} &
	 {8{UHR_DS}}) | ({WERTE7__q[57], WERTE6__q[57], WERTE5__q[57],
	 WERTE4__q[57], WERTE3__q[57], WERTE2__q[57], WERTE1__q[57],
	 WERTE0__q[57]} & {8{RTC_ADR_q == 6'b11_1001}} & {8{UHR_DS}}) |
	 ({WERTE7__q[58], WERTE6__q[58], WERTE5__q[58], WERTE4__q[58],
	 WERTE3__q[58], WERTE2__q[58], WERTE1__q[58], WERTE0__q[58]} &
	 {8{RTC_ADR_q == 6'b11_1010}} & {8{UHR_DS}}) | ({WERTE7__q[59],
	 WERTE6__q[59], WERTE5__q[59], WERTE4__q[59], WERTE3__q[59],
	 WERTE2__q[59], WERTE1__q[59], WERTE0__q[59]} & {8{RTC_ADR_q ==
	 6'b11_1011}} & {8{UHR_DS}}) | ({WERTE7__q[60], WERTE6__q[60],
	 WERTE5__q[60], WERTE4__q[60], WERTE3__q[60], WERTE2__q[60],
	 WERTE1__q[60], WERTE0__q[60]} & {8{RTC_ADR_q == 6'b11_1100}} &
	 {8{UHR_DS}}) | ({WERTE7__q[61], WERTE6__q[61], WERTE5__q[61],
	 WERTE4__q[61], WERTE3__q[61], WERTE2__q[61], WERTE1__q[61],
	 WERTE0__q[61]} & {8{RTC_ADR_q == 6'b11_1101}} & {8{UHR_DS}}) |
	 ({WERTE7__q[62], WERTE6__q[62], WERTE5__q[62], WERTE4__q[62],
	 WERTE3__q[62], WERTE2__q[62], WERTE1__q[62], WERTE0__q[62]} &
	 {8{RTC_ADR_q == 6'b11_1110}} & {8{UHR_DS}}) | ({WERTE7__q[63],
	 WERTE6__q[63], WERTE5__q[63], WERTE4__q[63], WERTE3__q[63],
	 WERTE2__q[63], WERTE1__q[63], WERTE0__q[63]} & {8{RTC_ADR_q ==
	 6'b11_1111}} & {8{UHR_DS}}) | ({2'b00, RTC_ADR_q} & {8{UHR_AS}}) |
	 ({8{INT_CTR_CS}} & INT_CTR_q[23:16]) | ({8{INT_ENA_CS}} &
	 INT_ENA_q[23:16]) | ({8{INT_LATCH_CS}} & INT_LATCH_q[23:16]) |
	 ({8{INT_CLEAR_CS}} & INT_IN[23:16]) | ({8{ACP_CONF_CS}} &
	 ACP_CONF_q[23:16]);
   assign u1_enabledt = (UHR_DS | UHR_AS | INT_CTR_CS | INT_ENA_CS |
	 INT_LATCH_CS | INT_CLEAR_CS | ACP_CONF_CS) & (!nFB_OE);
   assign FB_AD[23:16] = u1_tridata;
   assign u2_data = ({8{INT_CTR_CS}} & INT_CTR_q[15:8]) | ({8{INT_ENA_CS}} &
	 INT_ENA_q[15:8]) | ({8{INT_LATCH_CS}} & INT_LATCH_q[15:8]) |
	 ({8{INT_CLEAR_CS}} & INT_IN[15:8]) | ({8{ACP_CONF_CS}} &
	 ACP_CONF_q[15:8]);
   assign u2_enabledt = (INT_CTR_CS | INT_ENA_CS | INT_LATCH_CS | INT_CLEAR_CS
	 | ACP_CONF_CS) & (!nFB_OE);
   assign FB_AD[15:8] = u2_tridata;
   assign u3_data = ({8{INT_CTR_CS}} & INT_CTR_q[7:0]) | ({8{INT_ENA_CS}} &
	 INT_ENA_q[7:0]) | ({8{INT_LATCH_CS}} & INT_LATCH_q[7:0]) |
	 ({8{INT_CLEAR_CS}} & INT_IN[7:0]) | ({8{ACP_CONF_CS}} &
	 ACP_CONF_q[7:0]);
   assign u3_enabledt = (INT_CTR_CS | INT_ENA_CS | INT_LATCH_CS | INT_CLEAR_CS
	 | ACP_CONF_CS) & (!nFB_OE);
   assign FB_AD[7:0] = u3_tridata;
   assign INT_HANDLER_TA = INT_CTR_CS | INT_ENA_CS | INT_LATCH_CS |
	 INT_CLEAR_CS;


// Assignments added to explicitly combine the
// effects of multiple drivers in the source
   assign UPDATE_ON = UPDATE_ON_1 | UPDATE_ON_2;
   assign WERTE0_0_ena = WERTE0_0_ena_1 | WERTE0_0_ena_2;
   assign WERTE0_2_ena = WERTE0_2_ena_1 | WERTE0_2_ena_2;
   assign WERTE0_4_ena = WERTE0_4_ena_1 | WERTE0_4_ena_2;
   assign WERTE0_6_ena = WERTE0_6_ena_1 | WERTE0_6_ena_2;
   assign WERTE0_7_ena = WERTE0_7_ena_1 | WERTE0_7_ena_2;
   assign WERTE0_8_ena = WERTE0_8_ena_1 | WERTE0_8_ena_2;
   assign WERTE0_9_ena = WERTE0_9_ena_1 | WERTE0_9_ena_2;
   assign WERTE0_13_ena = WERTE0_13_ena_1 | WERTE0_13_ena_2;
   assign WERTE0__d[0] = WERTE0_0_d_1 | WERTE0_0_d_2;
   assign WERTE0__d[2] = WERTE0_2_d_1 | WERTE0_2_d_2;
   assign WERTE0__d[4] = WERTE0_4_d_1 | WERTE0_4_d_2;
   assign WERTE0__d[6] = WERTE0_6_d_1 | WERTE0_6_d_2;
   assign WERTE0__d[7] = WERTE0_7_d_1 | WERTE0_7_d_2;
   assign WERTE0__d[8] = WERTE0_8_d_1 | WERTE0_8_d_2;
   assign WERTE0__d[9] = WERTE0_9_d_1 | WERTE0_9_d_2;
   assign WERTE0__d[11] = WERTE0_11_d_1 | WERTE0_11_d_2;
   assign WERTE0__d[13] = WERTE0_13_d_1 | WERTE0_13_d_2;
   assign WERTE1_0_ena = WERTE1_0_ena_1 | WERTE1_0_ena_2;
   assign WERTE1_2_ena = WERTE1_2_ena_1 | WERTE1_2_ena_2;
   assign WERTE1_4_ena = WERTE1_4_ena_1 | WERTE1_4_ena_2;
   assign WERTE1_6_ena = WERTE1_6_ena_1 | WERTE1_6_ena_2;
   assign WERTE1_7_ena = WERTE1_7_ena_1 | WERTE1_7_ena_2;
   assign WERTE1_8_ena = WERTE1_8_ena_1 | WERTE1_8_ena_2;
   assign WERTE1_9_ena = WERTE1_9_ena_1 | WERTE1_9_ena_2;
   assign WERTE1__d[0] = WERTE1_0_d_1 | WERTE1_0_d_2;
   assign WERTE1__d[2] = WERTE1_2_d_1 | WERTE1_2_d_2;
   assign WERTE1__d[4] = WERTE1_4_d_1 | WERTE1_4_d_2;
   assign WERTE1__d[6] = WERTE1_6_d_1 | WERTE1_6_d_2;
   assign WERTE1__d[7] = WERTE1_7_d_1 | WERTE1_7_d_2;
   assign WERTE1__d[8] = WERTE1_8_d_1 | WERTE1_8_d_2;
   assign WERTE1__d[9] = WERTE1_9_d_1 | WERTE1_9_d_2;
   assign WERTE1__d[11] = WERTE1_11_d_1 | WERTE1_11_d_2;
   assign WERTE2_0_ena = WERTE2_0_ena_1 | WERTE2_0_ena_2;
   assign WERTE2_2_ena = WERTE2_2_ena_1 | WERTE2_2_ena_2;
   assign WERTE2_4_ena = WERTE2_4_ena_1 | WERTE2_4_ena_2;
   assign WERTE2_6_ena = WERTE2_6_ena_1 | WERTE2_6_ena_2;
   assign WERTE2_7_ena = WERTE2_7_ena_1 | WERTE2_7_ena_2;
   assign WERTE2_8_ena = WERTE2_8_ena_1 | WERTE2_8_ena_2;
   assign WERTE2_9_ena = WERTE2_9_ena_1 | WERTE2_9_ena_2;
   assign WERTE2__d[0] = WERTE2_0_d_1 | WERTE2_0_d_2;
   assign WERTE2__d[2] = WERTE2_2_d_1 | WERTE2_2_d_2;
   assign WERTE2__d[4] = WERTE2_4_d_1 | WERTE2_4_d_2;
   assign WERTE2__d[6] = WERTE2_6_d_1 | WERTE2_6_d_2;
   assign WERTE2__d[7] = WERTE2_7_d_1 | WERTE2_7_d_2;
   assign WERTE2__d[8] = WERTE2_8_d_1 | WERTE2_8_d_2;
   assign WERTE2__d[9] = WERTE2_9_d_1 | WERTE2_9_d_2;
   assign WERTE2__d[11] = WERTE2_11_d_1 | WERTE2_11_d_2;
   assign WERTE3_0_ena = WERTE3_0_ena_1 | WERTE3_0_ena_2;
   assign WERTE3_2_ena = WERTE3_2_ena_1 | WERTE3_2_ena_2;
   assign WERTE3_4_ena = WERTE3_4_ena_1 | WERTE3_4_ena_2;
   assign WERTE3_6_ena = WERTE3_6_ena_1 | WERTE3_6_ena_2;
   assign WERTE3_7_ena = WERTE3_7_ena_1 | WERTE3_7_ena_2;
   assign WERTE3_8_ena = WERTE3_8_ena_1 | WERTE3_8_ena_2;
   assign WERTE3_9_ena = WERTE3_9_ena_1 | WERTE3_9_ena_2;
   assign WERTE3__d[0] = WERTE3_0_d_1 | WERTE3_0_d_2;
   assign WERTE3__d[2] = WERTE3_2_d_1 | WERTE3_2_d_2;
   assign WERTE3__d[4] = WERTE3_4_d_1 | WERTE3_4_d_2;
   assign WERTE3__d[6] = WERTE3_6_d_1 | WERTE3_6_d_2;
   assign WERTE3__d[7] = WERTE3_7_d_1 | WERTE3_7_d_2;
   assign WERTE3__d[8] = WERTE3_8_d_1 | WERTE3_8_d_2;
   assign WERTE3__d[9] = WERTE3_9_d_1 | WERTE3_9_d_2;
   assign WERTE4_0_ena = WERTE4_0_ena_1 | WERTE4_0_ena_2;
   assign WERTE4_2_ena = WERTE4_2_ena_1 | WERTE4_2_ena_2;
   assign WERTE4_4_ena = WERTE4_4_ena_1 | WERTE4_4_ena_2;
   assign WERTE4_6_ena = WERTE4_6_ena_1 | WERTE4_6_ena_2;
   assign WERTE4_7_ena = WERTE4_7_ena_1 | WERTE4_7_ena_2;
   assign WERTE4_8_ena = WERTE4_8_ena_1 | WERTE4_8_ena_2;
   assign WERTE4_9_ena = WERTE4_9_ena_1 | WERTE4_9_ena_2;
   assign WERTE4__d[0] = WERTE4_0_d_1 | WERTE4_0_d_2;
   assign WERTE4__d[2] = WERTE4_2_d_1 | WERTE4_2_d_2;
   assign WERTE4__d[4] = WERTE4_4_d_1 | WERTE4_4_d_2;
   assign WERTE4__d[6] = WERTE4_6_d_1 | WERTE4_6_d_2;
   assign WERTE4__d[7] = WERTE4_7_d_1 | WERTE4_7_d_2;
   assign WERTE4__d[8] = WERTE4_8_d_1 | WERTE4_8_d_2;
   assign WERTE4__d[9] = WERTE4_9_d_1 | WERTE4_9_d_2;
   assign WERTE5_0_ena = WERTE5_0_ena_1 | WERTE5_0_ena_2;
   assign WERTE5_2_ena = WERTE5_2_ena_1 | WERTE5_2_ena_2;
   assign WERTE5_4_ena = WERTE5_4_ena_1 | WERTE5_4_ena_2;
   assign WERTE5_6_ena = WERTE5_6_ena_1 | WERTE5_6_ena_2;
   assign WERTE5_7_ena = WERTE5_7_ena_1 | WERTE5_7_ena_2;
   assign WERTE5_8_ena = WERTE5_8_ena_1 | WERTE5_8_ena_2;
   assign WERTE5_9_ena = WERTE5_9_ena_1 | WERTE5_9_ena_2;
   assign WERTE5__d[0] = WERTE5_0_d_1 | WERTE5_0_d_2;
   assign WERTE5__d[2] = WERTE5_2_d_1 | WERTE5_2_d_2;
   assign WERTE5__d[4] = WERTE5_4_d_1 | WERTE5_4_d_2;
   assign WERTE5__d[6] = WERTE5_6_d_1 | WERTE5_6_d_2;
   assign WERTE5__d[7] = WERTE5_7_d_1 | WERTE5_7_d_2;
   assign WERTE5__d[8] = WERTE5_8_d_1 | WERTE5_8_d_2;
   assign WERTE5__d[9] = WERTE5_9_d_1 | WERTE5_9_d_2;
   assign WERTE6_0_ena = WERTE6_0_ena_1 | WERTE6_0_ena_2;
   assign WERTE6_2_ena = WERTE6_2_ena_1 | WERTE6_2_ena_2;
   assign WERTE6_4_ena = WERTE6_4_ena_1 | WERTE6_4_ena_2;
   assign WERTE6_6_ena = WERTE6_6_ena_1 | WERTE6_6_ena_2;
   assign WERTE6_7_ena = WERTE6_7_ena_1 | WERTE6_7_ena_2;
   assign WERTE6_8_ena = WERTE6_8_ena_1 | WERTE6_8_ena_2;
   assign WERTE6_9_ena = WERTE6_9_ena_1 | WERTE6_9_ena_2;
   assign WERTE6__d[0] = WERTE6_0_d_1 | WERTE6_0_d_2;
   assign WERTE6__d[2] = WERTE6_2_d_1 | WERTE6_2_d_2;
   assign WERTE6__d[4] = WERTE6_4_d_1 | WERTE6_4_d_2;
   assign WERTE6__d[6] = WERTE6_6_d_1 | WERTE6_6_d_2;
   assign WERTE6__d[7] = WERTE6_7_d_1 | WERTE6_7_d_2;
   assign WERTE6__d[8] = WERTE6_8_d_1 | WERTE6_8_d_2;
   assign WERTE6__d[9] = WERTE6_9_d_1 | WERTE6_9_d_2;
   assign WERTE7_0_ena = WERTE7_0_ena_1 | WERTE7_0_ena_2;
   assign WERTE7_2_ena = WERTE7_2_ena_1 | WERTE7_2_ena_2;
   assign WERTE7_4_ena = WERTE7_4_ena_1 | WERTE7_4_ena_2;
   assign WERTE7_6_ena = WERTE7_6_ena_1 | WERTE7_6_ena_2;
   assign WERTE7_7_ena = WERTE7_7_ena_1 | WERTE7_7_ena_2;
   assign WERTE7_8_ena = WERTE7_8_ena_1 | WERTE7_8_ena_2;
   assign WERTE7_9_ena = WERTE7_9_ena_1 | WERTE7_9_ena_2;
   assign WERTE7__d[0] = WERTE7_0_d_1 | WERTE7_0_d_2;
   assign WERTE7__d[2] = WERTE7_2_d_1 | WERTE7_2_d_2;
   assign WERTE7__d[4] = WERTE7_4_d_1 | WERTE7_4_d_2;
   assign WERTE7__d[6] = WERTE7_6_d_1 | WERTE7_6_d_2;
   assign WERTE7__d[7] = WERTE7_7_d_1 | WERTE7_7_d_2;
   assign WERTE7__d[8] = WERTE7_8_d_1 | WERTE7_8_d_2;
   assign WERTE7__d[9] = WERTE7_9_d_1 | WERTE7_9_d_2;
   assign WERTE7__d[13] = WERTE7_13_d_1 | WERTE7_13_d_2;

// Define power signal(s)
   assign vcc = 1'b1;
   assign gnd = 1'b0;
endmodule
