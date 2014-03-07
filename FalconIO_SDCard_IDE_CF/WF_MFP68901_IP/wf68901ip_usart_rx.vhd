----------------------------------------------------------------------
----                                                              ----
---- ATARI MFP compatible IP Core					              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- This is the SUSKA MFP IP core USART receiver file.           ----
----                                                              ----
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
-- Revision 2K6B	2006/11/07 WF
--   Modified Source to compile with the Xilinx ISE.
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
-- Revision 2K9A  2009/06/20 WF
-- Process P_STARTBIT has now synchronous reset to meet preset requirement.
-- Process P_SAMPLE has now synchronous reset to meet preset requirement.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF68901IP_USART_RX is
  port (
		CLK			: in bit;
        RESETn		: in bit;

		SCR			: in bit_vector(7 downto 0); -- Synchronous character. 
		RX_SAMPLE	: buffer bit; -- Flag indicating valid shift register data.
        RX_DATA		: out bit_vector(7 downto 0); -- Received data.

        RXCLK		: in bit; -- Receiver clock.
        SDATA_IN	: in bit; -- Serial data input.

		CL			: in bit_vector(1 downto 0); -- Character length.
		ST			: in bit_vector(1 downto 0); -- Start and stop bit configuration.
		P_ENA		: in bit; -- Parity enable.
		P_EOn		: in bit; -- Even or odd parity.
		CLK_MODE	: in bit; -- Clock mode configuration bit.
		RE			: in bit; -- Receiver enable.
		FS_CLR		: in bit; -- Clear the Found/Search flag for resynchronisation purpose.
		SS			: in bit; -- Synchronous strip enable.
		UDR_READ	: in bit; -- Flag indicating reading the data register.
		RSR_READ	: in bit; -- Flag indicating reading the receiver status register.

		M_CIP		: out bit; -- Match/Character in progress.
		FS_B		: buffer bit; -- Find/Search or Break detect flag.
		BF			: out bit; -- Buffer full.
		OE			: out bit; -- Overrun error.
		PE			: out bit; -- Parity error.
		FE			: out bit  -- Framing error.
       );                                              
end entity WF68901IP_USART_RX;

architecture BEHAVIOR of WF68901IP_USART_RX is
type RCV_STATES is (IDLE, WAIT_START, SAMPLE, PARITY, STOP1, STOP2, SYNC);
signal RCV_STATE, RCV_NEXT_STATE	: RCV_STATES;
signal SDATA_DIV16					: bit;
signal SDATA_IN_I					: bit;
signal SDATA_EDGE					: bit;
signal SHIFT_REG					: bit_vector(7 downto 0);
signal CLK_STRB						: bit;
signal CLK_2_STRB					: bit;
signal BITCNT						: std_logic_vector(2 downto 0);
signal BREAK						: boolean;
signal RDRF							: bit;
signal STARTBIT						: boolean;
begin
	BF <= RDRF; -- Buffer full = Receiver Data Register Full.
	RX_SAMPLE <= '1' when RCV_STATE = SYNC and ST /= "00" else -- Asynchronous mode:
			     -- Synchronous modes:
				 '1' when RCV_STATE = SYNC and ST = "00" and SS = '0' else
			     '1' when RCV_STATE = SYNC and ST = "00" and SS = '1' and SHIFT_REG /= SCR else '0';

	-- Data multiplexer for the received data:
	RX_DATA <= 	"000" & SHIFT_REG(7 downto 3) when RX_SAMPLE = '1' and CL = "11" else -- 5 databits.
				"00" & SHIFT_REG(7 downto 2) when RX_SAMPLE = '1' and CL = "10" else -- 6 databits.
				'0' & SHIFT_REG(7 downto 1) when RX_SAMPLE = '1' and CL = "01" else -- 6 databits.
				SHIFT_REG when RX_SAMPLE = '1' and CL = "00" else x"00"; -- 8 databits.

	P_SAMPLE: process
	-- This process provides the 'valid transition logic' of the originally MC68901. For further
	-- details see the 'M68000 FAMILY REFERENCE MANUAL'.
	variable LOW_FLT		: std_logic_vector(1 downto 0);
	variable HI_FLT			: std_logic_vector(1 downto 0);
	variable CLK_LOCK		: boolean;
	variable EDGE_LOCK		: boolean;
	variable TIMER			: std_logic_vector(2 downto 0);
	variable TIMER_LOCK		: boolean;
	variable NEW_SDATA 		: bit;
	begin
		wait until CLK = '1' and CLK' event;
		if RESETn = '0' or RE = '0' then
			-- The reset condition assumes the SDATA_IN logic high. Otherwise
			-- one not valid SDATA_EDGE pulse occurs during system startup.
			CLK_LOCK := true;
			EDGE_LOCK := true;
			HI_FLT := "11";
			LOW_FLT := "11";
			SDATA_EDGE <= '0';
			NEW_SDATA := '1';
		-- Positive or negative edge detector for the incoming data.
		-- Any transition must be valid for at least three receiver clock
		-- cycles. The TIMER locking inhibits detecting four receiver
		-- clock cycles after a valid transition.
		elsif RXCLK = '1' and SDATA_IN = '0' and CLK_LOCK = false and LOW_FLT > "00" then
			CLK_LOCK := true;
			EDGE_LOCK := false;
			HI_FLT := "00";
			LOW_FLT := LOW_FLT - '1';
		elsif RXCLK = '1' and SDATA_IN = '1' and CLK_LOCK = false and HI_FLT < "11" then
			CLK_LOCK := true;
			EDGE_LOCK := false;
			LOW_FLT := "11";
			HI_FLT := HI_FLT + '1';
		elsif RXCLK = '1' and EDGE_LOCK = false and LOW_FLT = "00" then
			EDGE_LOCK := true;
			SDATA_EDGE <= '1'; -- Falling edge detected.
			NEW_SDATA := '0';
		elsif RXCLK = '1' and EDGE_LOCK = false and HI_FLT = "11" then
			EDGE_LOCK := true;
			SDATA_EDGE <= '1'; -- Rising edge detected.
			NEW_SDATA := '1';
		elsif RXCLK = '1' and CLK_LOCK = false then
			CLK_LOCK := true;
			SDATA_EDGE <= '0';
		elsif RXCLK = '0' then
			CLK_LOCK := false;
		end if;
		--
		if RESETn = '0' or RE = '0' then
			-- The reset condition assumes the SDATA_IN logic high. Otherwise
			-- one not valid SDATA_EDGE pulse occurs during system startup.
			TIMER := "111";
			TIMER_LOCK := true;
			SDATA_DIV16 <= '1';
		-- The timer controls the SDATA in a way, that after a detected valid
		-- Transistion, the serial data is sampled on the 8th receiver clock
		-- edge after the initial valid transition occured.
		elsif RXCLK = '1' and SDATA_EDGE = '1' and TIMER_LOCK = false then
			TIMER_LOCK := true;
			TIMER := "000"; -- Resynchronisation.
		elsif RXCLK = '1' and TIMER = "011" and TIMER_LOCK = false then
			TIMER_LOCK := true;
			SDATA_DIV16 <= NEW_SDATA; -- Scan the new data.
			TIMER := TIMER + '1'; -- Timing is active.
		elsif RXCLK = '1' and TIMER < "111" and TIMER_LOCK = false then
			TIMER_LOCK := true;
			TIMER := TIMER + '1'; -- Timing is active.
		elsif RXCLK = '0' then
			TIMER_LOCK := false;
		end if;
	end process P_SAMPLE;

	P_START_BIT: process(CLK)
	-- This is the valid start bit logic of the original MC68901 multi function
	-- port's USART receiver.
	variable TMP	: std_logic_vector(2 downto 0);
	variable LOCK 	: boolean;
	begin
		if CLK = '1' and CLK' event then
			if RESETn = '0' then
				TMP := "000";
				LOCK := true;
			elsif RE = '0' or RCV_STATE /= IDLE then -- Start bit logic disabled.
				TMP := "000";
				LOCK := true;
			elsif SDATA_EDGE = '1' then
				TMP := "000"; -- (Re)-Initialize.
				LOCK := false; -- Start counting.
			elsif RXCLK = '1' and SDATA_IN = '0' and TMP < "111" and LOCK = false then
				LOCK := true;
				TMP := TMP + '1'; -- Count 8 low bits to declare start condition valid.
			elsif RXCLK = '0' then
				LOCK := false;
			end if;
		end if;

		case TMP is
			when "111" => STARTBIT <= true;
			when others => STARTBIT <= false;
		end case;
	end process P_START_BIT;

	SDATA_IN_I <= 	SDATA_IN when CLK_MODE = '0' else -- Clock div by 1 mode.
					SDATA_IN when ST = "00" else SDATA_DIV16; -- Synchronous mode.

	CLKDIV: process
	variable CLK_LOCK	: boolean;
	variable STRB_LOCK	: boolean;
	variable CLK_DIVCNT	: std_logic_vector(4 downto 0);
	begin
		wait until CLK = '1' and CLK' event;
		if CLK_MODE = '0' then -- Divider off.
			if RXCLK = '1' and STRB_LOCK = false then
				CLK_STRB <= '1';
				STRB_LOCK := true;
			elsif RXCLK = '0' then
				CLK_STRB <= '0';
				STRB_LOCK := false;
			else
				CLK_STRB <= '0';
			end if;
			CLK_2_STRB <= '0'; -- No 1 1/2 stop bits in no div by 16 mode.
		elsif SDATA_EDGE = '1' then
CLK_DIVCNT := "01100"; -- Div by 16 mode.
			CLK_STRB <= '0'; -- Default.
			CLK_2_STRB <= '0'; -- Default.
		else
			CLK_STRB <= '0'; -- Default.
			CLK_2_STRB <= '0'; -- Default.
			if CLK_DIVCNT > "00000" and RXCLK = '1' and CLK_LOCK = false then
				CLK_DIVCNT := CLK_DIVCNT - '1';
				CLK_LOCK := true;
				if CLK_DIVCNT = "01000" then
					-- This strobe is asserted at half of the clock cycle.
					-- It is used for the stop bit timing.
					CLK_2_STRB <= '1';
				end if;
			elsif CLK_DIVCNT = "00000" then
				CLK_DIVCNT := "10000"; -- Div by 16 mode.
				if STRB_LOCK = false then
					STRB_LOCK := true;
					CLK_STRB <= '1';
				end if;
			elsif RXCLK = '0' then
				CLK_LOCK := false;
				STRB_LOCK := false;
			end if;
		end if;
	end process CLKDIV;
	
	SHIFTREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			SHIFT_REG <= x"00";
		elsif CLK = '1' and CLK' event then
			if RE = '0' then
				SHIFT_REG <= x"00";
			elsif RCV_STATE = SAMPLE and CLK_STRB = '1' then
				SHIFT_REG <= SDATA_IN_I & SHIFT_REG(7 downto 1); -- Shift right.
			end if;
		end if;
	end process SHIFTREG;	

	P_M_CIP: process(RESETn, CLK)
	-- In Synchronous mode this flag indicates wether a synchronous character M_CIP = '1' 
	-- or another character (M_CIP = '0') is transferred to the receive buffer.
	-- In asynchronous mode the flag indicates sampling condition.
	begin
		if RESETn = '0' then
			M_CIP <= '0';
		elsif CLK = '0' and CLK' event then
			if RE = '0' then
				M_CIP <= '0';
			elsif ST = "00" then -- Synchronous mode.
				if RCV_STATE = SYNC and SHIFT_REG = SCR and RDRF = '0' then
					M_CIP <= '1'; -- SCR transferred.
				elsif RCV_STATE = SYNC and RDRF = '0' then
					M_CIP <= '0'; -- No SCR transferred.
				end if;
			else -- Asynchronous mode.
				case RCV_STATE is
					when SAMPLE | PARITY | STOP1 | STOP2 => M_CIP <= '1'; -- Sampling.
					when others => M_CIP <= '0'; -- No Sampling.
				end case;
			end if;
		end if;
	end process P_M_CIP;

	BREAK_DETECT: process(RESETn, CLK)
	-- A break condition occurs, if there is no  STOP1 bit and the
	-- shift register contains zero data.
	begin
		if RESETn = '0' then
			BREAK <= false;
		elsif CLK = '1' and CLK' event then
			if RE = '0' then
				BREAK <= false;
			elsif CLK_STRB = '1' then
				if RCV_STATE = STOP1 and SDATA_IN_I = '0' and SHIFT_REG = x"00" then
					BREAK <= true; -- Break detected (empty shift register and no stop bit).
				elsif RCV_STATE = STOP1 and SDATA_IN_I = '1' then
					BREAK <= false; -- UPDATE.
				elsif RCV_STATE = STOP1 and SDATA_IN_I = '0' and SHIFT_REG /= x"00" then
					BREAK <= false; -- UPDATE, but framing error.
				end if;
			end if;
		end if;
	end process BREAK_DETECT;

	P_FS_B: process(RESETn, CLK)
	-- In the synchronous mode, this process provides the flag detecting the synchronous 
	-- character. In the asynchronous mode, the flag indicates a break condition.
	variable FS_B_I		: bit;
	variable FIRST_READ	: boolean;
	begin
		if RESETn = '0' then
			FS_B <= '0';
			FIRST_READ := false;
			FS_B_I := '0';
		elsif CLK = '0' and CLK' event then
			if RE = '0' then
				FS_B <= '0';
				FS_B_I := '0';
			else
				if ST = "00" then -- Synchronous operation.
					if FS_CLR = '1' then
						FS_B <= '0'; -- Clear during writing to the SCR.
					elsif SHIFT_REG = SCR then
						FS_B <= '1'; -- SCR detected.
					end if;
				else -- Asynchronous operation.
					if RX_SAMPLE = '1' and BREAK = true then -- Break condition detected.
						FS_B_I := '1'; -- Update.
					elsif RX_SAMPLE = '1' then -- No break condition.
						FS_B_I := '0'; -- Update.
					elsif RSR_READ = '1' and FS_B_I = '1' then
						-- If a break condition was detected, the concerning flag is
						-- set when the valid data word in the receiver data
						-- register is read. Thereafter the break flag is reset
						-- and the break condition disappears after a second read
						-- (in time) of the receiver status register.
						if FIRST_READ = false then
							FS_B <= '1';
							FIRST_READ := true;
						else
							FS_B <= '0';
							FIRST_READ := false;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process P_FS_B;

	P_BITCNT: process
	begin
		wait until CLK = '1' and CLK' event;
		if RCV_STATE = SAMPLE and CLK_STRB = '1' and ST /= "00" then -- Asynchronous mode.
			BITCNT <= BITCNT + '1';
		elsif RCV_STATE = SAMPLE and CLK_STRB = '1' and ST = "00" and FS_B = '1' then -- Synchronous mode.
			BITCNT <= BITCNT + '1'; -- Count, if matched data found (FS_B = '1').
		elsif RCV_STATE /= SAMPLE then
			BITCNT <= (others => '0');
		end if;
	end process P_BITCNT;

	BUFFER_FULL: process(RESETn, CLK)
	-- Receive data register full flag.
	begin
		if RESETn = '0' then
			RDRF <= '0';
		elsif CLK = '1' and CLK' event then
			if RE = '0' then
				RDRF <= '0';
			elsif RX_SAMPLE = '1' then
				RDRF <= '1'; -- Data register is full until now!
			elsif UDR_READ = '1' then
				RDRF <= '0'; -- After reading the data register ...
			end if;
		end if;
	end process BUFFER_FULL;
	
	OVERRUN: process(RESETn, CLK)
	variable OE_I		: bit;
	variable FIRST_READ	: boolean;
	begin
		if RESETn = '0' then
			OE_I := '0';
			OE <= '0';
			FIRST_READ := false;
		elsif CLK = '1' and CLK' event then
			if RESETn = '0' then
				OE_I := '0';
				OE <= '0';
				FIRST_READ := false;
			elsif CLK_STRB = '1' and RCV_STATE = SYNC and BREAK = false then
				-- Overrun appears if RDRF is '1' in this state and there
				-- is no break condition.
				OE_I := RDRF;
			end if;
			if RSR_READ = '1' and OE_I = '1' then
				-- if an overrun was detected, the concerning flag is
				-- set when the valid data word in the receiver data
				-- register is read. Thereafter the RDRF flag is reset
				-- and the overrun disappears (OE_I goes low) after 
				-- a second read (in time) of the receiver data register.
				if FIRST_READ = false then
					OE <= '1';
					FIRST_READ := true;
				else
					OE <= '0';
					FIRST_READ := false;
				end if;
			end if;
		end if;
	end process OVERRUN;
	
	PARITY_TEST: process(RESETn, CLK)
	variable PAR_TMP	: bit;
	variable P_ERR		: bit;
	begin
		if RESETn = '0' then
			PE <= '0';
		elsif CLK = '1' and CLK' event then
			if RE = '0' then
				PE <= '0';
			elsif RX_SAMPLE = '1' then
				PE <= P_ERR; -- Update on load shift register to data register.
			elsif CLK_STRB = '1' then -- Sample parity on clock strobe.
				P_ERR := '0'; -- Initialise.
				if RCV_STATE = PARITY then
				    for i in 1 to 7 loop
				        if i = 1 then
				            PAR_TMP := SHIFT_REG(i-1) xor SHIFT_REG(i);
				        else
				            PAR_TMP := PAR_TMP xor SHIFT_REG(i);
				        end if;
				    end loop;
					if P_ENA = '1' and P_EOn = '1' then -- Even parity.
				    	P_ERR := PAR_TMP xor SDATA_IN_I;
					elsif P_ENA = '1' and P_EOn = '0' then -- Odd parity.
						P_ERR := not PAR_TMP xor SDATA_IN_I;
					elsif P_ENA = '0' then -- No parity.
						P_ERR := '0';		
					end if;
				end if;
			end if;
		end if;
	end process PARITY_TEST;

	FRAME_ERR: process(RESETn, CLK)
	-- This module detects a framing error
	-- during stop bit 1 and stop bit 2.
	variable FE_I: bit;
	begin
		if RESETn = '0' then
			FE_I := '0';
			FE <= '0';
		elsif CLK = '1' and CLK' event then
			if RE = '0' then
				FE_I := '0';
				FE <= '0';
			elsif CLK_STRB = '1' then
				if RCV_STATE = STOP1 and SDATA_IN_I = '0' and SHIFT_REG /= x"00" then
					FE_I := '1';
				elsif RCV_STATE = STOP2 and SDATA_IN_I = '0' and SHIFT_REG /= x"00" then
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

	RCV_STATEREG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			RCV_STATE <= IDLE;
		elsif CLK = '1' and CLK' event then
			if RE = '0' then
				RCV_STATE <= IDLE;
			else
				RCV_STATE <= RCV_NEXT_STATE;
			end if;
		end if;
	end process RCV_STATEREG;
	
	RCV_STATEDEC: process(RCV_STATE, SDATA_IN_I, BITCNT, CLK_STRB, STARTBIT,
						  CLK_2_STRB, ST, CLK_MODE, CL, P_ENA, SHIFT_REG)
	begin
		case RCV_STATE is
			when IDLE =>
				if ST = "00" then
					RCV_NEXT_STATE <= SAMPLE; -- Synchronous mode.
				elsif SDATA_IN_I = '0' and CLK_MODE = '0' then
					RCV_NEXT_STATE <= SAMPLE; -- Startbit detected in div by 1 mode.
				elsif STARTBIT = true and CLK_MODE = '1' then
					RCV_NEXT_STATE <= WAIT_START; -- Startbit detected in div by 16 mode.
				else
					RCV_NEXT_STATE <= IDLE; -- No startbit; sleep well :-)
				end if;
			when WAIT_START =>
				-- This state delays the sample process by one CLK_STRB pulse
				-- to eliminate the start bit.
				if CLK_STRB = '1' then
					RCV_NEXT_STATE <= SAMPLE;
				else
					RCV_NEXT_STATE <= WAIT_START;
				end if;
			when SAMPLE =>
				if CLK_STRB = '1' then
					if CL = "11"  and BITCNT < "100" then
						RCV_NEXT_STATE <= SAMPLE; -- Go on sampling 5 data bits.
					elsif CL = "10" and BITCNT < "101" then
						RCV_NEXT_STATE <= SAMPLE; -- Go on sampling 6 data bits.
					elsif CL = "01" and BITCNT < "110" then
						RCV_NEXT_STATE <= SAMPLE; -- Go on sampling 7 data bits.
					elsif CL = "00" and BITCNT < "111" then
						RCV_NEXT_STATE <= SAMPLE; -- Go on sampling 8 data bits.
					elsif ST = "00" and P_ENA = '0' then -- Synchronous mode (no stop bits).
						RCV_NEXT_STATE <= IDLE; -- No parity check enabled.
					elsif P_ENA = '0' then
						RCV_NEXT_STATE <= STOP1; -- No parity check enabled.
					else
						RCV_NEXT_STATE <= PARITY; -- Parity enabled.
					end if;
				else
					RCV_NEXT_STATE <= SAMPLE; -- Stay in sample mode.
				end if;
			when PARITY =>
				if CLK_STRB = '1' then
					if ST = "00" then -- Synchronous mode (no stop bits).
						RCV_NEXT_STATE <= IDLE;
					else
						RCV_NEXT_STATE <= STOP1;
					end if;
				else
					RCV_NEXT_STATE <= PARITY;
				end if;				
			when STOP1 =>
				if CLK_STRB = '1' then
					if SHIFT_REG > x"00" and SDATA_IN_I = '0' then -- No Stop bit after non zero data.
						RCV_NEXT_STATE <= SYNC; -- Framing error detected.
					elsif ST = "11" or ST = "10" then
						RCV_NEXT_STATE <= STOP2; -- More than one stop bits selected.
					else
						RCV_NEXT_STATE <= SYNC; -- One stop bit selected.
					end if;
				else
					RCV_NEXT_STATE <= STOP1;
				end if;				
			when STOP2 =>
				if CLK_2_STRB = '1'  and ST = "10" then
					RCV_NEXT_STATE <= SYNC; -- One and a half stop bits selected.
				elsif CLK_STRB = '1' then
					RCV_NEXT_STATE <= SYNC; -- Two stop bits selected.
				else
					RCV_NEXT_STATE <= STOP2;
				end if;				
			when SYNC =>
				RCV_NEXT_STATE <= IDLE;
		end case;
	end process RCV_STATEDEC;
end architecture BEHAVIOR;

