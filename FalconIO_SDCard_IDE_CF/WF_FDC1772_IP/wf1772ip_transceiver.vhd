----------------------------------------------------------------------
----                                                              ----
---- WD1772 compatible floppy disk controller IP Core.            ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- Floppy disk controller with all features of the Western      ----
---- Digital WD1772-02 controller.                                ----
----                                                              ----
---- The transceiver unit contains on the one hand the receiver   ----
---- part which strips off the clock signal from the data stream  ----
---- and on the other hand the transmitter unit which provides in ----
---- the different modes (FM and MFM) all functions which are     ----
---- necessary to send data, CRC bytes, 'FF', '00' or the address ----
---- marks.                                                       ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2006 - 2008 Wolfgang Foerster                  ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/lgpl.html                   ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 
-- Revision 2006A  2006/06/03 WF
--   Initial Release.
-- Revision 2K6B  2006/11/05 WF
--   Modified Source to compile with the Xilinx ISE.
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
-- Revision 2K9A  2009/06/20 WF
--   MFM_In and MASK_SHFT have now synchronous reset to meet preset requirement.
-- 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF1772IP_TRANSCEIVER is
	port(
		-- System control
		CLK		: in bit; -- must be 16MHz
		RESETn	: in bit;

		-- Data and Control:
		HDTYPE			: in bit; -- Floppy type HD or DD.
		DDEn			: in bit; -- Double density select (FM or MFM).
		ID_AM			: in bit; -- ID addressmark strobe.
		DATA_AM			: in Bit; -- Data addressmark strobe.
		DDATA_AM		: in Bit; -- Deleted data addressmark strobe.
		SHFT_LOAD_SD	: in bit; -- Indication for shift register load time.
		DR				: in bit_vector(7 downto 0); -- Content of the data register.

		-- Data strobes:
		PLL_DSTRB	: in bit; -- Clock strobe for RD serial data input.
		DATA_STRB 	: buffer bit;
		
		-- Data strobe and data for the CRC during write operation:
		WDATA 		: buffer bit;

		-- Encoder (logic to disk):
		PRECOMP_EN	: in bit; -- control signal for MFM write precompensation.
		AM_TYPE		: in bit; -- Write deleted address mark in MFM mode when 0.
		AM_2_DISK	: in bit;
		DSR_2_DISK	: in bit;
		FF_2_DISK	: in bit;
		CRC_2_DISK	: in bit;
		SR_SDOUT	: in std_logic; -- encoder's data input from the shift register (serial).
		CRC_SDOUT	: in bit; -- encoder's data input from the CRC unit (serial).
		WRn			: out bit; -- write output for the MFM drive containing clock and data.

		-- Decoder (disk to logic):
		PLL_D		: in bit; -- Serial data input.
		SD_R		: out bit -- Serial (decoded) data output.
	);
end WF1772IP_TRANSCEIVER;

architecture BEHAVIOR of WF1772IP_TRANSCEIVER is
type MFM_STATES is (A_00, B_01, C_10);
type PRECOMP_VALUES is (EARLY, NOMINAL, LATE);
type DEC_STATES is (CLK_PHASE, DATA_PHASE);

signal MFM_STATE		: MFM_STATES;
signal NEXT_MFM_STATE	: MFM_STATES;
signal PRECOMP			: PRECOMP_VALUES;
signal DEC_STATE		: DEC_STATES;
signal NEXT_DEC_STATE	: DEC_STATES;

signal FM_In			: bit;

signal CLKMASK 			: bit; -- Control for suppression of FM clock transitions.

signal MFM_10_STRB		: bit;
signal MFM_01_STRB		: bit;

signal WR_CNT 			: std_logic_vector(3 downto 0);
signal MFM_In			: bit;

signal AM_SHFT			: bit_vector(31 downto 0);

begin
	-- #######################  encoder stuff  ###########################
	ADRMARK: process(RESETn, CLK)
	-- This process provides the address mark data for both FM and MFM in
	-- write to disk mode. In FM only one byte is written where in MFM
	-- 3 sync bytes x"A1" and one data address mark is written. 
	-- In this process only the data address mark is provided. The only way
	-- writing the ID address mark is the write track command.
	begin
		if RESETn = '0' then
			AM_SHFT <= (others => '0');
		elsif CLK = '1' and CLK' event then
			if AM_2_DISK = '1' and DATA_STRB = '1' then
				AM_SHFT <= AM_SHFT (30 downto 0) & '0'; -- Shift out.
			elsif AM_2_DISK = '0' and DDEn = '1'  and AM_TYPE = '0' then -- FM mode.
				AM_SHFT <= x"F8000000"; -- Load deleted FM address mark.
			elsif AM_2_DISK = '0' and DDEn = '1'  and AM_TYPE = '1' then -- FM mode.
				AM_SHFT <= x"FB000000"; -- Load normal FM address mark.
			elsif AM_2_DISK = '0' and DDEn = '0' and AM_TYPE = '0' then -- MFM mode deleted data mark.
				AM_SHFT <= x"A1A1A1F8"; -- Load MFM syncs and address mark.
			elsif AM_2_DISK = '0' and DDEn = '0' and AM_TYPE = '1' then -- Default: MFM mode normal data mark.
				AM_SHFT <= x"A1A1A1FB"; -- Load MFM syncs and address mark.
			end if;
		end if;
	end process ADRMARK;

	-- Input multiplexer:
	WDATA <= 	AM_SHFT(31) when AM_2_DISK = '1' else -- Address mark data data.
				To_Bit(SR_SDOUT) when DSR_2_DISK = '1' else -- Shift register data.
				CRC_SDOUT when CRC_2_DISK = '1' else -- CRC data.
				'1' when FF_2_DISK = '1' else '0'; -- Write zeros is default.

	-- Output multiplexer:
	WRn <= 	'0' when FM_In = '0' and DDEn = '1' else -- FM portion.
			'0' when MFM_In = '0' and DDEn = '0' else '1'; -- MFM portion and default.

	CLK_MASK: process(CLK)
	-- This part of software controls the suppression of the clock pulses
	-- during transmission of several FM special characters. During writing
	-- 'normal' data to the disk, only 8 mask bits of the shift register are
	-- used. During writing MFM sync and address mark bits, the register is
	-- used with 32 mask bits.
	variable MASK_SHFT	: bit_vector(23 downto 0);
	variable LOCK		: boolean;
	begin
		if CLK = '1' and CLK' event then
			if RESETn = '0' then
				MASK_SHFT := (others => '1');
				LOCK := false;
			-- Load the mask shift register just in time when the shift register is
			-- loaded with valid data from the data register.
			elsif SHFT_LOAD_SD = '1' and DDEn = '1' then -- FM mode.
				case DR is
					when x"F8" | x"F9" | x"FA" | x"FB" | x"FE" => MASK_SHFT := x"C7FFFF";
					when x"FC" => MASK_SHFT := x"D7FFFF";
					when x"F5" | x"F6" => MASK_SHFT := (others => '0'); -- Not allowed.
					when others => MASK_SHFT := x"FFFFFF"; -- Normal data.
				end case;
			elsif SHFT_LOAD_SD = '1' and DDEn = '0' then -- MFM mode.
				case DR is
					when x"F5" => MASK_SHFT := x"FBFFFF"; -- Suppress clock pulse between bits 4 and 5.
					when x"F6" => MASK_SHFT := x"F7FFFF"; -- Suppress clock pulse between bits 3 and 4.
					when others => MASK_SHFT := x"FFFFFF"; -- Normal data.
				end case;
			elsif AM_2_DISK = '1' and DDEn = '1' and LOCK = false then -- FM mode.
				MASK_SHFT := x"C7FFFF"; -- Load just once per AM_2_DISK rising edge.
				LOCK := true;
			elsif AM_2_DISK = '1' and DDEn = '0' and LOCK = false then -- MFM mode.
				MASK_SHFT := x"FBFBFB"; -- Three syncs with suppressed clock pulse then transparent mask.
				LOCK := true;
			elsif DATA_STRB = '1' then  -- shift as long as transmission is active
				-- The Shift register is shifted left. After shifting the clockmasks out it is
				-- transparent due to the '1's filled up from the left.
				MASK_SHFT := MASK_SHFT(22 downto 0) & '1'; -- Shift left.
			elsif AM_2_DISK = '0' then
				LOCK := false; -- Release the lock after address mark has been written.
			end if;
		end if;
		CLKMASK <= MASK_SHFT(23);
	end process CLK_MASK;

	FM_ENCODER: process (RESETn, DATA_STRB, CLK)
	-- For DD type floppies the data rate is 125kBps. Therefore there are 128 16-MHz clocks cycles
	-- per FM bit. 
	-- For HD type floppies the data rate is 250kBps. Therefore there are 64 16-MHz clocks cycles
	-- per FM bit. 
	-- The FM write pulse width is 1.375us for DD and 0.750us HD type floppies.
	-- This process provides the FM encoded signal. The first pulse is in any case the clock
	-- pulse and the second pulse is due to data. The FM encoding is very simple and therefore
	-- self explaining.
	variable CNT : std_logic_vector(7 downto 0);
	begin
		if RESETn = '0' then
			FM_In <= '1';
			CNT := x"00";
		elsif CLK = '1' and CLK' event then
			-- In case of HD type floppies the counter reaches a value of b"0100000"
			-- In case of DD type floppies the counter reaches a value of b"1000000"
			if DATA_STRB = '1' then
				CNT := x"00";
			else
				CNT := CNT + '1';
			end if;
			-- The flux reversal pulses are centered between the DATA_STRB pulses.
			-- In detail: the clock pulse appears in the middle of the first half
			-- of the DATA_STRB period and the data pulse appears in the middle of
			-- the second half.
			case HDTYPE is
				when '0' => -- DD type floppies:
					if CNT > "00010101" and CNT <= "00101011" then
						FM_In <= not CLKMASK; -- FM clock.
					elsif CNT > "01010101" and CNT <= "01101011" then
						FM_In <= not WDATA; -- FM data.
					else
						FM_In <= '1';
					end if;
				when '1' => -- HD type floppies:
					if CNT > "00001010" and CNT <= "00010110" then
						FM_In <= not CLKMASK; -- FM clock.
					elsif CNT > "00101010" and CNT <= "00110110" then
						FM_In <= not WDATA; -- FM data.
					else
						FM_In <= '1';
					end if;
			end case;
		end if;
	end process FM_ENCODER;
	
	MFM_ENCODE_REG: process(RESETn, CLK)
	-- This process is the first portion of the more complicated MFM encoder. It can be interpreted
	-- as a Moore machine. This part is the current state register.
	begin
		if RESETn = '0' then
			MFM_STATE <= A_00;
		elsif CLK = '1' and CLK' event then
			MFM_STATE <= NEXT_MFM_STATE;
		end if;
	end process MFM_ENCODE_REG;

	MFM_ENCODE_LOGIC: process(MFM_STATE, WDATA, DATA_STRB)
	-- Rules for Encoding:
		-- transitions are never located at the mid point of a 'zero'.
		-- transistions are always located at the mid point of a '1'.
		-- no transitions at the borders of a '1'.
		-- transitions appear between two adjacent 'zeros'.
	-- states are as follows:
	-- A_00: idle state, no transition.
	-- B_01: transistion between the MFM clock edges.
	-- C_10: transition on the leading MFM clock edges.
	-- The timing of the MFM output is done in the process MFM_WR_OUT.
	begin
		case MFM_STATE is
			when A_00 =>
				if WDATA = '0' and DATA_STRB = '1' then
					NEXT_MFM_STATE <= C_10;
				elsif  WDATA = '1' and DATA_STRB = '1' then
					NEXT_MFM_STATE <= B_01;
				else
					NEXT_MFM_STATE <= A_00; -- Stay, if there is no strobe.
				end if;
			when C_10 =>
				if WDATA = '0' and DATA_STRB = '1' then
					NEXT_MFM_STATE <= C_10;
				elsif  WDATA = '1' and DATA_STRB = '1' then
					NEXT_MFM_STATE <= B_01;
				else
					NEXT_MFM_STATE <= C_10; -- Stay, if there is no strobe.
				end if;
			when B_01 =>
				if WDATA = '0' and DATA_STRB = '1' then
					NEXT_MFM_STATE <= A_00;
				elsif  WDATA = '1' and DATA_STRB = '1' then
					NEXT_MFM_STATE <= B_01;
				else
					NEXT_MFM_STATE <= B_01; -- Stay, if there is no strobe.
				end if;
		end case;
	end process MFM_ENCODE_LOGIC;

	MFM_PRECOMPENSATION: process(RESETn, CLK)
	-- The write pattern is adjusted in the MFM write timing process as follows:
	-- after DATA_STRB (the duty cycle of this strobe is exactly one CLK) the
	-- incoming data is bufferd in WRITEPATTERN. After the following DATA_STRB
	-- the WDATA is shifted through WRITEPATTERN. After further DATA_STRBs the
	-- WRITEPATTERN consists of previous, current and next WDATA like this:
	-- WRITEPATTERN(3) is the second previous WDATA.
	-- WRITEPATTERN(2) is the previous WDATA.
	-- WRITEPATTERN(1) is the current WDATA to be sent.
	-- WRITEPATTERN(0) is the next WDATA to be sent.
	variable WRITEPATTERN : bit_vector(3 downto 0);
	begin
		if RESETn = '0' then
			PRECOMP <= NOMINAL;
			WRITEPATTERN := "0000";
		elsif CLK = '1' and CLK' event then
			if DATA_STRB = '1' then
				WRITEPATTERN := WRITEPATTERN(2 downto 0) & WDATA; -- shift left
			end if;
			if PRECOMP_EN = '0' then
				PRECOMP <= NOMINAL; -- no precompensation
			else
				case WRITEPATTERN is
					when "1110" | "0110" => PRECOMP <= EARLY;
					when "1011" | "0011" => PRECOMP <= LATE;
					when "0001" => PRECOMP <= EARLY;
					when "1000" => PRECOMP <= LATE;
					when others => PRECOMP <= NOMINAL;
				end case;
			end if;
		end if;
	end process MFM_PRECOMPENSATION;

	MFM_STROBES: process (RESETn, DATA_STRB, CLK)
	-- For the MFM frequency is 250 kBps for DD type floppies, there are 64 
	-- 16 MHz clock cycles per MFM bit and for HD type floppies, which have
	-- 500 kBps there are 32 16MHz clock pulses for one MFM bit.
	-- The MFM state machine (Moore) switches on the DATA_STRB. 
	-- During one cycle there are the two further strobes MFM_10_STRB and 
	-- MFM_01_STRB which control the MFM output in the process MFM_WR_OUT.
	-- The strobes are centered in the middle of the first half and in the
	-- middle of the second half of the DATA_STRB cycle.
	variable CNT : std_logic_vector(5 downto 0);
	begin
		if RESETn = '0' then
			CNT := "000000";
		elsif CLK = '1' and CLK' event then
			if DATA_STRB = '1' then
				CNT := (others => '0');
			else
				CNT := CNT + '1';
			end if;
			if HDTYPE = '1' then
				case CNT is
					-- encoder timing for MFM and HD type floppies.
				when "000100" => MFM_10_STRB <= '1'; MFM_01_STRB <= '0'; -- Pulse centered in the first half.
				when "010100" => MFM_10_STRB <= '0'; MFM_01_STRB <= '1'; -- Pulse centered in the second half.
					when others =>  MFM_10_STRB <= '0'; MFM_01_STRB <= '0';
				end case;
			else
				case CNT is
					-- encoder timing for MFM and DD type floppies.
				when "001010" => MFM_10_STRB <= '1'; MFM_01_STRB <= '0'; -- Pulse centered in the first half.
				when "101000" => MFM_10_STRB <= '0'; MFM_01_STRB <= '1'; -- Pulse centered in the second half.
					when others =>  MFM_10_STRB <= '0'; MFM_01_STRB <= '0';
				end case;
			end if;
		end if;
	end process MFM_STROBES;

	-- MFM_WR_TIMING generates the timing for the write pulses which are 
	-- required by a MFM device like floppy disk drive. The pulse timing 
	-- meets the timing of the MFM data with pulse width of 700ns +/- 100ns 
	-- depending on write precompensation.
	-- The original WD1772 (CLK = 8MHz) data timing was as follows:
	-- The output is asserted as long as CNT is active; in detail
	-- this are 4,5; 5,5 or 6,5 CLK cycles depending on the write
	-- precompensation.
	-- The new design which works with a 16MHz clock requires the following
	-- timing: 9; 11 or 13 CLK cycles depending on the writeprecompensation
	-- for DD floppies and 5; 6 or 7 CLK cycles depending on the write
	-- precompensation for HD floppies.
	-- To meet the timing requirements of half clocks
	-- the WRn is controlled by the following three processes where the one
	-- syncs on the positive clock edge and the other on the negative.
	-- For more information on the WTn timing see the datasheet of the
	-- WD177x floppy disc controller.

	MFM_WR_TIMING: process(RESETn, CLK)
	variable CLKMASK_MFM	: bit;
	begin
		if RESETn = '0' then
			WR_CNT <= x"F";
		elsif CLK = '1' and CLK' event then
			if DATA_STRB = '1' then
				-- The CLKMASK_MFM is synchronised to DATA_STRB. This brings one strobe latency.
				-- The timing in connection with the data is correct because the MFM encoder state machine
				-- causes the data to be 1 DATA_STRB late too.
				CLKMASK_MFM := CLKMASK;
			end if;
			if MFM_STATE = C_10 and MFM_10_STRB = '1' and CLKMASK_MFM = '1' then
				WR_CNT <= x"0";
			elsif MFM_STATE =  B_01 and MFM_01_STRB = '1' then
				WR_CNT <= x"0";
			elsif WR_CNT < x"F" then
				WR_CNT <= WR_CNT + '1';
			end if;
		end if;
	end process MFM_WR_TIMING;

	MFM_WR_OUT: process
	begin
		wait until CLK = '1' and CLK' event;
		if RESETn = '0' then
			MFM_In <= '1';
		else
			case HDTYPE is
				when '1' => -- HD type.
					if PRECOMP = EARLY and WR_CNT > x"0" and WR_CNT <= x"9" then
						MFM_In <= '0'; -- 9,0 clock cycles for WRn --> early timing
					elsif PRECOMP = NOMINAL and WR_CNT > x"0" and WR_CNT <= x"8" then
						MFM_In <= '0'; -- 8,0 clock cycles for WRn --> nominal timing
					elsif PRECOMP = LATE and WR_CNT > x"0" and WR_CNT <= x"7" then
						MFM_In <= '0'; -- 7,0 clock cycles for WRn --> late timing
					else
						MFM_In <= '1';
					end if;
				when '0' => -- DD type.
					if PRECOMP = EARLY and WR_CNT > x"0" and WR_CNT <= x"D" then
						MFM_In <= '0'; -- 13,0 clock cycles for WRn --> early timing
					elsif PRECOMP = NOMINAL and WR_CNT > x"0" and WR_CNT <= x"B" then
						MFM_In <= '0'; -- 11,0 clock cycles for WRn --> nominal timing
					elsif PRECOMP = LATE and WR_CNT > x"0" and WR_CNT <= x"9" then
						MFM_In <= '0'; -- 9,0 clock cycles for WRn --> late timing
					else
						MFM_In <= '1';
					end if;
			end case;
		end if;
	end process MFM_WR_OUT;

	-- #######################  Decoder stuff  ###########################
	-- The decoding of the serial FM or MFM encoded data stream
	-- is done in the following two processes (Moore machine).
	-- The decoder works in principle like a simple toggle Flip-Flop.
	-- It is important to synchronise it in a way, that the clock
	-- pulses are separated from the data pulses. The principle
	-- works for both FM and MFM data due to the digital phase
	-- locked loop, which delivers the serial data and the clock
	-- strobe. In general this decoder can be understood as the
	-- data separator where the digital phase locked loop provides
	-- the FM or the MFM decoding. The data separation lives from
	-- the fact, that FM and also MFM encoded signals consist of a
	-- mixture of alternating data and clock pulses. 
	-- FM works as follows:
	-- every first pulse of the FM signal is a clock pulse and every
	-- second pulse is a logic '1' of the data. A missing second 
	-- pulse represents a logic '0' of the data.
	-- MFM works as follows:
	-- every first pulse of the MFM signal is a clock pulse. The coding
	-- principle causes clock pulses to be absent in some conditions.
	-- Every second pulse is a logic '1' of the data. A missing second 
	-- pulse represents a logic '0' of the data.
	-- So FM and MFM compared, the data is represented directly by the
	-- second pulses and the data separator has to look only for these.
	-- The missing MFM clock pulses do not cause a problem because the
	-- digital PLL used in conjunction with this data separator fills
	-- up the clock pulses and delivers a PLL_DSTRB containing aequidistant
	-- clock strobes and data strobes.

	DEC_REG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			DEC_STATE <= CLK_PHASE;
		elsif CLK = '1' and CLK' event then
			DEC_STATE <= NEXT_DEC_STATE;
		end if;
	end process DEC_REG;

	DEC_LOGIC: process(DEC_STATE, ID_AM, DATA_AM, DDATA_AM, PLL_DSTRB, PLL_D)
	begin
		case DEC_STATE is
			when CLK_PHASE =>
				if PLL_DSTRB = '1' then
					NEXT_DEC_STATE <= DATA_PHASE;
				else
					NEXT_DEC_STATE <= CLK_PHASE;
				end if;
				DATA_STRB <= '0'; -- Inactive during clock pulse time.
				SD_R <= '0'; -- Inactive during clock pulse time.
			when DATA_PHASE =>
				if ID_AM = '1' or DATA_AM = '1' or DDATA_AM = '1' then
					-- Here the state machine is synchronised
					-- to separate data and clock pulses correctly.
					NEXT_DEC_STATE <= CLK_PHASE;
				elsif PLL_DSTRB = '1' then
					NEXT_DEC_STATE <= CLK_PHASE;
				else
					NEXT_DEC_STATE <= DATA_PHASE;
				end if;
				-- During the data phase valid data appears at SD.
				-- The data is valid during DATA_STRB.
				DATA_STRB <= PLL_DSTRB;
				SD_R <= PLL_D;
		end case;
	end process DEC_LOGIC;
end architecture BEHAVIOR;
