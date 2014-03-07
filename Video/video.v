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
// CREATED		"Sat Mar 01 09:20:01 2014"

module video(
	MAIN_CLK,
	nFB_CS1,
	nFB_CS2,
	nFB_CS3,
	nFB_WR,
	FB_SIZE0,
	FB_SIZE1,
	nRSTO,
	nFB_OE,
	FB_ALE,
	DDR_SYNC_66M,
	CLK33M,
	CLK25M,
	CLK_VIDEO,
	VR_BUSY,
	DDRCLK,
	FB_ADR,
	VR_D,
	nBLANK,
	nVWE,
	nVCAS,
	nVRAS,
	nVCS,
	nPD_VGA,
	VCKE,
	VSYNC,
	HSYNC,
	nSYNC,
	VIDEO_TA,
	PIXEL_CLK,
	VIDEO_RECONFIG,
	VR_WR,
	VR_RD,
	BA,
	FB_AD,
	VA,
	VB,
	VD,
	VDM,
	VDQS,
	VG,
	VR
);


input	MAIN_CLK;
input	nFB_CS1;
input	nFB_CS2;
input	nFB_CS3;
input	nFB_WR;
input	FB_SIZE0;
input	FB_SIZE1;
input	nRSTO;
input	nFB_OE;
input	FB_ALE;
input	DDR_SYNC_66M;
input	CLK33M;
input	CLK25M;
input	CLK_VIDEO;
input	VR_BUSY;
input	[3:0] DDRCLK;
input	[31:0] FB_ADR;
input	[8:0] VR_D;
output	nBLANK;
output	nVWE;
output	nVCAS;
output	nVRAS;
output	nVCS;
output	nPD_VGA;
output	VCKE;
output	VSYNC;
output	HSYNC;
output	nSYNC;
output	VIDEO_TA;
output	PIXEL_CLK;
output	VIDEO_RECONFIG;
output	VR_WR;
output	VR_RD;
output	[1:0] BA;
inout	[31:0] FB_AD;
output	[12:0] VA;
output	[7:0] VB;
inout	[31:0] VD;
output	[3:0] VDM;
inout	[3:0] VDQS;
output	[7:0] VG;
output	[7:0] VR;

wire	ACP_CLUT_RD;
wire	[3:0] ACP_CLUT_WR;
wire	[31:0] BLITTER_ADR;
wire	[4:0] BLITTER_DACK;
wire	[127:0] BLITTER_DIN;
wire	[127:0] BLITTER_DOUT;
wire	BLITTER_ON;
wire	BLITTER_RUN;
wire	BLITTER_SIG;
wire	BLITTER_TA;
wire	BLITTER_WR;
wire	[23:0] CC16;
wire	[31:0] CC24;
wire	[23:0] CCA;
wire	[23:0] CCF;
wire	[23:0] CCR;
wire	[23:0] CCS;
wire	[2:0] CCSEL;
wire	CLR_FIFO;
wire	[7:0] CLUT_ADR;
wire	CLUT_ADR1A;
wire	CLUT_ADR2A;
wire	CLUT_ADR3A;
wire	CLUT_ADR4A;
wire	CLUT_ADR5A;
wire	CLUT_ADR6A;
wire	CLUT_ADR7A;
wire	[3:0] CLUT_MUX_ADR;
wire	[3:0] CLUT_OFF;
wire	COLOR1;
wire	COLOR2;
wire	COLOR4;
wire	COLOR8;
wire	[4:0] DDR_FB;
reg	DDR_WR;

//GE reg	[1:0] DDRWR_D_SEL;
wire DDRWR_D_SEL1;
reg DDRWR_D_SEL0;

wire	DOP_FIFO_CLR;
wire	FALCON_CLUT_RDH;
wire	FALCON_CLUT_RDL;
wire	[3:0] FALCON_CLUT_WR;
wire	[127:0] FB_DDR;
wire	[3:0] FB_LE;
wire	[3:0] FB_VDOE;
wire	[127:0] FIFO_D;
wire	[8:0] FIFO_MW;
wire	FIFO_RDE;
wire	FIFO_WRE;
wire	INTER_ZEI;
wire	nFB_BURST;
wire	PIXEL_CLK_ALTERA_SYNTHESIZED;
wire	SR_BLITTER_DACK;
wire	SR_DDR_FB;
wire	SR_DDR_WR;
wire	SR_DDRWR_D_SEL;
wire	SR_FIFO_WRE;
wire	[7:0] SR_VDMP;
wire	ST_CLUT_RD;
wire	[1:0] ST_CLUT_WR;
wire	[3:0] VDM_SEL;
wire	[127:0] VDMA;
wire	[127:0] VDMB;
wire	[127:0] VDMC;
wire	[7:0] VDMP;
wire	VDOUT_OE;
wire	[63:0] VDP_IN;
wire	[63:0] VDP_OUT;
wire	[31:0] VDR;
wire	[127:0] VDVZ;
wire	VIDEO_DDR_TA;
wire	VIDEO_MOD_TA;
wire	[15:0] VIDEO_RAM_CTR;
wire	[7:0] ZR_C8;
wire	[7:0] ZR_C8B;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_60;
wire	[15:0] SYNTHESIZED_WIRE_7;
reg	DFF_inst93;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_61;
wire	[31:0] SYNTHESIZED_WIRE_11;
wire	[7:0] SYNTHESIZED_WIRE_12;
wire	[31:0] SYNTHESIZED_WIRE_13;
wire	[31:0] SYNTHESIZED_WIRE_14;
wire	[31:0] SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_23;
wire	SYNTHESIZED_WIRE_24;
wire	[23:0] SYNTHESIZED_WIRE_25;
wire	[23:0] SYNTHESIZED_WIRE_26;
wire	[23:0] SYNTHESIZED_WIRE_62;
wire	[2:0] SYNTHESIZED_WIRE_29;
wire	[7:0] SYNTHESIZED_WIRE_30;
wire	[2:0] SYNTHESIZED_WIRE_31;
wire	[7:0] SYNTHESIZED_WIRE_32;
wire	[7:0] SYNTHESIZED_WIRE_33;
wire	[2:0] SYNTHESIZED_WIRE_34;
wire	[127:0] SYNTHESIZED_WIRE_63;
wire	[127:0] SYNTHESIZED_WIRE_36;
wire	SYNTHESIZED_WIRE_38;
wire	SYNTHESIZED_WIRE_40;
wire	[5:0] SYNTHESIZED_WIRE_41;
wire	[23:0] SYNTHESIZED_WIRE_42;
wire	[23:0] SYNTHESIZED_WIRE_43;
wire	[5:0] SYNTHESIZED_WIRE_44;
wire	[5:0] SYNTHESIZED_WIRE_45;
wire	SYNTHESIZED_WIRE_46;
wire	[6:0] SYNTHESIZED_WIRE_47;
wire	[31:0] SYNTHESIZED_WIRE_48;
reg	DFF_inst91;
reg	SYNTHESIZED_WIRE_64;
wire	SYNTHESIZED_WIRE_49;
wire	SYNTHESIZED_WIRE_50;
wire	SYNTHESIZED_WIRE_51;
wire	SYNTHESIZED_WIRE_52;
wire	SYNTHESIZED_WIRE_53;
wire	SYNTHESIZED_WIRE_54;
wire	SYNTHESIZED_WIRE_55;
wire	SYNTHESIZED_WIRE_56;
wire	SYNTHESIZED_WIRE_57;
wire	[23:0] SYNTHESIZED_WIRE_65;

assign	VB[7:0] = SYNTHESIZED_WIRE_65[7:0];
assign	VG[7:0] = SYNTHESIZED_WIRE_65[15:8];
assign	VR[7:0] = SYNTHESIZED_WIRE_65[23:16];
assign	SYNTHESIZED_WIRE_0 = 0;
assign	SYNTHESIZED_WIRE_1 = 0;
assign	SYNTHESIZED_WIRE_2 = 0;
assign	SYNTHESIZED_WIRE_3 = 0;
assign	SYNTHESIZED_WIRE_4 = 0;
assign	SYNTHESIZED_WIRE_5 = 0;
assign	SYNTHESIZED_WIRE_19 = 0;
assign	SYNTHESIZED_WIRE_20 = 0;
assign	SYNTHESIZED_WIRE_21 = 0;
assign	SYNTHESIZED_WIRE_22 = 0;
assign	SYNTHESIZED_WIRE_23 = 0;
assign	SYNTHESIZED_WIRE_24 = 0;
assign	SYNTHESIZED_WIRE_55 = 0;
assign	SYNTHESIZED_WIRE_56 = 0;
assign	SYNTHESIZED_WIRE_57 = 0;
wire	[127:0] GDFX_TEMP_SIGNAL_6;
wire	[127:0] GDFX_TEMP_SIGNAL_7;
wire	[127:0] GDFX_TEMP_SIGNAL_8;
wire	[127:0] GDFX_TEMP_SIGNAL_9;
wire	[127:0] GDFX_TEMP_SIGNAL_10;
wire	[127:0] GDFX_TEMP_SIGNAL_11;
wire	[127:0] GDFX_TEMP_SIGNAL_12;
wire	[127:0] GDFX_TEMP_SIGNAL_13;
wire	[127:0] GDFX_TEMP_SIGNAL_14;
wire	[127:0] GDFX_TEMP_SIGNAL_0;
wire	[127:0] GDFX_TEMP_SIGNAL_1;
wire	[127:0] GDFX_TEMP_SIGNAL_2;
wire	[127:0] GDFX_TEMP_SIGNAL_3;
wire	[127:0] GDFX_TEMP_SIGNAL_4;
wire	[127:0] GDFX_TEMP_SIGNAL_5;


assign	GDFX_TEMP_SIGNAL_6 = {VDMB[119:0],VDMA[127:120]};
assign	GDFX_TEMP_SIGNAL_7 = {VDMB[111:0],VDMA[127:112]};
assign	GDFX_TEMP_SIGNAL_8 = {VDMB[103:0],VDMA[127:104]};
assign	GDFX_TEMP_SIGNAL_9 = {VDMB[95:0],VDMA[127:96]};
assign	GDFX_TEMP_SIGNAL_10 = {VDMB[87:0],VDMA[127:88]};
assign	GDFX_TEMP_SIGNAL_11 = {VDMB[79:0],VDMA[127:80]};
assign	GDFX_TEMP_SIGNAL_12 = {VDMB[71:0],VDMA[127:72]};
assign	GDFX_TEMP_SIGNAL_13 = {VDMB[63:0],VDMA[127:64]};
assign	GDFX_TEMP_SIGNAL_14 = {VDMB[55:0],VDMA[127:56]};
assign	GDFX_TEMP_SIGNAL_0 = {VDMB[47:0],VDMA[127:48]};
assign	GDFX_TEMP_SIGNAL_1 = {VDMB[39:0],VDMA[127:40]};
assign	GDFX_TEMP_SIGNAL_2 = {VDMB[31:0],VDMA[127:32]};
assign	GDFX_TEMP_SIGNAL_3 = {VDMB[23:0],VDMA[127:24]};
assign	GDFX_TEMP_SIGNAL_4 = {VDMB[15:0],VDMA[127:16]};
assign	GDFX_TEMP_SIGNAL_5 = {VDMB[7:0],VDMA[127:8]};


altdpram2	b2v_ACP_CLUT_RAM(
	.wren_a(ACP_CLUT_WR[3]),
	.wren_b(SYNTHESIZED_WIRE_0),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[9:2]),
	.address_b(ZR_C8B),
	.data_a(FB_AD[7:0]),
	
	.q_a(SYNTHESIZED_WIRE_30),
	.q_b(CCA[7:0]));


altdpram2	b2v_ACP_CLUT_RAM54(
	.wren_a(ACP_CLUT_WR[2]),
	.wren_b(SYNTHESIZED_WIRE_1),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[9:2]),
	.address_b(ZR_C8B),
	.data_a(FB_AD[15:8]),
	
	.q_a(SYNTHESIZED_WIRE_32),
	.q_b(CCA[15:8]));


altdpram2	b2v_ACP_CLUT_RAM55(
	.wren_a(ACP_CLUT_WR[1]),
	.wren_b(SYNTHESIZED_WIRE_2),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[9:2]),
	.address_b(ZR_C8B),
	.data_a(FB_AD[23:16]),
	
	.q_a(SYNTHESIZED_WIRE_33),
	.q_b(CCA[23:16]));


BLITTER	b2v_BLITTER(
	.nRSTO(nRSTO),
	.MAIN_CLK(MAIN_CLK),
	.FB_ALE(FB_ALE),
	.nFB_WR(nFB_WR),
	.nFB_OE(nFB_OE),
	.FB_SIZE0(FB_SIZE0),
	.FB_SIZE1(FB_SIZE1),
	.BLITTER_ON(BLITTER_ON),
	.nFB_CS1(nFB_CS1),
	.nFB_CS2(nFB_CS2),
	.nFB_CS3(nFB_CS3),
	.DDRCLK0(DDRCLK[0]),
	.BLITTER_DACK(BLITTER_DACK),
	.BLITTER_DIN(BLITTER_DIN),
	.FB_AD(FB_AD),
	.FB_ADR(FB_ADR),
	.VIDEO_RAM_CTR(VIDEO_RAM_CTR),
	.BLITTER_RUN(BLITTER_RUN),
	.BLITTER_SIG(BLITTER_SIG),
	.BLITTER_WR(BLITTER_WR),
	.BLITTER_TA(BLITTER_TA),
	.BLITTER_ADR(BLITTER_ADR),
	.BLITTER_DOUT(BLITTER_DOUT)
	);


DDR_CTR	b2v_DDR_CTR(
	.nFB_CS1(nFB_CS1),
	.nFB_CS2(nFB_CS2),
	.nFB_CS3(nFB_CS3),
	.nFB_OE(nFB_OE),
	.FB_SIZE0(FB_SIZE0),
	.FB_SIZE1(FB_SIZE1),
	.nRSTO(nRSTO),
	.MAIN_CLK(MAIN_CLK),
	.FB_ALE(FB_ALE),
	.nFB_WR(nFB_WR),
	.DDR_SYNC_66M(DDR_SYNC_66M),
	.BLITTER_SIG(BLITTER_SIG),
	.BLITTER_WR(BLITTER_WR),
	.DDRCLK0(DDRCLK[0]),
	.CLK33M(CLK33M),
	.CLR_FIFO(CLR_FIFO),
	.BLITTER_ADR(BLITTER_ADR),
	.FB_AD(FB_AD),
	.FB_ADR(FB_ADR),
	.FIFO_MW(FIFO_MW),
	.VIDEO_RAM_CTR(VIDEO_RAM_CTR),
	.nVWE(nVWE),
	.nVRAS(nVRAS),
	.nVCS(nVCS),
	.VCKE(VCKE),
	.nVCAS(nVCAS),
	.SR_FIFO_WRE(SR_FIFO_WRE),
	.SR_DDR_FB(SR_DDR_FB),
	.SR_DDR_WR(SR_DDR_WR),
	.SR_DDRWR_D_SEL(SR_DDRWR_D_SEL),
	.VIDEO_DDR_TA(VIDEO_DDR_TA),
	.SR_BLITTER_DACK(SR_BLITTER_DACK),
	.DDRWR_D_SEL1(DDRWR_D_SEL1),
	.BA(BA),
	
	.FB_LE(FB_LE),
	.FB_VDOE(FB_VDOE),
	.SR_VDMP(SR_VDMP),
	.VA(VA),
	.VDM_SEL(VDM_SEL));


altdpram1	b2v_FALCON_CLUT_BLUE(
	.wren_a(FALCON_CLUT_WR[3]),
	.wren_b(SYNTHESIZED_WIRE_3),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[9:2]),
	.address_b(CLUT_ADR),
	.data_a(FB_AD[23:18]),
	
	.q_a(SYNTHESIZED_WIRE_45),
	.q_b(CCF[7:2]));


altdpram1	b2v_FALCON_CLUT_GREEN(
	.wren_a(FALCON_CLUT_WR[1]),
	.wren_b(SYNTHESIZED_WIRE_4),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[9:2]),
	.address_b(CLUT_ADR),
	.data_a(FB_AD[23:18]),
	
	.q_a(SYNTHESIZED_WIRE_44),
	.q_b(CCF[15:10]));


altdpram1	b2v_FALCON_CLUT_RED(
	.wren_a(FALCON_CLUT_WR[0]),
	.wren_b(SYNTHESIZED_WIRE_5),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[9:2]),
	.address_b(CLUT_ADR),
	.data_a(FB_AD[31:26]),
	
	.q_a(SYNTHESIZED_WIRE_41),
	.q_b(CCF[23:18]));


lpm_fifo_dc0	b2v_inst(
	.wrreq(FIFO_WRE),
	.wrclk(DDRCLK[0]),
	.rdreq(SYNTHESIZED_WIRE_60),
	.rdclk(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.aclr(CLR_FIFO),
	.data(VDMC),
	
	.q(SYNTHESIZED_WIRE_63),
	.wrusedw(FIFO_MW));


altddio_bidir0	b2v_inst1(
	.oe(VDOUT_OE),
	.inclock(DDRCLK[1]),
	.outclock(DDRCLK[3]),
	.datain_h(VDP_OUT[63:32]),
	.datain_l(VDP_OUT[31:0]),
	.padio(VD),
	.combout(SYNTHESIZED_WIRE_15),
	.dataout_h(VDP_IN[31:0]),
	.dataout_l(VDP_IN[63:32])
	);


lpm_ff4	b2v_inst10(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data(SYNTHESIZED_WIRE_7),
	.q({CC16[23:19],CC16[15:10],CC16[7:3]}));


lpm_muxVDM	b2v_inst100(
	.data0x(VDMB),
	.data10x(GDFX_TEMP_SIGNAL_0),
	.data11x(GDFX_TEMP_SIGNAL_1),
	.data12x(GDFX_TEMP_SIGNAL_2),
	.data13x(GDFX_TEMP_SIGNAL_3),
	.data14x(GDFX_TEMP_SIGNAL_4),
	.data15x(GDFX_TEMP_SIGNAL_5),
	.data1x(GDFX_TEMP_SIGNAL_6),
	.data2x(GDFX_TEMP_SIGNAL_7),
	.data3x(GDFX_TEMP_SIGNAL_8),
	.data4x(GDFX_TEMP_SIGNAL_9),
	.data5x(GDFX_TEMP_SIGNAL_10),
	.data6x(GDFX_TEMP_SIGNAL_11),
	.data7x(GDFX_TEMP_SIGNAL_12),
	.data8x(GDFX_TEMP_SIGNAL_13),
	.data9x(GDFX_TEMP_SIGNAL_14),
	.sel(VDM_SEL),
	.result(VDMC));


lpm_mux3	b2v_inst102(
	.data1(DFF_inst93),
	.data0(ZR_C8[0]),
	.sel(COLOR1),
	.result(ZR_C8B[0]));

assign	CLUT_ADR[4] = CLUT_OFF[0] | SYNTHESIZED_WIRE_8;

assign	CLUT_ADR[6] = CLUT_OFF[2] | SYNTHESIZED_WIRE_9;

assign	SYNTHESIZED_WIRE_61 = COLOR8 | COLOR4;

assign	CLUT_ADR[2] = CLUT_ADR2A & SYNTHESIZED_WIRE_61;

assign	SYNTHESIZED_WIRE_16 = COLOR4 | COLOR8 | COLOR2;


/*lpm_bustri_LONG	b2v_inst108(
	.enabledt(FB_VDOE[0]),
	.data(VDR),
	.tridata(FB_AD)
	);*/
assign FB_AD = (FB_VDOE[0]) ? VDR : 32'hzzzzzzzz;


/*lpm_bustri_LONG	b2v_inst109(
	.enabledt(FB_VDOE[1]),
	.data(SYNTHESIZED_WIRE_11),
	.tridata(FB_AD)
	);*/
assign FB_AD = (FB_VDOE[1]) ? SYNTHESIZED_WIRE_11 : 32'hzzzzzzzz;


lpm_ff5	b2v_inst11(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data(SYNTHESIZED_WIRE_12),
	.q(ZR_C8));


/*lpm_bustri_LONG	b2v_inst110(
	.enabledt(FB_VDOE[2]),
	.data(SYNTHESIZED_WIRE_13),
	.tridata(FB_AD)
	);*/
assign FB_AD = (FB_VDOE[2]) ? SYNTHESIZED_WIRE_13 : 32'hzzzzzzzz;


/*lpm_bustri_LONG	b2v_inst119(
	.enabledt(FB_VDOE[3]),
	.data(SYNTHESIZED_WIRE_14),
	.tridata(FB_AD)
	);*/
assign FB_AD = (FB_VDOE[3]) ? SYNTHESIZED_WIRE_14 : 32'hzzzzzzzz;


lpm_ff1	b2v_inst12(
	.clock(DDRCLK[0]),
	.data(VDP_IN[31:0]),
	.q(VDVZ[31:0]));


lpm_ff0	b2v_inst13(
	.clock(DDR_SYNC_66M),
	.enable(FB_LE[0]),
	.data(FB_AD),
	.q(FB_DDR[127:96]));


lpm_ff0	b2v_inst14(
	.clock(DDR_SYNC_66M),
	.enable(FB_LE[1]),
	.data(FB_AD),
	.q(FB_DDR[95:64]));


lpm_ff0	b2v_inst15(
	.clock(DDR_SYNC_66M),
	.enable(FB_LE[2]),
	.data(FB_AD),
	.q(FB_DDR[63:32]));


lpm_ff0	b2v_inst16(
	.clock(DDR_SYNC_66M),
	.enable(FB_LE[3]),
	.data(FB_AD),
	.q(FB_DDR[31:0]));


lpm_ff0	b2v_inst17(
	.clock(DDRCLK[0]),
	.enable(DDR_FB[1]),
	.data(VDP_IN[31:0]),
	.q(SYNTHESIZED_WIRE_11));


lpm_ff0	b2v_inst18(
	.clock(DDRCLK[0]),
	.enable(DDR_FB[0]),
	.data(VDP_IN[63:32]),
	.q(SYNTHESIZED_WIRE_13));


lpm_ff0	b2v_inst19(
	.clock(DDRCLK[0]),
	.enable(DDR_FB[0]),
	.data(VDP_IN[31:0]),
	.q(SYNTHESIZED_WIRE_14));


altddio_out0	b2v_inst2(
	.outclock(DDRCLK[3]),
	.datain_h(VDMP[7:4]),
	.datain_l(VDMP[3:0]),
	.dataout(VDM));


lpm_ff1	b2v_inst20(
	.clock(DDRCLK[0]),
	.data(VDVZ[31:0]),
	.q(VDVZ[95:64]));


lpm_mux0	b2v_inst21(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data0x(FIFO_D[127:96]),
	.data1x(FIFO_D[95:64]),
	.data2x(FIFO_D[63:32]),
	.data3x(FIFO_D[31:0]),
	.sel(CLUT_MUX_ADR[1:0]),
	.result(SYNTHESIZED_WIRE_48));


lpm_mux5	b2v_inst22(
	.data0x(FB_DDR[127:64]),
	.data1x(FB_DDR[63:0]),
	.data2x(BLITTER_DOUT[127:64]),
	.data3x(BLITTER_DOUT[63:0]),
	.sel({DDRWR_D_SEL1, DDRWR_D_SEL0}),
	.result(VDP_OUT));


lpm_constant2	b2v_inst23(
	.result({CC16[18:16],CC16[9:8],CC16[2:0]}));


lpm_mux1	b2v_inst24(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data0x(FIFO_D[127:112]),
	.data1x(FIFO_D[111:96]),
	.data2x(FIFO_D[95:80]),
	.data3x(FIFO_D[79:64]),
	.data4x(FIFO_D[63:48]),
	.data5x(FIFO_D[47:32]),
	.data6x(FIFO_D[31:16]),
	.data7x(FIFO_D[15:0]),
	.sel(CLUT_MUX_ADR[2:0]),
	.result(SYNTHESIZED_WIRE_7));


lpm_mux2	b2v_inst25(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data0x(FIFO_D[127:120]),
	.data10x(FIFO_D[47:40]),
	.data11x(FIFO_D[39:32]),
	.data12x(FIFO_D[31:24]),
	.data13x(FIFO_D[23:16]),
	.data14x(FIFO_D[15:8]),
	.data15x(FIFO_D[7:0]),
	.data1x(FIFO_D[119:112]),
	.data2x(FIFO_D[111:104]),
	.data3x(FIFO_D[103:96]),
	.data4x(FIFO_D[95:88]),
	.data5x(FIFO_D[87:80]),
	.data6x(FIFO_D[79:72]),
	.data7x(FIFO_D[71:64]),
	.data8x(FIFO_D[63:56]),
	.data9x(FIFO_D[55:48]),
	.sel(CLUT_MUX_ADR),
	.result(SYNTHESIZED_WIRE_12));


lpm_shiftreg4	b2v_inst26(
	.clock(DDRCLK[0]),
	.shiftin(SR_FIFO_WRE),
	.shiftout(FIFO_WRE));


/*lpm_latch0	b2v_inst27(
	.gate(DDR_SYNC_66M),
	.data(SYNTHESIZED_WIRE_15),
	.q(VDR));*/
reg	[31:0] VDR_q = 32'd0;
assign VDR = VDR_q;
always @(DDR_SYNC_66M or SYNTHESIZED_WIRE_15) begin
	if (DDR_SYNC_66M) begin
		VDR_q <= SYNTHESIZED_WIRE_15;
	end else begin
		VDR_q <= VDR_q;
	end
end


assign	CLUT_ADR[1] = CLUT_ADR1A & SYNTHESIZED_WIRE_16;


lpm_ff1	b2v_inst3(
	.clock(DDRCLK[0]),
	.data(VDP_IN[63:32]),
	.q(VDVZ[63:32]));

assign	CLUT_ADR[3] = SYNTHESIZED_WIRE_61 & CLUT_ADR3A;

assign	CLUT_ADR[5] = CLUT_OFF[1] | SYNTHESIZED_WIRE_18;

assign	SYNTHESIZED_WIRE_8 = CLUT_ADR4A & COLOR8;

assign	SYNTHESIZED_WIRE_18 = CLUT_ADR5A & COLOR8;

assign	SYNTHESIZED_WIRE_9 = CLUT_ADR6A & COLOR8;

assign	SYNTHESIZED_WIRE_46 = CLUT_ADR7A & COLOR8;


lpm_ff6	b2v_inst36(
	.clock(DDRCLK[0]),
	.enable(BLITTER_DACK[0]),
	.data(VDVZ),
	.q(BLITTER_DIN));

assign	VDOUT_OE = DDR_WR | SR_DDR_WR;


assign	VIDEO_TA = BLITTER_TA | VIDEO_MOD_TA | VIDEO_DDR_TA;


lpm_ff1	b2v_inst4(
	.clock(DDRCLK[0]),
	.data(VDVZ[63:32]),
	.q(VDVZ[127:96]));


mux41_0	b2v_inst40(
	.S0(COLOR2),
	
	.S1(COLOR4),
	
	.D0(CLUT_ADR6A),
	.INH(SYNTHESIZED_WIRE_19),
	.D1(CLUT_ADR7A),
	.Q(SYNTHESIZED_WIRE_54));


mux41_1	b2v_inst41(
	.S0(COLOR2),
	
	.S1(COLOR4),
	
	.D0(CLUT_ADR5A),
	.INH(SYNTHESIZED_WIRE_20),
	.D1(CLUT_ADR6A),
	.Q(SYNTHESIZED_WIRE_53));


mux41_2	b2v_inst42(
	.S0(COLOR2),
	.D2(CLUT_ADR7A),
	.S1(COLOR4),
	
	.D0(CLUT_ADR4A),
	.INH(SYNTHESIZED_WIRE_21),
	.D1(CLUT_ADR5A),
	.Q(SYNTHESIZED_WIRE_52));


mux41_3	b2v_inst43(
	.S0(COLOR2),
	.D2(CLUT_ADR6A),
	.S1(COLOR4),
	
	.D0(CLUT_ADR3A),
	.INH(SYNTHESIZED_WIRE_22),
	.D1(CLUT_ADR4A),
	.Q(SYNTHESIZED_WIRE_51));


mux41_4	b2v_inst44(
	.S0(COLOR2),
	.D2(CLUT_ADR5A),
	.S1(COLOR4),
	
	.D0(CLUT_ADR2A),
	.INH(SYNTHESIZED_WIRE_23),
	.D1(CLUT_ADR3A),
	.Q(SYNTHESIZED_WIRE_50));


mux41_5	b2v_inst45(
	.S0(COLOR2),
	.D2(CLUT_ADR4A),
	.S1(COLOR4),
	
	.D0(CLUT_ADR1A),
	.INH(SYNTHESIZED_WIRE_24),
	.D1(CLUT_ADR2A),
	.Q(SYNTHESIZED_WIRE_49));


lpm_ff3	b2v_inst46(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data(SYNTHESIZED_WIRE_25),
	.q(SYNTHESIZED_WIRE_43));


lpm_ff3	b2v_inst47(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data(CCF),
	.q(SYNTHESIZED_WIRE_25));



lpm_ff3	b2v_inst49(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data(SYNTHESIZED_WIRE_26),
	.q(SYNTHESIZED_WIRE_42));


altddio_out2	b2v_inst5(
	.outclock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.datain_h(SYNTHESIZED_WIRE_62),
	.datain_l(SYNTHESIZED_WIRE_62),
	.dataout(SYNTHESIZED_WIRE_65));



/*lpm_bustri1	b2v_inst51(
	.enabledt(ST_CLUT_RD),
	.data(SYNTHESIZED_WIRE_29),
	.tridata(FB_AD[26:24])
	);*/
assign FB_AD[26:24] = (ST_CLUT_RD) ? SYNTHESIZED_WIRE_29 : 3'bzzz; 


lpm_ff3	b2v_inst52(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data(CCS),
	.q(SYNTHESIZED_WIRE_26));


/*lpm_bustri_BYT	b2v_inst53(
	.enabledt(ACP_CLUT_RD),
	.data(SYNTHESIZED_WIRE_30),
	.tridata(FB_AD[7:0])
	);*/
assign FB_AD[7:0] = (ACP_CLUT_RD) ? SYNTHESIZED_WIRE_30 : 8'hzz;


lpm_constant0	b2v_inst54(
	.result(CCS[20:16]));



/*lpm_bustri1	b2v_inst56(
	.enabledt(ST_CLUT_RD),
	.data(SYNTHESIZED_WIRE_31),
	.tridata(FB_AD[22:20])
	);*/
assign FB_AD[22:20] = (ST_CLUT_RD) ? SYNTHESIZED_WIRE_31 : 3'bzzz; 


/*lpm_bustri_BYT	b2v_inst57(
	.enabledt(ACP_CLUT_RD),
	.data(SYNTHESIZED_WIRE_32),
	.tridata(FB_AD[15:8])
	);*/
assign FB_AD[15:8] = (ACP_CLUT_RD) ? SYNTHESIZED_WIRE_32 : 8'hzz;

/*lpm_bustri_BYT	b2v_inst58(
	.enabledt(ACP_CLUT_RD),
	.data(SYNTHESIZED_WIRE_33),
	.tridata(FB_AD[23:16])
	);*/
assign FB_AD[23:16] = (ACP_CLUT_RD) ? SYNTHESIZED_WIRE_33 : 8'hzz;


lpm_constant0	b2v_inst59(
	.result(CCS[12:8]));




/*lpm_bustri1	b2v_inst61(
	.enabledt(ST_CLUT_RD),
	.data(SYNTHESIZED_WIRE_34),
	.tridata(FB_AD[18:16])
	);*/
assign FB_AD[18:16] = (ST_CLUT_RD) ? SYNTHESIZED_WIRE_34 : 3'bzzz;


lpm_muxDZ	b2v_inst62(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.clken(FIFO_RDE),
	.sel(INTER_ZEI),
	.data0x(SYNTHESIZED_WIRE_63),
	.data1x(SYNTHESIZED_WIRE_36),
	.result(FIFO_D));


lpm_fifoDZ	b2v_inst63(
	.wrreq(SYNTHESIZED_WIRE_60),
	.rdreq(SYNTHESIZED_WIRE_38),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.aclr(DOP_FIFO_CLR),
	.data(SYNTHESIZED_WIRE_63),
	.q(SYNTHESIZED_WIRE_36));


lpm_constant0	b2v_inst64(
	.result(CCS[4:0]));

assign	SYNTHESIZED_WIRE_60 = FIFO_RDE & SYNTHESIZED_WIRE_40;


/*lpm_bustri3	b2v_inst66(
	.enabledt(FALCON_CLUT_RDH),
	.data(SYNTHESIZED_WIRE_41),
	.tridata(FB_AD[31:26])
	);*/
assign FB_AD[31:26] = (FALCON_CLUT_RDH) ? SYNTHESIZED_WIRE_41 : 6'bzzzzzz; 

assign	SYNTHESIZED_WIRE_38 = FIFO_RDE & INTER_ZEI;


assign	SYNTHESIZED_WIRE_40 =  ~INTER_ZEI;


lpm_mux6	b2v_inst7(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data0x(SYNTHESIZED_WIRE_42),
	.data1x(SYNTHESIZED_WIRE_43),
	
	
	.data4x(CCA),
	.data5x(CC16),
	.data6x(CC24[23:0]),
	.data7x(CCR),
	.sel(CCSEL),
	.result(SYNTHESIZED_WIRE_62));


/*lpm_bustri3	b2v_inst70(
	.enabledt(FALCON_CLUT_RDH),
	.data(SYNTHESIZED_WIRE_44),
	.tridata(FB_AD[23:18])
	);*/
assign FB_AD[23:18] = (FALCON_CLUT_RDH) ? SYNTHESIZED_WIRE_44 : 6'bzzzzzz; 


lpm_ff6	b2v_inst71(
	.clock(DDRCLK[0]),
	.enable(FIFO_WRE),
	.data(VDVZ),
	.q(VDMA));




/*lpm_bustri3	b2v_inst74(
	.enabledt(FALCON_CLUT_RDL),
	.data(SYNTHESIZED_WIRE_45),
	.tridata(FB_AD[23:18])
	);*/
assign FB_AD[23:18] = (FALCON_CLUT_RDL) ? SYNTHESIZED_WIRE_45 : 6'bzzzzzz; 




lpm_constant1	b2v_inst77(
	.result(CCF[1:0]));


assign	CLUT_ADR[7] = CLUT_OFF[3] | SYNTHESIZED_WIRE_46;



lpm_constant1	b2v_inst80(
	.result(CCF[9:8]));


lpm_mux4	b2v_inst81(
	.sel(COLOR1),
	.data0x(ZR_C8[7:1]),
	.data1x(SYNTHESIZED_WIRE_47),
	.result(ZR_C8B[7:1]));


lpm_constant3	b2v_inst82(
	.result(SYNTHESIZED_WIRE_47));


lpm_constant1	b2v_inst83(
	.result(CCF[17:16]));

assign	VDQS[3] = DDR_WR ? DDRCLK[0] : 1'bz;

assign	VDQS[2] = DDR_WR ? DDRCLK[0] : 1'bz;

assign	VDQS[1] = DDR_WR ? DDRCLK[0] : 1'bz;

assign	VDQS[0] = DDR_WR ? DDRCLK[0] : 1'bz;


always@(posedge DDRCLK[3])
begin
	begin
	DDRWR_D_SEL0 = SR_DDRWR_D_SEL;
	end
end


lpm_shiftreg6	b2v_inst89(
	.clock(DDRCLK[0]),
	.shiftin(SR_BLITTER_DACK),
	.q(BLITTER_DACK));


lpm_ff1	b2v_inst9(
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.data(SYNTHESIZED_WIRE_48),
	.q(CC24));


always@(posedge DDRCLK[3])
begin
	begin
	DDR_WR = SR_DDR_WR;
	end
end


always@(posedge PIXEL_CLK_ALTERA_SYNTHESIZED)
begin
	begin
	DFF_inst91 = CLUT_ADR[0];
	end
end


lpm_shiftreg6	b2v_inst92(
	.clock(DDRCLK[0]),
	.shiftin(SR_DDR_FB),
	.q(DDR_FB));


always@(posedge PIXEL_CLK_ALTERA_SYNTHESIZED)
begin
	begin
	DFF_inst93 = DFF_inst91;
	end
end


lpm_ff6	b2v_inst94(
	.clock(DDRCLK[0]),
	.enable(FIFO_WRE),
	.data(VDMA),
	.q(VDMB));


always@(posedge PIXEL_CLK_ALTERA_SYNTHESIZED)
begin
	begin
	SYNTHESIZED_WIRE_64 = FIFO_RDE;
	end
end



lpm_ff5	b2v_inst97(
	.clock(DDRCLK[2]),
	.data(SR_VDMP),
	.q(VDMP));


lpm_shiftreg0	b2v_sr0(
	.load(SYNTHESIZED_WIRE_64),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.shiftin(SYNTHESIZED_WIRE_49),
	.data(FIFO_D[127:112]),
	.shiftout(CLUT_ADR[0]));


lpm_shiftreg0	b2v_sr1(
	.load(SYNTHESIZED_WIRE_64),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.shiftin(SYNTHESIZED_WIRE_50),
	.data(FIFO_D[111:96]),
	.shiftout(CLUT_ADR1A));


lpm_shiftreg0	b2v_sr2(
	.load(SYNTHESIZED_WIRE_64),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.shiftin(SYNTHESIZED_WIRE_51),
	.data(FIFO_D[95:80]),
	.shiftout(CLUT_ADR2A));


lpm_shiftreg0	b2v_sr3(
	.load(SYNTHESIZED_WIRE_64),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.shiftin(SYNTHESIZED_WIRE_52),
	.data(FIFO_D[79:64]),
	.shiftout(CLUT_ADR3A));


lpm_shiftreg0	b2v_sr4(
	.load(SYNTHESIZED_WIRE_64),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.shiftin(SYNTHESIZED_WIRE_53),
	.data(FIFO_D[63:48]),
	.shiftout(CLUT_ADR4A));


lpm_shiftreg0	b2v_sr5(
	.load(SYNTHESIZED_WIRE_64),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.shiftin(SYNTHESIZED_WIRE_54),
	.data(FIFO_D[47:32]),
	.shiftout(CLUT_ADR5A));


lpm_shiftreg0	b2v_sr6(
	.load(SYNTHESIZED_WIRE_64),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.shiftin(CLUT_ADR7A),
	.data(FIFO_D[31:16]),
	.shiftout(CLUT_ADR6A));


lpm_shiftreg0	b2v_sr7(
	.load(SYNTHESIZED_WIRE_64),
	.clock(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.shiftin(CLUT_ADR[0]),
	.data(FIFO_D[15:0]),
	.shiftout(CLUT_ADR7A));


altdpram0	b2v_ST_CLUT_BLUE(
	.wren_a(ST_CLUT_WR[1]),
	.wren_b(SYNTHESIZED_WIRE_55),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[4:1]),
	.address_b(CLUT_ADR[3:0]),
	.data_a(FB_AD[18:16]),
	
	.q_a(SYNTHESIZED_WIRE_34),
	.q_b(CCS[7:5]));


altdpram0	b2v_ST_CLUT_GREEN(
	.wren_a(ST_CLUT_WR[1]),
	.wren_b(SYNTHESIZED_WIRE_56),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[4:1]),
	.address_b(CLUT_ADR[3:0]),
	.data_a(FB_AD[22:20]),
	
	.q_a(SYNTHESIZED_WIRE_31),
	.q_b(CCS[15:13]));


altdpram0	b2v_ST_CLUT_RED(
	.wren_a(ST_CLUT_WR[0]),
	.wren_b(SYNTHESIZED_WIRE_57),
	.clock_a(MAIN_CLK),
	.clock_b(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.address_a(FB_ADR[4:1]),
	.address_b(CLUT_ADR[3:0]),
	.data_a(FB_AD[26:24]),
	
	.q_a(SYNTHESIZED_WIRE_29),
	.q_b(CCS[23:21]));


VIDEO_MOD_MUX_CLUTCTR	b2v_VIDEO_MOD_MUX_CLUTCTR(
	.nRSTO(nRSTO),
	.MAIN_CLK(MAIN_CLK),
	.nFB_CS1(nFB_CS1),
	.nFB_CS2(nFB_CS2),
	.nFB_CS3(nFB_CS3),
	.nFB_WR(nFB_WR),
	.nFB_OE(nFB_OE),
	.FB_SIZE0(FB_SIZE0),
	.FB_SIZE1(FB_SIZE1),
	.nFB_BURST(nFB_BURST),
	.CLK33M(CLK33M),
	.CLK25M(CLK25M),
	.BLITTER_RUN(BLITTER_RUN),
	.CLK_VIDEO(CLK_VIDEO),
	.VR_BUSY(VR_BUSY),
	.FB_AD(FB_AD),
	.FB_ADR(FB_ADR),
	.VR_D(VR_D),
	.COLOR8(COLOR8),
	.ACP_CLUT_RD(ACP_CLUT_RD),
	.COLOR1(COLOR1),
	.FALCON_CLUT_RDH(FALCON_CLUT_RDH),
	.FALCON_CLUT_RDL(FALCON_CLUT_RDL),
	.ST_CLUT_RD(ST_CLUT_RD),
	.HSYNC(HSYNC),
	.VSYNC(VSYNC),
	.nBLANK(nBLANK),
	.nSYNC(nSYNC),
	.nPD_VGA(nPD_VGA),
	.FIFO_RDE(FIFO_RDE),
	.COLOR2(COLOR2),
	.COLOR4(COLOR4),
	.PIXEL_CLK(PIXEL_CLK_ALTERA_SYNTHESIZED),
	.BLITTER_ON(BLITTER_ON),
	.VIDEO_MOD_TA(VIDEO_MOD_TA),
	.INTER_ZEI(INTER_ZEI),
	.DOP_FIFO_CLR(DOP_FIFO_CLR),
	.VIDEO_RECONFIG(VIDEO_RECONFIG),
	.VR_WR(VR_WR),
	.VR_RD(VR_RD),
	.CLR_FIFO(CLR_FIFO),
	.ACP_CLUT_WR(ACP_CLUT_WR),
	.CCR(CCR),
	.CCSEL(CCSEL),
	.CLUT_MUX_ADR(CLUT_MUX_ADR),
	.CLUT_OFF(CLUT_OFF),
	.FALCON_CLUT_WR(FALCON_CLUT_WR),
	
	.ST_CLUT_WR(ST_CLUT_WR),
	.VIDEO_RAM_CTR(VIDEO_RAM_CTR));

assign	PIXEL_CLK = PIXEL_CLK_ALTERA_SYNTHESIZED;

endmodule

module mux41_0(S0,S1,D0,INH,D1,Q);
/* synthesis black_box */

input S0;
input S1;
input D0;
input INH;
input D1;
output Q;

endmodule

module mux41_1(S0,S1,D0,INH,D1,Q);
/* synthesis black_box */

input S0;
input S1;
input D0;
input INH;
input D1;
output Q;

endmodule

module mux41_2(S0,D2,S1,D0,INH,D1,Q);
/* synthesis black_box */

input S0;
input D2;
input S1;
input D0;
input INH;
input D1;
output Q;

endmodule

module mux41_3(S0,D2,S1,D0,INH,D1,Q);
/* synthesis black_box */

input S0;
input D2;
input S1;
input D0;
input INH;
input D1;
output Q;

endmodule

module mux41_4(S0,D2,S1,D0,INH,D1,Q);
/* synthesis black_box */

input S0;
input D2;
input S1;
input D0;
input INH;
input D1;
output Q;

endmodule

module mux41_5(S0,D2,S1,D0,INH,D1,Q);
/* synthesis black_box */

input S0;
input D2;
input S1;
input D0;
input INH;
input D1;
output Q;

endmodule
