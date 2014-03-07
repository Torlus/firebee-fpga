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
---- This file models all the five WD1772 registers: DATA-,       ----
---- COMMAND-, SECTOR-, TRACK- and STATUS register as also the    ----
---- shift register.                                              ----
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
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF1772IP_REGISTERS is
	port(
		-- System control:
		CLK			: in bit;
		RESETn		: in bit;

		-- Bus interface:
		CSn			: in bit;
		ADR			: in bit_vector(1 downto 0);
		RWn			: in bit;
		DATA_IN		: in std_logic_vector (7 downto 0);
		DATA_OUT	: out std_logic_vector (7 downto 0);
		DATA_EN		: out bit;

		-- FDC data:
		CMD			: out std_logic_vector(7 downto 0); -- Command register.
		SR			: out std_logic_vector(7 downto 0); -- Sector register.
		TR			: out std_logic_vector(7 downto 0); -- Track register.
		DSR			: out std_logic_vector(7 downto 0); -- Data shift register.
		DR			: out bit_vector(7 downto 0); -- Data register.

		-- Serial data and clock strobes (in and out):
		DATA_STRB	: in bit; -- Strobe for the incoming data.
		SD_R		: in bit; -- Serial data input.
		
		-- DATA register control:
		DR_CLR		: in bit; -- Clear.
		DR_LOAD		: in bit; -- LOAD.

		-- Track register controls:
		TR_PRES		: in bit;	-- Set x"FF".
		TR_CLR		: in bit;	-- Clear.
		TR_INC		: in bit;	-- Increment.
		TR_DEC		: in bit;	-- Decrement.

		-- Sector register control:
		TRACK_NR 	: in std_logic_vector(7 downto 0);
		SR_LOAD		: in bit; -- Load.
		SR_INC		: in bit; -- Increment.

		-- Shift register control:
		SHFT_LOAD_SD	: in bit;
		SHFT_LOAD_ND	: in bit;

		-- Status register stuff
		MOTOR_ON		: in bit;
		WRITE_PROTECT	: in bit;
		SPINUP_RECTYPE	: in bit; -- Disk is on speed / data mark status.
		SEEK_RNF		: in bit; -- Seek error / record not found status flag.
		CRC_ERRFLAG		: in bit; -- CRC status flag.
		LOST_DATA_TR00	: in bit;
		DRQ				: in bit;
		DRQ_IPn			: in bit;
		BUSY			: in bit;

		-- Others:
		DDEn			: in bit
	);
end WF1772IP_REGISTERS;

architecture BEHAVIOR of WF1772IP_REGISTERS is
-- Remark: In the original data sheet 'WD17X-00' there is the following statement:
-- "After any register is written to, the same register cannot be read from until
-- 16us in MFM or 32us in FMMM have elapsed." If this is a hint for a hardware read
-- lock ... this lock is not implemented in this code.
signal SHIFT_REG	: std_logic_vector(7 downto 0);
signal DATA_REG		: std_logic_vector(7 downto 0);
signal COMMAND_REG	: std_logic_vector(7 downto 0);
signal SECTOR_REG	: std_logic_vector(7 downto 0);
signal TRACK_REG	: std_logic_vector(7 downto 0);
signal STATUS_REG	: bit_vector(7 downto 0);
signal SD_R_I		: std_logic;
begin
	-- Type conversion To_Std_Logic:
	SD_R_I <= '1' when SD_R = '1' else '0';

	P_SHIFTREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			SHIFT_REG <= x"00";
		elsif CLK = '1' and CLK' event then
			if SHFT_LOAD_ND = '1' then
				SHIFT_REG <= DATA_REG; -- Load data register stuff.
			elsif SHFT_LOAD_SD = '1' and DDEn = '1' then
				SHIFT_REG <= DATA_REG; -- Normal data in FM mode.
			elsif SHFT_LOAD_SD = '1' and DDEn = '0' then -- MFM mode:
				case DATA_REG is
					when x"F5" => SHIFT_REG <= x"A1"; -- Special character.
					when x"F6" => SHIFT_REG <= x"C2"; -- Special character.
					when others => SHIFT_REG <= DATA_REG; -- Normal MFM data.
				end case;
			elsif DATA_STRB = '1' then -- Shift left during read from disk or write to disk.
				SHIFT_REG <= SHIFT_REG(6 downto 0) & SD_R_I; -- for write operation SD_R_I is a dummy.
			end if;
		end if;
	end process P_SHIFTREG;
	DSR <= SHIFT_REG;

	DATAREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			DATA_REG <= x"00";
		elsif CLK = '1' and CLK' event then
			if CSn = '0' and ADR = "11" and RWn = '0' then
				DATA_REG <= DATA_IN; -- Write bus data to register
			elsif DR_LOAD = '1' and DRQ = '0' then
				DATA_REG <= SHIFT_REG; -- Correct data loaded to shift register.
			elsif DR_LOAD = '1' and DRQ = '1' then
				DATA_REG <= x"00"; -- Dummy byte due to lost data loaded to shift register.
			elsif DR_CLR = '1' then
				DATA_REG <= (others => '0');
			end if;
		end if;
	end process DATAREG;
	-- Data register buffered for further data processing.
	DR <= To_BitVector(DATA_REG);

	SECTORREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			SECTOR_REG <= x"00";
		elsif CLK = '1' and CLK' event then
            if CSn = '0' and ADR = "10" and RWn = '0' and BUSY = '0' then
				SECTOR_REG <= DATA_IN; -- Write to register when device is not busy.
			elsif SR_LOAD = '1' then
				-- Load the track number to the sector register in the type III command
				-- 'Read Address'.
				SECTOR_REG <= TRACK_NR;
			elsif SR_INC = '1' then
				SECTOR_REG <= SECTOR_REG + '1';
			end if;
		end if;
	end process SECTORREG;
	SR <= SECTOR_REG;

	TRACKREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			TRACK_REG <= x"00";
		elsif CLK = '1' and CLK' event then
			if CSn = '0' and ADR = "01" and RWn = '0' and BUSY = '0' then
				TRACK_REG <= DATA_IN; -- Write to register when device is busy.
			elsif TR_PRES = '1' then
				TRACK_REG <= (others => '1'); -- Preset the track register.
			elsif TR_CLR = '1' then
				TRACK_REG <= (others => '0'); -- Reset the track register.
			elsif TR_INC = '1' then
				TRACK_REG <= TRACK_REG + '1'; -- Increment register contents.
			elsif TR_DEC = '1' then
				TRACK_REG <= TRACK_REG - '1'; -- Decrement register contents.
			end if;
		end if;
	end process TRACKREG;
	TR <= TRACK_REG;

	COMMANDREG: process(RESETn, CLK)
	-- The command register is write only.
	begin
		if RESETn = '0' then
			COMMAND_REG <= x"00";
		elsif CLK = '1' and CLK' event then
			if CSn = '0' and ADR = "00" and RWn = '0' and BUSY = '0' then
				COMMAND_REG <= DATA_IN; -- Write to register when device is not busy.
			-- Write 'force interrupt' to register even when device is busy:
			elsif CSn = '0' and ADR = "00" and RWn = '0' and DATA_IN(7 downto 4) = x"D" then
				COMMAND_REG <= DATA_IN;
			end if;
		end if;
	end process COMMANDREG;
	CMD <= COMMAND_REG;

	STATUSREG: process(RESETn, CLK)
	-- The status register is read only to the data bus.
	begin
		-- Status register wiring:
		if RESETn = '0' then
			STATUS_REG <= x"00";
		elsif CLK = '1' and CLK' event then
			STATUS_REG(7) <= MOTOR_ON;
			STATUS_REG(6) <= WRITE_PROTECT;
			STATUS_REG(5) <= SPINUP_RECTYPE;
			STATUS_REG(4) <= SEEK_RNF;
			STATUS_REG(3) <= CRC_ERRFLAG;
			STATUS_REG(2) <= LOST_DATA_TR00;
			STATUS_REG(1) <= DRQ_IPn;
			STATUS_REG(0) <= BUSY;
		end if;
	end process STATUSREG;
	-- Read from track, sector or data register:
	-- The register data after writing to the track register is valid at least
	-- after 32us in FM mode and after 16us in MFM mode.
	-- Read from status register. This register is read only:
	-- Be aware, that the status register data bits 7 to 1 after writing 
	-- the command regsiter are valid at least after 64us in FM mode or 32us in MFM mode and
	-- the bit 0 (BUSY) is valid after 48us in FM mode or 24us in MFM mode.
	DATA_OUT <= TRACK_REG when CSn = '0' and ADR = "01" and RWn = '1' else
				SECTOR_REG when CSn = '0' and ADR = "10" and RWn = '1' else
				DATA_REG when CSn = '0' and ADR = "11" and RWn = '1' else
				To_StdLogicVector(STATUS_REG) when CSn = '0' and ADR = "00" and RWn = '1' else (others => '0');
	DATA_EN <= '1' when CSn = '0' and RWn = '1' else '0';
end architecture BEHAVIOR;