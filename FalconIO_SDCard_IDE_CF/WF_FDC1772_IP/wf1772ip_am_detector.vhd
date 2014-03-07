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
---- Address mark detector file. This part detects the address    ----
---- mark in the incoming data stream in FM and also in MFM mode  ----
---- and provides therewith synchronisation information for the   ----
---- control state machine and for the data separator in the      ----
---- transceiver unit.                                            ----
----                                                              ----
------------------------------- Some theory -------------------------------------
---- Frequency modulation FM:                                                ----
---- The frequency modulation works as follows:                              ----
---- 1. every first pulse of the clock and data line is a clock.             ----
---- 2. every second pulse is a data.                                        ----
---- 3. a logic 1 is represented by two consecutive pulses (clock and data). ----
---- 4. a logic 0 is represented by one clock pulse and no data pulse.       ----
---- 5. Hence there are a maximum of two pulses per data bit.                ----
---- 6. one clock and one data pulse come together in one bit cell.          ----
---- 7. the duration of a bit cell in FM is 4 microseconds.                  ----
---- 8. an ID address mark is represented as data FE with clock C7.          ----
---- 9. a DATA address mark is represented as data FB with clock C7.         ----
---- Examples:                                                               ----
---- Binary data 1 1 0 0 1 0 1 1 is represented in FM as follows:            ----
----            1111101011101111                                             ----
---- the FE data           1 1 1 1 1 1 1 0 is represented as follows:        ----
----                      1111111111111110                                   ----
---- with C7 clock mask   1 1 0 0 0 1 1 1 which masks the clock pulses there ----
---- results:             1111010101111110 this is the ID address mark.      ----
---- the FB data           1 1 1 1 1 0 1 1 is represented as follows:        ----
----                      1111111111101111                                   ----
---- with C7 clock mask   1 1 0 0 0 1 1 1 which masks the clock pulses there ----
---- results:             1111010101101111 this is the DATA address mark.    ----
---- the F8 data           1 1 1 1 1 0 0 0 is represented as follows:        ----
----                      1111111111101010                                   ----
---- with C7 clock mask   1 1 0 0 0 1 1 1 which masks the clock pulses there ----
---- results:             1111010101101010 this is the deleted DATA mark.    ----
----                                                                         ----
----                                                                         ----
---- Modified frequency modulation MFM:                                      ----
---- The modified frequency modulation works as follows:                     ----
---- 1. every first pulse of the clock and data line is a clock.             ----
---- 2. every second pulse is a data.                                        ----
---- 3. a logic 1 is represented by no clock but a data pulse.               ----
---- 4. a logic 0 is represented by a clock pulse and no data pulse if       ---- 
---- following a 0.                                                          ----
---- 5. a logic 0 is represented by no pulse if following a 1.               ----
---- 6. Hence there are a maximum of one pulse per data bit.                 ----
---- 7. one clock and one data pulse form together one bit cell.             ----
---- 8. the duration of a bit cell in MFM is 2 microseconds.                 ----
---- 9. an address mark sync is represented as data A1 with missing clock    ----
---- pulse between bit 4 and 5.                                              ----
---- Examples:                                                               ----
---- Binary data FE 1 1 1 1 1 1 1 0 is represented in MFM as follows:        ----
----               0101010101010100 this is the ID address mark.             ----
---- Binary data FB 1 1 1 1 1 0 1 1 is represented in MFM as follows:        ----
----               0101010101000101 this is the DATA address mark.           ----
---- Binary data F8 1 1 1 1 1 0 0 0 is represented in MFM as follows:        ----
----               0101010101001010 this is the deleted DATA address mark.   ----
---- the A1 data           1 0 1 0 0 0 0 1 is represented as follows:        ----
----                      0100010010101001                                   ----
---- with the missing clock pulse between bits 4 and 5 there results:        ----
---- results:             0100010010001001 this is the address mark sync.    ----
----                                                                         ----
---- Both MFM and FM are during read and write shifted with most significant ----
---- bit (MSB) first. During the FM address marks are written without a      ----
---- SYNC pulse the MFM coded data requires a synchronisation (A1 with       ----
---- missing clock pulse because at the beginning of the data stream it is   ----
---- not defined wether a clock pulse or a data pulse appears first. In FM   ----
---- coding the first pulse is in any case a clock pulse.                    ----
---------------------------------------------------------------------------------
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
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF1772IP_AM_DETECTOR is
	port(
		-- System control
		CLK				: in bit;
		RESETn			: in bit;

		-- Controls:
		DDEn		    : in bit;
		
		-- Serial data and clock:
		DATA			: in bit;
		DATA_STRB		: in bit;

		-- Address mark detector:
		ID_AM		: out bit; -- ID address mark strobe.
		DATA_AM		: out bit; -- Data address mark strobe.
		DDATA_AM	: out bit -- Deleted data address mark strobe.
	);
end WF1772IP_AM_DETECTOR;

architecture BEHAVIOR of WF1772IP_AM_DETECTOR is
signal SHIFT		: bit_vector(15 downto 0);
signal SYNC			: boolean;
signal ID_AM_I		: bit;
signal DATA_AM_I	: bit;
signal DDATA_AM_I	: bit;
begin
	SHIFTREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			SHIFT <= (others => '0');
		elsif CLK = '1' and CLK' event then
			if DATA_STRB = '1' then
				-- MSB first leads to a shift left operation.
				SHIFT <= SHIFT(14 downto 0) & DATA;
            elsif DDEn = '0' and SHIFT = "0100010010001001" then -- This is the synchronisation in MFM.
				SHIFT <= (others => '0');
			end if;
		end if;
	end process SHIFTREG;

	MFM_SYNCLOCK: process(RESETn, CLK)
	-- The SYNC pulse is generated in MFM mode only when the sync character
	-- appears in the shift register (A1 sync mark, see file header).
	-- After the sync character is detected, the sync time counter is loaded
	-- with a value of 17. During counting the following 17 read clock pulses
	-- down, the SYNC is true. After exactly 16 pulses the address mark is 
	-- detected if the pattern in the shift register fits one of the address 
	-- marks. The address mark pulses are valid for one read clock cycle until 
	-- SYNC  goes low again. This mechanism is used to detect the correct address 
	-- marks in the MFM data stream during the type III read track command. 
	-- This is an improvement over the original WD1772 chip.
	variable TMP : std_logic_vector(4 downto 0);
	begin
		if RESETn = '0' then
			TMP := "00000";
		elsif CLK = '1' and CLK' event then
			if SHIFT = "0100010010001001" and DDEn = '0' then
                TMP := "10001"; -- Load sync time counter.
			elsif DATA_STRB = '1' and TMP > "00000" then
				TMP := TMP - '1';
			end if;
		end if;
		case TMP is
			when "00000" => SYNC <= false;
			when others => SYNC <= true;
		end case;
	end process MFM_SYNCLOCK;

	-- The addressmark is nominally valid for one data pulse cycle (1us, 2us, 4us).
	-- The pulse is shorter due to the fact that the detected address marks change the
	-- state of the control state machine and so clear the address mark shift register...
	ID_AM_I <=	 '1' when DDEn = '1' and SHIFT = "1111010101111110" else
				 '1' when DDEn = '0' and SHIFT = "0101010101010100" and SYNC = true else '0';
	DATA_AM_I <= '1' when DDEn = '1' and SHIFT = "1111010101101111" else
				 -- Normal data address mark...
				 '1' when DDEn = '0' and SHIFT = "0101010101000101"  and SYNC = true else '0';
	DDATA_AM_I <= 	'1' when DDEn = '1' and SHIFT = "1111010101101010" else
					-- ... and deleted address mark in MFM mode:
					'1' when DDEn = '0' and SHIFT = "0101010101001010"  and SYNC = true else '0';
					
	ADRMARK_STROBES: process(RESETn, CLK)
	-- ... nevertheless The controller and the transceiver require ID address mark strobes 
	-- and DATA address mark strobes. Therefore this process provides these strobe
	-- signals independant of any 'feedbacks' like pulse shortening by the controller
	-- state machine itself.
	variable ID_AM_LOCK, DATA_AM_LOCK, DDATA_AM_LOCK	: boolean;
	begin
		if RESETn = '0' then
			ID_AM_LOCK := false;
			DATA_AM_LOCK := false;
			ID_AM <= '0';
			DATA_AM <= '0';
		elsif CLK = '1' and CLK' event then
			-- ID address mark:
			if ID_AM_I = '1' and ID_AM_LOCK = false then
				ID_AM <= '1';
				ID_AM_LOCK := true;
			elsif ID_AM_I = '0' then
				ID_AM <= '0';
				ID_AM_LOCK := false;
			else
				ID_AM <= '0';
			end if;
			-- Data address mark:
			if DATA_AM_I = '1' and DATA_AM_LOCK = false then
				DATA_AM <= '1';
				DATA_AM_LOCK := true;
			elsif DATA_AM_I = '0' then
				DATA_AM <= '0';
				DATA_AM_LOCK := false;
			else
				DATA_AM <= '0';
			end if;
			-- Deleted data address mark:
			if DDATA_AM_I = '1' and DDATA_AM_LOCK = false then
				DDATA_AM <= '1';
				DDATA_AM_LOCK := true;
			elsif DDATA_AM_I = '0' then
				DDATA_AM <= '0';
				DDATA_AM_LOCK := false;
			else
				DDATA_AM <= '0';
			end if;
		end if;
	end process ADRMARK_STROBES;
end architecture BEHAVIOR;
