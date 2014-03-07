----------------------------------------------------------------------
----                                                              ----
---- 6850 compatible IP Core    					              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- UART 6850 compatible IP core                                 ----
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
-- Revision 2K9A  2009/06/20 WF
--   CTRL_REG has now synchronous reset to meet preset requirements.
--   Process P_DCD has now synchronous reset to meet preset requirements.
--   IRQ_In has now synchronous reset to meet preset requirement.
-- Revision 2K9B  2009/12/24 WF
--   Fixed the interrupt logic.
--   Introduced a minor RTSn correction.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF6850IP_CTRL_STATUS is
  port (
		CLK			: in bit;
        RESETn		: in bit;

        CS			: in bit_vector(2 downto 0); -- Active if "011".
        E			: in bit;   
        RWn     	: in bit;
        RS			: in bit;

        DATA_IN		: in bit_vector(7 downto 0);   
        DATA_OUT	: out bit_vector(7 downto 0);   
		DATA_EN		: out bit;
		
		-- Status register stuff:
		RDRF		: in bit;	-- Receive data register full.
		TDRE		: in bit;	-- Transmit data register empty.
		DCDn		: in bit;	-- Data carrier detect.
		CTSn		: in bit;	-- Clear to send.
		FE			: in bit;	-- Framing error.
		OVR			: in bit;	-- Overrun error.
		PE			: in bit;	-- Parity error.

		-- Control register stuff:
		MCLR		: buffer bit; -- Master clear (high active).
		RTSn		: out bit; -- Request to send.
		CDS			: out bit_vector(1 downto 0); -- Clock control.
		WS			: out bit_vector(2 downto 0); -- Word select.
		TC			: out bit_vector(1 downto 0); -- Transmit control.
		IRQn		: out bit -- Interrupt request.
       );                                              
end entity WF6850IP_CTRL_STATUS;

architecture BEHAVIOR of WF6850IP_CTRL_STATUS is
signal CTRL_REG		: bit_vector(7 downto 0);
signal STATUS_REG	: bit_vector(7 downto 0);
signal RIE			: bit;
signal IRQ_I		: bit;
signal CTS_In		: bit;
signal DCD_In		: bit;
signal DCD_FLAGn	: bit;
begin
	P_SAMPLE: process
	begin
		wait until CLK = '0' and CLK' event;
		CTS_In <= CTSn; -- Sample CTSn on the negative clock edge.
		DCD_In <= DCDn; -- Sample DCDn on the negative clock edge.
	end process P_SAMPLE;

	STATUS_REG(7) <= IRQ_I;
	STATUS_REG(6) <= PE;
	STATUS_REG(5) <= OVR;
	STATUS_REG(4) <= FE;
	STATUS_REG(3) <= CTS_In; -- Reflexion of the input pin.
	STATUS_REG(2) <= DCD_FLAGn;
	STATUS_REG(1) <= TDRE and not CTS_In; -- No TDRE for CTSn = '1'.
	STATUS_REG(0) <= RDRF and not DCD_In; -- DCDn = '1' indicates empty.

	DATA_OUT <= STATUS_REG when CS = "011" and RWn = '1' and RS = '0' and E = '1' else (others => '0');
	DATA_EN <= '1' when CS = "011" and RWn = '1' and RS = '0' and E = '1' else '0';
	
	MCLR <= '1' when CTRL_REG(1 downto 0) = "11" else '0';
	RTSn <= '0' when CTRL_REG(6 downto 5) /= "10" else '1';

	CDS <= CTRL_REG(1 downto 0);
	WS <= CTRL_REG(4 downto 2);
	TC <= CTRL_REG(6 downto 5);
	RIE <= CTRL_REG(7);
	
	P_IRQ: process
	variable DCD_OVR_LOCK	: boolean;
	variable DCD_LOCK	    : boolean;
	variable DCD_TRANS	    : boolean;	
	begin
		wait until CLK = '1' and CLK' event;
		if RESETn = '0' then
			DCD_OVR_LOCK := false;
			IRQn <= '1';
			IRQ_I <= '0';
		elsif CS = "011" and RWn = '1' and RS = '0' and E = '1' then
			DCD_OVR_LOCK := false; -- Enable reset by reading the status.
		end if;

        -- Clear interrupts when disabled.
        if CTRL_REG(7) = '0' then
            IRQn <= '1';
            IRQ_I <= '0';
        elsif CTRL_REG(6 downto 5) /= "01" then
            IRQn <= '1';
            IRQ_I <= '0';
        end if;

		-- Transmitter interrupt:
        if TDRE = '1' and CTRL_REG(6 downto 5) = "01" and CTS_In = '0' then
			IRQn <= '0';
			IRQ_I <= '1';
		elsif  CS = "011" and RWn = '0' and RS = '1' and E = '1' then
			IRQn <= '1'; -- Clear by writing to the transmit data register.
		end if;
					
		-- Receiver interrupts:
		if RDRF = '1' and RIE = '1' and DCD_In = '0' then
			IRQn <= '0';
			IRQ_I <= '1';
		elsif CS = "011" and RWn = '1' and RS = '1' and E = '1' then
			IRQn <= '1'; -- Clear by reading the receive data register.
		end if;

		if OVR = '1' and RIE = '1' then
			IRQn <= '0';
			IRQ_I <= '1';
			DCD_OVR_LOCK := true;
		elsif CS = "011" and RWn = '1' and RS = '1' and E = '1'  and DCD_OVR_LOCK = false then
			IRQn <= '1'; -- Clear by reading the receive data register after the status.
		end if;
					
		if DCD_In = '1' and RIE = '1' and DCD_TRANS = false then
			IRQn <= '0';
			IRQ_I <= '1';
			-- DCD_TRANS is used to detect a low to high transition of DCDn.
			DCD_TRANS := true;
			DCD_OVR_LOCK := true;
		elsif CS = "011" and RWn = '1' and RS = '1' and E = '1'  and DCD_OVR_LOCK = false then
			IRQn <= '1'; -- Clear by reading the receive data register after the status.
		elsif DCD_In = '0' then
			DCD_TRANS := false;
		end if;

		-- The reset of the IRQ status flag:
		-- Clear by writing to the transmit data register.
		-- Clear by reading the receive data register.
		if  CS = "011" and RS = '1' and E = '1' then
			IRQ_I <= '0'; 
		end if;
	end process P_IRQ;
	
	CONTROL: process
	begin
		wait until CLK = '1' and CLK' event;
		if RESETn = '0' then
			CTRL_REG <= "01000000";
		elsif CS = "011" and RWn = '0' and RS = '0' and E = '1' then
			CTRL_REG <= DATA_IN;
		end if;
	end process CONTROL;	

	P_DCD: process
	-- This process is some kind of tricky. Refer to the MC6850 data
	-- sheet for more information.
	variable READ_LOCK		: boolean;
	variable DCD_RELEASE	: boolean;
	begin
		wait until CLK = '1' and CLK' event;
		if RESETn = '0' then
			DCD_FLAGn <= '0'; -- This interrupt source must initialise low.
			READ_LOCK := true;
			DCD_RELEASE := false;
		elsif MCLR = '1' then
			DCD_FLAGn <= DCD_In;
			READ_LOCK := true;
		elsif DCD_In = '1' then
			DCD_FLAGn <= '1';
		elsif CS = "011" and RWn = '1' and RS = '0' and E = '1' then
			READ_LOCK := false;	-- Un-READ_LOCK if receiver data register is read. 
		elsif CS = "011" and RWn = '1' and RS = '1' and E = '1' and READ_LOCK = false then
			-- Clear if receiver status register read access.
			-- After data register has ben read and READ_LOCK again.
			DCD_RELEASE := true;
			READ_LOCK := true;
			DCD_FLAGn <= DCD_In;
		elsif DCD_In = '0' and DCD_RELEASE = true then
			DCD_FLAGn <= '0';
			DCD_RELEASE := false;
		end if;
	end process P_DCD;	
end architecture BEHAVIOR;

