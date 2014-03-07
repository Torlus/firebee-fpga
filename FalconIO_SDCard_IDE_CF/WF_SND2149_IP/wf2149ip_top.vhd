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
---- Copyright (C) 2006 Wolfgang Foerster                         ----
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
-- Revision 2K8B  2008/12/24 WF
--   Rewritten this top level file as a wrapper for the top_soc file.
--

library ieee;
use ieee.std_logic_1164.all;
use work.wf2149ip_pkg.all;

entity WF2149IP_TOP is
	port(
		
		SYS_CLK		: in bit; -- Read the inforation in the header!
		RESETn   	: in bit;

		WAV_CLK		: in bit; -- Read the inforation in the header!
		SELn		: in bit;
		
		BDIR		: in bit;
		BC2, BC1	: in bit;

		A9n, A8		: in bit;
		DA			: inout std_logic_vector(7 downto 0);
		
		IO_A		: inout std_logic_vector(7 downto 0);
		IO_B		: inout std_logic_vector(7 downto 0);
		
		OUT_A		: out bit; -- Analog (PWM) outputs.
		OUT_B		: out bit;
		OUT_C		: out bit
	);
end WF2149IP_TOP;

architecture STRUCTURE of WF2149IP_TOP is
component WF2149IP_TOP_SOC
	port(
		SYS_CLK		: in bit;
		RESETn   	: in bit;
		WAV_CLK		: in bit;
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
		OUT_A		: out bit;
		OUT_B		: out bit;
		OUT_C		: out bit
	);
end component;
--
signal DA_OUT       : std_logic_vector(7 downto 0);
signal DA_EN        : bit;
signal IO_A_IN      : bit_vector(7 downto 0);
signal IO_A_OUT     : bit_vector(7 downto 0);
signal IO_A_EN      : bit;
signal IO_B_IN      : bit_vector(7 downto 0);
signal IO_B_OUT     : bit_vector(7 downto 0);
signal IO_B_EN      : bit;
begin
    IO_A_IN <= To_BitVector(IO_A);
    IO_B_IN <= To_BitVector(IO_B);

    IO_A <= To_StdLogicVector(IO_A_OUT) when IO_A_EN = '1' else (others => 'Z');
    IO_B <= To_StdLogicVector(IO_B_OUT) when IO_B_EN = '1' else (others => 'Z');

    DA <= DA_OUT when DA_EN = '1' else (others => 'Z');

    I_SOUND: WF2149IP_TOP_SOC
        port map(SYS_CLK            => SYS_CLK,
                 RESETn             => RESETn,
                 WAV_CLK            => WAV_CLK,
                 SELn               => SELn,
                 BDIR               => BDIR,
                 BC2                => BC2,
                 BC1                => BC1,
                 A9n                => A9n,
                 A8                 => A8,
                 DA_IN              => DA,
                 DA_OUT             => DA_OUT,
                 DA_EN              => DA_EN,
                 IO_A_IN            => IO_A_IN,
                 IO_A_OUT           => IO_A_OUT,
                 IO_A_EN            => IO_A_EN,
                 IO_B_IN            => IO_B_IN,
                 IO_B_OUT           => IO_B_OUT,
                 IO_B_EN            => IO_B_EN,
                 OUT_A              => OUT_A,
                 OUT_B              => OUT_B,
                 OUT_C              => OUT_C
        );
end STRUCTURE;
