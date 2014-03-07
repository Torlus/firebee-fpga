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
-- Revision 2K9B  2009/12/24 WF
--   Fixed the interrupt logic.
--   Introduced a minor RTSn correction.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF6850IP_TOP_SOC is
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
end entity WF6850IP_TOP_SOC;

architecture STRUCTURE of WF6850IP_TOP_SOC is
component WF6850IP_CTRL_STATUS
	port (
		CLK			: in bit;
        RESETn		: in bit;
        CS			: in bit_vector(2 downto 0);
        E			: in bit;   
        RWn     	: in bit;
        RS			: in bit;
        DATA_IN		: in bit_vector(7 downto 0);   
        DATA_OUT	: out bit_vector(7 downto 0);  
		DATA_EN		: out bit;
		RDRF		: in bit;
		TDRE		: in bit;
		DCDn		: in bit;
		CTSn		: in bit;
		FE			: in bit;
		OVR			: in bit;
		PE			: in bit;
		MCLR		: out bit;
		RTSn		: out bit;
		CDS			: out bit_vector(1 downto 0);
		WS			: out bit_vector(2 downto 0);
		TC			: out bit_vector(1 downto 0);
		IRQn		: out bit
       );                                              
end component;

component WF6850IP_RECEIVE
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
		RDRF				: out bit;
		OVR					: out bit;
		PE					: out bit;
		FE					: out bit
       );                                              
end component;

component WF6850IP_TRANSMIT
	port (
		CLK					: in bit;
        RESETn				: in bit;
		MCLR				: in bit;
        CS					: in bit_vector(2 downto 0);
        E		       		: in bit;   
        RWn              	: in bit;
        RS					: in bit;
        DATA_IN		        : in bit_vector(7 downto 0);   
		CTSn				: in bit;
		TC					: in bit_vector(1 downto 0);
		WS					: in bit_vector(2 downto 0);
		CDS					: in bit_vector(1 downto 0);
        TXCLK				: in bit;
		TDRE				: out bit;        
        TXDATA				: out bit
       );                                              
end component;
signal DATA_IN_I	: bit_vector(7 downto 0);
signal DATA_RX		: bit_vector(7 downto 0);
signal DATA_RX_EN	: bit;
signal DATA_CTRL	: bit_vector(7 downto 0);
signal DATA_CTRL_EN	: bit;
signal RDRF_I		: bit;
signal TDRE_I		: bit;
signal FE_I			: bit;
signal OVR_I		: bit;
signal PE_I			: bit;
signal MCLR_I		: bit;
signal CDS_I		: bit_vector(1 downto 0);
signal WS_I			: bit_vector(2 downto 0);
signal TC_I			: bit_vector(1 downto 0);
signal IRQ_In		: bit;
begin
	DATA_IN_I <= To_BitVector(DATA_IN);
	DATA_EN <= DATA_RX_EN or DATA_CTRL_EN;
	DATA_OUT <= To_StdLogicVector(DATA_RX) when DATA_RX_EN = '1' else
				To_StdLogicVector(DATA_CTRL) when DATA_CTRL_EN = '1' else (others => '0');
				
	IRQn <= '0' when IRQ_In = '0' else '1';

	I_UART_CTRL_STATUS: WF6850IP_CTRL_STATUS
	port map(
			CLK			=> CLK,
	        RESETn		=> RESETn,
	        CS(2)		=> CS2n,
	        CS(1)		=> CS1,
	        CS(0)		=> CS0,
	        E			=> E,
	        RWn     	=> RWn,
	        RS			=> RS,
	        DATA_IN		=> DATA_IN_I,
			DATA_OUT	=> DATA_CTRL,
			DATA_EN		=> DATA_CTRL_EN,
			RDRF		=> RDRF_I,
			TDRE		=> TDRE_I,
			DCDn		=> DCDn,
			CTSn		=> CTSn,
			FE			=> FE_I,
			OVR			=> OVR_I,
			PE			=> PE_I,
			MCLR		=> MCLR_I,
			RTSn		=> RTSn,
			CDS			=> CDS_I,
			WS			=> WS_I,
			TC			=> TC_I,
			IRQn		=> IRQ_In
	);                                              

	I_UART_RECEIVE: WF6850IP_RECEIVE
	port map (
			CLK			=> CLK,
	        RESETn		=> RESETn,
			MCLR		=> MCLR_I,
	        CS(2)		=> CS2n,
	        CS(1)		=> CS1,
	        CS(0)		=> CS0,
	        E			=> E,
	        RWn     	=> RWn,
	        RS			=> RS,
	        DATA_OUT	=> DATA_RX,
			DATA_EN		=> DATA_RX_EN,
			WS			=> WS_I,
			CDS			=> CDS_I,
			RXCLK		=> RXCLK,
			RXDATA		=> RXDATA,
			RDRF		=> RDRF_I,
			OVR			=> OVR_I,
			PE			=> PE_I,
			FE			=> FE_I
	);                                              

	I_UART_TRANSMIT: WF6850IP_TRANSMIT
	port map (
			CLK			=> CLK,
	        RESETn		=> RESETn,
			MCLR		=> MCLR_I,
	        CS(2)		=> CS2n,
	        CS(1)		=> CS1,
	        CS(0)		=> CS0,
	        E			=> E,
	        RWn     	=> RWn,
	        RS			=> RS,
	        DATA_IN		=> DATA_IN_I,
			CTSn		=> CTSn,
			TC			=> TC_I,
			WS			=> WS_I,
			CDS			=> CDS_I,
			TDRE		=> TDRE_I,
			TXCLK		=> TXCLK,
			TXDATA		=> TXDATA
	);
end architecture STRUCTURE;