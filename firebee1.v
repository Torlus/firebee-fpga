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
// CREATED		"Sat Mar 01 09:20:47 2014"

module firebee1(
	FB_ALE,
	nFB_WR,
	CLK33M,
	nFB_CS1,
	nFB_CS2,
	nFB_CS3,
	FB_SIZE0,
	FB_SIZE1,
	nFB_BURST,
	LP_BUSY,
	nACSI_DRQ,
	nACSI_INT,
	RxD,
	CTS,
	RI,
	DCD,
	AMKB_RX,
	PIC_AMKB_RX,
	IDE_RDY,
	IDE_INT,
	WP_CF_CARD,
	TRACK00,
	nWP,
	nDCHG,
	SD_DATA0,
	SD_DATA1,
	SD_DATA2,
	SD_CARD_DEDECT,
	MIDI_IN,
	nSCSI_DRQ,
	SD_WP,
	nRD_DATA,
	nSCSI_C_D,
	nSCSI_I_O,
	nSCSI_MSG,
	nDACK0,
	PIC_INT,
	nFB_OE,
	TOUT0,
	nMASTER,
	DVI_INT,
	nDACK1,
	nPCI_INTD,
	nPCI_INTC,
	nPCI_INTB,
	nPCI_INTA,
	E0_INT,
	nINDEX,
	HD_DD,
	MAIN_CLK,
	nRSTO_MCF,
	CLK24M576,
	LP_STR,
	nACSI_ACK,
	nACSI_RESET,
	nACSI_CS,
	ACSI_DIR,
	ACSI_A1,
	nSCSI_ACK,
	nSCSI_ATN,
	SCSI_DIR,
	MIDI_OLR,
	MIDI_TLR,
	TxD,
	RTS,
	DTR,
	AMKB_TX,
	IDE_RES,
	nIDE_CS0,
	nIDE_CS1,
	nIDE_WR,
	nIDE_RD,
	nCF_CS0,
	nCF_CS1,
	nROM3,
	nROM4,
	nRP_UDS,
	nRP_LDS,
	nSDSEL,
	nWR_GATE,
	nWR,
	YM_QA,
	YM_QB,
	YM_QC,
	SD_CLK,
	DSA_D,
	nVWE,
	nVCAS,
	nVRAS,
	nVCS,
	nPD_VGA,
	CLK25M,
	TIN0,
	nSRCS,
	nSRBLE,
	nSRBHE,
	nSRWE,
	nDREQ1,
	LED_FPGA_OK,
	nSROE,
	VCKE,
	nFB_TA,
	nDDR_CLK,
	DDR_CLK,
	VSYNC_PAD,
	HSYNC_PAD,
	nBLANK_PAD,
	PIXEL_CLK_PAD,
	nSYNC,
	nMOT_ON,
	nSTEP_DIR,
	nSTEP,
	CLKUSB,
	LPDIR,
	SCSI_PAR,
	nSCSI_RST,
	nSCSI_SEL,
	nSCSI_BUSY,
	SD_CD_DATA3,
	SD_CMD_D1,
	ACSI_D,
	BA,
	FB_AD,
	IO,
	LP_D,
	nIRQ,
	SCSI_D,
	SRD,
	VA,
	VB,
	VD,
	VDM,
	VDQS,
	VG,
	VR
);


input	FB_ALE;
input	nFB_WR;
input	CLK33M;
input	nFB_CS1;
input	nFB_CS2;
input	nFB_CS3;
input	FB_SIZE0;
input	FB_SIZE1;
input	nFB_BURST;
input	LP_BUSY;
input	nACSI_DRQ;
input	nACSI_INT;
input	RxD;
input	CTS;
input	RI;
input	DCD;
input	AMKB_RX;
input	PIC_AMKB_RX;
input	IDE_RDY;
input	IDE_INT;
input	WP_CF_CARD;
input	TRACK00;
input	nWP;
input	nDCHG;
input	SD_DATA0;
input	SD_DATA1;
input	SD_DATA2;
input	SD_CARD_DEDECT;
input	MIDI_IN;
input	nSCSI_DRQ;
input	SD_WP;
input	nRD_DATA;
input	nSCSI_C_D;
input	nSCSI_I_O;
input	nSCSI_MSG;
input	nDACK0;
input	PIC_INT;
input	nFB_OE;
input	TOUT0;
input	nMASTER;
input	DVI_INT;
input	nDACK1;
input	nPCI_INTD;
input	nPCI_INTC;
input	nPCI_INTB;
input	nPCI_INTA;
input	E0_INT;
input	nINDEX;
input	HD_DD;
input	MAIN_CLK;
input	nRSTO_MCF;
output	CLK24M576;
output	LP_STR;
output	nACSI_ACK;
output	nACSI_RESET;
output	nACSI_CS;
output	ACSI_DIR;
output	ACSI_A1;
output	nSCSI_ACK;
output	nSCSI_ATN;
output	SCSI_DIR;
output	MIDI_OLR;
output	MIDI_TLR;
output	TxD;
output	RTS;
output	DTR;
output	AMKB_TX;
output	IDE_RES;
output	nIDE_CS0;
output	nIDE_CS1;
output	nIDE_WR;
output	nIDE_RD;
output	nCF_CS0;
output	nCF_CS1;
output	nROM3;
output	nROM4;
output	nRP_UDS;
output	nRP_LDS;
output	nSDSEL;
output	nWR_GATE;
output	nWR;
output	YM_QA;
output	YM_QB;
output	YM_QC;
output	SD_CLK;
output	DSA_D;
output	nVWE;
output	nVCAS;
output	nVRAS;
output	nVCS;
output	nPD_VGA;
output	CLK25M;
output	TIN0;
output	nSRCS;
output	nSRBLE;
output	nSRBHE;
output	nSRWE;
output	nDREQ1;
output	LED_FPGA_OK;
output	nSROE;
output	VCKE;
output	nFB_TA;
output	nDDR_CLK;
output	DDR_CLK;
output	VSYNC_PAD;
output	HSYNC_PAD;
output	nBLANK_PAD;
output	PIXEL_CLK_PAD;
output	nSYNC;
output	nMOT_ON;
output	nSTEP_DIR;
output	nSTEP;
output	CLKUSB;
output	LPDIR;
inout	SCSI_PAR;
inout	nSCSI_RST;
inout	nSCSI_SEL;
inout	nSCSI_BUSY;
inout	SD_CD_DATA3;
inout	SD_CMD_D1;
inout	[7:0] ACSI_D;
output	[1:0] BA;
inout	[31:0] FB_AD;
inout	[17:0] IO;
inout	[7:0] LP_D;
output	[7:2] nIRQ;
inout	[7:0] SCSI_D;
inout	[15:0] SRD;
output	[12:0] VA;
output	[7:0] VB;
inout	[31:0] VD;
output	[3:0] VDM;
inout	[3:0] VDQS;
output	[7:0] VG;
output	[7:0] VR;

wire	[31:0] ACP_CONF;
wire	CLK25M_ALTERA_SYNTHESIZED;
wire	CLK2M;
wire	CLK2M4576;
wire	CLK48M;
wire	CLK500k;
wire	CLK_VIDEO;
wire	DDR_SYNC_66M;
wire	[3:0] DDRCLK;
wire	DMA_DRQ;
wire	DSP_INT;
wire	DSP_TA;
wire	FALCON_IO_TA;

//GE wire	[31:0] FB_ADR;
reg 	[31:0] FB_ADR;

wire	FDC_CLK;
wire	HSYNC;
wire	INT_HANDLER_TA;
wire	LP_DIR;
wire	MOT_ON;
wire	nBLANK;
wire	nDREQ0;
wire	nMFP_INT;
wire	nRSTO;
wire	PIXEL_CLK;
wire	SD_CDM_D1;
wire	STEP;
wire	STEP_DIR;
wire	[17:0] TIMEBASE;
wire	VIDEO_RECONFIG;
wire	Video_TA;
wire	VR_BUSY;
wire	[8:0] VR_D;
wire	VR_RD;
wire	VR_WR;
wire	VSYNC;
wire	WR_DATA;
wire	WR_GATE;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;

assign	nDREQ1 = nDACK1;
assign	SYNTHESIZED_WIRE_9 = 0;
assign	SYNTHESIZED_WIRE_10 = 1;

wire w_MAIN_CLK;
assign w_MAIN_CLK = CLK33M;

video	b2v_Fredi_Aschwanden(
	.MAIN_CLK(w_MAIN_CLK),
	.nFB_CS1(nFB_CS1),
	.nFB_CS2(nFB_CS2),
	.nFB_CS3(nFB_CS3),
	.nFB_WR(nFB_WR),
	.FB_SIZE0(FB_SIZE0),
	.FB_SIZE1(FB_SIZE1),
	.nRSTO(nRSTO),
	.nFB_OE(nFB_OE),
	.FB_ALE(FB_ALE),
	.DDR_SYNC_66M(DDR_SYNC_66M),
	.CLK33M(CLK33M),
	.CLK25M(CLK25M_ALTERA_SYNTHESIZED),
	.CLK_VIDEO(CLK_VIDEO),
	.VR_BUSY(VR_BUSY),
	.DDRCLK(DDRCLK),
	.FB_AD(FB_AD),
	.FB_ADR(FB_ADR),
	.VD(VD),
	.VDQS(VDQS),
	.VR_D(VR_D),
	.VR_RD(VR_RD),
	.nBLANK(nBLANK),
	.nVWE(nVWE),
	.nVCAS(nVCAS),
	.nVRAS(nVRAS),
	.nVCS(nVCS),
	.nPD_VGA(nPD_VGA),
	.VCKE(VCKE),
	.VSYNC(VSYNC),
	.HSYNC(HSYNC),
	.nSYNC(nSYNC),
	.VIDEO_TA(Video_TA),
	.PIXEL_CLK(PIXEL_CLK),
	.VIDEO_RECONFIG(VIDEO_RECONFIG),
	.VR_WR(VR_WR),
	.BA(BA),
	
	.VA(VA),
	.VB(VB),
	
	.VDM(VDM),
	
	.VG(VG),
	.VR(VR));


altpll1	b2v_inst(
	.inclk0(CLK33M),
	.c0(CLK500k),
	.c1(CLK2M4576),
	.c2(CLK24M576),
	.locked(SYNTHESIZED_WIRE_5));


/*lpm_ff0	b2v_inst1(
	.clock(DDR_SYNC_66M),
	.enable(FB_ALE),
	.data(FB_AD),
	.q(FB_ADR));*/
always @(posedge DDR_SYNC_66M)
begin
	if (FB_ALE)
		FB_ADR <= FB_AD;
end





altpll2	b2v_inst12(
	.inclk0(w_MAIN_CLK),
	.c0(DDRCLK[0]),
	.c1(DDRCLK[1]),
	.c2(DDRCLK[2]),
	.c3(DDRCLK[3]),
	.c4(DDR_SYNC_66M));


altpll3	b2v_inst13(
	.inclk0(CLK33M),
	.c0(CLK2M),
	.c1(FDC_CLK),
	.c2(CLK25M_ALTERA_SYNTHESIZED),
	.c3(CLK48M));

assign	nMOT_ON =  ~MOT_ON;

assign	nSTEP_DIR =  ~STEP_DIR;

assign	nSTEP =  ~STEP;

assign	nWR =  ~WR_DATA;


lpm_counter0	b2v_inst18(
	.clock(CLK500k),
	.q(TIMEBASE));

assign	nWR_GATE =  ~WR_GATE;

assign	nFB_TA = ~(Video_TA | INT_HANDLER_TA | DSP_TA | FALCON_IO_TA);


altpll4	b2v_inst22(
	.inclk0(CLK48M),
	.areset(SYNTHESIZED_WIRE_0),
	.scanclk(SYNTHESIZED_WIRE_1),
	.scandata(SYNTHESIZED_WIRE_2),
	.scanclkena(SYNTHESIZED_WIRE_3),
	.configupdate(SYNTHESIZED_WIRE_4),
	.c0(CLK_VIDEO),
	.scandataout(SYNTHESIZED_WIRE_6),
	.scandone(SYNTHESIZED_WIRE_7)
	);

assign	SYNTHESIZED_WIRE_8 =  ~nRSTO;

assign	nRSTO = SYNTHESIZED_WIRE_5 & nRSTO_MCF;

assign	LED_FPGA_OK = TIMEBASE[17];


assign	nDDR_CLK =  ~DDRCLK[0];


altddio_out3	b2v_inst5(
	.datain_h(VSYNC),
	.datain_l(VSYNC),
	.outclock(PIXEL_CLK),
	.dataout(VSYNC_PAD));


altddio_out3	b2v_inst6(
	.datain_h(HSYNC),
	.datain_l(HSYNC),
	.outclock(PIXEL_CLK),
	.dataout(HSYNC_PAD));


altpll_reconfig1	b2v_inst7(
	.reconfig(VIDEO_RECONFIG),
	.read_param(VR_RD),
	.write_param(VR_WR),
	.pll_scandataout(SYNTHESIZED_WIRE_6),
	.pll_scandone(SYNTHESIZED_WIRE_7),
	.clock(w_MAIN_CLK),
	.reset(SYNTHESIZED_WIRE_8),
	
	.counter_param(FB_ADR[8:6]),
	.counter_type(FB_ADR[5:2]),
	.data_in(FB_AD[24:16]),
	.busy(VR_BUSY),
	.pll_scandata(SYNTHESIZED_WIRE_2),
	.pll_scanclk(SYNTHESIZED_WIRE_1),
	.pll_scanclkena(SYNTHESIZED_WIRE_3),
	.pll_configupdate(SYNTHESIZED_WIRE_4),
	.pll_areset(SYNTHESIZED_WIRE_0),
	.data_out(VR_D));


altddio_out3	b2v_inst8(
	.datain_h(nBLANK),
	.datain_l(nBLANK),
	.outclock(PIXEL_CLK),
	.dataout(nBLANK_PAD));


altddio_out3	b2v_inst9(
	.datain_h(SYNTHESIZED_WIRE_9),
	.datain_l(SYNTHESIZED_WIRE_10),
	.outclock(PIXEL_CLK),
	.dataout(PIXEL_CLK_PAD));


DSP	b2v_Mathias_Alles(
	.CLK33M(CLK33M),
	.MAIN_CLK(w_MAIN_CLK),
	.nFB_OE(nFB_OE),
	.nFB_WR(nFB_WR),
	.nFB_CS1(nFB_CS1),
	.nFB_CS2(nFB_CS2),
	.FB_SIZE0(FB_SIZE0),
	.FB_SIZE1(FB_SIZE1),
	.nFB_BURST(nFB_BURST),
	.nRSTO(nRSTO),
	.nFB_CS3(nFB_CS3),
	.FB_AD(FB_AD),
	.FB_ADR(FB_ADR),
	.IO(IO),
	.SRD(SRD),
	.nSRCS(nSRCS),
	.nSRBLE(nSRBLE),
	.nSRBHE(nSRBHE),
	.nSRWE(nSRWE),
	.nSROE(nSROE),
	.DSP_INT(DSP_INT),
	.DSP_TA(DSP_TA)
	
	
	);


interrupt_handler	b2v_nobody(
	.MAIN_CLK(w_MAIN_CLK),
	.nFB_WR(nFB_WR),
	.nFB_CS1(nFB_CS1),
	.nFB_CS2(nFB_CS2),
	.FB_SIZE0(FB_SIZE0),
	.FB_SIZE1(FB_SIZE1),
	.PIC_INT(PIC_INT),
	.E0_INT(E0_INT),
	.DVI_INT(DVI_INT),
	.nPCI_INTA(nPCI_INTA),
	.nPCI_INTB(nPCI_INTB),
	.nPCI_INTC(nPCI_INTC),
	.nPCI_INTD(nPCI_INTD),
	.nMFP_INT(nMFP_INT),
	.nFB_OE(nFB_OE),
	.DSP_INT(DSP_INT),
	.VSYNC(VSYNC),
	.HSYNC(HSYNC),
	.DMA_DRQ(DMA_DRQ),
	.FB_AD(FB_AD),
	.FB_ADR(FB_ADR),
	.INT_HANDLER_TA(INT_HANDLER_TA),
	.TIN0(TIN0),
	.ACP_CONF(ACP_CONF),
	.nRST(nRSTO), //GE
	.nIRQ(nIRQ));


FalconIO_SDCard_IDE_CF	b2v_Wolfgang_Foerster_and_Fredi_Aschwanden(
	.CLK33M(CLK33M),
	.MAIN_CLK(w_MAIN_CLK),
	.CLK2M(CLK2M),
	.CLK500k(CLK500k),
	.nFB_CS1(nFB_CS1),
	.FB_SIZE0(FB_SIZE0),
	.FB_SIZE1(FB_SIZE1),
	.nFB_BURST(nFB_BURST),
	.LP_BUSY(LP_BUSY),
	.nACSI_DRQ(nACSI_DRQ),
	.nACSI_INT(nACSI_INT),
	.nSCSI_DRQ(nSCSI_DRQ),
	.nSCSI_MSG(nSCSI_MSG),
	.MIDI_IN(MIDI_IN),
	.RxD(RxD),
	.CTS(CTS),
	.RI(RI),
	.DCD(DCD),
	.AMKB_RX(AMKB_RX),
	.PIC_AMKB_RX(PIC_AMKB_RX),
	.IDE_RDY(IDE_RDY),
	.IDE_INT(IDE_INT),
	
	.nINDEX(nINDEX),
	.TRACK00(TRACK00),
	.nRD_DATA(nRD_DATA),
	.nDCHG(nDCHG),
	.SD_DATA0(SD_DATA0),
	.SD_DATA1(SD_DATA1),
	.SD_DATA2(SD_DATA2),
	.SD_CARD_DEDECT(SD_CARD_DEDECT),
	.SD_WP(SD_WP),
	.nDACK0(nDACK0),
	.nFB_WR(nFB_WR),
	.WP_CF_CARD(WP_CF_CARD),
	.nWP(nWP),
	.nFB_CS2(nFB_CS2),
	.nRSTO(nRSTO),
	.nSCSI_C_D(nSCSI_C_D),
	.nSCSI_I_O(nSCSI_I_O),
	.CLK2M4576(CLK2M4576),
	.nFB_OE(nFB_OE),
	.VSYNC(VSYNC),
	.HSYNC(HSYNC),
	.DSP_INT(DSP_INT),
	.nBLANK(nBLANK),
	.FDC_CLK(FDC_CLK),
	.FB_ALE(FB_ALE),
	.HD_DD(HD_DD),
	.SCSI_PAR(SCSI_PAR),
	.nSCSI_SEL(nSCSI_SEL),
	.nSCSI_BUSY(nSCSI_BUSY),
	.nSCSI_RST(nSCSI_RST),
	.SD_CD_DATA3(SD_CD_DATA3),
	.SD_CDM_D1(SD_CDM_D1),
	.ACP_CONF(ACP_CONF[31:24]),
	.ACSI_D(ACSI_D),
	.FB_AD(FB_AD),
	.FB_ADR(FB_ADR),
	.LP_D(LP_D),
	.SCSI_D(SCSI_D),
	.nIDE_CS1(nIDE_CS1),
	.nIDE_CS0(nIDE_CS0),
	.LP_STR(LP_STR),
	.LP_DIR(LP_DIR),
	.nACSI_ACK(nACSI_ACK),
	.nACSI_RESET(nACSI_RESET),
	.nACSI_CS(nACSI_CS),
	.ACSI_DIR(ACSI_DIR),
	.ACSI_A1(ACSI_A1),
	.nSCSI_ACK(nSCSI_ACK),
	.nSCSI_ATN(nSCSI_ATN),
	.SCSI_DIR(SCSI_DIR),
	.SD_CLK(SD_CLK),
	.YM_QA(YM_QA),
	.YM_QC(YM_QC),
	.YM_QB(YM_QB),
	.nSDSEL(nSDSEL),
	.STEP(STEP),
	.MOT_ON(MOT_ON),
	.nRP_LDS(nRP_LDS),
	.nRP_UDS(nRP_UDS),
	.nROM4(nROM4),
	.nROM3(nROM3),
	.nCF_CS1(nCF_CS1),
	.nCF_CS0(nCF_CS0),
	.nIDE_RD(nIDE_RD),
	.nIDE_WR(nIDE_WR),
	.AMKB_TX(AMKB_TX),
	.IDE_RES(IDE_RES),
	.DTR(DTR),
	.RTS(RTS),
	.TxD(TxD),
	.MIDI_OLR(MIDI_OLR),
	.MIDI_TLR(MIDI_TLR),
	
	.DSA_D(DSA_D),
	.nMFP_INT(nMFP_INT),
	.FALCON_IO_TA(FALCON_IO_TA),
	.STEP_DIR(STEP_DIR),
	.WR_DATA(WR_DATA),
	.WR_GATE(WR_GATE),
	.DMA_DRQ(DMA_DRQ)
	
	
	
	
	
	
	
	
	
	);

assign	SD_CMD_D1 = SD_CDM_D1;
assign	CLK25M = CLK25M_ALTERA_SYNTHESIZED;
assign	DDR_CLK = DDRCLK[0];
assign	CLKUSB = CLK48M;
assign	LPDIR = LP_DIR;

endmodule
