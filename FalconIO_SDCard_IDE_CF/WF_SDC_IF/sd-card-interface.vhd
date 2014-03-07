----------------------------------------------------------------------
----                                                              ----
---- ATARI IP Core peripheral Add-On				              ----
----                                                              ----
---- This file is part of the FPGA-ATARI project.                 ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- This hardware provides an interface to connect to a SD-Card. ----
----                                                              ----
---- This interface is based on the project 'SatanDisk' of        ----
---- Miroslav Nohaj 'Jookie'. The code is an interpretation of    ----
---- the original code, written in VERILOG. It is provided for    ----
---- the use in a system on programmable chips (SOPC).            ----
----                                                              ----
---- Timing: Use a clock frequency of 16MHz for this component.   ----
----         Use the same clock frequency for the connected AVR   ----
----         microcontroller.                                     ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2007 Wolfgang Foerster                         ----
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
---- This hardware works with the original ATARI                  ----
---- hard dik driver.                                             ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 
-- Revision 1.0  2007/01/05 WF
--   Initial Release.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF_SD_CARD is
	port (
		-- System:
		RESETn			: in bit;
		CLK				: in bit; -- 16MHz, see above.

		-- ACSI section:		
		ACSI_A1			: in bit;
		ACSI_CSn		: in bit;
		ACSI_ACKn		: in bit;
		ACSI_INTn		: out bit;
		ACSI_DRQn		: out bit;
		ACSI_D			: inout std_logic_vector(7 downto 0);

		-- Microcontroller interface:
		MC_D			: inout std_logic_vector(7 downto 0);
		MC_DO			: in bit;
		MC_PIO_DMAn		: in bit;
		MC_RWn			: in bit;
		MC_CLR_CMD		: in bit;
		MC_DONE			: out bit;
		MC_GOT_CMD		: out bit
      );
end WF_SD_CARD;

architecture BEHAVIOR of WF_SD_CARD is
signal DATA_REG		: std_logic_vector(7 downto 0);
signal D0_REG		: bit;
signal INT_REG		: bit;
signal DRQ_REG		: bit;
signal DONE_REG		: bit;
signal GOT_CMD_REG	: bit;
signal HOLD			: bit;
signal PREV_CSn		: bit;
signal PREV_ACKn	: bit;
begin
	MC_D <= DATA_REG when MC_RWn = '0' and DONE_REG = '1' else (others => 'Z');
	ACSI_D <= DATA_REG when MC_RWn = '1' and (ACSI_CSn = '0' or ACSI_ACKn = '0' or HOLD = '1') else (others => 'Z');
	ACSI_INTn <= INT_REG;
	ACSI_DRQn <= DRQ_REG;
	MC_DONE <= DONE_REG;
	MC_GOT_CMD <= GOT_CMD_REG;

	P_DATA: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			DATA_REG <= (others => '0');
		elsif CLK = '1' and CLK' event then
			if D0_REG = '0' and MC_DO = '1' and MC_RWn = '1' then
				DATA_REG <= MC_D;  -- Read from AVR to ACSI.
			end if;
			--			
			if PREV_CSn = '0' and ACSI_CSn = '0' and MC_RWn = '0' and DONE_REG = '0' then
				DATA_REG <= ACSI_D; -- Write from ACSI to AVR.
			elsif PREV_ACKn = '0' and ACSI_ACKn = '0' and MC_RWn = '0' and DONE_REG = '0' then
				DATA_REG <= ACSI_D; -- Write from ACSI to AVR.
			end if;
		end if;
	end process P_DATA;
	
	P_SYNC: process
	begin
		wait until CLK = '1' and CLK' event;
		PREV_CSn <= ACSI_CSn;
		PREV_ACKn <= ACSI_ACKn;
	end process P_SYNC;

	P_INT_DRQ: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			INT_REG <= '1'; -- No interrupt.
			DRQ_REG <= '1'; -- No data request.
		elsif CLK = '1' and CLK' event then
			if D0_REG = '0' and MC_DO = '1' and MC_PIO_DMAn = '1' then -- Positive MC_DO edge.
				INT_REG <= '0'; -- Release an interrupt.
				DRQ_REG <= '1';
			elsif D0_REG = '0' and MC_DO = '1' then
				INT_REG <= '1';
				DRQ_REG <= '0'; -- Release a data request.
			end if;
			--
			if MC_CLR_CMD = '1' then -- Clear done.
				INT_REG <= '1'; -- Restore INT_REG.
				DRQ_REG <= '1'; -- Restore DRQ_REG.
			end if;
			--
			if (PREV_CSn = '0' and ACSI_CSn = '0') or (PREV_ACKn = '0' and ACSI_ACKn = '0') then
				if ACSI_CSn = '0' then
					INT_REG <= '1';
				end if;
				--
				if ACSI_ACKn = '0' then
					DRQ_REG <= '1';
				end if;
			end if;
		end if;
	end process P_INT_DRQ;
				
	P_HOLD: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			HOLD <= '0';
		elsif CLK = '1' and CLK' event then
			if (PREV_CSn = '0' and ACSI_CSn = '0') or (PREV_ACKn = '0' and ACSI_ACKn = '0') then
				HOLD <= '1';
			elsif PREV_CSn = '1' and ACSI_CSn = '1' then -- If signal is high.
				HOLD <= '0';
			elsif PREV_ACKn = '1' and ACSI_ACKn = '1' then -- If signal is high.
				HOLD <= '0';
			elsif PREV_CSn = '0' and ACSI_CSn = '1' then -- Rising edge.
				HOLD <= '1';
			elsif PREV_ACKn = '0' and ACSI_ACKn = '1' then -- Rising edge.
				HOLD <= '1';
			elsif MC_CLR_CMD = '1' then -- Clear done.
				HOLD <= '0';
			end if;
		end if;
	end process P_HOLD;

	P_DONE: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			DONE_REG <= '0';
		elsif CLK = '1' and CLK' event then
			if (PREV_CSn = '0' and ACSI_CSn = '0') or (PREV_ACKn = '0' and ACSI_ACKn = '0') then
				DONE_REG <= '1';
			elsif MC_CLR_CMD = '1' then -- Clear done.
				DONE_REG <= '0';
			elsif D0_REG = '0' and MC_DO = '1' then -- Positive MC_DO edge.
				DONE_REG <= '0';
			elsif D0_REG = '1' and MC_DO = '0' then -- Negative MC_DO edge.
				DONE_REG <= '0';
			end if;
		end if;
	end process P_DONE;

	P_DO_REG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			D0_REG <= '0';
		elsif CLK = '1' and CLK' event then
			if D0_REG = '0' and MC_DO = '1' then -- Positive MC_DO edge.
				D0_REG <= MC_DO;
			elsif D0_REG = '1' and MC_DO = '0' then -- Negative MC_DO edge.
				D0_REG <= MC_DO;
			end if;
		end if;
	end process P_DO_REG;

	P_GOT_CMD: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			GOT_CMD_REG <= '0';
		elsif CLK = '1' and CLK' event then
			if PREV_CSn = '0' and ACSI_CSn = '0' and ACSI_CSn = '0' and ACSI_A1 = '0' then
				GOT_CMD_REG <= '1'; -- If command was received.
			elsif PREV_ACKn = '0' and ACSI_ACKn = '0' and ACSI_CSn = '0' and ACSI_A1 = '0' then
				GOT_CMD_REG <= '1'; -- If command was received.
			elsif MC_CLR_CMD = '1' then -- Clear done.
				GOT_CMD_REG <= '0';
			end if;
		end if;
	end process P_GOT_CMD;
end architecture BEHAVIOR;