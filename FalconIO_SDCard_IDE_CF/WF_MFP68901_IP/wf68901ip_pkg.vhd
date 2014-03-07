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
---- This is the package file containing the component            ----
---- declarations.                                                ----
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

package WF68901IP_PKG is
component WF68901IP_USART_TOP
	port (  CLK			: in bit;
			RESETn		: in bit;
			DSn			: in bit;
			CSn			: in bit;
			RWn			: in bit;
			RS			: in bit_vector(5 downto 1);
			DATA_IN		: in bit_vector(7 downto 0);
			DATA_OUT	: out bit_vector(7 downto 0);
			DATA_OUT_EN	: out bit;
			RC			: in bit;
			TC			: in bit;
			SI			: in bit;
			SO			: out bit;
			SO_EN		: out bit;
			RX_ERR_INT	: out bit;
			RX_BUFF_INT	: out bit;
			TX_ERR_INT	: out bit;
			TX_BUFF_INT	: out bit;
			RRn			: out bit;
			TRn			: out bit			
	);
end component;

component WF68901IP_USART_CTRL
	port (
		CLK				: in bit;
        RESETn			: in bit;
        DSn				: in bit;
        CSn				: in bit;   
        RWn     		: in bit;
        RS				: in bit_vector(5 downto 1);
        DATA_IN			: in bit_vector(7 downto 0);   
        DATA_OUT		: out bit_vector(7 downto 0);   
		DATA_OUT_EN		: out bit;
		RX_SAMPLE		: in bit;
        RX_DATA			: in bit_vector(7 downto 0);   
        TX_DATA			: out bit_vector(7 downto 0);   
        SCR_OUT			: out bit_vector(7 downto 0);   
		BF				: in bit;
		BE				: in bit;
		FE				: in bit;
		OE				: in bit;
		UE				: in bit;
		PE				: in bit;
		M_CIP			: in bit;
		FS_B			: in bit;
		TX_END			: in bit;
		CL				: out bit_vector(1 downto 0);
		ST				: out bit_vector(1 downto 0);
		FS_CLR			: out bit;
		RSR_READ		: out bit;
		TSR_READ		: out bit;
		UDR_READ		: out bit;
		UDR_WRITE		: out bit;
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
end component;

component WF68901IP_USART_TX
	port (
		CLK			: in bit;
        RESETn		: in bit;
		SCR			: in bit_vector(7 downto 0);
		TX_DATA		: in bit_vector(7 downto 0);
        SDATA_OUT	: out bit;
        TXCLK		: in bit;
		CL			: in bit_vector(1 downto 0);
		ST			: in bit_vector(1 downto 0);
		TE			: in bit;
		BR			: in bit;
		P_ENA		: in bit;
		P_EOn		: in bit;
		UDR_WRITE	: in bit;
		TSR_READ	: in bit;
		CLK_MODE	: in bit;
		TX_END		: out bit;
		UE			: out bit;
		BE			: out bit
	);                                              
end component;

component WF68901IP_USART_RX
	port (
		CLK			: in bit;
        RESETn		: in bit;
		SCR			: in bit_vector(7 downto 0);
		RX_SAMPLE	: out bit;
        RX_DATA	  	: out bit_vector(7 downto 0);   
        RXCLK		: in bit;
        SDATA_IN	: in bit;
		CL			: in bit_vector(1 downto 0);
		ST			: in bit_vector(1 downto 0);
		P_ENA		: in bit;
		P_EOn		: in bit;
		CLK_MODE	: in bit;
		RE			: in bit;
		FS_CLR		: in bit;
		SS			: in bit;
		RSR_READ	: in bit;
		UDR_READ	: in bit;
		M_CIP		: out bit;
		FS_B		: out bit;
		BF			: out bit;
		OE			: out bit;
		PE			: out bit;
		FE			: out bit
	);                                              
end component;

component WF68901IP_INTERRUPTS
	port ( 	
		CLK			: in bit;
		RESETn		: in bit;
		DSn			: in bit;
		CSn			: in bit;
		RWn			: in bit;
		RS			: in bit_vector(5 downto 1);
		DATA_IN		: in bit_vector(7 downto 0);
		DATA_OUT	: out bit_vector(7 downto 0);
		DATA_OUT_EN	: out bit;
		IACKn		: in bit;
		IEIn		: in bit;
		IEOn		: out bit;
		IRQn		: out bit;
		GP_INT		: in bit_vector(7 downto 0);
		AER_4		: in bit;
		AER_3		: in bit;
		TAI			: in bit;
		TBI			: in bit;
		TA_PWM		: in bit;
		TB_PWM		: in bit;
		TIMER_A_INT	: in bit;
		TIMER_B_INT	: in bit;
		TIMER_C_INT	: in bit;
		TIMER_D_INT	: in bit;
		RCV_ERR		: in bit;
		TRM_ERR		: in bit;
		RCV_BUF_F	: in bit;
		TRM_BUF_E	: in bit
	);
end component;

component WF68901IP_GPIO
	port (  
		CLK			: in bit;
		RESETn		: in bit;
		DSn			: in bit;
		CSn			: in bit;
		RWn			: in bit;
		RS			: in bit_vector(5 downto 1);
		DATA_IN		: in bit_vector(7 downto 0);
		DATA_OUT	: out bit_vector(7 downto 0);
		DATA_OUT_EN	: out bit;
		AER_4		: out bit;
		AER_3		: out bit;
		GPIP_IN		: in bit_vector(7 downto 0);
		GPIP_OUT	: out bit_vector(7 downto 0);
		GPIP_OUT_EN	: out bit_vector(7 downto 0);
		GP_INT		: out bit_vector(7 downto 0)
	);
end component;

component WF68901IP_TIMERS
	port (  
		CLK			: in bit;
		RESETn		: in bit;
		DSn			: in bit;
		CSn			: in bit;
		RWn			: in bit;
		RS			: in bit_vector(5 downto 1);
		DATA_IN		: in bit_vector(7 downto 0);
		DATA_OUT	: out bit_vector(7 downto 0);
		DATA_OUT_EN	: out bit;
		XTAL1		: in bit;
		TAI			: in bit;
		TBI			: in bit;
		AER_4		: in bit;
		AER_3		: in bit;
		TA_PWM		: out bit;
		TB_PWM		: out bit;
		TAO			: out bit;			
		TBO			: out bit;			
		TCO			: out bit;			
		TDO			: out bit;
		TIMER_A_INT	: out bit;
		TIMER_B_INT	: out bit;
		TIMER_C_INT	: out bit;
		TIMER_D_INT	: out bit
	);
end component;

end WF68901IP_PKG;
