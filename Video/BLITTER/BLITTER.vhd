-- WARNING: Do NOT edit the input and output ports in this file in a text
-- editor if you plan to continue editing the block that represents it in
-- the Block Editor! File corruption is VERY likely to occur.

-- Copyright (C) 1991-2008 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.


-- Generated by Quartus II Version 8.1 (Build Build 163 10/28/2008)
-- Created on Fri Oct 16 15:40:59 2009

LIBRARY ieee;
USE ieee.std_logic_1164.all;


--  Entity Declaration

ENTITY BLITTER IS
	-- {{ALTERA_IO_BEGIN}} DO NOT REMOVE THIS LINE!
	PORT
	(
		nRSTO : IN STD_LOGIC;
		MAIN_CLK : IN STD_LOGIC;
		FB_ALE : IN STD_LOGIC;
		nFB_WR : IN STD_LOGIC;
		nFB_OE : IN STD_LOGIC;
		FB_SIZE0 : IN STD_LOGIC;
		FB_SIZE1 : IN STD_LOGIC;
		VIDEO_RAM_CTR : IN STD_LOGIC_VECTOR(15 downto 0);
		BLITTER_ON : IN STD_LOGIC;
		FB_ADR : IN STD_LOGIC_VECTOR(31 downto 0);
		nFB_CS1 : IN STD_LOGIC;
		nFB_CS2 : IN STD_LOGIC;
		nFB_CS3 : IN STD_LOGIC;
		DDRCLK0 : IN STD_LOGIC;
		BLITTER_DIN : IN STD_LOGIC_VECTOR(127 downto 0);
		BLITTER_DACK : IN STD_LOGIC_VECTOR(4 downto 0);
		BLITTER_RUN : OUT STD_LOGIC;
		BLITTER_DOUT : OUT STD_LOGIC_VECTOR(127 downto 0);
		BLITTER_ADR : OUT STD_LOGIC_VECTOR(31 downto 0);
		BLITTER_SIG : OUT STD_LOGIC;
		BLITTER_WR : OUT STD_LOGIC;
		BLITTER_TA : OUT STD_LOGIC;
		FB_AD : INOUT STD_LOGIC_VECTOR(31 downto 0)
	);
	-- {{ALTERA_IO_END}} DO NOT REMOVE THIS LINE!
	
END BLITTER;


--  Architecture Body

ARCHITECTURE BLITTER_architecture OF BLITTER IS

	
BEGIN
	BLITTER_RUN <= '0';
	BLITTER_DOUT <= x"FEDCBA9876543210F0F0F0F0F0F0F0F0";
	BLITTER_ADR <=  x"76543210";
	BLITTER_SIG <= '0';
	BLITTER_WR <= '0';
	BLITTER_TA <= '0';

END BLITTER_architecture;
