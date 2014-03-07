// Xilinx XPort Language Converter, Version 4.1 (110)
// 
// AHDL    Design Source: DDR_CTR.tdf
// Verilog Design Output: DDR_CTR.v
// Created 03-Mar-2014 09:18 PM
//
// Copyright (c) 2014, Xilinx, Inc.  All Rights Reserved.
// Xilinx Inc makes no warranty, expressed or implied, with respect to
// the operation and/or functionality of the converted output files.
// 

// DDR_CTR


//  CREATED BY FREDI ASCHWANDEN
//  FIFO WATER MARK
//  {{ALTERA_PARAMETERS_BEGIN}} DO NOT REMOVE THIS LINE!
//  {{ALTERA_PARAMETERS_END}} DO NOT REMOVE THIS LINE!
module DDR_CTR(FB_ADR, nFB_CS1, nFB_CS2, nFB_CS3, nFB_OE, FB_SIZE0, FB_SIZE1,
      nRSTO, MAIN_CLK, FB_ALE, nFB_WR, DDR_SYNC_66M, CLR_FIFO, VIDEO_RAM_CTR,
      BLITTER_ADR, BLITTER_SIG, BLITTER_WR, DDRCLK0, CLK33M, FIFO_MW, VA, nVWE,
      nVRAS, nVCS, VCKE, nVCAS, FB_LE, FB_VDOE, SR_FIFO_WRE, SR_DDR_FB,
      SR_DDR_WR, SR_DDRWR_D_SEL, SR_VDMP, VIDEO_DDR_TA, SR_BLITTER_DACK, BA,
      DDRWR_D_SEL1, VDM_SEL, FB_AD);

//  {{ALTERA_IO_BEGIN}} DO NOT REMOVE THIS LINE!
//  {{ALTERA_IO_END}} DO NOT REMOVE THIS LINE!
   input [31:0] FB_ADR;
   input nFB_CS1, nFB_CS2, nFB_CS3, nFB_OE, FB_SIZE0, FB_SIZE1, nRSTO,
	 MAIN_CLK, FB_ALE, nFB_WR, DDR_SYNC_66M, CLR_FIFO;
   input [15:0] VIDEO_RAM_CTR;
   input [31:0] BLITTER_ADR;
   input BLITTER_SIG, BLITTER_WR, DDRCLK0, CLK33M;
   input [8:0] FIFO_MW;
   output [12:0] VA;
   output nVWE, nVRAS, nVCS, VCKE, nVCAS;
   output [3:0] FB_LE;
   output [3:0] FB_VDOE;
   output SR_FIFO_WRE, SR_DDR_FB, SR_DDR_WR, SR_DDRWR_D_SEL;
   output [7:0] SR_VDMP;
   output VIDEO_DDR_TA, SR_BLITTER_DACK;
   output [1:0] BA;
   output DDRWR_D_SEL1;
   output [3:0] VDM_SEL;
   reg [3:0] FB_LE;
   reg [3:0] FB_VDOE;
   reg SR_DDR_FB, VIDEO_DDR_TA, SR_BLITTER_DACK;
   inout [31:0] FB_AD;

//  START (NORMAL 8 CYCLES TOTAL = 60ns)
//  CONFIG
//  READ CPU UND BLITTER,
//  WRITE CPU UND BLITTER
//  READ FIFO
//  CLOSE FIFO BANK
//  REFRESH 10X7.5NS=75NS
   wire [2:0] FB_REGDDR_;
   wire [5:0] DDR_SM_;
   wire LINE;
   wire [3:0] FB_B;
   wire [12:0] VA_P;
   wire [1:0] BA_P;
   wire [12:0] VA_S;
   wire [1:0] BA_S;
   wire [1:0] MCS;
   wire [1:0] MCS_d;
   wire CPU_DDR_SYNC, CPU_DDR_SYNC_d, CPU_DDR_SYNC_clk, DDR_SEL, DDR_CS,
	 DDR_CS_d, DDR_CS_clk, DDR_CS_ena, DDR_CONFIG, SR_DDR_WR_clk,
	 SR_DDRWR_D_SEL_clk;
   wire [12:0] CPU_ROW_ADR;
   wire [1:0] CPU_BA;
   wire [9:0] CPU_COL_ADR;
   wire CPU_SIG, CPU_REQ, CPU_REQ_d, CPU_REQ_clk, CPU_AC, CPU_AC_clk, BUS_CYC,
	 BUS_CYC_d, BUS_CYC_clk, BLITTER_REQ, BLITTER_REQ_d, BLITTER_REQ_clk,
	 BLITTER_AC, BLITTER_AC_clk;
   wire [12:0] BLITTER_ROW_ADR;
   wire [1:0] BLITTER_BA;
   wire [9:0] BLITTER_COL_ADR;
   wire FIFO_REQ, FIFO_REQ_d, FIFO_REQ_clk, FIFO_AC, FIFO_AC_clk;
   wire [12:0] FIFO_ROW_ADR;
   wire [1:0] FIFO_BA;
   wire [9:0] FIFO_COL_ADR;
   wire FIFO_ACTIVE, CLR_FIFO_SYNC, CLR_FIFO_SYNC_d, CLR_FIFO_SYNC_clk,
	 CLEAR_FIFO_CNT, CLEAR_FIFO_CNT_d, CLEAR_FIFO_CNT_clk, STOP, STOP_d,
	 STOP_clk, SR_FIFO_WRE_clk, FIFO_BANK_OK, FIFO_BANK_OK_d,
	 FIFO_BANK_OK_clk, DDR_REFRESH_ON;
   wire [10:0] DDR_REFRESH_CNT;
   wire [10:0] DDR_REFRESH_CNT_d;
   wire DDR_REFRESH_REQ, DDR_REFRESH_REQ_d, DDR_REFRESH_REQ_clk;
   wire [3:0] DDR_REFRESH_SIG;
   wire [3:0] DDR_REFRESH_SIG_d;
   wire REFRESH_TIME, REFRESH_TIME_d, REFRESH_TIME_clk;
   wire [7:0] VIDEO_BASE_L_D;
   wire [7:0] VIDEO_BASE_L_D_d;
   wire VIDEO_BASE_L;
   wire [7:0] VIDEO_BASE_M_D;
   wire [7:0] VIDEO_BASE_M_D_d;
   wire VIDEO_BASE_M;
   wire [7:0] VIDEO_BASE_H_D;
   wire [7:0] VIDEO_BASE_H_D_d;
   wire VIDEO_BASE_H;
   wire [2:0] VIDEO_BASE_X_D;
   wire [2:0] VIDEO_BASE_X_D_d;
   wire [7:0] VIDEO_BASE_X_D_FULL;
   wire [22:0] VIDEO_ADR_CNT;
   wire [22:0] VIDEO_ADR_CNT_d;
   wire VIDEO_CNT_L, VIDEO_CNT_M, VIDEO_CNT_H;
   wire [22:0] VIDEO_BASE_ADR;
   wire [26:0] VIDEO_ACT_ADR;
   wire vcc, gnd;
   wire [7:0] u0_data;
   wire u0_enabledt;
   wire [7:0] u0_tridata;
   wire [7:0] u1_data;
   wire u1_enabledt;
   wire [7:0] u1_tridata;
   wire FIFO_BANK_OK_d_2, BUS_CYC_d_1, BA0_1, BA1_1, VA0_1, VA1_1, VA2_1,
	 VA3_1, VA4_1, VA5_1, VA6_1, VA7_1, VA8_1, VA9_1, VA10_1, VA11_1,
	 VA12_1, VIDEO_BASE_X_D0_ena_ctrl, VIDEO_BASE_X_D0_clk_ctrl,
	 VIDEO_BASE_H_D0_ena_ctrl, VIDEO_BASE_H_D0_clk_ctrl,
	 VIDEO_BASE_M_D0_ena_ctrl, VIDEO_BASE_M_D0_clk_ctrl,
	 VIDEO_BASE_L_D0_ena_ctrl, VIDEO_BASE_L_D0_clk_ctrl,
	 DDR_REFRESH_SIG0_ena_ctrl, DDR_REFRESH_SIG0_clk_ctrl,
	 DDR_REFRESH_CNT0_clk_ctrl, VIDEO_ADR_CNT0_ena_ctrl,
	 VIDEO_ADR_CNT0_clk_ctrl, DDR_SM_0_clk_ctrl, BA_P0_clk_ctrl,
	 VA_P0_clk_ctrl, BA_S0_clk_ctrl, VA_S0_clk_ctrl, MCS0_clk_ctrl,
	 SR_VDMP0_clk_ctrl, FB_REGDDR_0_clk_ctrl;
   reg [2:0] FB_REGDDR__d;
   reg [2:0] FB_REGDDR__q;
   reg [5:0] DDR_SM__d;
   reg [5:0] DDR_SM__q;
   reg VCAS, VRAS, VWE;
   reg [12:0] VA_P_d;
   reg [12:0] VA_P_q;
   reg [1:0] BA_P_d;
   reg [1:0] BA_P_q;
   reg [12:0] VA_S_d;
   reg [12:0] VA_S_q;
   reg [1:0] BA_S_d;
   reg [1:0] BA_S_q;
   reg [1:0] MCS_q;
   reg CPU_DDR_SYNC_q, DDR_CS_q, SR_DDR_WR_d, SR_DDR_WR_q, SR_DDRWR_D_SEL_d,
	 SR_DDRWR_D_SEL_q;
   reg [7:0] SR_VDMP_d;
   reg [7:0] SR_VDMP_q;
   reg CPU_REQ_q, CPU_AC_d, CPU_AC_q, BUS_CYC_q, BUS_CYC_END, BLITTER_REQ_q,
	 BLITTER_AC_d, BLITTER_AC_q, FIFO_REQ_q, FIFO_AC_d, FIFO_AC_q,
	 CLR_FIFO_SYNC_q, CLEAR_FIFO_CNT_q, STOP_q, SR_FIFO_WRE_d,
	 SR_FIFO_WRE_q, FIFO_BANK_OK_q, FIFO_BANK_NOT_OK;
   reg [10:0] DDR_REFRESH_CNT_q;
   reg DDR_REFRESH_REQ_q;
   reg [3:0] DDR_REFRESH_SIG_q;
   reg REFRESH_TIME_q;
   reg [7:0] VIDEO_BASE_L_D_q;
   reg [7:0] VIDEO_BASE_M_D_q;
   reg [7:0] VIDEO_BASE_H_D_q;
   reg [2:0] VIDEO_BASE_X_D_q;
   reg [22:0] VIDEO_ADR_CNT_q;
   reg FIFO_BANK_OK_d_1, BUS_CYC_d_2, BA0_2, BA1_2, VA0_2, VA1_2, VA2_2, VA3_2,
	 VA4_2, VA5_2, VA6_2, VA7_2, VA8_2, VA9_2, VA10_2, VA11_2, VA12_2;


// Sub Module Section
   /*lpm_bustri_BYT  u0 (.data(u0_data), .enabledt(u0_enabledt),
	 .tridata(u0_tridata));

   lpm_bustri_BYT  u1 (.data(u1_data), .enabledt(u1_enabledt),
	 .tridata(u1_tridata));*/
	 assign u0_tridata = (u0_enabledt) ? u0_data : 8'hzz;
	 assign u1_tridata = (u1_enabledt) ? u1_data : 8'hzz;


   assign SR_FIFO_WRE = SR_FIFO_WRE_q;
   always @(posedge SR_FIFO_WRE_clk)
      SR_FIFO_WRE_q <= SR_FIFO_WRE_d;

   assign SR_DDR_WR = SR_DDR_WR_q;
   always @(posedge SR_DDR_WR_clk)
      SR_DDR_WR_q <= SR_DDR_WR_d;

   assign SR_DDRWR_D_SEL = SR_DDRWR_D_SEL_q;
   always @(posedge SR_DDRWR_D_SEL_clk)
      SR_DDRWR_D_SEL_q <= SR_DDRWR_D_SEL_d;

   assign SR_VDMP = SR_VDMP_q;
   always @(posedge SR_VDMP0_clk_ctrl)
      SR_VDMP_q <= SR_VDMP_d;

   always @(posedge FB_REGDDR_0_clk_ctrl)
      FB_REGDDR__q <= FB_REGDDR__d;

   always @(posedge DDR_SM_0_clk_ctrl)
      DDR_SM__q <= DDR_SM__d;

   always @(posedge VA_P0_clk_ctrl)
      VA_P_q <= VA_P_d;

   always @(posedge BA_P0_clk_ctrl)
      BA_P_q <= BA_P_d;

   always @(posedge VA_S0_clk_ctrl)
      VA_S_q <= VA_S_d;

   always @(posedge BA_S0_clk_ctrl)
      BA_S_q <= BA_S_d;

   always @(posedge MCS0_clk_ctrl)
      MCS_q <= MCS_d;

   always @(posedge CPU_DDR_SYNC_clk)
      CPU_DDR_SYNC_q <= CPU_DDR_SYNC_d;

   always @(posedge DDR_CS_clk)
      if (DDR_CS_ena)
	 DDR_CS_q <= DDR_CS_d;

   always @(posedge CPU_REQ_clk)
      CPU_REQ_q <= CPU_REQ_d;

   always @(posedge CPU_AC_clk)
      CPU_AC_q <= CPU_AC_d;

   always @(posedge BUS_CYC_clk)
      BUS_CYC_q <= BUS_CYC_d;

   always @(posedge BLITTER_REQ_clk)
      BLITTER_REQ_q <= BLITTER_REQ_d;

   always @(posedge BLITTER_AC_clk)
      BLITTER_AC_q <= BLITTER_AC_d;

   always @(posedge FIFO_REQ_clk)
      FIFO_REQ_q <= FIFO_REQ_d;

   always @(posedge FIFO_AC_clk)
      FIFO_AC_q <= FIFO_AC_d;

   always @(posedge CLR_FIFO_SYNC_clk)
      CLR_FIFO_SYNC_q <= CLR_FIFO_SYNC_d;

   always @(posedge CLEAR_FIFO_CNT_clk)
      CLEAR_FIFO_CNT_q <= CLEAR_FIFO_CNT_d;

   always @(posedge STOP_clk)
      STOP_q <= STOP_d;

   always @(posedge FIFO_BANK_OK_clk)
      FIFO_BANK_OK_q <= FIFO_BANK_OK_d;

   always @(posedge DDR_REFRESH_CNT0_clk_ctrl)
      DDR_REFRESH_CNT_q <= DDR_REFRESH_CNT_d;

   always @(posedge DDR_REFRESH_REQ_clk)
      DDR_REFRESH_REQ_q <= DDR_REFRESH_REQ_d;

   always @(posedge DDR_REFRESH_SIG0_clk_ctrl)
      if (DDR_REFRESH_SIG0_ena_ctrl)
	 DDR_REFRESH_SIG_q <= DDR_REFRESH_SIG_d;

   always @(posedge REFRESH_TIME_clk)
      REFRESH_TIME_q <= REFRESH_TIME_d;

   always @(posedge VIDEO_BASE_L_D0_clk_ctrl)
      if (VIDEO_BASE_L_D0_ena_ctrl)
	 VIDEO_BASE_L_D_q <= VIDEO_BASE_L_D_d;

   always @(posedge VIDEO_BASE_M_D0_clk_ctrl)
      if (VIDEO_BASE_M_D0_ena_ctrl)
	 VIDEO_BASE_M_D_q <= VIDEO_BASE_M_D_d;

   always @(posedge VIDEO_BASE_H_D0_clk_ctrl)
      if (VIDEO_BASE_H_D0_ena_ctrl)
	 VIDEO_BASE_H_D_q <= VIDEO_BASE_H_D_d;

   always @(posedge VIDEO_BASE_X_D0_clk_ctrl)
      if (VIDEO_BASE_X_D0_ena_ctrl)
	 VIDEO_BASE_X_D_q <= VIDEO_BASE_X_D_d;

   always @(posedge VIDEO_ADR_CNT0_clk_ctrl)
      if (VIDEO_ADR_CNT0_ena_ctrl)
	 VIDEO_ADR_CNT_q <= VIDEO_ADR_CNT_d;

// Start of original equations
   assign LINE = FB_SIZE0 & FB_SIZE1;

//  BYT SELECT
//  ADR==0
//  LONG UND LINE
   assign FB_B[0] = FB_ADR[1:0] == 2'b00 | (FB_SIZE1 & FB_SIZE0) | ((!FB_SIZE1)
	 & (!FB_SIZE0));

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

//  CPU READ (REG DDR => CPU) AND WRITE (CPU => REG DDR)  --------------------------------------------------
   assign FB_REGDDR_0_clk_ctrl = MAIN_CLK;


   always @(FB_REGDDR__q or DDR_SEL or BUS_CYC_q or LINE or DDR_CS_q or nFB_OE
	 or MAIN_CLK or DDR_CONFIG or nFB_WR or vcc) begin
      FB_REGDDR__d = FB_REGDDR__q;
      {FB_VDOE[0], FB_VDOE[1]} = 2'b00;
      {FB_LE[0], FB_LE[1], FB_VDOE[2], FB_LE[2], FB_VDOE[3], FB_LE[3],
	    VIDEO_DDR_TA, BUS_CYC_END} = 8'b0000_0000;
      casex (FB_REGDDR__q)
      3'b000: begin
	    FB_LE[0] = !nFB_WR;

//  LOS WENN BEREIT ODER IMMER BEI LINE WRITE
	    if (BUS_CYC_q | (DDR_SEL & LINE & (!nFB_WR))) begin
	       FB_REGDDR__d = 3'b001;
	    end else begin
	       FB_REGDDR__d = 3'b000;
	    end
	 end
      3'b001: begin
	    if (DDR_CS_q) begin
	       FB_LE[0] = !nFB_WR;
	       VIDEO_DDR_TA = vcc;
	       if (LINE) begin
		  FB_VDOE[0] = (!nFB_OE) & (!DDR_CONFIG);
		  FB_REGDDR__d = 3'b010;
	       end else begin
		  BUS_CYC_END = vcc;
		  FB_VDOE[0] = (!nFB_OE) & (!MAIN_CLK) & (!DDR_CONFIG);
		  FB_REGDDR__d = 3'b000;
	       end
	    end else begin
	       FB_REGDDR__d = 3'b000;
	    end
	 end
      3'b010: begin
	    if (DDR_CS_q) begin
	       FB_VDOE[1] = (!nFB_OE) & (!DDR_CONFIG);
	       FB_LE[1] = !nFB_WR;
	       VIDEO_DDR_TA = vcc;
	       FB_REGDDR__d = 3'b011;
	    end else begin
	       FB_REGDDR__d = 3'b000;
	    end
	 end
      3'b011: begin
	    if (DDR_CS_q) begin
	       FB_VDOE[2] = (!nFB_OE) & (!DDR_CONFIG);
	       FB_LE[2] = !nFB_WR;

//  BEI LINE WRITE EVT. WARTEN
	       if ((!BUS_CYC_q) & LINE & (!nFB_WR)) begin
		  FB_REGDDR__d = 3'b011;
	       end else begin
		  VIDEO_DDR_TA = vcc;
		  FB_REGDDR__d = 3'b100;
	       end
	    end else begin
	       FB_REGDDR__d = 3'b000;
	    end
	 end
      3'b100: begin
	    if (DDR_CS_q) begin
	       FB_VDOE[3] = (!nFB_OE) & (!MAIN_CLK) & (!DDR_CONFIG);
	       FB_LE[3] = !nFB_WR;
	       VIDEO_DDR_TA = vcc;
	       BUS_CYC_END = vcc;
	       FB_REGDDR__d = 3'b000;
	    end else begin
	       FB_REGDDR__d = 3'b000;
	    end
	 end
      endcase
   end

//  DDR STEUERUNG -----------------------------------------------------
//  VIDEO RAM CONTROL REGISTER (IST IN VIDEO_MUX_CTR) $F0000400: BIT 0: VCKE; 1: !nVCS ;2:REFRESH ON , (0=FIFO UND CNT CLEAR); 3: CONFIG; 8: FIFO_ACTIVE;
   assign VCKE = VIDEO_RAM_CTR[0];
   assign nVCS = !VIDEO_RAM_CTR[1];
   assign DDR_REFRESH_ON = VIDEO_RAM_CTR[2];
   assign DDR_CONFIG = VIDEO_RAM_CTR[3];
   assign FIFO_ACTIVE = VIDEO_RAM_CTR[8];

// ------------------------------
   assign CPU_ROW_ADR = FB_ADR[26:14];
   assign CPU_BA = FB_ADR[13:12];
   assign CPU_COL_ADR = FB_ADR[11:2];
   assign nVRAS = !VRAS;
   assign nVCAS = !VCAS;
   assign nVWE = !VWE;
   assign SR_DDR_WR_clk = DDRCLK0;
   assign SR_DDRWR_D_SEL_clk = DDRCLK0;
   assign SR_VDMP0_clk_ctrl = DDRCLK0;
   assign SR_FIFO_WRE_clk = DDRCLK0;
   assign CPU_AC_clk = DDRCLK0;
   assign FIFO_AC_clk = DDRCLK0;
   assign BLITTER_AC_clk = DDRCLK0;
   assign DDRWR_D_SEL1 = BLITTER_AC_q;

//  SELECT LOGIC
   assign DDR_SEL = FB_ALE & FB_AD[31:30] == 2'b01;
   assign DDR_CS_clk = MAIN_CLK;
   assign DDR_CS_ena = FB_ALE;
   assign DDR_CS_d = DDR_SEL;

//  WENN READ ODER WRITE B,W,L DDR SOFORT ANFORDERN, BEI WRITE LINE SPÄTER
//  NICHT LINE ODER READ SOFORT LOS WENN NICHT CONFIG
//  CONFIG SOFORT LOS
//  LINE WRITE SPÄTER
   assign CPU_SIG = (DDR_SEL & (nFB_WR | (!LINE)) & (!DDR_CONFIG)) | (DDR_SEL &
	 DDR_CONFIG) | (FB_REGDDR__q == 3'b010 & (!nFB_WR));
   assign CPU_REQ_clk = DDR_SYNC_66M;

//  HALTEN BUS CYC BEGONNEN ODER FERTIG
   assign CPU_REQ_d = CPU_SIG | (CPU_REQ_q & FB_REGDDR__q != 3'b010 &
	 FB_REGDDR__q != 3'b100 & (!BUS_CYC_END) & (!BUS_CYC_q));
   assign BUS_CYC_clk = DDRCLK0;
   assign BUS_CYC_d_1 = BUS_CYC_q & (!BUS_CYC_END);

//  STATE MACHINE SYNCHRONISIEREN -----------------
   assign MCS0_clk_ctrl = DDRCLK0;
   assign MCS_d[0] = MAIN_CLK;
   assign MCS_d[1] = MCS_q[0];
   assign CPU_DDR_SYNC_clk = DDRCLK0;

//  NUR 1 WENN EIN
   assign CPU_DDR_SYNC_d = MCS_q == 2'b10 & VCKE & (!nVCS);

// -------------------------------------------------
   assign VA_S0_clk_ctrl = DDRCLK0;
   assign BA_S0_clk_ctrl = DDRCLK0;
   assign {VA12_1, VA11_1, VA10_1, VA9_1, VA8_1, VA7_1, VA6_1, VA5_1, VA4_1,
	 VA3_1, VA2_1, VA1_1, VA0_1} = VA_S_q;
   assign {BA1_1, BA0_1} = BA_S_q;
   assign VA_P0_clk_ctrl = DDRCLK0;
   assign BA_P0_clk_ctrl = DDRCLK0;

//  DDR STATE MACHINE  -----------------------------------------------
   assign DDR_SM_0_clk_ctrl = DDRCLK0;


   always @(DDR_SM__q or DDR_REFRESH_REQ_q or CPU_DDR_SYNC_q or DDR_CONFIG or
	 CPU_ROW_ADR or FIFO_ROW_ADR or BLITTER_ROW_ADR or BLITTER_REQ_q or
	 BLITTER_WR or FIFO_AC_q or CPU_COL_ADR or BLITTER_COL_ADR or VA_S_q or
	 CPU_BA or BLITTER_BA or FB_B or CPU_AC_q or BLITTER_AC_q or
	 FIFO_BANK_OK_q or FIFO_MW or FIFO_REQ_q or VIDEO_ADR_CNT_q or
	 FIFO_COL_ADR or gnd or DDR_SEL or LINE or FIFO_BA or FB_AD or VA_P_q
	 or BA_P_q or CPU_REQ_q or nFB_WR or FB_SIZE0 or FB_SIZE1 or
	 DDR_REFRESH_SIG_q or vcc) begin
      DDR_SM__d = DDR_SM__q;
      BA_S_d = 2'b00;
      VA_S_d = 13'b0_0000_0000_0000;
      BA_P_d = 2'b00;
      {VA_P_d[9], VA_P_d[8], VA_P_d[7], VA_P_d[6], VA_P_d[5], VA_P_d[4],
	    VA_P_d[3], VA_P_d[2], VA_P_d[1], VA_P_d[0], VA_P_d[10]} =
	    11'b000_0000_0000;
      SR_VDMP_d = 8'b0000_0000;
      VA_P_d[12:11] = 2'b00;
      {FIFO_BANK_OK_d_1, FIFO_AC_d, SR_DDR_FB, SR_BLITTER_DACK, BLITTER_AC_d,
	    SR_DDR_WR_d, SR_DDRWR_D_SEL_d, CPU_AC_d, VA12_2, VA11_2, VA9_2,
	    VA8_2, VA7_2, VA6_2, VA5_2, VA4_2, VA3_2, VA2_2, VA1_2, VA0_2,
	    BA1_2, BA0_2, SR_FIFO_WRE_d, BUS_CYC_d_2, VWE, VA10_2,
	    FIFO_BANK_NOT_OK, VCAS, VRAS} =
	    29'b0_0000_0000_0000_0000_0000_0000_0000;
      casex (DDR_SM__q)
      6'b00_0000: begin
	    if (DDR_REFRESH_REQ_q) begin
	       DDR_SM__d = 6'b01_1111;

//  SYNCHRON UND EIN?
	    end else if (CPU_DDR_SYNC_q) begin

//  JA
	       if (DDR_CONFIG) begin
		  DDR_SM__d = 6'b00_1000;

//  BEI WAIT UND LINE WRITE
	       end else if (CPU_REQ_q) begin
		  VA_S_d = CPU_ROW_ADR;
		  BA_S_d = CPU_BA;
		  CPU_AC_d = vcc;
		  BUS_CYC_d_2 = vcc;
		  DDR_SM__d = 6'b00_0010;
	       end else begin

//  FIFO IST DEFAULT
		  if (FIFO_REQ_q | (!BLITTER_REQ_q)) begin
		     VA_P_d = FIFO_ROW_ADR;
		     BA_P_d = FIFO_BA;

//  VORBESETZEN
		     FIFO_AC_d = vcc;
		  end else begin
		     VA_P_d = BLITTER_ROW_ADR;
		     BA_P_d = BLITTER_BA;

//  VORBESETZEN
		     BLITTER_AC_d = vcc;
		  end
		  DDR_SM__d = 6'b00_0001;
	       end
	    end else begin

//  NEIN ->SYNCHRONISIEREN
	       DDR_SM__d = 6'b00_0000;
	    end
	 end
      6'b00_0001: begin

//  SCHNELLZUGRIFF *** HIER IST PAGE IMMER NOT OK ***
	    if (DDR_SEL & (nFB_WR | (!LINE))) begin
	       VRAS = vcc;
	       {VA12_2, VA11_2, VA10_2, VA9_2, VA8_2, VA7_2, VA6_2, VA5_2,
		     VA4_2, VA3_2, VA2_2, VA1_2, VA0_2} = FB_AD[26:14];
	       {BA1_2, BA0_2} = FB_AD[13:12];

//  AUTO PRECHARGE DA NICHT FIFO PAGE
	       VA_S_d[10] = vcc;
	       CPU_AC_d = vcc;

//  BUS CYCLUS LOSTRETEN
	       BUS_CYC_d_2 = vcc;
	    end else begin
	       VRAS = (FIFO_AC_q & FIFO_REQ_q) | (BLITTER_AC_q &
		     BLITTER_REQ_q);
	       {VA12_2, VA11_2, VA10_2, VA9_2, VA8_2, VA7_2, VA6_2, VA5_2,
		     VA4_2, VA3_2, VA2_2, VA1_2, VA0_2} = VA_P_q;
	       {BA1_2, BA0_2} = BA_P_q;
	       VA_S_d[10] = !(FIFO_AC_q & FIFO_REQ_q);
	       FIFO_BANK_OK_d_1 = FIFO_AC_q & FIFO_REQ_q;
	       FIFO_AC_d = FIFO_AC_q & FIFO_REQ_q;
	       BLITTER_AC_d = BLITTER_AC_q & BLITTER_REQ_q;
	    end
	    DDR_SM__d = 6'b00_0011;
	 end
      6'b00_0010: begin
	    VRAS = vcc;
	    FIFO_BANK_NOT_OK = vcc;
	    CPU_AC_d = vcc;

//  BUS CYCLUS LOSTRETEN
	    BUS_CYC_d_2 = vcc;
	    DDR_SM__d = 6'b00_0011;
	 end
      6'b00_0011: begin
	    CPU_AC_d = CPU_AC_q;
	    FIFO_AC_d = FIFO_AC_q;
	    BLITTER_AC_d = BLITTER_AC_q;

//  AUTO PRECHARGE WENN NICHT FIFO PAGE
	    VA_S_d[10] = VA_S_q[10];
	    if (((!nFB_WR) & CPU_AC_q) | (BLITTER_WR & BLITTER_AC_q)) begin
	       DDR_SM__d = 6'b01_0000;

//  CPU?
	    end else if (CPU_AC_q) begin
	       VA_S_d[9:0] = CPU_COL_ADR;
	       BA_S_d = CPU_BA;
	       DDR_SM__d = 6'b00_1110;

//  FIFO?
	    end else if (FIFO_AC_q) begin
	       VA_S_d[9:0] = FIFO_COL_ADR;
	       BA_S_d = FIFO_BA;
	       DDR_SM__d = 6'b01_0110;
	    end else if (BLITTER_AC_q) begin
	       VA_S_d[9:0] = BLITTER_COL_ADR;
	       BA_S_d = BLITTER_BA;
	       DDR_SM__d = 6'b00_1110;
	    end else begin

//  READ
	       DDR_SM__d = 6'b00_0111;
	    end
	 end
      6'b00_1110: begin
	    CPU_AC_d = CPU_AC_q;
	    BLITTER_AC_d = BLITTER_AC_q;
	    VCAS = vcc;

//  READ DATEN FÜR CPU
	    SR_DDR_FB = CPU_AC_q;

//  BLITTER DACK AND BLITTER LATCH DATEN
	    SR_BLITTER_DACK = BLITTER_AC_q;
	    DDR_SM__d = 6'b00_1111;
	 end
      6'b00_1111: begin
	    CPU_AC_d = CPU_AC_q;
	    BLITTER_AC_d = BLITTER_AC_q;

//  FIFO READ EINSCHIEBEN WENN BANK OK
	    if (FIFO_REQ_q & FIFO_BANK_OK_q) begin
	       VA_S_d[9:0] = FIFO_COL_ADR;

//  MANUEL PRECHARGE
	       VA_S_d[10] = gnd;
	       BA_S_d = FIFO_BA;
	       DDR_SM__d = 6'b01_1000;
	    end else begin

//  ALLE PAGES SCHLIESSEN
	       VA_S_d[10] = vcc;

//  WRITE
	       DDR_SM__d = 6'b01_1101;
	    end
	 end
      6'b01_0000: begin
	    CPU_AC_d = CPU_AC_q;
	    BLITTER_AC_d = BLITTER_AC_q;

//  BLITTER ACK AND BLITTER LATCH DATEN
	    SR_BLITTER_DACK = BLITTER_AC_q;

//  AUTO PRECHARGE WENN NICHT FIFO PAGE
	    VA_S_d[10] = VA_S_q[10];
	    DDR_SM__d = 6'b01_0001;
	 end
      6'b01_0001: begin
	    CPU_AC_d = CPU_AC_q;
	    BLITTER_AC_d = BLITTER_AC_q;
	    VA_S_d[9:0] = ({10{CPU_AC_q}} & CPU_COL_ADR) | ({10{BLITTER_AC_q}}
		  & BLITTER_COL_ADR);

//  AUTO PRECHARGE WENN NICHT FIFO PAGE
	    VA_S_d[10] = VA_S_q[10];
	    BA_S_d = ({2{CPU_AC_q}} & CPU_BA) | ({2{BLITTER_AC_q}} &
		  BLITTER_BA);

//  BYTE ENABLE WRITE
	    SR_VDMP_d[7:4] = FB_B;

//  LINE ENABLE WRITE
	    SR_VDMP_d[3:0] = {4{LINE}} & 4'b1111;
	    DDR_SM__d = 6'b01_0010;
	 end
      6'b01_0010: begin
	    CPU_AC_d = CPU_AC_q;
	    BLITTER_AC_d = BLITTER_AC_q;
	    VCAS = vcc;
	    VWE = vcc;

//  WRITE COMMAND CPU UND BLITTER IF WRITER
	    SR_DDR_WR_d = vcc;

//  2. HÄLFTE WRITE DATEN SELEKTIEREN
	    SR_DDRWR_D_SEL_d = vcc;

//  WENN LINE DANN ACTIV
	    SR_VDMP_d = {8{LINE}} & 8'b1111_1111;
	    DDR_SM__d = 6'b01_0011;
	 end
      6'b01_0011: begin
	    CPU_AC_d = CPU_AC_q;
	    BLITTER_AC_d = BLITTER_AC_q;

//  WRITE COMMAND CPU UND BLITTER IF WRITE
	    SR_DDR_WR_d = vcc;

//  2. HÄLFTE WRITE DATEN SELEKTIEREN
	    SR_DDRWR_D_SEL_d = vcc;
	    DDR_SM__d = 6'b01_0100;
	 end
      6'b01_0100: begin
	    DDR_SM__d = 6'b01_0101;
	 end
      6'b01_0101: begin
	    if (FIFO_REQ_q & FIFO_BANK_OK_q) begin
	       VA_S_d[9:0] = FIFO_COL_ADR;

//  NON AUTO PRECHARGE
	       VA_S_d[10] = gnd;
	       BA_S_d = FIFO_BA;
	       DDR_SM__d = 6'b01_1000;
	    end else begin

//  ALLE PAGES SCHLIESSEN
	       VA_S_d[10] = vcc;

//  FIFO READ
	       DDR_SM__d = 6'b01_1101;
	    end
	 end
      6'b01_0110: begin
	    VCAS = vcc;

//  DATEN WRITE FIFO
	    SR_FIFO_WRE_d = vcc;
	    DDR_SM__d = 6'b01_0111;
	 end
      6'b01_0111: begin
	    if (FIFO_REQ_q) begin

//  NEUE PAGE?
	       if (VIDEO_ADR_CNT_q[7:0] == 8'b1111_1111) begin

//  ALLE PAGES SCHLIESSEN
		  VA_S_d[10] = vcc;

//  BANK SCHLIESSEN
		  DDR_SM__d = 6'b01_1101;
	       end else begin
		  VA_S_d[9:0] = FIFO_COL_ADR + 10'b00_0000_0100;

//  NON AUTO PRECHARGE
		  VA_S_d[10] = gnd;
		  BA_S_d = FIFO_BA;
		  DDR_SM__d = 6'b01_1000;
	       end
	    end else begin

//  ALLE PAGES SCHLIESSEN
	       VA_S_d[10] = vcc;

//  NOCH OFFEN LASSEN
	       DDR_SM__d = 6'b01_1101;
	    end
	 end
      6'b01_1000: begin
	    VCAS = vcc;

//  DATEN WRITE FIFO
	    SR_FIFO_WRE_d = vcc;
	    DDR_SM__d = 6'b01_1001;
	 end
      6'b01_1001: begin
	    if (CPU_REQ_q & FIFO_MW > 9'b0_0000_0000) begin

//  ALLE PAGES SCHLIESEN
	       VA_S_d[10] = vcc;

//  BANK SCHLIESSEN
	       DDR_SM__d = 6'b01_1110;
	    end else if (FIFO_REQ_q) begin

//  NEUE PAGE?
	       if (VIDEO_ADR_CNT_q[7:0] == 8'b1111_1111) begin

//  ALLE PAGES SCHLIESSEN
		  VA_S_d[10] = vcc;

//  BANK SCHLIESSEN
		  DDR_SM__d = 6'b01_1110;
	       end else begin
		  VA_S_d[9:0] = FIFO_COL_ADR + 10'b00_0000_0100;

//  NON AUTO PRECHARGE
		  VA_S_d[10] = gnd;
		  BA_S_d = FIFO_BA;
		  DDR_SM__d = 6'b01_1010;
	       end
	    end else begin

//  ALLE PAGES SCHLIESEN
	       VA_S_d[10] = vcc;

//  BANK SCHLIESSEN
	       DDR_SM__d = 6'b01_1110;
	    end
	 end
      6'b01_1010: begin
	    VCAS = vcc;

//  DATEN WRITE FIFO
	    SR_FIFO_WRE_d = vcc;

//  NOTFALL?
	    if (FIFO_MW < 9'b0_0000_0000) begin

//  JA->
	       DDR_SM__d = 6'b01_0111;
	    end else begin
	       DDR_SM__d = 6'b01_1011;
	    end
	 end
      6'b01_1011: begin
	    if (FIFO_REQ_q) begin

//  NEUE PAGE?
	       if (VIDEO_ADR_CNT_q[7:0] == 8'b1111_1111) begin

//  ALLE BANKS SCHLIESEN
		  VA_S_d[10] = vcc;

//  BANK SCHLIESSEN
		  DDR_SM__d = 6'b01_1101;
	       end else begin
		  VA_P_d[9:0] = FIFO_COL_ADR + 10'b00_0000_0100;

//  NON AUTO PRECHARGE
		  VA_P_d[10] = gnd;
		  BA_P_d = FIFO_BA;
		  DDR_SM__d = 6'b01_1100;
	       end
	    end else begin

//  ALLE BANKS SCHLIESEN
	       VA_S_d[10] = vcc;

//  BANK SCHLIESSEN
	       DDR_SM__d = 6'b01_1101;
	    end
	 end
      6'b01_1100: begin
	    if (DDR_SEL & (nFB_WR | (!LINE)) & FB_AD[13:12] != FIFO_BA) begin
	       VRAS = vcc;
	       {VA12_2, VA11_2, VA10_2, VA9_2, VA8_2, VA7_2, VA6_2, VA5_2,
		     VA4_2, VA3_2, VA2_2, VA1_2, VA0_2} = FB_AD[26:14];
	       {BA1_2, BA0_2} = FB_AD[13:12];
	       CPU_AC_d = vcc;

//  BUS CYCLUS LOSTRETEN
	       BUS_CYC_d_2 = vcc;

//  AUTO PRECHARGE DA NICHT FIFO BANK
	       VA_S_d[10] = vcc;
	       DDR_SM__d = 6'b00_0011;
	    end else begin
	       VCAS = vcc;
	       {VA12_2, VA11_2, VA10_2, VA9_2, VA8_2, VA7_2, VA6_2, VA5_2,
		     VA4_2, VA3_2, VA2_2, VA1_2, VA0_2} = VA_P_q;
	       {BA1_2, BA0_2} = BA_P_q;

//  DATEN WRITE FIFO
	       SR_FIFO_WRE_d = vcc;

//  CONFIG CYCLUS
	       DDR_SM__d = 6'b01_1001;
	    end
	 end
      6'b00_1000: begin
	    DDR_SM__d = 6'b00_1001;
	 end
      6'b00_1001: begin
	    BUS_CYC_d_2 = CPU_REQ_q;
	    DDR_SM__d = 6'b00_1010;
	 end
      6'b00_1010: begin
	    if (CPU_REQ_q) begin
	       DDR_SM__d = 6'b00_1011;
	    end else begin
	       DDR_SM__d = 6'b00_0000;
	    end
	 end
      6'b00_1011: begin
	    DDR_SM__d = 6'b00_1100;
	 end
      6'b00_1100: begin
	    VA_S_d = FB_AD[12:0];
	    BA_S_d = FB_AD[14:13];
	    DDR_SM__d = 6'b00_1101;
	 end
      6'b00_1101: begin

//  NUR BEI LONG WRITE
	    VRAS = FB_AD[18] & (!nFB_WR) & (!FB_SIZE0) & (!FB_SIZE1);

//  NUR BEI LONG WRITE
	    VCAS = FB_AD[17] & (!nFB_WR) & (!FB_SIZE0) & (!FB_SIZE1);

//  NUR BEI LONG WRITE
	    VWE = FB_AD[16] & (!nFB_WR) & (!FB_SIZE0) & (!FB_SIZE1);

//  CLOSE FIFO BANK
	    DDR_SM__d = 6'b00_0111;
	 end
      6'b01_1101: begin

//  AUF NOT OK
	    FIFO_BANK_NOT_OK = vcc;

//  BÄNKE SCHLIESSEN
	    VRAS = vcc;
	    VWE = vcc;
	    DDR_SM__d = 6'b00_0110;
	 end
      6'b01_1110: begin

//  AUF NOT OK
	    FIFO_BANK_NOT_OK = vcc;

//  BÄNKE SCHLIESSEN
	    VRAS = vcc;
	    VWE = vcc;

//  REFRESH 70NS = 10 ZYCLEN
	    DDR_SM__d = 6'b00_0000;
	 end
      6'b01_1111: begin

//  EIN CYCLUS VORLAUF UM BANKS ZU SCHLIESSEN
	    if (DDR_REFRESH_SIG_q == 4'b1001) begin

//  ALLE BANKS SCHLIESSEN
	       VRAS = vcc;
	       VWE = vcc;
	       VA10_2 = vcc;
	       FIFO_BANK_NOT_OK = vcc;
	       DDR_SM__d = 6'b10_0001;
	    end else begin
	       VCAS = vcc;
	       VRAS = vcc;
	       DDR_SM__d = 6'b10_0000;
	    end
	 end
      6'b10_0000: begin
	    DDR_SM__d = 6'b10_0001;
	 end
      6'b10_0001: begin
	    DDR_SM__d = 6'b10_0010;
	 end
      6'b10_0010: begin
	    DDR_SM__d = 6'b10_0011;
	 end
      6'b10_0011: begin

//  LEERSCHLAUFE
	    DDR_SM__d = 6'b00_0100;
	 end
      6'b00_0100: begin
	    DDR_SM__d = 6'b00_0101;
	 end
      6'b00_0101: begin
	    DDR_SM__d = 6'b00_0110;
	 end
      6'b00_0110: begin
	    DDR_SM__d = 6'b00_0111;
	 end
      6'b00_0111: begin
	    DDR_SM__d = 6'b00_0000;
	 end
      endcase
   end

// -------------------------------------------------------------
//  BLITTER ----------------------
// ---------------------------------------
   assign BLITTER_REQ_clk = DDRCLK0;
   assign BLITTER_REQ_d = BLITTER_SIG & (!DDR_CONFIG) & VCKE & (!nVCS);
   assign BLITTER_ROW_ADR = BLITTER_ADR[26:14];
   assign BLITTER_BA[1] = BLITTER_ADR[13];
   assign BLITTER_BA[0] = BLITTER_ADR[12];
   assign BLITTER_COL_ADR = BLITTER_ADR[11:2];

// ----------------------------------------------------------------------------
//  FIFO ---------------------------------
// ------------------------------------------------------
   assign FIFO_REQ_clk = DDRCLK0;
   assign FIFO_REQ_d = (FIFO_MW < 9'b0_1100_1000 | (FIFO_MW < 9'b1_1111_0100 &
	 FIFO_REQ_q)) & FIFO_ACTIVE & (!CLEAR_FIFO_CNT_q) & (!STOP_q) &
	 (!DDR_CONFIG) & VCKE & (!nVCS);
   assign FIFO_ROW_ADR = VIDEO_ADR_CNT_q[22:10];
   assign FIFO_BA[1] = VIDEO_ADR_CNT_q[9];
   assign FIFO_BA[0] = VIDEO_ADR_CNT_q[8];
   assign FIFO_COL_ADR = {VIDEO_ADR_CNT_q[7], VIDEO_ADR_CNT_q[6],
	 VIDEO_ADR_CNT_q[5], VIDEO_ADR_CNT_q[4], VIDEO_ADR_CNT_q[3],
	 VIDEO_ADR_CNT_q[2], VIDEO_ADR_CNT_q[1], VIDEO_ADR_CNT_q[0], 2'b00};
   assign FIFO_BANK_OK_clk = DDRCLK0;
   assign FIFO_BANK_OK_d_2 = FIFO_BANK_OK_q & (!FIFO_BANK_NOT_OK);

//  ZÄHLER RÜCKSETZEN WENN CLR FIFO ----------------
   assign CLR_FIFO_SYNC_clk = DDRCLK0;

//  SYNCHRONISIEREN
   assign CLR_FIFO_SYNC_d = CLR_FIFO;
   assign CLEAR_FIFO_CNT_clk = DDRCLK0;
   assign CLEAR_FIFO_CNT_d = CLR_FIFO_SYNC_q | (!FIFO_ACTIVE);
   assign STOP_clk = DDRCLK0;
   assign STOP_d = CLR_FIFO_SYNC_q | CLEAR_FIFO_CNT_q;

//  ZÄHLEN -----------------------------------------------
   assign VIDEO_ADR_CNT0_clk_ctrl = DDRCLK0;
   assign VIDEO_ADR_CNT0_ena_ctrl = SR_FIFO_WRE_q | CLEAR_FIFO_CNT_q;
   assign VIDEO_ADR_CNT_d = ({23{CLEAR_FIFO_CNT_q}} & VIDEO_BASE_ADR) |
	 ({23{!CLEAR_FIFO_CNT_q}} & (VIDEO_ADR_CNT_q + 23'h1));
   assign VIDEO_BASE_ADR[22:20] = VIDEO_BASE_X_D_q;
   assign VIDEO_BASE_ADR[19:12] = VIDEO_BASE_H_D_q;
   assign VIDEO_BASE_ADR[11:4] = VIDEO_BASE_M_D_q;
   assign VIDEO_BASE_ADR[3:0] = VIDEO_BASE_L_D_q[7:4];
   assign VDM_SEL = VIDEO_BASE_L_D_q[3:0];

//  AKTUELLE VIDEO ADRESSE
   assign VIDEO_ACT_ADR[26:4] = VIDEO_ADR_CNT_q - {14'b00_0000_0000_0000,
	 FIFO_MW};
   assign VIDEO_ACT_ADR[3:0] = VDM_SEL;

// ---------------------------------------------------------------------------------------
//  REFRESH: IMMER 8 AUFS MAL, ANFORDERUNG ALLE 7.8us X 8 STCK. = 62.4us = 2059->2048 33MHz CLOCKS
// ---------------------------------------------------------------------------------------
   assign DDR_REFRESH_CNT0_clk_ctrl = CLK33M;

//  ZÄHLEN 0-2047
   assign DDR_REFRESH_CNT_d = DDR_REFRESH_CNT_q + 11'b000_0000_0001;
   assign REFRESH_TIME_clk = DDRCLK0;

//  SYNC
   assign REFRESH_TIME_d = DDR_REFRESH_CNT_q == 11'b000_0000_0000 &
	 (!MAIN_CLK);
   assign DDR_REFRESH_SIG0_clk_ctrl = DDRCLK0;
   assign DDR_REFRESH_SIG0_ena_ctrl = REFRESH_TIME_q | DDR_SM__q == 6'b10_0011;

//  9 STÜCK (8 REFRESH UND 1 ALS VORLAUF)
//  MINUS 1 WENN GEMACHT
   assign DDR_REFRESH_SIG_d = ({4{REFRESH_TIME_q}} & 4'b1001 &
	 {4{DDR_REFRESH_ON}} & {4{!DDR_CONFIG}}) | ({4{!REFRESH_TIME_q}} &
	 (DDR_REFRESH_SIG_q - 4'b0001) & {4{DDR_REFRESH_ON}} &
	 {4{!DDR_CONFIG}});
   assign DDR_REFRESH_REQ_clk = DDRCLK0;
   assign DDR_REFRESH_REQ_d = DDR_REFRESH_SIG_q != 4'b0000 & DDR_REFRESH_ON &
	 (!REFRESH_TIME_q) & (!DDR_CONFIG);

// ---------------------------------------------------------
//  VIDEO REGISTER -----------------------
// -------------------------------------------------------------------------------------------------------------------
   assign VIDEO_BASE_L_D0_clk_ctrl = MAIN_CLK;

//  820D/2
   assign VIDEO_BASE_L = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C106;

//  SORRY, NUR 16 BYT GRENZEN
   assign VIDEO_BASE_L_D_d = FB_AD[23:16];
   assign VIDEO_BASE_L_D0_ena_ctrl = (!nFB_WR) & VIDEO_BASE_L & FB_B[1];
   assign VIDEO_BASE_M_D0_clk_ctrl = MAIN_CLK;

//  8203/2
   assign VIDEO_BASE_M = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C101;
   assign VIDEO_BASE_M_D_d = FB_AD[23:16];
   assign VIDEO_BASE_M_D0_ena_ctrl = (!nFB_WR) & VIDEO_BASE_M & FB_B[3];
   assign VIDEO_BASE_H_D0_clk_ctrl = MAIN_CLK;

//  8200-1/2
   assign VIDEO_BASE_H = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C100;
   assign VIDEO_BASE_H_D_d = FB_AD[23:16];
   assign VIDEO_BASE_H_D0_ena_ctrl = (!nFB_WR) & VIDEO_BASE_H & FB_B[1];
   assign VIDEO_BASE_X_D0_clk_ctrl = MAIN_CLK;
   assign VIDEO_BASE_X_D_d = FB_AD[26:24];
   assign VIDEO_BASE_X_D0_ena_ctrl = (!nFB_WR) & VIDEO_BASE_H & FB_B[0];

//  8209/2
   assign VIDEO_CNT_L = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C104;

//  8207/2
   assign VIDEO_CNT_M = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C103;

//  8204,5/2
   assign VIDEO_CNT_H = (!nFB_CS1) & FB_ADR[19:1] == 19'h7_C102;

//  GE
   assign VIDEO_BASE_X_D_FULL = {5'b0_0000, VIDEO_BASE_X_D_q};
   assign u0_data = ({8{VIDEO_BASE_H}} & VIDEO_BASE_X_D_FULL) |
	 ({8{VIDEO_CNT_H}} & {5'b0_0000, VIDEO_ACT_ADR[26:24]});
   assign u0_enabledt = (VIDEO_BASE_H | VIDEO_CNT_H) & (!nFB_OE);
   assign FB_AD[31:24] = u0_tridata;
   assign u1_data = ({8{VIDEO_BASE_L}} & VIDEO_BASE_L_D_q) | ({8{VIDEO_BASE_M}}
	 & VIDEO_BASE_M_D_q) | ({8{VIDEO_BASE_H}} & VIDEO_BASE_H_D_q) |
	 ({8{VIDEO_CNT_L}} & VIDEO_ACT_ADR[7:0]) | ({8{VIDEO_CNT_M}} &
	 VIDEO_ACT_ADR[15:8]) | ({8{VIDEO_CNT_H}} & VIDEO_ACT_ADR[23:16]);
   assign u1_enabledt = (VIDEO_BASE_L | VIDEO_BASE_M | VIDEO_BASE_H |
	 VIDEO_CNT_L | VIDEO_CNT_M | VIDEO_CNT_H) & (!nFB_OE);
   assign FB_AD[23:16] = u1_tridata;


// Assignments added to explicitly combine the
// effects of multiple drivers in the source
   assign FIFO_BANK_OK_d = FIFO_BANK_OK_d_1 | FIFO_BANK_OK_d_2;
   assign BUS_CYC_d = BUS_CYC_d_1 | BUS_CYC_d_2;
   assign BA[0] = BA0_1 | BA0_2;
   assign BA[1] = BA1_1 | BA1_2;
   assign VA[0] = VA0_1 | VA0_2;
   assign VA[1] = VA1_1 | VA1_2;
   assign VA[2] = VA2_1 | VA2_2;
   assign VA[3] = VA3_1 | VA3_2;
   assign VA[4] = VA4_1 | VA4_2;
   assign VA[5] = VA5_1 | VA5_2;
   assign VA[6] = VA6_1 | VA6_2;
   assign VA[7] = VA7_1 | VA7_2;
   assign VA[8] = VA8_1 | VA8_2;
   assign VA[9] = VA9_1 | VA9_2;
   assign VA[10] = VA10_1 | VA10_2;
   assign VA[11] = VA11_1 | VA11_2;
   assign VA[12] = VA12_1 | VA12_2;

// Define power signal(s)
   assign vcc = 1'b1;
   assign gnd = 1'b0;
endmodule
