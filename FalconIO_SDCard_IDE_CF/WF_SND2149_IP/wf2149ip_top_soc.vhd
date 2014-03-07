----------------------------------------------------------------------
----                                                              ----
----  YM2149 compatible sound generator.			              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- Model of the ST or STE's YM2149 sound generator.             ----
---- This IP core of the sound generator differs slightly from    ----
---- the original. Firstly it is a synchronous design without any ----
---- latches (like assumed in the original chip). This required   ----
---- the introduction of a system adequate clock. In detail this  ----
---- SYS_CLK should on the one hand be fast enough to meet the    ----
---- timing requirements of the system's bus cycle and should one ----
---- the other hand drive the PWM modules correctly. To meet both ----
---- a SYS_CLK of 16MHz or above is recommended.                  ----
---- Secondly, the original chip has an implemented DA converter. ----
---- This feature is not possible in today's FPGAs. Therefore the ----
---- converter is replaced by pulse width modulators. This solu-  ----
---- tion is very simple in comparison to other approaches like   ----
---- external DA converters with wave tables etc. The soltution   ----
---- with the pulse width modulators is probably not as accurate  ----
---- DAs with wavetables. For a detailed descrition of the hard-  ----
---- ware PWM filter look at the end of the wave file, where the  ----
---- pulse width modulators can be found.                         ----
---- For a proper operation it is required, that the wave clock   ----
---- is lower than the system clock. A good choice is for example ----
---- 2MHz for the wave clock and 16MHz for the system clock.      ----
----                                                              ----
---- Main module file.                                            ----
---- Top level file for use in systems on programmable chips.     ----
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
--   Top level file provided for SOC (systems on programmable chips).
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
--

library ieee;
use ieee.std_logic_1164.all;
use work.wf2149ip_pkg.all;

entity WF2149IP_TOP_SOC is
	port(
		
		SYS_CLK		: in bit; -- Read the inforation in the header!
		RESETn   	: in bit;

		WAV_CLK		: in bit; -- Read the inforation in the header!
		SELn		: in bit;
		
		BDIR		: in bit;
		BC2, BC1	: in bit;

		A9n, A8		: in bit;
		DA_IN		: in std_logic_vector(7 downto 0);
		DA_OUT		: out std_logic_vector(7 downto 0);
		DA_EN		: out bit;
		
		IO_A_IN		: in bit_vector(7 downto 0);
		IO_A_OUT	: out bit_vector(7 downto 0);
		IO_A_EN		: out bit;
		IO_B_IN		: in bit_vector(7 downto 0);
		IO_B_OUT	: out bit_vector(7 downto 0);
		IO_B_EN		: out bit;

		OUT_A		: out bit; -- Analog (PWM) outputs.
		OUT_B		: out bit;
		OUT_C		: out bit
	);
end WF2149IP_TOP_SOC;

architecture STRUCTURE of WF2149IP_TOP_SOC is
signal BUSCYCLE		: BUSCYCLES;
signal DATA_OUT_I	: std_logic_vector(7 downto 0);
signal DATA_EN_I	: bit;
signal WAV_STRB		: bit;
signal ADR_I		: bit_vector(3 downto 0);
signal CTRL_REG		: bit_vector(7 downto 0);
signal PORT_A		: bit_vector(7 downto 0);
signal PORT_B		: bit_vector(7 downto 0);
begin
	P_WAVSTRB: process(RESETn, SYS_CLK)
	variable LOCK	: boolean;
	variable TMP	: bit;
	begin
		if RESETn = '0' then
			LOCK := false;
			TMP := '0';
		elsif SYS_CLK = '1' and SYS_CLK' event then
			if WAV_CLK = '1' and LOCK = false then
				LOCK := true;
				TMP := not TMP; -- Divider by 2.
				case SELn is
					when '1' 	=> WAV_STRB <= '1';
					when others => WAV_STRB <= TMP;
				end case;
			elsif WAV_CLK = '0' then
				LOCK := false;
				WAV_STRB <= '0';
			else
				WAV_STRB <= '0';
			end if;
		end if;
	end process P_WAVSTRB;		

	with BDIR & BC2 & BC1 select
		BUSCYCLE <= INACTIVE	when "000" | "010" | "101",
					ADDRESS 	when "001" | "100" | "111",
					R_READ 		when "011",
					R_WRITE 	when "110";

	ADDRESSLATCH: process(RESETn, SYS_CLK)
	-- This process is responsible to store the desired register
	-- address. The default (after reset) is channel A fine tone 
	-- adjustment.
	begin
		if RESETn = '0' then
			ADR_I <= (others => '0');
        elsif SYS_CLK = '1' and SYS_CLK' event then
			if BUSCYCLE = ADDRESS and A9n = '0' and A8 = '1' and DA_IN(7 downto 4) = x"0" then
				ADR_I <= To_BitVector(DA_IN(3 downto 0));
			end if;
		end if;
	end process ADDRESSLATCH;	

	P_CTRL_REG: process(RESETn, SYS_CLK)
	-- THIS is the Control register for the mixer and for the I/O ports.
	begin
		if RESETn = '0' then
			CTRL_REG <= x"00";
		elsif SYS_CLK = '1' and SYS_CLK' event then
			if BUSCYCLE = R_WRITE and ADR_I = x"7" then
				CTRL_REG <= To_BitVector(DA_IN);
			end if;
		end if;
	end process P_CTRL_REG;
	
	DIG_PORTS: process(RESETn, SYS_CLK)
	begin
		if RESETn = '0' then
			PORT_A <= x"00";
			PORT_B <= x"00";
		elsif SYS_CLK = '1' and SYS_CLK' event then
			if BUSCYCLE = R_WRITE and ADR_I = x"E" then
				PORT_A <= To_BitVector(DA_IN);
			elsif BUSCYCLE = R_WRITE and ADR_I = x"F" then
				PORT_B <= To_BitVector(DA_IN);
			end if;
		end if;	
	end process DIG_PORTS;
	-- Set port direction to input or to output:
	IO_A_EN	<= '1' when CTRL_REG(6) = '1' else '0';
	IO_B_EN <= '1' when CTRL_REG(7) = '1' else '0';
	IO_A_OUT <= PORT_A;
	IO_B_OUT <= PORT_B;

	I_PSG_WAVE: WF2149IP_WAVE
		port map(
			RESETn		=> RESETn,
			SYS_CLK	=> SYS_CLK,

			WAV_STRB	=> WAV_STRB,

			ADR			=> ADR_I,
			DATA_IN		=> DA_IN,
			DATA_OUT	=> DATA_OUT_I,
			DATA_EN		=> DATA_EN_I,
			
			BUSCYCLE	=> BUSCYCLE,
			CTRL_REG	=> CTRL_REG(5 downto 0),
						
			OUT_A		=> OUT_A,
			OUT_B		=> OUT_B,
			OUT_C		=> OUT_C
		);

	-- Read the ports and registers:
	DA_EN <= 	'1' when DATA_EN_I = '1' else
				'1' when BUSCYCLE = R_READ and ADR_I = x"7" else
				'1' when BUSCYCLE = R_READ and ADR_I = x"E" else
				'1' when BUSCYCLE = R_READ and ADR_I = x"F" else '0';
				
	DA_OUT <= 	DATA_OUT_I when DATA_EN_I = '1' else -- WAV stuff.
				To_StdLogicVector(IO_A_IN) when BUSCYCLE = R_READ and ADR_I = x"E" else
				To_StdLogicVector(IO_B_IN) when BUSCYCLE = R_READ and ADR_I = x"F" else
				To_StdLogicVector(CTRL_REG) when BUSCYCLE = R_READ and ADR_I = x"7" else (others => '0');

end STRUCTURE;
