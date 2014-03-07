----------------------------------------------------------------------
----                                                              ----
---- 6850 compatible IP Core     					              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- UART 6850 compatible IP core                                 ----
----                                                              ----
---- This is the top level file.                                  ----
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
use ieee.std_logic_unsigned.all;

entity WF6850IP_TOP is
  port (
		CLK					: in bit;
        RESETn				: in bit;

        CS2n, CS1, CS0		: in bit;
        E		       		: in bit;   
        RWn              	: in bit;
        RS					: in bit;

        DATA		        : inout std_logic_vector(7 downto 0);   

        TXCLK				: in bit;
        RXCLK				: in bit;
        RXDATA				: in bit;
        CTSn				: in bit;
        DCDn				: in bit;
        
        IRQn				: out std_logic;
        TXDATA				: out bit;   
        RTSn				: out bit
       );                                              
end entity WF6850IP_TOP;

architecture STRUCTURE of WF6850IP_TOP is
component WF6850IP_TOP_SOC
  port (
		CLK					: in bit;
        RESETn				: in bit;
        CS2n, CS1, CS0		: in bit;
        E		       		: in bit;   
        RWn              	: in bit;
        RS					: in bit;
        DATA_IN		        : in std_logic_vector(7 downto 0);   
        DATA_OUT	        : out std_logic_vector(7 downto 0);   
		DATA_EN				: out bit;
        TXCLK				: in bit;
        RXCLK				: in bit;
        RXDATA				: in bit;
        CTSn				: in bit;
        DCDn				: in bit;
        IRQn				: out bit;
        TXDATA				: out bit;   
        RTSn				: out bit
       );                                              
end component;
signal DATA_OUT     : std_logic_vector(7 downto 0);
signal DATA_EN      : bit;
signal IRQ_In       : bit;
begin
    DATA <= DATA_OUT when DATA_EN = '1' else (others => 'Z');
    IRQn <= '0' when IRQ_In = '0' else 'Z'; -- Open drain.

    I_UART: WF6850IP_TOP_SOC
      port map(CLK          => CLK,
               RESETn       => RESETn,
               CS2n         => CS2n,
               CS1          => CS1,
               CS0          => CS0,
               E            => E,
               RWn          => RWn,
               RS           => RS,
               DATA_IN      => DATA,
               DATA_OUT     => DATA_OUT,
               DATA_EN      => DATA_EN,
               TXCLK        => TXCLK,
               RXCLK        => RXCLK,
               RXDATA       => RXDATA,
               CTSn         => CTSn,
               DCDn         => DCDn,
               IRQn         => IRQ_In,
               TXDATA       => TXDATA,
               RTSn         => RTSn
           );                                              
end architecture STRUCTURE;