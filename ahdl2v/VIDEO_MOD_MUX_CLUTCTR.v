// Xilinx XPort Language Converter, Version 4.1 (110)
// 
// AHDL    Design Source: VIDEO_MOD_MUX_CLUTCTR.tdf
// Verilog Design Output: VIDEO_MOD_MUX_CLUTCTR.v
// Created 02-Mar-2014 04:36 PM
//
// Copyright (c) 2014, Xilinx, Inc.  All Rights Reserved.
// Xilinx Inc makes no warranty, expressed or implied, with respect to
// the operation and/or functionality of the converted output files.
// 

// VIDEO MODUSE UND CLUT CONTROL


//  CREATED BY FREDI ASCHWANDEN
//  GE http://quartushelp.altera.com/current/mergedProjects/hdl/ahdl/ahdl_elements_arithmetic_operators.htm
//  {{ALTERA_PARAMETERS_BEGIN}} DO NOT REMOVE THIS LINE!
//  {{ALTERA_PARAMETERS_END}} DO NOT REMOVE THIS LINE!
module VIDEO_MOD_MUX_CLUTCTR(nRSTO, MAIN_CLK, nFB_CS1, nFB_CS2, nFB_CS3,
      nFB_WR, nFB_OE, FB_SIZE0, FB_SIZE1, nFB_BURST, FB_ADR, CLK33M, CLK25M,
      BLITTER_RUN, CLK_VIDEO, VR_D, VR_BUSY, COLOR8, ACP_CLUT_RD, COLOR1,
      FALCON_CLUT_RDH, FALCON_CLUT_RDL, FALCON_CLUT_WR, ST_CLUT_RD, ST_CLUT_WR,
      CLUT_MUX_ADR, HSYNC, VSYNC, nBLANK, nSYNC, nPD_VGA, FIFO_RDE, COLOR2,
      COLOR4, PIXEL_CLK, CLUT_OFF, BLITTER_ON, VIDEO_RAM_CTR, VIDEO_MOD_TA,
      CCR, CCSEL, ACP_CLUT_WR, INTER_ZEI, DOP_FIFO_CLR, VIDEO_RECONFIG, VR_WR,
      VR_RD, CLR_FIFO, FB_AD);

//  {{ALTERA_IO_BEGIN}} DO NOT REMOVE THIS LINE!
//  {{ALTERA_IO_END}} DO NOT REMOVE THIS LINE!
   input nRSTO, MAIN_CLK, nFB_CS1, nFB_CS2, nFB_CS3, nFB_WR, nFB_OE, FB_SIZE0,
	 FB_SIZE1, nFB_BURST;
   input [31:0] FB_ADR;
   input CLK33M, CLK25M, BLITTER_RUN, CLK_VIDEO;
   input [8:0] VR_D;
   input VR_BUSY;
   output COLOR8, ACP_CLUT_RD, COLOR1, FALCON_CLUT_RDH, FALCON_CLUT_RDL;
   output [3:0] FALCON_CLUT_WR;
   output ST_CLUT_RD;
   output [1:0] ST_CLUT_WR;
   output [3:0] CLUT_MUX_ADR;
   output HSYNC, VSYNC, nBLANK, nSYNC, nPD_VGA, FIFO_RDE, COLOR2, COLOR4,
	 PIXEL_CLK;
   output [3:0] CLUT_OFF;
   output BLITTER_ON;
   output [15:0] VIDEO_RAM_CTR;
   output VIDEO_MOD_TA;
   output [23:0] CCR;
   output [2:0] CCSEL;
   output [3:0] ACP_CLUT_WR;
   output INTER_ZEI, DOP_FIFO_CLR, VIDEO_RECONFIG, VR_WR, VR_RD, CLR_FIFO;
   inout [31:0] FB_AD;

//  DIV. CONTROL REGISTER
//  BRAUCHT EIN WAITSTAT
//  LÄNGE HSYNC PULS IN PIXEL_CLK
//  LETZTES PIXEL EINER ZEILE ERREICHT
//  ATARI RESOLUTION
//  HORIZONTAL TIMING 640x480
//  VERTIKAL TIMING 640x480
//  HORIZONTAL TIMING 320x240
//  VERTIKAL TIMING 320x240
//  HORIZONTAL
//  GE
//  GE
//  GE
//  VERTIKAL
   wire CLK17M, CLK17M_d, CLK17M_clk, CLK13M, CLK13M_d, CLK13M_clk,
	 ACP_CLUT_CS, ACP_CLUT, VIDEO_PLL_CONFIG_CS, VR_WR_d, VR_WR_clk;
   wire [8:0] VR_DOUT;
   wire [8:0] VR_DOUT_d;
   wire [7:0] VR_FRQ;
   wire [7:0] VR_FRQ_d;
   wire VIDEO_PLL_RECONFIG_CS, VIDEO_RECONFIG_d, VIDEO_RECONFIG_clk,
	 FALCON_CLUT_CS, FALCON_CLUT, ST_CLUT_CS, ST_CLUT;
   wire [3:0] FB_B;
   wire [1:0] FB_16B;
   wire [1:0] ST_SHIFT_MODE;
   wire [1:0] ST_SHIFT_MODE_d;
   wire ST_SHIFT_MODE_CS;
   wire [10:0] FALCON_SHIFT_MODE;
   wire [10:0] FALCON_SHIFT_MODE_d;
   wire FALCON_SHIFT_MODE_CS;
   wire [3:0] CLUT_MUX_ADR_d;
   wire [3:0] CLUT_MUX_AV1_;
   wire [3:0] CLUT_MUX_AV1__d;
   wire [3:0] CLUT_MUX_AV0_;
   wire [3:0] CLUT_MUX_AV0__d;
   wire ACP_VCTR_CS;
   wire [31:0] ACP_VCTR;
   wire [31:0] ACP_VCTR_d;
   wire CCR_CS;
   wire [23:0] CCR_d;
   wire ACP_VIDEO_ON;
   wire [6:0] SYS_CTR;
   wire [6:0] SYS_CTR_d;
   wire SYS_CTR_CS;
   wire [15:0] VDL_LOF;
   wire [15:0] VDL_LOF_d;
   wire VDL_LOF_CS;
   wire [15:0] VDL_LWD;
   wire [15:0] VDL_LWD_d;
   wire VDL_LWD_CS, CLUT_TA, CLUT_TA_d, CLUT_TA_clk, HSYNC_d, HSYNC_clk;
   wire [7:0] HSYNC_I;
   wire [7:0] HSYNC_I_d;
   wire [7:0] HSY_LEN;
   wire [7:0] HSY_LEN_d;
   wire HSYNC_START, HSYNC_START_d, HSYNC_START_clk, LAST, LAST_d, LAST_clk,
	 VSYNC_d, VSYNC_clk, VSYNC_START, VSYNC_START_d, VSYNC_START_clk,
	 VSYNC_START_ena;
   wire [2:0] VSYNC_I;
   wire [2:0] VSYNC_I_d;
   wire nBLANK_d, nBLANK_clk, DISP_ON, DISP_ON_d, DISP_ON_clk, DPO_ZL,
	 DPO_ZL_d, DPO_ZL_clk, DPO_ZL_ena, DPO_ON, DPO_ON_d, DPO_ON_clk,
	 DPO_OFF, DPO_OFF_d, DPO_OFF_clk, VDTRON, VDTRON_d, VDTRON_clk, VDO_ZL,
	 VDO_ZL_d, VDO_ZL_clk, VDO_ZL_ena, VDO_ON, VDO_ON_d, VDO_ON_clk,
	 VDO_OFF, VDO_OFF_d, VDO_OFF_clk;
   wire [11:0] VHCNT;
   wire [11:0] VHCNT_d;
   wire [6:0] SUB_PIXEL_CNT;
   wire [6:0] SUB_PIXEL_CNT_d;
   wire [10:0] VVCNT;
   wire [10:0] VVCNT_d;
   wire [9:0] VERZ2_;
   wire [9:0] VERZ2__d;
   wire [9:0] VERZ1_;
   wire [9:0] VERZ1__d;
   wire [9:0] VERZ0_;
   wire [9:0] VERZ0__d;
   wire [6:0] RAND;
   wire [6:0] RAND_d;
   wire RAND_ON, FIFO_RDE_d, FIFO_RDE_clk, CLR_FIFO_d, CLR_FIFO_clk,
	 CLR_FIFO_ena, START_ZEILE, START_ZEILE_d, START_ZEILE_clk,
	 START_ZEILE_ena, SYNC_PIX, SYNC_PIX_d, SYNC_PIX_clk, SYNC_PIX1,
	 SYNC_PIX1_d, SYNC_PIX1_clk, SYNC_PIX2, SYNC_PIX2_d, SYNC_PIX2_clk;
   wire [2:0] CCSEL_d;
   wire COLOR16, COLOR24, ATARI_SYNC;
   wire [31:0] ATARI_HH;
   wire [31:0] ATARI_HH_d;
   wire ATARI_HH_CS;
   wire [31:0] ATARI_VH;
   wire [31:0] ATARI_VH_d;
   wire ATARI_VH_CS;
   wire [31:0] ATARI_HL;
   wire [31:0] ATARI_HL_d;
   wire ATARI_HL_CS;
   wire [31:0] ATARI_VL;
   wire [31:0] ATARI_VL_d;
   wire ATARI_VL_CS;
   wire [11:0] RAND_LINKS;
   wire [23:0] RAND_LINKS_FULL;
   wire [11:0] HDIS_START;
   wire [11:0] HDIS_END;
   wire [11:0] RAND_RECHTS;
   wire [11:0] HS_START;
   wire [23:0] HS_START_FULL;
   wire [11:0] H_TOTAL;
   wire [23:0] H_TOTAL_FULL;
   wire [11:0] HDIS_LEN;
   wire [5:0] MULF;
   wire [11:0] VDL_HHT;
   wire [11:0] VDL_HHT_d;
   wire VDL_HHT_CS;
   wire [11:0] VDL_HBE;
   wire [11:0] VDL_HBE_d;
   wire VDL_HBE_CS;
   wire [11:0] VDL_HDB;
   wire [11:0] VDL_HDB_d;
   wire VDL_HDB_CS;
   wire [11:0] VDL_HDE;
   wire [11:0] VDL_HDE_d;
   wire VDL_HDE_CS;
   wire [11:0] VDL_HBB;
   wire [11:0] VDL_HBB_d;
   wire VDL_HBB_CS;
   wire [11:0] VDL_HSS;
   wire [11:0] VDL_HSS_d;
   wire VDL_HSS_CS;
   wire [10:0] RAND_OBEN;
   wire [10:0] VDIS_START;
   wire [10:0] VDIS_END;
   wire [10:0] RAND_UNTEN;
   wire [10:0] VS_START;
   wire [10:0] V_TOTAL;
   wire FALCON_VIDEO, ST_VIDEO, INTER_ZEI_d, INTER_ZEI_clk, DOP_ZEI, DOP_ZEI_d,
	 DOP_ZEI_clk, DOP_FIFO_CLR_d, DOP_FIFO_CLR_clk;
   wire [10:0] VDL_VBE;
   wire [10:0] VDL_VBE_d;
   wire VDL_VBE_CS;
   wire [10:0] VDL_VDB;
   wire [10:0] VDL_VDB_d;
   wire VDL_VDB_CS;
   wire [10:0] VDL_VDE;
   wire [10:0] VDL_VDE_d;
   wire VDL_VDE_CS;
   wire [10:0] VDL_VBB;
   wire [10:0] VDL_VBB_d;
   wire VDL_VBB_CS;
   wire [10:0] VDL_VSS;
   wire [10:0] VDL_VSS_d;
   wire VDL_VSS_CS;
   wire [10:0] VDL_VFT;
   wire [10:0] VDL_VFT_d;
   wire VDL_VFT_CS;
   wire [8:0] VDL_VCT;
   wire [8:0] VDL_VCT_d;
   wire VDL_VCT8_ena, VDL_VCT_CS;
   wire [3:0] VDL_VMD;
   wire [3:0] VDL_VMD_d;
   wire VDL_VMD_CS;
   wire [15:0] u0_data;
   wire u0_enabledt;
   wire [15:0] u0_tridata;
   wire [15:0] u1_data;
   wire u1_enabledt;
   wire [15:0] u1_tridata;
   wire gnd, COLOR16_1, COLOR16_2, VERZ1_0_d_1, VERZ1_0_d_2, COLOR4_1,
	 COLOR4_2, COLOR1_1, COLOR1_2, COLOR1_3, COLOR8_1, COLOR8_2,
	 CLUT_MUX_AV0_0_clk_ctrl, CLUT_MUX_AV1_0_clk_ctrl,
	 CLUT_MUX_ADR0_clk_ctrl, SUB_PIXEL_CNT0_ena_ctrl,
	 SUB_PIXEL_CNT0_clk_ctrl, RAND0_clk_ctrl, VERZ0_0_clk_ctrl,
	 VERZ1_0_clk_ctrl, VERZ2_0_clk_ctrl, VSYNC_I0_ena_ctrl,
	 VSYNC_I0_clk_ctrl, HSYNC_I0_clk_ctrl, VVCNT0_ena_ctrl,
	 VVCNT0_clk_ctrl, VHCNT0_clk_ctrl, HSY_LEN0_clk_ctrl,
	 VDL_VMD0_ena_ctrl, VDL_VMD0_clk_ctrl, VDL_VCT0_ena_ctrl,
	 VDL_VCT0_clk_ctrl, VDL_VFT0_ena_ctrl, VDL_VFT8_ena_ctrl,
	 VDL_VFT0_clk_ctrl, VDL_VSS0_ena_ctrl, VDL_VSS8_ena_ctrl,
	 VDL_VSS0_clk_ctrl, VDL_VBB0_ena_ctrl, VDL_VBB8_ena_ctrl,
	 VDL_VBB0_clk_ctrl, VDL_VDE0_ena_ctrl, VDL_VDE8_ena_ctrl,
	 VDL_VDE0_clk_ctrl, VDL_VDB0_ena_ctrl, VDL_VDB8_ena_ctrl,
	 VDL_VDB0_clk_ctrl, VDL_VBE0_ena_ctrl, VDL_VBE8_ena_ctrl,
	 VDL_VBE0_clk_ctrl, VDL_HSS0_ena_ctrl, VDL_HSS8_ena_ctrl,
	 VDL_HSS0_clk_ctrl, VDL_HBB0_ena_ctrl, VDL_HBB8_ena_ctrl,
	 VDL_HBB0_clk_ctrl, VDL_HDE0_ena_ctrl, VDL_HDE8_ena_ctrl,
	 VDL_HDE0_clk_ctrl, VDL_HDB0_ena_ctrl, VDL_HDB8_ena_ctrl,
	 VDL_HDB0_clk_ctrl, VDL_HBE0_ena_ctrl, VDL_HBE8_ena_ctrl,
	 VDL_HBE0_clk_ctrl, VDL_HHT0_ena_ctrl, VDL_HHT8_ena_ctrl,
	 VDL_HHT0_clk_ctrl, VDL_LWD0_ena_ctrl, VDL_LWD8_ena_ctrl,
	 VDL_LWD0_clk_ctrl, VDL_LOF0_ena_ctrl, VDL_LOF8_ena_ctrl,
	 VDL_LOF0_clk_ctrl, SYS_CTR0_ena_ctrl, SYS_CTR0_clk_ctrl,
	 CCR0_ena_ctrl, CCR8_ena_ctrl, CCR16_ena_ctrl, CCR0_clk_ctrl,
	 CCSEL0_clk_ctrl, ACP_VCTR6_ena_ctrl, VR_FRQ0_ena_ctrl,
	 VR_FRQ0_clk_ctrl, VR_DOUT0_ena_ctrl, VR_DOUT0_clk_ctrl,
	 ATARI_VL0_ena_ctrl, ATARI_VL8_ena_ctrl, ATARI_VL16_ena_ctrl,
	 ATARI_VL24_ena_ctrl, ATARI_VL0_clk_ctrl, ATARI_HL0_ena_ctrl,
	 ATARI_HL8_ena_ctrl, ATARI_HL16_ena_ctrl, ATARI_HL24_ena_ctrl,
	 ATARI_HL0_clk_ctrl, ATARI_VH0_ena_ctrl, ATARI_VH8_ena_ctrl,
	 ATARI_VH16_ena_ctrl, ATARI_VH24_ena_ctrl, ATARI_VH0_clk_ctrl,
	 ATARI_HH0_ena_ctrl, ATARI_HH8_ena_ctrl, ATARI_HH16_ena_ctrl,
	 ATARI_HH24_ena_ctrl, ATARI_HH0_clk_ctrl, ACP_VCTR0_ena_ctrl,
	 ACP_VCTR8_ena_ctrl, ACP_VCTR16_ena_ctrl, ACP_VCTR24_ena_ctrl,
	 ACP_VCTR0_clk_ctrl, FALCON_SHIFT_MODE0_ena_ctrl,
	 FALCON_SHIFT_MODE8_ena_ctrl, FALCON_SHIFT_MODE0_clk_ctrl,
	 ST_SHIFT_MODE0_ena_ctrl, ST_SHIFT_MODE0_clk_ctrl;
   reg CLK17M_q, CLK13M_q, VR_WR_q;
   reg [8:0] VR_DOUT_q;
   reg [7:0] VR_FRQ_q;
   reg VIDEO_RECONFIG_q;
   reg [1:0] ST_SHIFT_MODE_q;
   reg [10:0] FALCON_SHIFT_MODE_q;
   reg [3:0] CLUT_MUX_ADR_q;
   reg [3:0] CLUT_MUX_AV1__q;
   reg [3:0] CLUT_MUX_AV0__q;
   reg [31:0] ACP_VCTR_q;
   reg [23:0] CCR_q;
   reg [6:0] SYS_CTR_q;
   reg [15:0] VDL_LOF_q;
   reg [15:0] VDL_LWD_q;
   reg CLUT_TA_q, HSYNC_q;
   reg [7:0] HSYNC_I_q;
   reg [7:0] HSY_LEN_q;
   reg HSYNC_START_q, LAST_q, VSYNC_q, VSYNC_START_q;
   reg [2:0] VSYNC_I_q;
   reg nBLANK_q, DISP_ON_q, DPO_ZL_q, DPO_ON_q, DPO_OFF_q, VDTRON_q, VDO_ZL_q,
	 VDO_ON_q, VDO_OFF_q;
   reg [11:0] VHCNT_q;
   reg [6:0] SUB_PIXEL_CNT_q;
   reg [10:0] VVCNT_q;
   reg [9:0] VERZ2__q;
   reg [9:0] VERZ1__q;
   reg [9:0] VERZ0__q;
   reg [6:0] RAND_q;
   reg FIFO_RDE_q, CLR_FIFO_q, START_ZEILE_q, SYNC_PIX_q, SYNC_PIX1_q,
	 SYNC_PIX2_q;
   reg [2:0] CCSEL_q;
   reg [31:0] ATARI_HH_q;
   reg [31:0] ATARI_VH_q;
   reg [31:0] ATARI_HL_q;
   reg [31:0] ATARI_VL_q;
   reg [11:0] VDL_HHT_q;
   reg [11:0] VDL_HBE_q;
   reg [11:0] VDL_HDB_q;
   reg [11:0] VDL_HDE_q;
   reg [11:0] VDL_HBB_q;
   reg [11:0] VDL_HSS_q;
   reg INTER_ZEI_q, DOP_ZEI_q, DOP_FIFO_CLR_q;
   reg [10:0] VDL_VBE_q;
   reg [10:0] VDL_VDB_q;
   reg [10:0] VDL_VDE_q;
   reg [10:0] VDL_VBB_q;
   reg [10:0] VDL_VSS_q;
   reg [10:0] VDL_VFT_q;
   reg [8:0] VDL_VCT_q;
   reg [3:0] VDL_VMD_q;


// Sub Module Section
   lpm_bustri_WORD  u0 (.data(u0_data), .enabledt(u0_enabledt),
	 .tridata(u0_tridata));

   lpm_bustri_WORD  u1 (.data(u1_data), .enabledt(u1_enabledt),
	 .tridata(u1_tridata));


   assign CLUT_MUX_ADR = CLUT_MUX_ADR_q;
   always @(posedge CLUT_MUX_ADR0_clk_ctrl)
      CLUT_MUX_ADR_q <= CLUT_MUX_ADR_d;

   assign HSYNC = HSYNC_q;
   always @(posedge HSYNC_clk)
      HSYNC_q <= HSYNC_d;

   assign VSYNC = VSYNC_q;
   always @(posedge VSYNC_clk)
      VSYNC_q <= VSYNC_d;

   assign nBLANK = nBLANK_q;
   always @(posedge nBLANK_clk)
      nBLANK_q <= nBLANK_d;

   assign FIFO_RDE = FIFO_RDE_q;
   always @(posedge FIFO_RDE_clk)
      FIFO_RDE_q <= FIFO_RDE_d;

   assign CCR[23:16] = CCR_q[23:16];
   always @(posedge CCR0_clk_ctrl)
      if (CCR16_ena_ctrl)
	 {CCR_q[23], CCR_q[22], CCR_q[21], CCR_q[20], CCR_q[19], CCR_q[18],
	       CCR_q[17], CCR_q[16]} <= CCR_d[23:16];

   assign CCR[15:8] = CCR_q[15:8];
   always @(posedge CCR0_clk_ctrl)
      if (CCR8_ena_ctrl)
	 {CCR_q[15], CCR_q[14], CCR_q[13], CCR_q[12], CCR_q[11], CCR_q[10],
	       CCR_q[9], CCR_q[8]} <= CCR_d[15:8];

   assign CCR[7:0] = CCR_q[7:0];
   always @(posedge CCR0_clk_ctrl)
      if (CCR0_ena_ctrl)
	 {CCR_q[7], CCR_q[6], CCR_q[5], CCR_q[4], CCR_q[3], CCR_q[2], CCR_q[1],
	       CCR_q[0]} <= CCR_d[7:0];

   assign CCSEL = CCSEL_q;
   always @(posedge CCSEL0_clk_ctrl)
      CCSEL_q <= CCSEL_d;

   assign INTER_ZEI = INTER_ZEI_q;
   always @(posedge INTER_ZEI_clk)
      INTER_ZEI_q <= INTER_ZEI_d;

   assign DOP_FIFO_CLR = DOP_FIFO_CLR_q;
   always @(posedge DOP_FIFO_CLR_clk)
      DOP_FIFO_CLR_q <= DOP_FIFO_CLR_d;

   assign VIDEO_RECONFIG = VIDEO_RECONFIG_q;
   always @(posedge VIDEO_RECONFIG_clk)
      VIDEO_RECONFIG_q <= VIDEO_RECONFIG_d;

   assign VR_WR = VR_WR_q;
   always @(posedge VR_WR_clk)
      VR_WR_q <= VR_WR_d;

   assign CLR_FIFO = CLR_FIFO_q;
   always @(posedge CLR_FIFO_clk)
      if (CLR_FIFO_ena)
	 CLR_FIFO_q <= CLR_FIFO_d;

   always @(posedge CLK17M_clk)
      CLK17M_q <= CLK17M_d;

   always @(posedge CLK13M_clk)
      CLK13M_q <= CLK13M_d;

   always @(posedge VR_DOUT0_clk_ctrl)
      if (VR_DOUT0_ena_ctrl)
	 VR_DOUT_q <= VR_DOUT_d;

   always @(posedge VR_FRQ0_clk_ctrl)
      if (VR_FRQ0_ena_ctrl)
	 VR_FRQ_q <= VR_FRQ_d;

   always @(posedge ST_SHIFT_MODE0_clk_ctrl)
      if (ST_SHIFT_MODE0_ena_ctrl)
	 ST_SHIFT_MODE_q <= ST_SHIFT_MODE_d;

   always @(posedge FALCON_SHIFT_MODE0_clk_ctrl)
      if (FALCON_SHIFT_MODE8_ena_ctrl)
	 {FALCON_SHIFT_MODE_q[10], FALCON_SHIFT_MODE_q[9],
	       FALCON_SHIFT_MODE_q[8]} <= FALCON_SHIFT_MODE_d[10:8];

   always @(posedge FALCON_SHIFT_MODE0_clk_ctrl)
      if (FALCON_SHIFT_MODE0_ena_ctrl)
	 {FALCON_SHIFT_MODE_q[7], FALCON_SHIFT_MODE_q[6],
	       FALCON_SHIFT_MODE_q[5], FALCON_SHIFT_MODE_q[4],
	       FALCON_SHIFT_MODE_q[3], FALCON_SHIFT_MODE_q[2],
	       FALCON_SHIFT_MODE_q[1], FALCON_SHIFT_MODE_q[0]} <=
	       FALCON_SHIFT_MODE_d[7:0];

   always @(posedge CLUT_MUX_AV1_0_clk_ctrl)
      CLUT_MUX_AV1__q <= CLUT_MUX_AV1__d;

   always @(posedge CLUT_MUX_AV0_0_clk_ctrl)
      CLUT_MUX_AV0__q <= CLUT_MUX_AV0__d;

   always @(posedge ACP_VCTR0_clk_ctrl)
      if (ACP_VCTR24_ena_ctrl)
	 {ACP_VCTR_q[31], ACP_VCTR_q[30], ACP_VCTR_q[29], ACP_VCTR_q[28],
	       ACP_VCTR_q[27], ACP_VCTR_q[26], ACP_VCTR_q[25], ACP_VCTR_q[24]}
	       <= ACP_VCTR_d[31:24];

   always @(posedge ACP_VCTR0_clk_ctrl)
      if (ACP_VCTR16_ena_ctrl)
	 {ACP_VCTR_q[23], ACP_VCTR_q[22], ACP_VCTR_q[21], ACP_VCTR_q[20],
	       ACP_VCTR_q[19], ACP_VCTR_q[18], ACP_VCTR_q[17], ACP_VCTR_q[16]}
	       <= ACP_VCTR_d[23:16];

   always @(posedge ACP_VCTR0_clk_ctrl)
      if (ACP_VCTR8_ena_ctrl)
	 {ACP_VCTR_q[15], ACP_VCTR_q[14], ACP_VCTR_q[13], ACP_VCTR_q[12],
	       ACP_VCTR_q[11], ACP_VCTR_q[10], ACP_VCTR_q[9], ACP_VCTR_q[8]} <=
	       ACP_VCTR_d[15:8];

   always @(posedge ACP_VCTR0_clk_ctrl)
      if (ACP_VCTR6_ena_ctrl)
	 {ACP_VCTR_q[7], ACP_VCTR_q[6]} <= ACP_VCTR_d[7:6];

   always @(posedge ACP_VCTR0_clk_ctrl)
      if (ACP_VCTR0_ena_ctrl)
	 {ACP_VCTR_q[5], ACP_VCTR_q[4], ACP_VCTR_q[3], ACP_VCTR_q[2],
	       ACP_VCTR_q[1], ACP_VCTR_q[0]} <= ACP_VCTR_d[5:0];

   always @(posedge SYS_CTR0_clk_ctrl)
      if (SYS_CTR0_ena_ctrl)
	 SYS_CTR_q <= SYS_CTR_d;

   always @(posedge VDL_LOF0_clk_ctrl)
      if (VDL_LOF8_ena_ctrl)
	 {VDL_LOF_q[15], VDL_LOF_q[14], VDL_LOF_q[13], VDL_LOF_q[12],
	       VDL_LOF_q[11], VDL_LOF_q[10], VDL_LOF_q[9], VDL_LOF_q[8]} <=
	       VDL_LOF_d[15:8];

   always @(posedge VDL_LOF0_clk_ctrl)
      if (VDL_LOF0_ena_ctrl)
	 {VDL_LOF_q[7], VDL_LOF_q[6], VDL_LOF_q[5], VDL_LOF_q[4], VDL_LOF_q[3],
	       VDL_LOF_q[2], VDL_LOF_q[1], VDL_LOF_q[0]} <= VDL_LOF_d[7:0];

   always @(posedge VDL_LWD0_clk_ctrl)
      if (VDL_LWD8_ena_ctrl)
	 {VDL_LWD_q[15], VDL_LWD_q[14], VDL_LWD_q[13], VDL_LWD_q[12],
	       VDL_LWD_q[11], VDL_LWD_q[10], VDL_LWD_q[9], VDL_LWD_q[8]} <=
	       VDL_LWD_d[15:8];

   always @(posedge VDL_LWD0_clk_ctrl)
      if (VDL_LWD0_ena_ctrl)
	 {VDL_LWD_q[7], VDL_LWD_q[6], VDL_LWD_q[5], VDL_LWD_q[4], VDL_LWD_q[3],
	       VDL_LWD_q[2], VDL_LWD_q[1], VDL_LWD_q[0]} <= VDL_LWD_d[7:0];

   always @(posedge CLUT_TA_clk)
      CLUT_TA_q <= CLUT_TA_d;

   always @(posedge HSYNC_I0_clk_ctrl)
      HSYNC_I_q <= HSYNC_I_d;

   always @(posedge HSY_LEN0_clk_ctrl)
      HSY_LEN_q <= HSY_LEN_d;

   always @(posedge HSYNC_START_clk)
      HSYNC_START_q <= HSYNC_START_d;

   always @(posedge LAST_clk)
      LAST_q <= LAST_d;

   always @(posedge VSYNC_START_clk)
      if (VSYNC_START_ena)
	 VSYNC_START_q <= VSYNC_START_d;

   always @(posedge VSYNC_I0_clk_ctrl)
      if (VSYNC_I0_ena_ctrl)
	 VSYNC_I_q <= VSYNC_I_d;

   always @(posedge DISP_ON_clk)
      DISP_ON_q <= DISP_ON_d;

   always @(posedge DPO_ZL_clk)
      if (DPO_ZL_ena)
	 DPO_ZL_q <= DPO_ZL_d;

   always @(posedge DPO_ON_clk)
      DPO_ON_q <= DPO_ON_d;

   always @(posedge DPO_OFF_clk)
      DPO_OFF_q <= DPO_OFF_d;

   always @(posedge VDTRON_clk)
      VDTRON_q <= VDTRON_d;

   always @(posedge VDO_ZL_clk)
      if (VDO_ZL_ena)
	 VDO_ZL_q <= VDO_ZL_d;

   always @(posedge VDO_ON_clk)
      VDO_ON_q <= VDO_ON_d;

   always @(posedge VDO_OFF_clk)
      VDO_OFF_q <= VDO_OFF_d;

   always @(posedge VHCNT0_clk_ctrl)
      VHCNT_q <= VHCNT_d;

   always @(posedge SUB_PIXEL_CNT0_clk_ctrl)
      if (SUB_PIXEL_CNT0_ena_ctrl)
	 SUB_PIXEL_CNT_q <= SUB_PIXEL_CNT_d;

   always @(posedge VVCNT0_clk_ctrl)
      if (VVCNT0_ena_ctrl)
	 VVCNT_q <= VVCNT_d;

   always @(posedge VERZ2_0_clk_ctrl)
      VERZ2__q <= VERZ2__d;

   always @(posedge VERZ1_0_clk_ctrl)
      VERZ1__q <= VERZ1__d;

   always @(posedge VERZ0_0_clk_ctrl)
      VERZ0__q <= VERZ0__d;

   always @(posedge RAND0_clk_ctrl)
      RAND_q <= RAND_d;

   always @(posedge START_ZEILE_clk)
      if (START_ZEILE_ena)
	 START_ZEILE_q <= START_ZEILE_d;

   always @(posedge SYNC_PIX_clk)
      SYNC_PIX_q <= SYNC_PIX_d;

   always @(posedge SYNC_PIX1_clk)
      SYNC_PIX1_q <= SYNC_PIX1_d;

   always @(posedge SYNC_PIX2_clk)
      SYNC_PIX2_q <= SYNC_PIX2_d;

   always @(posedge ATARI_HH0_clk_ctrl)
      if (ATARI_HH24_ena_ctrl)
	 {ATARI_HH_q[31], ATARI_HH_q[30], ATARI_HH_q[29], ATARI_HH_q[28],
	       ATARI_HH_q[27], ATARI_HH_q[26], ATARI_HH_q[25], ATARI_HH_q[24]}
	       <= ATARI_HH_d[31:24];

   always @(posedge ATARI_HH0_clk_ctrl)
      if (ATARI_HH16_ena_ctrl)
	 {ATARI_HH_q[23], ATARI_HH_q[22], ATARI_HH_q[21], ATARI_HH_q[20],
	       ATARI_HH_q[19], ATARI_HH_q[18], ATARI_HH_q[17], ATARI_HH_q[16]}
	       <= ATARI_HH_d[23:16];

   always @(posedge ATARI_HH0_clk_ctrl)
      if (ATARI_HH8_ena_ctrl)
	 {ATARI_HH_q[15], ATARI_HH_q[14], ATARI_HH_q[13], ATARI_HH_q[12],
	       ATARI_HH_q[11], ATARI_HH_q[10], ATARI_HH_q[9], ATARI_HH_q[8]} <=
	       ATARI_HH_d[15:8];

   always @(posedge ATARI_HH0_clk_ctrl)
      if (ATARI_HH0_ena_ctrl)
	 {ATARI_HH_q[7], ATARI_HH_q[6], ATARI_HH_q[5], ATARI_HH_q[4],
	       ATARI_HH_q[3], ATARI_HH_q[2], ATARI_HH_q[1], ATARI_HH_q[0]} <=
	       ATARI_HH_d[7:0];

   always @(posedge ATARI_VH0_clk_ctrl)
      if (ATARI_VH24_ena_ctrl)
	 {ATARI_VH_q[31], ATARI_VH_q[30], ATARI_VH_q[29], ATARI_VH_q[28],
	       ATARI_VH_q[27], ATARI_VH_q[26], ATARI_VH_q[25], ATARI_VH_q[24]}
	       <= ATARI_VH_d[31:24];

   always @(posedge ATARI_VH0_clk_ctrl)
      if (ATARI_VH16_ena_ctrl)
	 {ATARI_VH_q[23], ATARI_VH_q[22], ATARI_VH_q[21], ATARI_VH_q[20],
	       ATARI_VH_q[19], ATARI_VH_q[18], ATARI_VH_q[17], ATARI_VH_q[16]}
	       <= ATARI_VH_d[23:16];

   always @(posedge ATARI_VH0_clk_ctrl)
      if (ATARI_VH8_ena_ctrl)
	 {ATARI_VH_q[15], ATARI_VH_q[14], ATARI_VH_q[13], ATARI_VH_q[12],
	       ATARI_VH_q[11], ATARI_VH_q[10], ATARI_VH_q[9], ATARI_VH_q[8]} <=
	       ATARI_VH_d[15:8];

   always @(posedge ATARI_VH0_clk_ctrl)
      if (ATARI_VH0_ena_ctrl)
	 {ATARI_VH_q[7], ATARI_VH_q[6], ATARI_VH_q[5], ATARI_VH_q[4],
	       ATARI_VH_q[3], ATARI_VH_q[2], ATARI_VH_q[1], ATARI_VH_q[0]} <=
	       ATARI_VH_d[7:0];

   always @(posedge ATARI_HL0_clk_ctrl)
      if (ATARI_HL24_ena_ctrl)
	 {ATARI_HL_q[31], ATARI_HL_q[30], ATARI_HL_q[29], ATARI_HL_q[28],
	       ATARI_HL_q[27], ATARI_HL_q[26], ATARI_HL_q[25], ATARI_HL_q[24]}
	       <= ATARI_HL_d[31:24];

   always @(posedge ATARI_HL0_clk_ctrl)
      if (ATARI_HL16_ena_ctrl)
	 {ATARI_HL_q[23], ATARI_HL_q[22], ATARI_HL_q[21], ATARI_HL_q[20],
	       ATARI_HL_q[19], ATARI_HL_q[18], ATARI_HL_q[17], ATARI_HL_q[16]}
	       <= ATARI_HL_d[23:16];

   always @(posedge ATARI_HL0_clk_ctrl)
      if (ATARI_HL8_ena_ctrl)
	 {ATARI_HL_q[15], ATARI_HL_q[14], ATARI_HL_q[13], ATARI_HL_q[12],
	       ATARI_HL_q[11], ATARI_HL_q[10], ATARI_HL_q[9], ATARI_HL_q[8]} <=
	       ATARI_HL_d[15:8];

   always @(posedge ATARI_HL0_clk_ctrl)
      if (ATARI_HL0_ena_ctrl)
	 {ATARI_HL_q[7], ATARI_HL_q[6], ATARI_HL_q[5], ATARI_HL_q[4],
	       ATARI_HL_q[3], ATARI_HL_q[2], ATARI_HL_q[1], ATARI_HL_q[0]} <=
	       ATARI_HL_d[7:0];

   always @(posedge ATARI_VL0_clk_ctrl)
      if (ATARI_VL24_ena_ctrl)
	 {ATARI_VL_q[31], ATARI_VL_q[30], ATARI_VL_q[29], ATARI_VL_q[28],
	       ATARI_VL_q[27], ATARI_VL_q[26], ATARI_VL_q[25], ATARI_VL_q[24]}
	       <= ATARI_VL_d[31:24];

   always @(posedge ATARI_VL0_clk_ctrl)
      if (ATARI_VL16_ena_ctrl)
	 {ATARI_VL_q[23], ATARI_VL_q[22], ATARI_VL_q[21], ATARI_VL_q[20],
	       ATARI_VL_q[19], ATARI_VL_q[18], ATARI_VL_q[17], ATARI_VL_q[16]}
	       <= ATARI_VL_d[23:16];

   always @(posedge ATARI_VL0_clk_ctrl)
      if (ATARI_VL8_ena_ctrl)
	 {ATARI_VL_q[15], ATARI_VL_q[14], ATARI_VL_q[13], ATARI_VL_q[12],
	       ATARI_VL_q[11], ATARI_VL_q[10], ATARI_VL_q[9], ATARI_VL_q[8]} <=
	       ATARI_VL_d[15:8];

   always @(posedge ATARI_VL0_clk_ctrl)
      if (ATARI_VL0_ena_ctrl)
	 {ATARI_VL_q[7], ATARI_VL_q[6], ATARI_VL_q[5], ATARI_VL_q[4],
	       ATARI_VL_q[3], ATARI_VL_q[2], ATARI_VL_q[1], ATARI_VL_q[0]} <=
	       ATARI_VL_d[7:0];

   always @(posedge VDL_HHT0_clk_ctrl)
      if (VDL_HHT8_ena_ctrl)
	 {VDL_HHT_q[11], VDL_HHT_q[10], VDL_HHT_q[9], VDL_HHT_q[8]} <=
	       VDL_HHT_d[11:8];

   always @(posedge VDL_HHT0_clk_ctrl)
      if (VDL_HHT0_ena_ctrl)
	 {VDL_HHT_q[7], VDL_HHT_q[6], VDL_HHT_q[5], VDL_HHT_q[4], VDL_HHT_q[3],
	       VDL_HHT_q[2], VDL_HHT_q[1], VDL_HHT_q[0]} <= VDL_HHT_d[7:0];

   always @(posedge VDL_HBE0_clk_ctrl)
      if (VDL_HBE8_ena_ctrl)
	 {VDL_HBE_q[11], VDL_HBE_q[10], VDL_HBE_q[9], VDL_HBE_q[8]} <=
	       VDL_HBE_d[11:8];

   always @(posedge VDL_HBE0_clk_ctrl)
      if (VDL_HBE0_ena_ctrl)
	 {VDL_HBE_q[7], VDL_HBE_q[6], VDL_HBE_q[5], VDL_HBE_q[4], VDL_HBE_q[3],
	       VDL_HBE_q[2], VDL_HBE_q[1], VDL_HBE_q[0]} <= VDL_HBE_d[7:0];

   always @(posedge VDL_HDB0_clk_ctrl)
      if (VDL_HDB8_ena_ctrl)
	 {VDL_HDB_q[11], VDL_HDB_q[10], VDL_HDB_q[9], VDL_HDB_q[8]} <=
	       VDL_HDB_d[11:8];

   always @(posedge VDL_HDB0_clk_ctrl)
      if (VDL_HDB0_ena_ctrl)
	 {VDL_HDB_q[7], VDL_HDB_q[6], VDL_HDB_q[5], VDL_HDB_q[4], VDL_HDB_q[3],
	       VDL_HDB_q[2], VDL_HDB_q[1], VDL_HDB_q[0]} <= VDL_HDB_d[7:0];

   always @(posedge VDL_HDE0_clk_ctrl)
      if (VDL_HDE8_ena_ctrl)
	 {VDL_HDE_q[11], VDL_HDE_q[10], VDL_HDE_q[9], VDL_HDE_q[8]} <=
	       VDL_HDE_d[11:8];

   always @(posedge VDL_HDE0_clk_ctrl)
      if (VDL_HDE0_ena_ctrl)
	 {VDL_HDE_q[7], VDL_HDE_q[6], VDL_HDE_q[5], VDL_HDE_q[4], VDL_HDE_q[3],
	       VDL_HDE_q[2], VDL_HDE_q[1], VDL_HDE_q[0]} <= VDL_HDE_d[7:0];

   always @(posedge VDL_HBB0_clk_ctrl)
      if (VDL_HBB8_ena_ctrl)
	 {VDL_HBB_q[11], VDL_HBB_q[10], VDL_HBB_q[9], VDL_HBB_q[8]} <=
	       VDL_HBB_d[11:8];

   always @(posedge VDL_HBB0_clk_ctrl)
      if (VDL_HBB0_ena_ctrl)
	 {VDL_HBB_q[7], VDL_HBB_q[6], VDL_HBB_q[5], VDL_HBB_q[4], VDL_HBB_q[3],
	       VDL_HBB_q[2], VDL_HBB_q[1], VDL_HBB_q[0]} <= VDL_HBB_d[7:0];

   always @(posedge VDL_HSS0_clk_ctrl)
      if (VDL_HSS8_ena_ctrl)
	 {VDL_HSS_q[11], VDL_HSS_q[10], VDL_HSS_q[9], VDL_HSS_q[8]} <=
	       VDL_HSS_d[11:8];

   always @(posedge VDL_HSS0_clk_ctrl)
      if (VDL_HSS0_ena_ctrl)
	 {VDL_HSS_q[7], VDL_HSS_q[6], VDL_HSS_q[5], VDL_HSS_q[4], VDL_HSS_q[3],
	       VDL_HSS_q[2], VDL_HSS_q[1], VDL_HSS_q[0]} <= VDL_HSS_d[7:0];

   always @(posedge DOP_ZEI_clk)
      DOP_ZEI_q <= DOP_ZEI_d;

   always @(posedge VDL_VBE0_clk_ctrl)
      if (VDL_VBE8_ena_ctrl)
	 {VDL_VBE_q[10], VDL_VBE_q[9], VDL_VBE_q[8]} <= VDL_VBE_d[10:8];

   always @(posedge VDL_VBE0_clk_ctrl)
      if (VDL_VBE0_ena_ctrl)
	 {VDL_VBE_q[7], VDL_VBE_q[6], VDL_VBE_q[5], VDL_VBE_q[4], VDL_VBE_q[3],
	       VDL_VBE_q[2], VDL_VBE_q[1], VDL_VBE_q[0]} <= VDL_VBE_d[7:0];

   always @(posedge VDL_VDB0_clk_ctrl)
      if (VDL_VDB8_ena_ctrl)
	 {VDL_VDB_q[10], VDL_VDB_q[9], VDL_VDB_q[8]} <= VDL_VDB_d[10:8];

   always @(posedge VDL_VDB0_clk_ctrl)
      if (VDL_VDB0_ena_ctrl)
	 {VDL_VDB_q[7], VDL_VDB_q[6], VDL_VDB_q[5], VDL_VDB_q[4], VDL_VDB_q[3],
	       VDL_VDB_q[2], VDL_VDB_q[1], VDL_VDB_q[0]} <= VDL_VDB_d[7:0];

   always @(posedge VDL_VDE0_clk_ctrl)
      if (VDL_VDE8_ena_ctrl)
	 {VDL_VDE_q[10], VDL_VDE_q[9], VDL_VDE_q[8]} <= VDL_VDE_d[10:8];

   always @(posedge VDL_VDE0_clk_ctrl)
      if (VDL_VDE0_ena_ctrl)
	 {VDL_VDE_q[7], VDL_VDE_q[6], VDL_VDE_q[5], VDL_VDE_q[4], VDL_VDE_q[3],
	       VDL_VDE_q[2], VDL_VDE_q[1], VDL_VDE_q[0]} <= VDL_VDE_d[7:0];

   always @(posedge VDL_VBB0_clk_ctrl)
      if (VDL_VBB8_ena_ctrl)
	 {VDL_VBB_q[10], VDL_VBB_q[9], VDL_VBB_q[8]} <= VDL_VBB_d[10:8];

   always @(posedge VDL_VBB0_clk_ctrl)
      if (VDL_VBB0_ena_ctrl)
	 {VDL_VBB_q[7], VDL_VBB_q[6], VDL_VBB_q[5], VDL_VBB_q[4], VDL_VBB_q[3],
	       VDL_VBB_q[2], VDL_VBB_q[1], VDL_VBB_q[0]} <= VDL_VBB_d[7:0];

   always @(posedge VDL_VSS0_clk_ctrl)
      if (VDL_VSS8_ena_ctrl)
	 {VDL_VSS_q[10], VDL_VSS_q[9], VDL_VSS_q[8]} <= VDL_VSS_d[10:8];

   always @(posedge VDL_VSS0_clk_ctrl)
      if (VDL_VSS0_ena_ctrl)
	 {VDL_VSS_q[7], VDL_VSS_q[6], VDL_VSS_q[5], VDL_VSS_q[4], VDL_VSS_q[3],
	       VDL_VSS_q[2], VDL_VSS_q[1], VDL_VSS_q[0]} <= VDL_VSS_d[7:0];

   always @(posedge VDL_VFT0_clk_ctrl)
      if (VDL_VFT8_ena_ctrl)
	 {VDL_VFT_q[10], VDL_VFT_q[9], VDL_VFT_q[8]} <= VDL_VFT_d[10:8];

   always @(posedge VDL_VFT0_clk_ctrl)
      if (VDL_VFT0_ena_ctrl)
	 {VDL_VFT_q[7], VDL_VFT_q[6], VDL_VFT_q[5], VDL_VFT_q[4], VDL_VFT_q[3],
	       VDL_VFT_q[2], VDL_VFT_q[1], VDL_VFT_q[0]} <= VDL_VFT_d[7:0];

   always @(posedge VDL_VCT0_clk_ctrl)
      if (VDL_VCT8_ena)
	 VDL_VCT_q[8] <= VDL_VCT_d[8];

   always @(posedge VDL_VCT0_clk_ctrl)
      if (VDL_VCT0_ena_ctrl)
	 {VDL_VCT_q[7], VDL_VCT_q[6], VDL_VCT_q[5], VDL_VCT_q[4], VDL_VCT_q[3],
	       VDL_VCT_q[2], VDL_VCT_q[1], VDL_VCT_q[0]} <= VDL_VCT_d[7:0];

   always @(posedge VDL_VMD0_clk_ctrl)
      if (VDL_VMD0_ena_ctrl)
	 VDL_VMD_q <= VDL_VMD_d;

// Start of original equations

//  BYT SELECT 32 BIT
//  ADR==0
   assign FB_B[0] = FB_ADR[1:0] == 2'b00;

//  ADR==1
//  HIGH WORD
//  LONG UND LINE
   assign FB_B[1] = FB_ADR[1:0] == 2'b01 | (FB_SIZE1 & (!FB_SIZE0) &
	 (!FB_ADR[1])) | (FB_SIZE1 & FB_SIZE0) | ((!FB_SIZE1) & (!FB_SIZE0));

//  ADR==2
//  LONG UND LINE
   assign FB_B[2] = FB_ADR[1:0] == 2'b10 | (FB_SIZE1 & FB_SIZE0) | ((!FB_SIZE1)
	 & (!FB_SIZE0));

//  ADR==3
//  LOW WORD
//  LONG UND LINE
   assign FB_B[3] = FB_ADR[1:0] == 2'b11 | (FB_SIZE1 & (!FB_SIZE0) & FB_ADR[1])
	 | (FB_SIZE1 & FB_SIZE0) | ((!FB_SIZE1) & (!FB_SIZE0));

//  BYT SELECT 16 BIT
//  ADR==0
   assign FB_16B[0] = FB_ADR[0] == 1'b0;

//  ADR==1
//  NOT BYT
   assign FB_16B[1] = FB_ADR[0] == 1'b1 | (!((!FB_SIZE1) & FB_SIZE0));

//  ACP CLUT --
//  0-3FF/1024
   assign ACP_CLUT_CS = (!nFB_CS2) & FB_ADR[27:10] == 18'h0;
   assign ACP_CLUT_RD = ACP_CLUT_CS & (!nFB_OE);
   assign ACP_CLUT_WR = FB_B & {4{ACP_CLUT_CS}} & {4{!nFB_WR}};
   assign CLUT_TA_clk = MAIN_CLK;
   assign CLUT_TA_d = (ACP_CLUT_CS | FALCON_CLUT_CS | ST_CLUT_CS) &
	 (!VIDEO_MOD_TA);

// FALCON CLUT --
//  $F9800/$400
   assign FALCON_CLUT_CS = (!nFB_CS1) & FB_ADR[19:10] == 10'b11_1110_0110;

//  HIGH WORD
   assign FALCON_CLUT_RDH = FALCON_CLUT_CS & (!nFB_OE) & (!FB_ADR[1]);

//  LOW WORD
   assign FALCON_CLUT_RDL = FALCON_CLUT_CS & (!nFB_OE) & FB_ADR[1];
   assign FALCON_CLUT_WR[1:0] = FB_16B & {2{!FB_ADR[1]}} & {2{FALCON_CLUT_CS}}
	 & {2{!nFB_WR}};
   assign FALCON_CLUT_WR[3:2] = FB_16B & {2{FB_ADR[1]}} & {2{FALCON_CLUT_CS}} &
	 {2{!nFB_WR}};

//  ST CLUT --
//  $F8240/$20
   assign ST_CLUT_CS = (!nFB_CS1) & FB_ADR[19:5] == 15'b111_1100_0001_0010;
   assign ST_CLUT_RD = ST_CLUT_CS & (!nFB_OE);
   assign ST_CLUT_WR = FB_16B & {2{ST_CLUT_CS}} & {2{!nFB_WR}};

//  ST SHIFT MODE
   assign ST_SHIFT_MODE0_clk_ctrl = MAIN_CLK;

//  $F8260/2
   assign ST_SHIFT_MODE_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C130;
   assign ST_SHIFT_MODE_d = FB_AD[25:24];
   assign ST_SHIFT_MODE0_ena_ctrl = ST_SHIFT_MODE_CS & (!nFB_WR) & FB_B[0];

//  MONO
   assign COLOR1_1 = ST_SHIFT_MODE_q == 2'b10 & (!COLOR8) & ST_VIDEO &
	 (!ACP_VIDEO_ON);

//  4 FARBEN
   assign COLOR2 = ST_SHIFT_MODE_q == 2'b01 & (!COLOR8) & ST_VIDEO &
	 (!ACP_VIDEO_ON);

//  16 FARBEN
   assign COLOR4_1 = ST_SHIFT_MODE_q == 2'b00 & (!COLOR8) & ST_VIDEO &
	 (!ACP_VIDEO_ON);

//  FALCON SHIFT MODE
   assign FALCON_SHIFT_MODE0_clk_ctrl = MAIN_CLK;

//  $F8266/2
   assign FALCON_SHIFT_MODE_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C133;
   assign FALCON_SHIFT_MODE_d = FB_AD[26:16];
   assign FALCON_SHIFT_MODE8_ena_ctrl = FALCON_SHIFT_MODE_CS & (!nFB_WR) &
	 FB_B[2];
   assign FALCON_SHIFT_MODE0_ena_ctrl = FALCON_SHIFT_MODE_CS & (!nFB_WR) &
	 FB_B[3];
   assign CLUT_OFF = FALCON_SHIFT_MODE_q[3:0] & {4{COLOR4}};
   assign COLOR1_2 = FALCON_SHIFT_MODE_q[10] & (!COLOR16) & (!COLOR8) &
	 FALCON_VIDEO & (!ACP_VIDEO_ON);
   assign COLOR8_1 = FALCON_SHIFT_MODE_q[4] & (!COLOR16) & FALCON_VIDEO &
	 (!ACP_VIDEO_ON);
   assign COLOR16_1 = FALCON_SHIFT_MODE_q[8] & FALCON_VIDEO & (!ACP_VIDEO_ON);
   assign COLOR4_2 = (!COLOR1) & (!COLOR16) & (!COLOR8) & FALCON_VIDEO &
	 (!ACP_VIDEO_ON);

//  ACP VIDEO CONTROL BIT 0=ACP VIDEO ON, 1=POWER ON VIDEO DAC, 2=ACP 24BIT,3=ACP 16BIT,4=ACP 8BIT,5=ACP 1BIT, 6=FALCON SHIFT MODE;7=ST SHIFT MODE;9..8= VCLK FREQUENZ;15=-SYNC ALLOWED; 31..16=VIDEO_RAM_CTR,25=RANDFARBE EINSCHALTEN, 26=STANDARD ATARI SYNCS
   assign ACP_VCTR0_clk_ctrl = MAIN_CLK;

//  $400/4
   assign ACP_VCTR_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h100;
   assign ACP_VCTR_d[31:8] = FB_AD[31:8];
   assign ACP_VCTR_d[5:0] = FB_AD[5:0];
   assign ACP_VCTR24_ena_ctrl = ACP_VCTR_CS & FB_B[0] & (!nFB_WR);
   assign ACP_VCTR16_ena_ctrl = ACP_VCTR_CS & FB_B[1] & (!nFB_WR);
   assign ACP_VCTR8_ena_ctrl = ACP_VCTR_CS & FB_B[2] & (!nFB_WR);
   assign ACP_VCTR0_ena_ctrl = ACP_VCTR_CS & FB_B[3] & (!nFB_WR);
   assign ACP_VIDEO_ON = ACP_VCTR_q[0];
   assign nPD_VGA = ACP_VCTR_q[1];

//  ATARI MODUS
//  WENN 1 AUTOMATISCHE AUFLÖSUNG
   assign ATARI_SYNC = ACP_VCTR_q[26];

//  HORIZONTAL TIMING 640x480
   assign ATARI_HH0_clk_ctrl = MAIN_CLK;

//  $410/4
   assign ATARI_HH_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h104;
   assign ATARI_HH_d = FB_AD;
   assign ATARI_HH24_ena_ctrl = ATARI_HH_CS & FB_B[0] & (!nFB_WR);
   assign ATARI_HH16_ena_ctrl = ATARI_HH_CS & FB_B[1] & (!nFB_WR);
   assign ATARI_HH8_ena_ctrl = ATARI_HH_CS & FB_B[2] & (!nFB_WR);
   assign ATARI_HH0_ena_ctrl = ATARI_HH_CS & FB_B[3] & (!nFB_WR);

//  VERTIKAL TIMING 640x480
   assign ATARI_VH0_clk_ctrl = MAIN_CLK;

//  $414/4
   assign ATARI_VH_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h105;
   assign ATARI_VH_d = FB_AD;
   assign ATARI_VH24_ena_ctrl = ATARI_VH_CS & FB_B[0] & (!nFB_WR);
   assign ATARI_VH16_ena_ctrl = ATARI_VH_CS & FB_B[1] & (!nFB_WR);
   assign ATARI_VH8_ena_ctrl = ATARI_VH_CS & FB_B[2] & (!nFB_WR);
   assign ATARI_VH0_ena_ctrl = ATARI_VH_CS & FB_B[3] & (!nFB_WR);

//  HORIZONTAL TIMING 320x240
   assign ATARI_HL0_clk_ctrl = MAIN_CLK;

//  $418/4
   assign ATARI_HL_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h106;
   assign ATARI_HL_d = FB_AD;
   assign ATARI_HL24_ena_ctrl = ATARI_HL_CS & FB_B[0] & (!nFB_WR);
   assign ATARI_HL16_ena_ctrl = ATARI_HL_CS & FB_B[1] & (!nFB_WR);
   assign ATARI_HL8_ena_ctrl = ATARI_HL_CS & FB_B[2] & (!nFB_WR);
   assign ATARI_HL0_ena_ctrl = ATARI_HL_CS & FB_B[3] & (!nFB_WR);

//  VERTIKAL TIMING 320x240
   assign ATARI_VL0_clk_ctrl = MAIN_CLK;

//  $41C/4
   assign ATARI_VL_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h107;
   assign ATARI_VL_d = FB_AD;
   assign ATARI_VL24_ena_ctrl = ATARI_VL_CS & FB_B[0] & (!nFB_WR);
   assign ATARI_VL16_ena_ctrl = ATARI_VL_CS & FB_B[1] & (!nFB_WR);
   assign ATARI_VL8_ena_ctrl = ATARI_VL_CS & FB_B[2] & (!nFB_WR);
   assign ATARI_VL0_ena_ctrl = ATARI_VL_CS & FB_B[3] & (!nFB_WR);

//  VIDEO PLL CONFIG
//  $(F)000'0600-7FF ->6/2 WORD RESP LONG ONLY
   assign VIDEO_PLL_CONFIG_CS = (!nFB_CS2) & FB_ADR[27:9] == 19'h3 & FB_B[0] &
	 FB_B[1];
   assign VR_WR_clk = MAIN_CLK;
   assign VR_WR_d = VIDEO_PLL_CONFIG_CS & (!nFB_WR) & (!VR_BUSY) & (!VR_WR_q);
   assign VR_RD = VIDEO_PLL_CONFIG_CS & nFB_WR & (!VR_BUSY);
   assign VR_DOUT0_clk_ctrl = MAIN_CLK;
   assign VR_DOUT0_ena_ctrl = !VR_BUSY;
   assign VR_DOUT_d = VR_D;
   assign VR_FRQ0_clk_ctrl = MAIN_CLK;
   assign VR_FRQ0_ena_ctrl = VR_WR_q & FB_ADR[8:0] == 9'b0_0000_0100;
   assign VR_FRQ_d = FB_AD[23:16];

//  VIDEO PLL RECONFIG
//  $(F)000'0800
   assign VIDEO_PLL_RECONFIG_CS = (!nFB_CS2) & FB_ADR[27:0] == 28'h800 &
	 FB_B[0];
   assign VIDEO_RECONFIG_clk = MAIN_CLK;
   assign VIDEO_RECONFIG_d = VIDEO_PLL_RECONFIG_CS & (!nFB_WR) & (!VR_BUSY) &
	 (!VIDEO_RECONFIG_q);

// ----------------------------------------------------------------------------------------------------------------------
   assign VIDEO_RAM_CTR = ACP_VCTR_q[31:16];

// ------------ COLOR MODE IM ACP SETZEN
   assign COLOR1_3 = ACP_VCTR_q[5] & (!ACP_VCTR_q[4]) & (!ACP_VCTR_q[3]) &
	 (!ACP_VCTR_q[2]) & ACP_VIDEO_ON;
   assign COLOR8_2 = ACP_VCTR_q[4] & (!ACP_VCTR_q[3]) & (!ACP_VCTR_q[2]) &
	 ACP_VIDEO_ON;
   assign COLOR16_2 = ACP_VCTR_q[3] & (!ACP_VCTR_q[2]) & ACP_VIDEO_ON;
   assign COLOR24 = ACP_VCTR_q[2] & ACP_VIDEO_ON;
   assign ACP_CLUT = (ACP_VIDEO_ON & (COLOR1 | COLOR8)) | (ST_VIDEO & COLOR1);

//  ST ODER FALCON SHIFT MODE SETZEN WENN WRITE X..SHIFT REGISTER
   assign ACP_VCTR_d[7] = FALCON_SHIFT_MODE_CS & (!nFB_WR) & (!ACP_VIDEO_ON);
   assign ACP_VCTR_d[6] = ST_SHIFT_MODE_CS & (!nFB_WR) & (!ACP_VIDEO_ON);
   assign ACP_VCTR6_ena_ctrl = (FALCON_SHIFT_MODE_CS & (!nFB_WR)) |
	 (ST_SHIFT_MODE_CS & (!nFB_WR)) | (ACP_VCTR_CS & FB_B[3] & (!nFB_WR) &
	 FB_AD[0]);
   assign FALCON_VIDEO = ACP_VCTR_q[7];
   assign FALCON_CLUT = FALCON_VIDEO & (!ACP_VIDEO_ON) & (!COLOR16);
   assign ST_VIDEO = ACP_VCTR_q[6];
   assign ST_CLUT = ST_VIDEO & (!ACP_VIDEO_ON) & (!FALCON_CLUT) & (!COLOR1);
   assign CCSEL0_clk_ctrl = PIXEL_CLK;

//  ONLY FOR INFORMATION
   assign CCSEL_d = (3'b000 & {3{ST_CLUT}}) | (3'b001 & {3{FALCON_CLUT}}) |
	 (3'b100 & {3{ACP_CLUT}}) | (3'b101 & {3{COLOR16}}) | (3'b110 &
	 {3{COLOR24}}) | (3'b111 & {3{RAND_ON}});

//  DIVERSE (VIDEO)-REGISTER ----------------------------
//  RANDFARBE
   assign CCR0_clk_ctrl = MAIN_CLK;

//  $404/4
   assign CCR_CS = (!nFB_CS2) & FB_ADR[27:2] == 26'h101;
   assign CCR_d = FB_AD[23:0];
   assign CCR16_ena_ctrl = CCR_CS & FB_B[1] & (!nFB_WR);
   assign CCR8_ena_ctrl = CCR_CS & FB_B[2] & (!nFB_WR);
   assign CCR0_ena_ctrl = CCR_CS & FB_B[3] & (!nFB_WR);

// SYS CTR
//  $8006/2
   assign SYS_CTR_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C003;
   assign SYS_CTR0_clk_ctrl = MAIN_CLK;
   assign SYS_CTR_d = FB_AD[22:16];
   assign SYS_CTR0_ena_ctrl = SYS_CTR_CS & (!nFB_WR) & FB_B[3];
   assign BLITTER_ON = !SYS_CTR_q[3];

// VDL_LOF
//  $820E/2
   assign VDL_LOF_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C107;
   assign VDL_LOF0_clk_ctrl = MAIN_CLK;
   assign VDL_LOF_d = FB_AD[31:16];
   assign VDL_LOF8_ena_ctrl = VDL_LOF_CS & (!nFB_WR) & FB_B[2];
   assign VDL_LOF0_ena_ctrl = VDL_LOF_CS & (!nFB_WR) & FB_B[3];

// VDL_LWD
//  $8210/2
   assign VDL_LWD_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C108;
   assign VDL_LWD0_clk_ctrl = MAIN_CLK;
   assign VDL_LWD_d = FB_AD[31:16];
   assign VDL_LWD8_ena_ctrl = VDL_LWD_CS & (!nFB_WR) & FB_B[0];
   assign VDL_LWD0_ena_ctrl = VDL_LWD_CS & (!nFB_WR) & FB_B[1];

//  HORIZONTAL
//  VDL_HHT
//  $8282/2
   assign VDL_HHT_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C141;
   assign VDL_HHT0_clk_ctrl = MAIN_CLK;
   assign VDL_HHT_d = FB_AD[27:16];
   assign VDL_HHT8_ena_ctrl = VDL_HHT_CS & (!nFB_WR) & FB_B[2];
   assign VDL_HHT0_ena_ctrl = VDL_HHT_CS & (!nFB_WR) & FB_B[3];

//  VDL_HBE
//  $8286/2
   assign VDL_HBE_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C143;
   assign VDL_HBE0_clk_ctrl = MAIN_CLK;
   assign VDL_HBE_d = FB_AD[27:16];
   assign VDL_HBE8_ena_ctrl = VDL_HBE_CS & (!nFB_WR) & FB_B[2];
   assign VDL_HBE0_ena_ctrl = VDL_HBE_CS & (!nFB_WR) & FB_B[3];

//  VDL_HDB
//  $8288/2
   assign VDL_HDB_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C144;
   assign VDL_HDB0_clk_ctrl = MAIN_CLK;
   assign VDL_HDB_d = FB_AD[27:16];
   assign VDL_HDB8_ena_ctrl = VDL_HDB_CS & (!nFB_WR) & FB_B[0];
   assign VDL_HDB0_ena_ctrl = VDL_HDB_CS & (!nFB_WR) & FB_B[1];

//  VDL_HDE
//  $828A/2
   assign VDL_HDE_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C145;
   assign VDL_HDE0_clk_ctrl = MAIN_CLK;
   assign VDL_HDE_d = FB_AD[27:16];
   assign VDL_HDE8_ena_ctrl = VDL_HDE_CS & (!nFB_WR) & FB_B[2];
   assign VDL_HDE0_ena_ctrl = VDL_HDE_CS & (!nFB_WR) & FB_B[3];

//  VDL_HBB
//  $8284/2
   assign VDL_HBB_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C142;
   assign VDL_HBB0_clk_ctrl = MAIN_CLK;
   assign VDL_HBB_d = FB_AD[27:16];
   assign VDL_HBB8_ena_ctrl = VDL_HBB_CS & (!nFB_WR) & FB_B[0];
   assign VDL_HBB0_ena_ctrl = VDL_HBB_CS & (!nFB_WR) & FB_B[1];

//  VDL_HSS
//  $828C/2
   assign VDL_HSS_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C146;
   assign VDL_HSS0_clk_ctrl = MAIN_CLK;
   assign VDL_HSS_d = FB_AD[27:16];
   assign VDL_HSS8_ena_ctrl = VDL_HSS_CS & (!nFB_WR) & FB_B[0];
   assign VDL_HSS0_ena_ctrl = VDL_HSS_CS & (!nFB_WR) & FB_B[1];

//  VERTIKAL
//  VDL_VBE
//  $82A6/2
   assign VDL_VBE_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C153;
   assign VDL_VBE0_clk_ctrl = MAIN_CLK;
   assign VDL_VBE_d = FB_AD[26:16];
   assign VDL_VBE8_ena_ctrl = VDL_VBE_CS & (!nFB_WR) & FB_B[2];
   assign VDL_VBE0_ena_ctrl = VDL_VBE_CS & (!nFB_WR) & FB_B[3];

//  VDL_VDB
//  $82A8/2
   assign VDL_VDB_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C154;
   assign VDL_VDB0_clk_ctrl = MAIN_CLK;
   assign VDL_VDB_d = FB_AD[26:16];
   assign VDL_VDB8_ena_ctrl = VDL_VDB_CS & (!nFB_WR) & FB_B[0];
   assign VDL_VDB0_ena_ctrl = VDL_VDB_CS & (!nFB_WR) & FB_B[1];

//  VDL_VDE
//  $82AA/2
   assign VDL_VDE_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C155;
   assign VDL_VDE0_clk_ctrl = MAIN_CLK;
   assign VDL_VDE_d = FB_AD[26:16];
   assign VDL_VDE8_ena_ctrl = VDL_VDE_CS & (!nFB_WR) & FB_B[2];
   assign VDL_VDE0_ena_ctrl = VDL_VDE_CS & (!nFB_WR) & FB_B[3];

//  VDL_VBB
//  $82A4/2
   assign VDL_VBB_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C152;
   assign VDL_VBB0_clk_ctrl = MAIN_CLK;
   assign VDL_VBB_d = FB_AD[26:16];
   assign VDL_VBB8_ena_ctrl = VDL_VBB_CS & (!nFB_WR) & FB_B[0];
   assign VDL_VBB0_ena_ctrl = VDL_VBB_CS & (!nFB_WR) & FB_B[1];

//  VDL_VSS
//  $82AC/2
   assign VDL_VSS_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C156;
   assign VDL_VSS0_clk_ctrl = MAIN_CLK;
   assign VDL_VSS_d = FB_AD[26:16];
   assign VDL_VSS8_ena_ctrl = VDL_VSS_CS & (!nFB_WR) & FB_B[0];
   assign VDL_VSS0_ena_ctrl = VDL_VSS_CS & (!nFB_WR) & FB_B[1];

//  VDL_VFT
//  $82A2/2
   assign VDL_VFT_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C151;
   assign VDL_VFT0_clk_ctrl = MAIN_CLK;
   assign VDL_VFT_d = FB_AD[26:16];
   assign VDL_VFT8_ena_ctrl = VDL_VFT_CS & (!nFB_WR) & FB_B[2];
   assign VDL_VFT0_ena_ctrl = VDL_VFT_CS & (!nFB_WR) & FB_B[3];

//  VDL_VCT
//  $82C0/2
   assign VDL_VCT_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C160;
   assign VDL_VCT0_clk_ctrl = MAIN_CLK;
   assign VDL_VCT_d = FB_AD[24:16];
   assign VDL_VCT8_ena = VDL_VCT_CS & (!nFB_WR) & FB_B[0];
   assign VDL_VCT0_ena_ctrl = VDL_VCT_CS & (!nFB_WR) & FB_B[1];

//  VDL_VMD
//  $82C2/2
   assign VDL_VMD_CS = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C161;
   assign VDL_VMD0_clk_ctrl = MAIN_CLK;
   assign VDL_VMD_d = FB_AD[19:16];
   assign VDL_VMD0_ena_ctrl = VDL_VMD_CS & (!nFB_WR) & FB_B[3];

// - REGISTER OUT
   assign u0_data = ({16{ST_SHIFT_MODE_CS}} & {6'b00_0000, ST_SHIFT_MODE_q,
	 8'b0000_0000}) | ({16{FALCON_SHIFT_MODE_CS}} & {5'b0_0000,
	 FALCON_SHIFT_MODE_q}) | ({16{SYS_CTR_CS}} & {9'b1_0000_0000,
	 SYS_CTR_q[6:4], !BLITTER_RUN, SYS_CTR_q[2:0]}) | ({16{VDL_LOF_CS}} &
	 VDL_LOF_q) | ({16{VDL_LWD_CS}} & VDL_LWD_q) | ({16{VDL_HBE_CS}} &
	 {4'b0000, VDL_HBE_q}) | ({16{VDL_HDB_CS}} & {4'b0000, VDL_HDB_q}) |
	 ({16{VDL_HDE_CS}} & {4'b0000, VDL_HDE_q}) | ({16{VDL_HBB_CS}} &
	 {4'b0000, VDL_HBB_q}) | ({16{VDL_HSS_CS}} & {4'b0000, VDL_HSS_q}) |
	 ({16{VDL_HHT_CS}} & {4'b0000, VDL_HHT_q}) | ({16{VDL_VBE_CS}} &
	 {5'b0_0000, VDL_VBE_q}) | ({16{VDL_VDB_CS}} & {5'b0_0000, VDL_VDB_q})
	 | ({16{VDL_VDE_CS}} & {5'b0_0000, VDL_VDE_q}) | ({16{VDL_VBB_CS}} &
	 {5'b0_0000, VDL_VBB_q}) | ({16{VDL_VSS_CS}} & {5'b0_0000, VDL_VSS_q})
	 | ({16{VDL_VFT_CS}} & {5'b0_0000, VDL_VFT_q}) | ({16{VDL_VCT_CS}} &
	 {7'b000_0000, VDL_VCT_q}) | ({16{VDL_VMD_CS}} & {12'b0000_0000_0000,
	 VDL_VMD_q}) | ({16{ACP_VCTR_CS}} & ACP_VCTR_q[31:16]) |
	 ({16{ATARI_HH_CS}} & ATARI_HH_q[31:16]) | ({16{ATARI_VH_CS}} &
	 ATARI_VH_q[31:16]) | ({16{ATARI_HL_CS}} & ATARI_HL_q[31:16]) |
	 ({16{ATARI_VL_CS}} & ATARI_VL_q[31:16]) | ({16{CCR_CS}} &
	 {8'b0000_0000, CCR_q[23:16]}) | ({16{VIDEO_PLL_CONFIG_CS}} &
	 {7'b000_0000, VR_DOUT_q}) | ({16{VIDEO_PLL_RECONFIG_CS}} & {VR_BUSY,
	 4'b0000, VR_WR_q, VR_RD, VIDEO_RECONFIG_q, 8'b1111_1010});
   assign u0_enabledt = (ST_SHIFT_MODE_CS | FALCON_SHIFT_MODE_CS | ACP_VCTR_CS
	 | CCR_CS | SYS_CTR_CS | VDL_LOF_CS | VDL_LWD_CS | VDL_HBE_CS |
	 VDL_HDB_CS | VDL_HDE_CS | VDL_HBB_CS | VDL_HSS_CS | VDL_HHT_CS |
	 ATARI_HH_CS | ATARI_VH_CS | ATARI_HL_CS | ATARI_VL_CS |
	 VIDEO_PLL_CONFIG_CS | VIDEO_PLL_RECONFIG_CS | VDL_VBE_CS | VDL_VDB_CS
	 | VDL_VDE_CS | VDL_VBB_CS | VDL_VSS_CS | VDL_VFT_CS | VDL_VCT_CS |
	 VDL_VMD_CS) & (!nFB_OE);
   assign FB_AD[31:16] = u0_tridata;
   assign u1_data = ({16{ACP_VCTR_CS}} & ACP_VCTR_q[15:0]) | ({16{ATARI_HH_CS}}
	 & ATARI_HH_q[15:0]) | ({16{ATARI_VH_CS}} & ATARI_VH_q[15:0]) |
	 ({16{ATARI_HL_CS}} & ATARI_HL_q[15:0]) | ({16{ATARI_VL_CS}} &
	 ATARI_VL_q[15:0]) | ({16{CCR_CS}} & CCR_q[15:0]);
   assign u1_enabledt = (ACP_VCTR_CS | CCR_CS | ATARI_HH_CS | ATARI_VH_CS |
	 ATARI_HL_CS | ATARI_VL_CS) & (!nFB_OE);
   assign FB_AD[15:0] = u1_tridata;
   assign VIDEO_MOD_TA = CLUT_TA_q | ST_SHIFT_MODE_CS | FALCON_SHIFT_MODE_CS |
	 ACP_VCTR_CS | SYS_CTR_CS | VDL_LOF_CS | VDL_LWD_CS | VDL_HBE_CS |
	 VDL_HDB_CS | VDL_HDE_CS | VDL_HBB_CS | VDL_HSS_CS | VDL_HHT_CS |
	 ATARI_HH_CS | ATARI_VH_CS | ATARI_HL_CS | ATARI_VL_CS | VDL_VBE_CS |
	 VDL_VDB_CS | VDL_VDE_CS | VDL_VBB_CS | VDL_VSS_CS | VDL_VFT_CS |
	 VDL_VCT_CS | VDL_VMD_CS;

//  VIDEO AUSGABE SETZEN
   assign CLK17M_clk = CLK33M;
   assign CLK17M_d = !CLK17M_q;
   assign CLK13M_clk = CLK25M;
   assign CLK13M_d = !CLK13M_q;
   assign PIXEL_CLK = (CLK13M_q & (!ACP_VIDEO_ON) & (FALCON_VIDEO | ST_VIDEO) &
	 ((VDL_VMD_q[2] & VDL_VCT_q[2]) | VDL_VCT_q[0])) | (CLK17M_q &
	 (!ACP_VIDEO_ON) & (FALCON_VIDEO | ST_VIDEO) & ((VDL_VMD_q[2] &
	 (!VDL_VCT_q[2])) | VDL_VCT_q[0])) | (CLK25M & (!ACP_VIDEO_ON) &
	 (FALCON_VIDEO | ST_VIDEO) & (!VDL_VMD_q[2]) & VDL_VCT_q[2] &
	 (!VDL_VCT_q[0])) | (CLK33M & (!ACP_VIDEO_ON) & (FALCON_VIDEO |
	 ST_VIDEO) & (!VDL_VMD_q[2]) & (!VDL_VCT_q[2]) & (!VDL_VCT_q[0])) |
	 (CLK25M & ACP_VIDEO_ON & ACP_VCTR_q[9:8] == 2'b00) | (CLK33M &
	 ACP_VIDEO_ON & ACP_VCTR_q[9:8] == 2'b01) | (CLK_VIDEO & ACP_VIDEO_ON &
	 ACP_VCTR_q[9]);

// ------------------------------------------------------------
//  HORIZONTALE SYNC LÄNGE in PIXEL_CLK
// --------------------------------------------------------------
   assign HSY_LEN0_clk_ctrl = MAIN_CLK;

//  hsync puls length in pixeln=frequenz/ = 500ns
   assign HSY_LEN_d = (8'b0000_1110 & {8{!ACP_VIDEO_ON}} & ({8{FALCON_VIDEO}} |
	 {8{ST_VIDEO}}) & (({8{VDL_VMD_q[2]}} & {8{VDL_VCT_q[2]}}) |
	 {8{VDL_VCT_q[0]}})) | (8'b0001_0000 & {8{!ACP_VIDEO_ON}} &
	 ({8{FALCON_VIDEO}} | {8{ST_VIDEO}}) & (({8{VDL_VMD_q[2]}} &
	 {8{!VDL_VCT_q[2]}}) | {8{VDL_VCT_q[0]}})) | (8'b0001_1100 &
	 {8{!ACP_VIDEO_ON}} & ({8{FALCON_VIDEO}} | {8{ST_VIDEO}}) &
	 {8{!VDL_VMD_q[2]}} & {8{VDL_VCT_q[2]}} & {8{!VDL_VCT_q[0]}}) |
	 (8'b0010_0000 & {8{!ACP_VIDEO_ON}} & ({8{FALCON_VIDEO}} |
	 {8{ST_VIDEO}}) & {8{!VDL_VMD_q[2]}} & {8{!VDL_VCT_q[2]}} &
	 {8{!VDL_VCT_q[0]}}) | (8'b0001_1100 & {8{ACP_VIDEO_ON}} &
	 {8{ACP_VCTR_q[9:8] == 2'b00}}) | (8'b0010_0000 & {8{ACP_VIDEO_ON}} &
	 {8{ACP_VCTR_q[9:8] == 2'b01}}) | ((8'b0001_0000 + {1'b0,
	 VR_FRQ_q[7:1]}) & {8{ACP_VIDEO_ON}} & {8{ACP_VCTR_q[9]}});

//  MULTIPLIKATIONS FAKTOR
   assign MULF = (6'b00_0010 & {6{!ST_VIDEO}} & {6{VDL_VMD_q[2]}}) |
	 (6'b00_0100 & {6{!ST_VIDEO}} & {6{!VDL_VMD_q[2]}}) | (6'b01_0000 &
	 {6{ST_VIDEO}} & {6{VDL_VMD_q[2]}}) | (6'b10_0000 & {6{ST_VIDEO}} &
	 {6{!VDL_VMD_q[2]}});

//  BREITE IN PIXELN
   assign HDIS_LEN = (12'b0001_0100_0000 & {12{VDL_VMD_q[2]}}) |
	 (12'b0010_1000_0000 & {12{!VDL_VMD_q[2]}});

//  DOPPELZEILENMODUS
   assign DOP_ZEI_clk = MAIN_CLK;

//  ZEILENVERDOPPELUNG EIN AUS
   assign DOP_ZEI_d = VDL_VMD_q[0] & ST_VIDEO;
   assign INTER_ZEI_clk = PIXEL_CLK;

//  EINSCHIEBEZEILE AUF "DOPPEL" ZEILEN UND ZEILE NULL WEGEN SYNC
//  EINSCHIEBEZEILE AUF "NORMAL" ZEILEN UND ZEILE NULL WEGEN SYNC
   assign INTER_ZEI_d = (DOP_ZEI_q & VVCNT_q[0] != VDIS_START[0] & VVCNT_q !=
	 11'b000_0000_0000 & VHCNT_q < (HDIS_END - 12'b0000_0000_0001)) |
	 (DOP_ZEI_q & VVCNT_q[0] == VDIS_START[0] & VVCNT_q !=
	 11'b000_0000_0000 & VHCNT_q > (HDIS_END - 12'b0000_0000_0010));
   assign DOP_FIFO_CLR_clk = PIXEL_CLK;

//  DOPPELZEILENFIFO LÖSCHEN AM ENDE DER DOPPELZEILE UND BEI MAIN FIFO START
   assign DOP_FIFO_CLR_d = (INTER_ZEI_q & HSYNC_START_q) | SYNC_PIX_q;

//  GE
   assign RAND_LINKS_FULL = VDL_HBE_q * {7'b000_0000, MULF[5:1]};

//  GE
   assign HS_START_FULL = ((VDL_HHT_q + 24'h1) + VDL_HSS_q) * {7'b000_0000,
	 MULF[5:1]};

//  GE
   assign H_TOTAL_FULL = (VDL_HHT_q + 24'h2) * {6'b00_0000, MULF};
   assign RAND_LINKS = (VDL_HBE_q & {12{ACP_VIDEO_ON}}) | (12'b0000_0001_0101 &
	 {12{!ACP_VIDEO_ON}} & {12{ATARI_SYNC}} & {12{VDL_VMD_q[2]}}) |
	 (12'b0000_0010_1010 & {12{!ACP_VIDEO_ON}} & {12{ATARI_SYNC}} &
	 {12{!VDL_VMD_q[2]}}) | (RAND_LINKS_FULL[11:0] & {12{!ACP_VIDEO_ON}} &
	 {12{!ATARI_SYNC}});
   assign HDIS_START = (VDL_HDB_q & {12{ACP_VIDEO_ON}}) | ((RAND_LINKS +
	 12'b0000_0000_0001) & {12{!ACP_VIDEO_ON}});
   assign HDIS_END = (VDL_HDE_q & {12{ACP_VIDEO_ON}}) | ((RAND_LINKS +
	 HDIS_LEN) & {12{!ACP_VIDEO_ON}});
   assign RAND_RECHTS = (VDL_HBB_q & {12{ACP_VIDEO_ON}}) | ((HDIS_END +
	 12'b0000_0000_0001) & {12{!ACP_VIDEO_ON}});
   assign HS_START = (VDL_HSS_q & {12{ACP_VIDEO_ON}}) | (ATARI_HL_q[11:0] &
	 {12{!ACP_VIDEO_ON}} & {12{ATARI_SYNC}} & {12{VDL_VMD_q[2]}}) |
	 (ATARI_HH_q[11:0] & {12{!ACP_VIDEO_ON}} & {12{ATARI_SYNC}} &
	 {12{!VDL_VMD_q[2]}}) | (HS_START_FULL[11:0] & {12{!ACP_VIDEO_ON}} &
	 {12{!ATARI_SYNC}});
   assign H_TOTAL = (VDL_HHT_q & {12{ACP_VIDEO_ON}}) | (ATARI_HL_q[27:16] &
	 {12{!ACP_VIDEO_ON}} & {12{ATARI_SYNC}} & {12{VDL_VMD_q[2]}}) |
	 (ATARI_HH_q[27:16] & {12{!ACP_VIDEO_ON}} & {12{ATARI_SYNC}} &
	 {12{!VDL_VMD_q[2]}}) | (H_TOTAL_FULL[11:0] & {12{!ACP_VIDEO_ON}} &
	 {12{!ATARI_SYNC}});
   assign RAND_OBEN = (VDL_VBE_q & {11{ACP_VIDEO_ON}}) | (11'b000_0001_1111 &
	 {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}}) | ({1'b0, VDL_VBE_q[10:1]} &
	 {11{!ACP_VIDEO_ON}} & {11{!ATARI_SYNC}});
   assign VDIS_START = (VDL_VDB_q & {11{ACP_VIDEO_ON}}) | (11'b000_0010_0000 &
	 {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}}) | (({1'b0, VDL_VDB_q[10:1]} +
	 11'b000_0000_0001) & {11{!ACP_VIDEO_ON}} & {11{!ATARI_SYNC}});
   assign VDIS_END = (VDL_VDE_q & {11{ACP_VIDEO_ON}}) | (11'b001_1010_1111 &
	 {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}} & {11{ST_VIDEO}}) |
	 (11'b001_1111_1111 & {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}} &
	 {11{!ST_VIDEO}}) | ({1'b0, VDL_VDE_q[10:1]} & {11{!ACP_VIDEO_ON}} &
	 {11{!ATARI_SYNC}});
   assign RAND_UNTEN = (VDL_VBB_q & {11{ACP_VIDEO_ON}}) | ((VDIS_END +
	 11'b000_0000_0001) & {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}}) |
	 (({1'b0, VDL_VBB_q[10:1]} + 11'b000_0000_0001) & {11{!ACP_VIDEO_ON}} &
	 {11{!ATARI_SYNC}});
   assign VS_START = (VDL_VSS_q & {11{ACP_VIDEO_ON}}) | (ATARI_VL_q[10:0] &
	 {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}} & {11{VDL_VMD_q[2]}}) |
	 (ATARI_VH_q[10:0] & {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}} &
	 {11{!VDL_VMD_q[2]}}) | ({1'b0, VDL_VSS_q[10:1]} & {11{!ACP_VIDEO_ON}}
	 & {11{!ATARI_SYNC}});
   assign V_TOTAL = (VDL_VFT_q & {11{ACP_VIDEO_ON}}) | (ATARI_VL_q[26:16] &
	 {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}} & {11{VDL_VMD_q[2]}}) |
	 (ATARI_VH_q[26:16] & {11{!ACP_VIDEO_ON}} & {11{ATARI_SYNC}} &
	 {11{!VDL_VMD_q[2]}}) | ({1'b0, VDL_VFT_q[10:1]} & {11{!ACP_VIDEO_ON}}
	 & {11{!ATARI_SYNC}});

//  ZÄHLER
   assign LAST_clk = PIXEL_CLK;
   assign LAST_d = VHCNT_q == (H_TOTAL - 12'b0000_0000_0010);
   assign VHCNT0_clk_ctrl = PIXEL_CLK;
   assign VHCNT_d = (VHCNT_q + 12'b0000_0000_0001) & {12{!LAST_q}};
   assign VVCNT0_clk_ctrl = PIXEL_CLK;
   assign VVCNT0_ena_ctrl = LAST_q;
   assign VVCNT_d = (VVCNT_q + 11'b000_0000_0001) & {11{VVCNT_q != (V_TOTAL -
	 11'b000_0000_0001)}};

//  DISPLAY ON OFF
   assign DPO_ZL_clk = PIXEL_CLK;

//  1 ZEILE DAVOR ON OFF
   assign DPO_ZL_d = VVCNT_q > (RAND_OBEN - 11'b000_0000_0001) & VVCNT_q <
	 (RAND_UNTEN - 11'b000_0000_0001);

//  AM ZEILENENDE ÜBERNEHMEN
   assign DPO_ZL_ena = LAST_q;
   assign DPO_ON_clk = PIXEL_CLK;

//  BESSER EINZELN WEGEN TIMING
   assign DPO_ON_d = VHCNT_q == RAND_LINKS;
   assign DPO_OFF_clk = PIXEL_CLK;
   assign DPO_OFF_d = VHCNT_q == (RAND_RECHTS - 12'b0000_0000_0001);
   assign DISP_ON_clk = PIXEL_CLK;
   assign DISP_ON_d = (DISP_ON_q & (!DPO_OFF_q)) | (DPO_ON_q & DPO_ZL_q);

//  DATENTRANSFER ON OFF
   assign VDO_ON_clk = PIXEL_CLK;

//  BESSER EINZELN WEGEN TIMING
   assign VDO_ON_d = VHCNT_q == (HDIS_START - 12'b0000_0000_0001);
   assign VDO_OFF_clk = PIXEL_CLK;
   assign VDO_OFF_d = VHCNT_q == HDIS_END;
   assign VDO_ZL_clk = PIXEL_CLK;

//  AM ZEILENENDE ÜBERNEHMEN
   assign VDO_ZL_ena = LAST_q;

//  1 ZEILE DAVOR ON OFF
   assign VDO_ZL_d = VVCNT_q >= (VDIS_START - 11'b000_0000_0001) & VVCNT_q <
	 VDIS_END;
   assign VDTRON_clk = PIXEL_CLK;
   assign VDTRON_d = (VDTRON_q & (!VDO_OFF_q)) | (VDO_ON_q & VDO_ZL_q);

//  VERZÖGERUNG UND SYNC
   assign HSYNC_START_clk = PIXEL_CLK;
   assign HSYNC_START_d = VHCNT_q == (HS_START - 12'b0000_0000_0011);
   assign HSYNC_I0_clk_ctrl = PIXEL_CLK;
   assign HSYNC_I_d = (HSY_LEN_q & {8{HSYNC_START_q}}) | ((HSYNC_I_q -
	 8'b0000_0001) & {8{!HSYNC_START_q}} & {8{HSYNC_I_q != 8'b0000_0000}});
   assign VSYNC_START_clk = PIXEL_CLK;
   assign VSYNC_START_ena = LAST_q;

//  start am ende der Zeile vor dem vsync
   assign VSYNC_START_d = VVCNT_q == (VS_START - 11'b000_0000_0011);
   assign VSYNC_I0_clk_ctrl = PIXEL_CLK;

//  start am ende der Zeile vor dem vsync
   assign VSYNC_I0_ena_ctrl = LAST_q;

//  3 zeilen vsync length
//  runterzählen bis 0
   assign VSYNC_I_d = (3'b011 & {3{VSYNC_START_q}}) | ((VSYNC_I_q - 3'b001) &
	 {3{!VSYNC_START_q}} & {3{VSYNC_I_q != 3'b000}});
   assign VERZ2_0_clk_ctrl = PIXEL_CLK;
   assign VERZ1_0_clk_ctrl = PIXEL_CLK;
   assign VERZ0_0_clk_ctrl = PIXEL_CLK;
   assign {VERZ2__d[1], VERZ1__d[1], VERZ0__d[1]} = {VERZ2__q[0], VERZ1__q[0],
	 VERZ0__q[0]};
   assign {VERZ2__d[2], VERZ1__d[2], VERZ0__d[2]} = {VERZ2__q[1], VERZ1__q[1],
	 VERZ0__q[1]};
   assign {VERZ2__d[3], VERZ1__d[3], VERZ0__d[3]} = {VERZ2__q[2], VERZ1__q[2],
	 VERZ0__q[2]};
   assign {VERZ2__d[4], VERZ1__d[4], VERZ0__d[4]} = {VERZ2__q[3], VERZ1__q[3],
	 VERZ0__q[3]};
   assign {VERZ2__d[5], VERZ1__d[5], VERZ0__d[5]} = {VERZ2__q[4], VERZ1__q[4],
	 VERZ0__q[4]};
   assign {VERZ2__d[6], VERZ1__d[6], VERZ0__d[6]} = {VERZ2__q[5], VERZ1__q[5],
	 VERZ0__q[5]};
   assign {VERZ2__d[7], VERZ1__d[7], VERZ0__d[7]} = {VERZ2__q[6], VERZ1__q[6],
	 VERZ0__q[6]};
   assign {VERZ2__d[8], VERZ1__d[8], VERZ0__d[8]} = {VERZ2__q[7], VERZ1__q[7],
	 VERZ0__q[7]};
   assign {VERZ2__d[9], VERZ1__d[9], VERZ0__d[9]} = {VERZ2__q[8], VERZ1__q[8],
	 VERZ0__q[8]};
   assign VERZ0__d[0] = DISP_ON_q;
   assign VERZ1_0_d_1 = HSYNC_I_q != 8'b0000_0000;

//  NUR MÖGLICH WENN BEIDE
   assign VERZ1_0_d_2 = (((!ACP_VCTR_q[15]) | (!VDL_VCT_q[6])) & HSYNC_I_q !=
	 8'b0000_0000) | (ACP_VCTR_q[15] & VDL_VCT_q[6] & HSYNC_I_q ==
	 8'b0000_0000);

//  NUR MÖGLICH WENN BEIDE
   assign VERZ2__d[0] = (((!ACP_VCTR_q[15]) | (!VDL_VCT_q[5])) & VSYNC_I_q !=
	 3'b000) | (ACP_VCTR_q[15] & VDL_VCT_q[5] & VSYNC_I_q == 3'b000);
   assign nBLANK_clk = PIXEL_CLK;
   assign nBLANK_d = VERZ0__q[8];
   assign HSYNC_clk = PIXEL_CLK;
   assign HSYNC_d = VERZ1__q[9];
   assign VSYNC_clk = PIXEL_CLK;
   assign VSYNC_d = VERZ2__q[9];
   assign nSYNC = gnd;

//  RANDFARBE MACHEN ------------------------------------
   assign RAND0_clk_ctrl = PIXEL_CLK;
   assign RAND_d[0] = DISP_ON_q & (!VDTRON_q) & ACP_VCTR_q[25];
   assign RAND_d[1] = RAND_q[0];
   assign RAND_d[2] = RAND_q[1];
   assign RAND_d[3] = RAND_q[2];
   assign RAND_d[4] = RAND_q[3];
   assign RAND_d[5] = RAND_q[4];
   assign RAND_d[6] = RAND_q[5];
   assign RAND_ON = RAND_q[6];

// --------------------------------------------------------
   assign CLR_FIFO_clk = PIXEL_CLK;
   assign CLR_FIFO_ena = LAST_q;

//  IN LETZTER ZEILE LÖSCHEN
   assign CLR_FIFO_d = VVCNT_q == (V_TOTAL - 11'b000_0000_0010);
   assign START_ZEILE_clk = PIXEL_CLK;
   assign START_ZEILE_ena = LAST_q;

//  ZEILE 1
   assign START_ZEILE_d = VVCNT_q == 11'b000_0000_0000;
   assign SYNC_PIX_clk = PIXEL_CLK;

//  SUB PIXEL ZÄHLER SYNCHRONISIEREN
   assign SYNC_PIX_d = VHCNT_q == 12'b0000_0000_0011 & START_ZEILE_q;
   assign SYNC_PIX1_clk = PIXEL_CLK;

//  SUB PIXEL ZÄHLER SYNCHRONISIEREN
   assign SYNC_PIX1_d = VHCNT_q == 12'b0000_0000_0101 & START_ZEILE_q;
   assign SYNC_PIX2_clk = PIXEL_CLK;

//  SUB PIXEL ZÄHLER SYNCHRONISIEREN
   assign SYNC_PIX2_d = VHCNT_q == 12'b0000_0000_0111 & START_ZEILE_q;
   assign SUB_PIXEL_CNT0_clk_ctrl = PIXEL_CLK;
   assign SUB_PIXEL_CNT0_ena_ctrl = VDTRON_q | SYNC_PIX_q;

// count up if display on sonst clear bei sync pix
   assign SUB_PIXEL_CNT_d = (SUB_PIXEL_CNT_q + 7'b000_0001) & {7{!SYNC_PIX_q}};
   assign FIFO_RDE_clk = PIXEL_CLK;

//  3 CLOCK ZUSÄTZLICH FÜR FIFO SHIFT DATAOUT UND SHIFT RIGTH POSITION
   assign FIFO_RDE_d = (((SUB_PIXEL_CNT_q == 7'b000_0001 & COLOR1) |
	 (SUB_PIXEL_CNT_q[5:0] == 6'b00_0001 & COLOR2) | (SUB_PIXEL_CNT_q[4:0]
	 == 5'b0_0001 & COLOR4) | (SUB_PIXEL_CNT_q[3:0] == 4'b0001 & COLOR8) |
	 (SUB_PIXEL_CNT_q[2:0] == 3'b001 & COLOR16) | (SUB_PIXEL_CNT_q[1:0] ==
	 2'b01 & COLOR24)) & VDTRON_q) | SYNC_PIX_q | SYNC_PIX1_q |
	 SYNC_PIX2_q;
   assign CLUT_MUX_ADR0_clk_ctrl = PIXEL_CLK;
   assign CLUT_MUX_AV1_0_clk_ctrl = PIXEL_CLK;
   assign CLUT_MUX_AV0_0_clk_ctrl = PIXEL_CLK;
   assign CLUT_MUX_AV0__d = SUB_PIXEL_CNT_q[3:0];
   assign CLUT_MUX_AV1__d = CLUT_MUX_AV0__q;
   assign CLUT_MUX_ADR_d = CLUT_MUX_AV1__q;


// Assignments added to explicitly combine the
// effects of multiple drivers in the source
   assign COLOR16 = COLOR16_1 | COLOR16_2;
   assign VERZ1__d[0] = VERZ1_0_d_1 | VERZ1_0_d_2;
   assign COLOR4 = COLOR4_1 | COLOR4_2;
   assign COLOR1 = COLOR1_1 | COLOR1_2 | COLOR1_3;
   assign COLOR8 = COLOR8_1 | COLOR8_2;

// Define power signal(s)
   assign gnd = 1'b0;
endmodule
