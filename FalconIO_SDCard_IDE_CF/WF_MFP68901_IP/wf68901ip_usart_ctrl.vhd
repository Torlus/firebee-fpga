----------------------------------------------------------------------
----                                                              ----
---- ATARI MFP compatible IP Core					              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- This is the SUSKA MFP IP core USART control file.            ----
----                                                              ----
---- Control unit and status logic.                               ----
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

entity WF68901IP_USART_CTRL is
	port (
		-- System Control:
		CLK				: in bit;
        RESETn			: in bit;

		-- Bus control:
        DSn				: in bit;
        CSn				: in bit;   
        RWn     		: in bit;
        RS				: in bit_vector(5 downto 1);
        DATA_IN			: in bit_vector(7 downto 0);   
        DATA_OUT		: out bit_vector(7 downto 0);   
		DATA_OUT_EN		: out bit;

		-- USART data register
		RX_SAMPLE		: in bit;
        RX_DATA			: in bit_vector(7 downto 0);
        TX_DATA			: out bit_vector(7 downto 0);   
        SCR_OUT			: out bit_vector(7 downto 0);   

		-- USART control inputs:
		BF				: in bit;
		BE				: in bit;
		FE				: in bit;
		OE				: in bit;
		UE				: in bit;
		PE				: in bit;
		M_CIP			: in bit;
		FS_B			: in bit;
		TX_END			: in bit;

		-- USART control outputs:
		CL				: out bit_vector(1 downto 0);
		ST				: out bit_vector(1 downto 0);
		FS_CLR			: out bit;
		UDR_WRITE		: out bit;
		UDR_READ		: out bit;
		RSR_READ		: out bit;
		TSR_READ		: out bit;
		LOOPBACK		: out bit;
		SDOUT_EN		: out bit;
		SD_LEVEL		: out bit;
		CLK_MODE		: out bit;
		RE				: out bit;
		TE				: out bit;
		P_ENA			: out bit;
		P_EOn			: out bit;
		SS				: out bit;
		BR				: out bit
       );                                              
end entity WF68901IP_USART_CTRL;

architecture BEHAVIOR of WF68901IP_USART_CTRL is
signal SCR	: bit_vector(7 downto 0); -- Synchronous data register.
signal UCR	: bit_vector(7 downto 1); -- USART control register.
signal RSR	: bit_vector(7 downto 0); -- Receiver status register.
signal TSR	: bit_vector(7 downto 0); -- Transmitter status register.
signal UDR	: bit_vector(7 downto 0); -- USART data register.
begin
	USART_REGISTERS: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			SCR <= (others => '0');
			UCR <= (others => '0');
			RSR <= (others => '0');
			-- TSR and UDR are not cleared during an asserted RESETn
		elsif CLK = '1' and CLK' event then
			-- Loading via receiver shift register
			-- has priority over data buss access:
			if RX_SAMPLE = '1' then
				UDR <= RX_DATA;
			elsif 	CSn = '0' and DSn = '0' and RWn = '0' then
				case RS is
					when "10011"	=> SCR <= DATA_IN;
					when "10100"	=> UCR <= DATA_IN(7 downto 1);
					when "10101"	=> RSR(1 downto 0) <= DATA_IN(1 downto 0); -- Only the two LSB are read/write.
					when "10110"	=> TSR(5) <= DATA_IN(5); TSR(3 downto 0) <= DATA_IN(3 downto 0);
					when "10111"	=> UDR <= DATA_IN;
					when others		=> null;
				end case;
			end if;
			RSR(7 downto 2) <= BF & OE & PE & FE & FS_B & M_CIP;
			TSR(7 downto 6) <= BE & UE;
			TSR(4) <= TX_END;
			TX_DATA <= UDR;		
		end if;
	end process USART_REGISTERS;
	DATA_OUT_EN <= '1' when CSn = '0' and DSn = '0' and RWn = '1' and RS >= "10011" and RS <= "10111" else '0';
	DATA_OUT <= SCR when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10011" else
				UCR & '0' when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10100" else
				RSR when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10101" else
				TSR when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10110" else
				UDR when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10111" else x"00";

	UDR_WRITE 	<= '1' when CSn = '0' and DSn = '0' and RWn = '0' and RS = "10111" else '0';
	UDR_READ 	<= '1' when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10111" else '0';
	RSR_READ 	<= '1' when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10101" else '0';
	TSR_READ 	<= '1' when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10110" else '0';
	FS_CLR		<= '1' when CSn = '0' and DSn = '0' and RWn = '0' and RS = "10011" else '0';

	RE <= '1' when RSR(0) = '1' else -- Receiver enable.
		  '1' when TSR(5) = '1' and TX_END = '1' else '0'; -- Auto Turnaround.
	SS <= RSR(1); -- Synchronous strip enable.
	BR <= TSR(3); -- Send break.
	TE <= TSR(0); -- Transmitter enable.

	SCR_OUT <= SCR;

	CLK_MODE <= UCR(7); -- Clock mode.
	CL <= UCR(6 downto 5); -- Character length.
	ST <= UCR(4 downto 3); -- Start/Stop configuration.
	P_ENA <= UCR(2); -- Parity enable.
	P_EOn <= UCR(1); -- Even or odd parity.
	
	SOUT_CONFIG: process
	begin
		wait until CLK = '1' and CLK' event;
		-- Do not change the output configuration until the transmitter is disabled and
		-- current character has been transmitted (TX_END = '1').
		if TX_END = '1' then
			case TSR(2 downto 1) is
				when "00" => LOOPBACK <= '0'; SD_LEVEL <= '0'; SDOUT_EN <= '0';
				when "01" => LOOPBACK <= '0'; SD_LEVEL <= '0'; SDOUT_EN <= '1';
				when "10" => LOOPBACK <= '0'; SD_LEVEL <= '1'; SDOUT_EN <= '1';
				when "11" => LOOPBACK <= '1'; SD_LEVEL <= '1'; SDOUT_EN <= '1';
			end case;			
		end if;
	end process SOUT_CONFIG;
end architecture BEHAVIOR;

