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
---- This is the SUSKA MFP IP core USART top level file.          ----
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

use work.wf68901ip_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF68901IP_USART_TOP is
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

			-- Serial I/O control:
			RC			: in bit; -- Receiver clock.
			TC			: in bit; -- Transmitter clock.
			SI			: in bit; -- Serial input.
			SO			: out bit; -- Serial output.
			SO_EN		: out bit; -- Serial output enable.
			
			-- Interrupt channels:
			RX_ERR_INT	: out bit; -- Receiver errors.
			RX_BUFF_INT	: out bit; -- Receiver buffer full.
			TX_ERR_INT	: out bit; -- Transmitter errors.
			TX_BUFF_INT	: out bit; -- Transmitter buffer empty.

			-- DMA control:
			RRn			: out bit;
			TRn			: out bit			
	);
end entity WF68901IP_USART_TOP;

architecture STRUCTURE of WF68901IP_USART_TOP is
	signal BF_I				: bit;
	signal BE_I				: bit;
	signal FE_I				: bit;
	signal OE_I				: bit;
	signal UE_I				: bit;
	signal PE_I				: bit;
	signal LOOPBACK_I		: bit;
	signal SD_LEVEL_I		: bit;
	signal SDATA_IN_I		: bit;
	signal SDATA_OUT_I		: bit;
	signal RXCLK_I			: bit;
	signal CLK_MODE_I		: bit;
	signal SCR_I			: bit_vector(7 downto 0);
	signal RX_SAMPLE_I		: bit;
	signal RX_DATA_I		: bit_vector(7 downto 0);
	signal TX_DATA_I		: bit_vector(7 downto 0);
	signal CL_I				: bit_vector(1 downto 0);
	signal ST_I				: bit_vector(1 downto 0);
	signal P_ENA_I			: bit;
	signal P_EOn_I			: bit;
	signal RE_I				: bit;
	signal TE_I				: bit;
	signal FS_CLR_I			: bit;
	signal SS_I				: bit;
	signal M_CIP_I			: bit;
	signal FS_B_I			: bit;
	signal BR_I				: bit;
	signal UDR_READ_I		: bit;
	signal UDR_WRITE_I		: bit;
	signal RSR_READ_I		: bit;
	signal TSR_READ_I		: bit;
	signal TX_END_I			: bit;
begin
	SO <= SDATA_OUT_I when TE_I = '1' else SD_LEVEL_I;
	-- Loopback mode:
	SDATA_IN_I 	<= 	SDATA_OUT_I when LOOPBACK_I = '1' and TE_I = '1' else 	  -- Loopback, transmitter enabled.
					'1' 		when LOOPBACK_I = '1' and TE_I = '0' else SI; -- Loopback, transmitter disabled.

	RXCLK_I 	<= 	TC when LOOPBACK_I = '1' else RC;
	RRn <= '0' when BF_I = '1' and PE_I = '0' and FE_I = '0' else '1';
	TRn <= not BE_I;

	-- Interrupt sources:
	RX_ERR_INT 	<= OE_I or PE_I or FE_I or FS_B_I;
	RX_BUFF_INT	<= BF_I;
	TX_ERR_INT 	<= UE_I or TX_END_I;
	TX_BUFF_INT <= BE_I;

	I_USART_CTRL: WF68901IP_USART_CTRL
	port map(
			CLK				=> CLK,
	        RESETn			=> RESETn,
			DSn				=> DSn,
			CSn				=> CSn,
	        RWn     		=> RWn,
	        RS				=> RS,
			DATA_IN			=> DATA_IN,
			DATA_OUT		=> DATA_OUT,
			DATA_OUT_EN		=> DATA_OUT_EN,
			LOOPBACK		=> LOOPBACK_I,
			SDOUT_EN		=> SO_EN,
			SD_LEVEL		=> SD_LEVEL_I,
			CLK_MODE		=> CLK_MODE_I,
			RE				=> RE_I,
			TE				=> TE_I,
			P_ENA			=> P_ENA_I,
			P_EOn			=> P_EOn_I,
			BF				=> BF_I,
			BE				=> BE_I,
			FE				=> FE_I,
			OE				=> OE_I,
			UE				=> UE_I,
			PE				=> PE_I,
			M_CIP			=> M_CIP_I,	
			FS_B			=> FS_B_I,
			SCR_OUT			=> SCR_I,
			TX_DATA			=> TX_DATA_I,
			RX_SAMPLE		=> RX_SAMPLE_I,
			RX_DATA			=> RX_DATA_I,
			SS				=> SS_I,
			BR				=> BR_I,
			CL				=> CL_I,
			ST				=> ST_I,
			FS_CLR			=> FS_CLR_I,
			UDR_READ		=> UDR_READ_I,
			UDR_WRITE		=> UDR_WRITE_I,
			RSR_READ		=> RSR_READ_I,
			TSR_READ		=> TSR_READ_I,
			TX_END			=> TX_END_I
	);                                              

	I_USART_RECEIVE: WF68901IP_USART_RX
	port map (
			CLK				=> CLK,
	        RESETn			=> RESETn,
			SCR				=> SCR_I,
			RX_SAMPLE		=> RX_SAMPLE_I,
			RX_DATA			=> RX_DATA_I,
			CL				=> CL_I,
			ST				=> ST_I,
			P_ENA			=> P_ENA_I,
			P_EOn			=> P_EOn_I,
			CLK_MODE		=> CLK_MODE_I,
			RE				=> RE_I,
			FS_CLR			=> FS_CLR_I,
			SS				=> SS_I,
			RXCLK			=> RXCLK_I,
			SDATA_IN		=> SDATA_IN_I,
			RSR_READ		=> RSR_READ_I,
			UDR_READ		=> UDR_READ_I,
			M_CIP			=> M_CIP_I,	
			FS_B			=> FS_B_I,
			BF				=> BF_I,
			OE				=> OE_I,
			PE				=> PE_I,
			FE				=> FE_I
	);                                              

	I_USART_TRANSMIT: WF68901IP_USART_TX
	port map (
			CLK				=> CLK,
	        RESETn			=> RESETn,
			SCR				=> SCR_I,
			TX_DATA			=> TX_DATA_I,
	        SDATA_OUT		=> SDATA_OUT_I,
	        TXCLK			=> TC,
			CL				=> CL_I,
			ST				=> ST_I,
			TE				=> TE_I,
			BR				=> BR_I,
			P_ENA			=> P_ENA_I,
			P_EOn			=> P_EOn_I,
			UDR_WRITE		=> UDR_WRITE_I,
			TSR_READ		=> TSR_READ_I,
			CLK_MODE		=> CLK_MODE_I,
			TX_END			=> TX_END_I,
			UE				=> UE_I,
			BE				=> BE_I
	);                  
end architecture STRUCTURE;
