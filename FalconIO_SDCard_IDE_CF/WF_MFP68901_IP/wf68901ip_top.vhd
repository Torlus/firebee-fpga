----------------------------------------------------------------------
----                                                              ----
---- ATARI MFP compatible IP Core					              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- MC68901 compatible multi function port core.                 ----
----                                                              ----
---- This is the SUSKA MFP IP core top level file.                ----
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
-- Revision 2K7A	2006/12/28 WF
--   The timer is modified to work on the CLK instead
--   of XTAL1. This modification is done to provide
--   a synchronous design.
-- Revision 2K8B  2008/12/24 WF
--   Rewritten this top level file as a wrapper for the top_soc file.
--

use work.wf68901ip_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF68901IP_TOP is
	port (  -- System control:
			CLK			: in bit;
			RESETn		: in bit;
			
			-- Asynchronous bus control:
			DSn			: in bit;
			CSn			: in bit;
			RWn			: in bit;
			DTACKn		: out std_logic;
			
			-- Data and Adresses:
			RS			: in bit_vector(5 downto 1);
			DATA		: inout std_logic_vector(7 downto 0);
			GPIP		: inout std_logic_vector(7 downto 0);
			
			-- Interrupt control:
			IACKn		: in bit;
			IEIn		: in bit;
			IEOn		: out bit;
			IRQn		: out std_logic;
			
			-- Timers and timer control:
			XTAL1		: in bit; -- Use an oszillator instead of a quartz.
			TAI			: in bit;
			TBI			: in bit;
			TAO			: out bit;			
			TBO			: out bit;			
			TCO			: out bit;			
			TDO			: out bit;			
			
			-- Serial I/O control:
			RC			: in bit;
			TC			: in bit;
			SI			: in bit;
			SO			: out std_logic;
			
			-- DMA control:
			RRn			: out bit;
			TRn			: out bit			
	);
end entity WF68901IP_TOP;

architecture STRUCTURE of WF68901IP_TOP is
component WF68901IP_TOP_SOC
	port(CLK			: in bit;
         RESETn		    : in bit;
         DSn			: in bit;
         CSn			: in bit;
         RWn			: in bit;
         DTACKn		    : out bit;
         RS			    : in bit_vector(5 downto 1);
         DATA_IN		: in std_logic_vector(7 downto 0);
         DATA_OUT	    : out std_logic_vector(7 downto 0);
         DATA_EN		: out bit;
         GPIP_IN		: in bit_vector(7 downto 0);
         GPIP_OUT	    : out bit_vector(7 downto 0);
         GPIP_EN		: out bit_vector(7 downto 0);
         IACKn		    : in bit;
         IEIn		    : in bit;
         IEOn		    : out bit;
         IRQn		    : out bit;
         XTAL1		    : in bit;
         TAI			: in bit;
         TBI			: in bit;
         TAO			: out bit;			
         TBO			: out bit;			
         TCO			: out bit;			
         TDO			: out bit;			
         RC			    : in bit;
         TC			    : in bit;
         SI			    : in bit;
         SO			    : out bit;
         SO_EN		    : out bit;
         RRn			: out bit;
         TRn			: out bit			
	);
end component;
--
signal DTACK_In         : bit;
signal IRQ_In           : bit;
signal DATA_OUT         : std_logic_vector(7 downto 0);
signal DATA_EN          : bit;
signal GPIP_IN          : bit_vector(7 downto 0);
signal GPIP_OUT         : bit_vector(7 downto 0);
signal GPIP_EN          : bit_vector(7 downto 0);
signal SO_I             : bit;
signal SO_EN            : bit;
begin
    DTACKn <= '0' when DTACK_In = '0' else 'Z'; -- Open drain.
    IRQn <= '0' when IRQ_In = '0' else 'Z'; -- Open drain.

    DATA <= DATA_OUT when DATA_EN = '1' else (others => 'Z');

    GPIP_IN <= To_BitVector(GPIP);

	P_GPIP_OUT: process(GPIP_OUT, GPIP_EN)
	begin
		for i in 7 downto 0 loop
			if GPIP_EN(i) = '1' then
				case GPIP_OUT(i) is
					when '0' => GPIP(i) <= '0';
					when others => GPIP(i) <= '1';
				end case;
			else
				GPIP(i) <= 'Z';
			end if;
		end loop;
	end process P_GPIP_OUT;

    SO <= '0' when SO_I = '0' and SO_EN = '1' else
          '1' when SO_I = '1' and SO_EN = '1' else 'Z';

    I_MFP: WF68901IP_TOP_SOC
        port map(CLK            => CLK,
                 RESETn         => RESETn,
                 DSn            => DSn,
                 CSn            => CSn,
                 RWn            => RWn,
                 DTACKn         => DTACK_In,
                 RS             => RS,
                 DATA_IN        => DATA,
                 DATA_OUT       => DATA_OUT,
                 DATA_EN        => DATA_EN,
                 GPIP_IN        => GPIP_IN,
                 GPIP_OUT       => GPIP_OUT,
                 GPIP_EN        => GPIP_EN,
                 IACKn          => IACKn,
                 IEIn           => IEIn,
                 IEOn           => IEOn,
                 IRQn           => IRQ_In,
                 XTAL1          => XTAL1,
                 TAI            => TAI,
                 TBI            => TBI,
                 TAO            => TAO,
                 TBO            => TBO,
                 TCO            => TCO,
                 TDO            => TDO,
                 RC             => RC,
                 TC             => TC,
                 SI             => SI,
                 SO             => SO_I,
                 SO_EN          => SO_EN,
                 RRn            => RRn,
                 TRn            => TRn
        );
end architecture STRUCTURE;
