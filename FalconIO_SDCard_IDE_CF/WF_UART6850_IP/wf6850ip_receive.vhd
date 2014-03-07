----------------------------------------------------------------------
----                                                              ----
---- 6850 compatible IP Core    					              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- UART 6850 compatible IP core                                 ----
----                                                              ----
---- 6850's receiver unit.                                        ----
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
-- Revision 2K6A  2006/06/03 WF
--   Initial Release.
-- Revision 2K6B  2006/11/07 WF
--   Modified Source to compile with the Xilinx ISE.
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF6850IP_RECEIVE is
  port (
		CLK					: in bit;
        RESETn				: in bit;
		MCLR				: in bit;

        CS					: in bit_vector(2 downto 0);
        E		       		: in bit;   
        RWn              	: in bit;
        RS					: in bit;

        DATA_OUT	        : out bit_vector(7 downto 0);   
		DATA_EN				: out bit;
		
		WS					: in bit_vector(2 downto 0);
		CDS					: in bit_vector(1 downto 0);

        RXCLK				: in bit;
        RXDATA				: in bit;

		RDRF				: buffer bit;
		OVR					: out bit;
		PE					: out bit;
		FE					: out bit
       );                                              
end entity WF6850IP_RECEIVE;

architecture BEHAVIOR of WF6850IP_RECEIVE is
type RCV_STATES is (IDLE, WAIT_START, SAMPLE, PARITY, STOP1, STOP2, SYNC);
signal RCV_STATE, RCV_NEXT_STATE	: RCV_STATES;
signal RXDATA_I		: bit;
signal RXDATA_S		: bit;
signal DATA_REG		: bit_vector(7 downto 0);
signal SHIFT_REG	: bit_vector(7 downto 0);
signal CLK_STRB		: bit;
signal BITCNT		: std_logic_vector(2 downto 0);
begin
	P_SAMPLE: process
	-- This filter provides a synchronisation to the system
	-- clock, even for random baud rates of the received data
	-- stream.
	variable FLT_TMP	: integer range 0 to 2;
	begin
		wait until CLK = '1' and CLK' event;
		--
		RXDATA_I <= RXDATA;
		--
		if RXDATA_I = '1' and FLT_TMP < 2 then
			FLT_TMP := FLT_TMP + 1;
		elsif RXDATA_I = '1' then
			RXDATA_S <= '1';
		elsif RXDATA_I = '0' and FLT_TMP > 0 then
			FLT_TMP := FLT_TMP - 1;
		elsif RXDATA_I = '0' then
			RXDATA_S <= '0';
		end if;
	end process P_SAMPLE;

	CLKDIV: process
	variable CLK_LOCK	: boolean;
	variable STRB_LOCK	: boolean;
	variable CLK_DIVCNT	: std_logic_vector(6 downto 0);
	begin
		wait until CLK = '1' and CLK' event;
		if CDS = "00" then -- Divider off.
			if RXCLK = '1' and STRB_LOCK = false then
				CLK_STRB <= '1';
				STRB_LOCK := true;
			elsif RXCLK = '0' then
				CLK_STRB <= '0';
				STRB_LOCK := false;
			else
				CLK_STRB <= '0';
			end if;
		elsif RCV_STATE = IDLE then
			-- Preset the CLKDIV with the start delays.
			if CDS = "01" then
				CLK_DIVCNT := "0001000"; -- Half of div by 16 mode.
			elsif CDS = "10" then
				CLK_DIVCNT := "0100000"; -- Half of div by 64 mode.
			end if;
	 		CLK_STRB <= '0';
		else
			if CLK_DIVCNT > "0000000" and RXCLK = '1' and CLK_LOCK = false then
				CLK_DIVCNT := CLK_DIVCNT - '1';
				CLK_STRB <= '0';
				CLK_LOCK := true;
			elsif CDS = "01" and CLK_DIVCNT = "0000000" then
				CLK_DIVCNT := "0010000"; -- Div by 16 mode.
				--
				if STRB_LOCK = false then
					STRB_LOCK := true;
					CLK_STRB <= '1';
				else
					CLK_STRB <= '0';
				end if;
			elsif CDS = "10" and CLK_DIVCNT = "0000000" then
				CLK_DIVCNT := "1000000"; -- Div by 64 mode.
				if STRB_LOCK = false then
					STRB_LOCK := true;
					CLK_STRB <= '1';
				else
					CLK_STRB <= '0';
				end if;
			elsif RXCLK = '0' then
				CLK_LOCK := false;
				STRB_LOCK := false;
				CLK_STRB <= '0';
			else
				CLK_STRB <= '0';
			end if;
		end if;
	end process CLKDIV;
	
	DATAREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			DATA_REG <= x"00";
		elsif CLK = '1' and CLK' event then
			if MCLR = '1' then
				DATA_REG <= x"00";
			elsif RCV_STATE = SYNC and WS(2) = '0' and RDRF = '0' then -- 7 bit data.
				-- Transfer from shift- to data register only if
				-- data register is empty (RDRF = '0').
				DATA_REG <= '0' & SHIFT_REG(7 downto 1);
			elsif RCV_STATE = SYNC and WS(2) = '1' and RDRF = '0' then -- 8 bit data.
				-- Transfer from shift- to data register only if
				-- data register is empty (RDRF = '0').
				DATA_REG <= SHIFT_REG;
			end if;
		end if;
	end process DATAREG;	
    DATA_OUT <= DATA_REG when CS = "011" and RWn = '1' and RS = '1' and E = '1' else (others => '0');
    DATA_EN <= '1' when CS = "011" and RWn = '1' and RS = '1' and E = '1' else '0';
	
	SHIFTREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			SHIFT_REG <= x"00";
		elsif CLK = '1' and CLK' event then
			if MCLR = '1' then
				SHIFT_REG <= x"00";
			elsif RCV_STATE = SAMPLE and CLK_STRB = '1' then
				SHIFT_REG <= RXDATA_S & SHIFT_REG(7 downto 1); -- Shift right.
			end if;
		end if;
	end process SHIFTREG;	

	P_BITCNT: process
	begin
		wait until CLK = '1' and CLK' event;
		if RCV_STATE = SAMPLE and CLK_STRB = '1' then
			BITCNT <= BITCNT + '1';
		elsif RCV_STATE /= SAMPLE then
			BITCNT <= (others => '0');
		end if;
	end process P_BITCNT;

	FRAME_ERR: process(RESETn, CLK)
	-- This module detects a framing error
	-- during stop bit 1 and stop bit 2.
	variable FE_I: bit;
	begin
		if RESETn = '0' then
			FE_I := '0';
			FE <= '0';
		elsif CLK = '1' and CLK' event then
			if MCLR = '1' then
				FE_I := '0';
				FE <= '0';
			elsif CLK_STRB = '1' then
				if RCV_STATE = STOP1 and RXDATA_S = '0' then
					FE_I := '1';
				elsif RCV_STATE = STOP2 and RXDATA_S = '0' then
					FE_I := '1';
				elsif RCV_STATE = STOP1 or RCV_STATE = STOP2 then
					FE_I := '0'; -- Error resets when correct data appears.
				end if;
			end if;
			if RCV_STATE = SYNC then
				FE <= FE_I; -- Update the FE every SYNC time.
			end if;
		end if;
	end process FRAME_ERR;

	OVERRUN: process(RESETn, CLK)
	variable OVR_I		: bit;
	variable FIRST_READ	: boolean;
	begin
		if RESETn = '0' then
			OVR_I := '0';
			OVR <= '0';
			FIRST_READ := false;
		elsif CLK = '1' and CLK' event then
			if MCLR = '1' then
				OVR_I := '0';
				OVR <= '0';
				FIRST_READ := false;
			elsif CLK_STRB = '1' and RCV_STATE = STOP1 then
				-- Overrun appears if RDRF is '1' in this state.
				OVR_I := RDRF;
			end if;
			if CS = "011" and RWn = '1' and RS = '1' and E = '1' and OVR_I = '1' then
				-- If an overrun was detected, the concerning flag is
				-- set when the valid data word in the receiver data
				-- register is read. Thereafter the RDRF flag is reset
				-- and the overrun disappears (OVR_I goes low) after 
				-- a second read (in time) of the receiver data register.
				if FIRST_READ = false then
					OVR <= '1';
					FIRST_READ := true;
				else
					OVR <= '0';
					FIRST_READ := false;
				end if;
			end if;
		end if;
	end process OVERRUN;
	
	PARITY_TEST: process(RESETn, CLK)
	variable PAR_TMP	: bit;
	variable PE_I		: bit;
	begin
		if RESETn = '0' then
			PE <= '0';
		elsif CLK = '1' and CLK' event then
			if MCLR = '1' then
				PE <= '0';
			elsif CLK_STRB = '1' then -- Sample parity on clock strobe.
				PE_I := '0'; -- Initialise.
				if RCV_STATE = PARITY then
				    for i in 1 to 7 loop
				        if i = 1 then
				            PAR_TMP := SHIFT_REG(i-1) xor SHIFT_REG(i);
				        else
				            PAR_TMP := PAR_TMP xor SHIFT_REG(i);
				        end if;
				    end loop;
					if WS = "000" or WS = "010" or WS = "110" then -- Even parity.
				    	PE_I := PAR_TMP xor RXDATA_S;
					elsif WS = "001" or WS = "011" or WS = "111" then -- Odd parity.
						PE_I := not PAR_TMP xor RXDATA_S;
					else -- No parity for WS = "100" and WS = "101".
						PE_I := '0';		
					end if;
				end if;
			end if;
			-- Transmit the parity flag together with the data
			-- In other words: no parity to the status register
			-- when RDRF inhibits the data transfer to the
			-- receiver data register.
			if RCV_STATE = SYNC and RDRF = '0' then
				PE <= PE_I;
			elsif CS = "011" and RWn = '1' and RS = '1' and E = '1' then
				PE <= '0'; -- Clear when reading the data register.
			end if;
		end if;
	end process PARITY_TEST;

	P_RDRF: process(RESETn, CLK)
	-- Receive data register full flag.
	begin
		if RESETn = '0' then
			RDRF <= '0';
		elsif CLK = '1' and CLK' event then
			if MCLR = '1' then
				RDRF <= '0';
			elsif RCV_STATE = SYNC then
				RDRF <= '1'; -- Data register is full until now!
			elsif CS = "011" and RWn = '1' and RS = '1' and E = '1' then
				RDRF <= '0'; -- After reading the data register ...
			end if;
		end if;
	end process P_RDRF;
	
	RCV_STATEREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			RCV_STATE <= IDLE;
		elsif CLK = '1' and CLK' event then
			if MCLR = '1' then
				RCV_STATE <= IDLE;
			else
				RCV_STATE <= RCV_NEXT_STATE;
			end if;
		end if;
	end process RCV_STATEREG;
	
	RCV_STATEDEC: process(RCV_STATE, RXDATA_S, CDS, WS, BITCNT, CLK_STRB)
	begin
		case RCV_STATE is
			when IDLE =>
				if RXDATA_S = '0' and CDS = "00" then
					RCV_NEXT_STATE <= SAMPLE; -- Startbit detected in div by 1 mode.
				elsif RXDATA_S = '0' and CDS = "01" then
					RCV_NEXT_STATE <= WAIT_START; -- Startbit detected in div by 16 mode.
				elsif RXDATA_S = '0' and CDS = "10" then
					RCV_NEXT_STATE <= WAIT_START; -- Startbit detected in div by 64 mode.
				else
					RCV_NEXT_STATE <= IDLE; -- No startbit; sleep well :-)
				end if;
			when WAIT_START =>
				if CLK_STRB = '1' then
					if RXDATA_S = '0' then
						RCV_NEXT_STATE <= SAMPLE; -- Start condition in no div by 1 modes.
					else
						RCV_NEXT_STATE <= IDLE; -- No valid start condition, go back.
					end if;
				else
					RCV_NEXT_STATE <= WAIT_START; -- Stay.
				end if;
			when SAMPLE =>
				if CLK_STRB = '1' then
					if BITCNT < "110" and WS(2) = '0' then
						RCV_NEXT_STATE <= SAMPLE; -- Go on sampling 7 data bits.
					elsif BITCNT < "111" and WS(2) = '1' then
						RCV_NEXT_STATE <= SAMPLE; -- Go on sampling 8 data bits.
					elsif WS = "100" or WS = "101" then
						RCV_NEXT_STATE <= STOP1; -- No parity check enabled.
					else
						RCV_NEXT_STATE <= PARITY; -- Parity enabled.
					end if;
				else
					RCV_NEXT_STATE <= SAMPLE; -- Stay in sample mode.
				end if;
			when PARITY =>
				if CLK_STRB = '1' then
					RCV_NEXT_STATE <= STOP1;
				else
					RCV_NEXT_STATE <= PARITY;
				end if;				
			when STOP1 =>
				if CLK_STRB = '1' then
					if RXDATA_S = '0' then
						RCV_NEXT_STATE <= SYNC; -- Framing error detected.
					elsif WS = "000" or WS = "001" or WS = "100" then
						RCV_NEXT_STATE <= STOP2; -- Two stop bits selected.
					else
						RCV_NEXT_STATE <= SYNC; -- One stop bit selected.
					end if;
				else
					RCV_NEXT_STATE <= STOP1;
				end if;				
			when STOP2 =>
				if CLK_STRB = '1' then
					RCV_NEXT_STATE <= SYNC;
				else
					RCV_NEXT_STATE <= STOP2;
				end if;				
			when SYNC =>
				RCV_NEXT_STATE <= IDLE;
		end case;
	end process RCV_STATEDEC;
end architecture BEHAVIOR;

