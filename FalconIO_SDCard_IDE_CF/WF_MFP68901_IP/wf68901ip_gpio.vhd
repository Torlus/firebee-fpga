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
---- This are the SUSKA MFP IP core's general purpose I/Os.       ----
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

entity WF68901IP_GPIO is
	port (  -- System control:
			CLK			: in bit;
			RESETn		: in bit;
			
			-- Asynchronous bus control:
			DSn			: in bit;
			CSn			: in bit;
			RWn			: in bit;
			
			-- Data and Adresses:
			RS			: in bit_vector(5 downto 1);
			DATA_IN		: in bit_vector(7 downto 0);
			DATA_OUT	: out bit_vector(7 downto 0);
			DATA_OUT_EN	: out bit;

			-- Timer controls:
			AER_4		: out bit;
			AER_3		: out bit;

			GPIP_IN		: in bit_vector(7 downto 0);
			GPIP_OUT	: out bit_vector(7 downto 0);
			GPIP_OUT_EN	: buffer bit_vector(7 downto 0);
			GP_INT		: out bit_vector(7 downto 0)
	);
end entity WF68901IP_GPIO;

architecture BEHAVIOR of WF68901IP_GPIO is
signal GPDR		: bit_vector(7 downto 0);
signal DDR		: bit_vector(7 downto 0);
signal AER		: bit_vector(7 downto 0);
signal GPDR_I	: bit_vector(7 downto 0);
begin
	-- These two bits control the timers A and B pulse width operation and the
	-- timers A and B event count operation.
	AER_4 <= AER(4);
	AER_3 <= AER(3);
	-- This statement provides 8 XOR units setting the desired interrupt polarity.
	-- While the level control is done here, the edge triggering is provided by
	-- the interrupt control hardware. The level control is individually for each
	-- GPIP port pin. The interrupt edge trigger unit must operate in any case on
	-- the low to high transistion of the respective port pin.
	GP_INT <= AER xnor GPIP_IN;
	
	GPIO_REGISTERS: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			GPDR <= (others => '0');
			DDR <= (others => '0');
			AER <= (others => '0');
		elsif CLK = '1' and CLK' event then
			if 	CSn = '0' and DSn = '0' and RWn = '0' then
				case RS is
					when "00000"	=> GPDR <= DATA_IN;
					when "00001"	=> AER <= DATA_IN;
					when "00010"	=> DDR <= DATA_IN;
					when others		=> null;
				end case;
			end if;
		end if;
	end process GPIO_REGISTERS;
	GPIP_OUT <= GPDR; -- Port outputs.
	GPIP_OUT_EN <= DDR; -- The DDR is capable to control bitwise the GPIP.
	DATA_OUT_EN <= '1' when CSn = '0' and DSn = '0' and RWn = '1' and RS <= "00010" else '0';
	DATA_OUT <= DDR when CSn = '0' and DSn = '0' and RWn = '1' and RS = "00010" else
				AER when CSn = '0' and DSn = '0' and RWn = '1' and RS = "00001" else
				GPDR_I when CSn = '0' and DSn = '0' and RWn = '1' and RS = "00000" else (others => '0');
	
	P_GPDR: process(GPIP_IN, GPIP_OUT_EN, GPDR)
	-- Read back control: Read the port pins, if the data direction is configured as input.
	-- Read the respective GPDR register bit, if the data direction is configured as output.
	begin
		for i in 7 downto 0 loop
			if GPIP_OUT_EN(i) = '1' then -- Port is configured output.
				GPDR_I(i) <= GPDR(i);
			else
				GPDR_I(i) <= GPIP_IN(i); -- Port is configured input.
			end if;
		end loop;
	end process P_GPDR;
end architecture BEHAVIOR;
