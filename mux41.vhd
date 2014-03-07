-- Copyright (C) 1991-2009 Altera Corporation
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

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 9.1 Build 222 10/21/2009 SJ Full Version"
-- CREATED		"Sat Mar 01 09:16:22 2014"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY mux41 IS 
	PORT
	(
		S0 :  IN  STD_LOGIC;
		D2 :  IN  STD_LOGIC;
		INH :  IN  STD_LOGIC;
		D0 :  IN  STD_LOGIC;
		D1 :  IN  STD_LOGIC;
		D3 :  IN  STD_LOGIC;
		S1 :  IN  STD_LOGIC;
		Q :  OUT  STD_LOGIC
	);
END mux41;

ARCHITECTURE bdf_type OF mux41 IS 

SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC;


BEGIN 



SYNTHESIZED_WIRE_18 <= NOT(S0);



SYNTHESIZED_WIRE_21 <= NOT(SYNTHESIZED_WIRE_18);



SYNTHESIZED_WIRE_13 <= SYNTHESIZED_WIRE_19 AND SYNTHESIZED_WIRE_20 AND SYNTHESIZED_WIRE_18 AND D0;


SYNTHESIZED_WIRE_14 <= SYNTHESIZED_WIRE_19 AND SYNTHESIZED_WIRE_20 AND SYNTHESIZED_WIRE_21 AND D1;


SYNTHESIZED_WIRE_15 <= SYNTHESIZED_WIRE_19 AND SYNTHESIZED_WIRE_22 AND SYNTHESIZED_WIRE_18 AND D2;


SYNTHESIZED_WIRE_16 <= SYNTHESIZED_WIRE_19 AND SYNTHESIZED_WIRE_22 AND SYNTHESIZED_WIRE_21 AND D3;


Q <= SYNTHESIZED_WIRE_13 OR SYNTHESIZED_WIRE_14 OR SYNTHESIZED_WIRE_15 OR SYNTHESIZED_WIRE_16;


SYNTHESIZED_WIRE_19 <= NOT(INH);



SYNTHESIZED_WIRE_20 <= NOT(S1);



SYNTHESIZED_WIRE_22 <= NOT(SYNTHESIZED_WIRE_20);



END bdf_type;