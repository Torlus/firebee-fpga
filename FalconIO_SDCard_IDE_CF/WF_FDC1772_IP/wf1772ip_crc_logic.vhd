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
---- The CRC cyclic redundancy checker unit. Further description  ----
---- see below.                                                   ----
----                                                              ----
---- Working principle of the CRC generator and verify unit:      ----
---- During read operation:                                       ----
---- The CRC generator is switched on via after the detection of  ----
---- the address ID of the data ID mark. The CRC generation last  ----
---- in case of the address ID until the lenght byte is read.     ----
---- In case of generation after the data address mark the CRC    ----
---- generator is activated until the last data byte is read.     ----
---- The number of data bytes to be read depends on the LENGHT    ----
---- information in the header file. After generation of the CRC  ----
---- the CRC_GEN is switched off and the VERIFY procedure begins  ----
---- by activating CRC_VERIFY. The previously generated CRC is    ----
---- then compared (serially) with the two consecutive read CRC   ----
---- bytes. The CRC error appeas, when the comparision fails.     ----
---- During write operation:                                      ----
---- The CRC generator is switched on via after the detection of  ----
---- the address ID of the data ID mark. The CRC generation last  ----
---- in case of the address ID until the lenght byte is read.     ----
---- In case of generation after the data address mark the CRC    ----
---- generator is activated until the last data byte is read.     ----
---- The number of data bytes to be read depends on the LENGHT    ----
---- information in the header file. After the generation of the  ----
---- two CRC bytes, the write out process begins by activating    ----
---- CRC_SHFTOUT. The CRC data appears in this case serially on   ----
---- the CRC_SDOUT.                                               ----
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
-- Revision 2K9A  2009/06/20 WF
--   CRC_SHIFT has now synchronous reset to meeet preset behaviour.
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF1772IP_CRC_LOGIC is
	port(
		-- System control
		CLK				: in bit;
		RESETn			: in bit;
		DISK_RWn		: in bit;

		-- Preset controls:
		DDEn		: in bit;
		ID_AM		: in bit;
		DATA_AM		: in Bit;
		DDATA_AM	: in Bit;
		
		-- CRC unit:
		SD			: in bit; -- Serial data input.
		CRC_STRB	: in bit; -- Data strobe.
		CRC_2_DISK	: in bit; -- Forces the unit to flush the CRC remainder.
		CRC_PRES	: in bit; -- Presets the CRC unit during write to disk.
		CRC_SDOUT	: out bit; -- Serial data output.
		CRC_ERR		: out bit -- Indicates CRC error.
	);
end WF1772IP_CRC_LOGIC;

architecture BEHAVIOR of WF1772IP_CRC_LOGIC is
signal CRC_SHIFT	: bit_vector(15 downto 0);
begin
	P_CRC: process
	-- The shift register is initialised with appropriate values in HD or DD mode.
	-- In theory the shift register should be preset to ones. Due to a latency of one byte 
	-- in FM mode or 4 bytes in MFM mode it is necessary to preset the shift register with 
	-- the CRC values of this ID address mark, data address mark and the A1 sync bytes. The 
	-- latency is caused by the addressmark detector which needs one or 4 byte time(s) for 
	-- detection. The CRC unit therefore starts with every detection of an address mark and
	-- ends if the CRC unit is flushed.
	begin 
		wait until CLK = '1' and CLK' event;
		if RESETn = '0' then
			CRC_SHIFT <= (others => '1');
		elsif CRC_2_DISK = '1' then
			if CRC_STRB = '1' then
				CRC_SHIFT <= CRC_SHIFT(14 downto 0) & '0';
			end if;
		elsif CRC_PRES = '1' then -- Preset during write sector or write track command.
			CRC_SHIFT <= x"FFFF";
		elsif DDEn = '1' and ID_AM = '1' then -- DD mode and ID address mark detected.
			CRC_SHIFT <= x"EF21"; -- The CRC-CCITT for data x"FE" is x"EF21"
		elsif DDEn = '1' and DATA_AM = '1' then -- DD mode and data address mark detected.
			CRC_SHIFT <= x"BF84"; -- The CRC-CCITT for data x"FB" is x"BF84"
		elsif DDEn = '1' and DDATA_AM = '1' then -- DD mode and deleted data address mark detected.
			CRC_SHIFT <= x"8FE7"; -- The CRC-CCITT for data x"F8" is x"8FE7"
		elsif DDEn = '0' and ID_AM = '1' then -- HD mode and ID address mark detected.
			CRC_SHIFT <= x"B230"; -- The CRC-CCITT for data x"A1A1A1FE" is x"B230"
		elsif DDEn = '0' and DATA_AM = '1' then -- HD mode and data address mark detected.
			CRC_SHIFT <= x"E295"; -- The CRC-CCITT for data x"A1A1A1FB" is x"E295"
		elsif DDEn = '0' and DDATA_AM = '1' then -- HD mode and deleted data address mark detected.
			CRC_SHIFT <= x"D2F6"; -- The CRC-CCITT for data x"A1A1A1F8" is x"D2F6"
		elsif CRC_STRB = '1' then
			-- CRC-CCITT (xFFFF):
			-- the polynomial is G(x) = x^16 + x^12 + x^5 + 1
			-- In this mode the CRC is encoded. In read from disk mode, the encoding works as CRC
			-- verification. In this operating condition the ID or the data field is compared 
			-- against the CRC checksum. if there are no errors, the shift register's value is 
			-- x"0000" after the last bit of the checksum is shifted in. In write to disk mode the
			-- CRC linear feedback shift register (lfsr) works to generate the CRC remainder of the
			-- ID or data field.
			CRC_SHIFT <= CRC_SHIFT(14 downto 12) & (CRC_SHIFT(15) xor CRC_SHIFT(11) xor SD) &
						 CRC_SHIFT(10 downto 5) & (CRC_SHIFT(15) xor CRC_SHIFT(4) xor SD) &
						 CRC_SHIFT(3 downto 0) & (CRC_SHIFT(15) xor SD);
		end if;
	end process P_CRC;

	CRC_SDOUT <= CRC_SHIFT(15);
    CRC_ERR <= '0' when CRC_SHIFT = x"0000" else '1';
end architecture BEHAVIOR;
