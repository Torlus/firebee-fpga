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
-- Revision 2006A  2006/06/03 WF
--   Initial Release.
-- Revision 2K6B  2006/11/05 WF
--   Modified Source to compile with the Xilinx ISE.
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
--   Removed CRC_BUSY.


library ieee;
use ieee.std_logic_1164.all;

package WF1772IP_PKG is
-- component declarations:
component WF1772IP_AM_DETECTOR
	port(
		CLK			: in bit;
		RESETn		: in bit;
		DDEn		: in bit;
		DATA		: in bit;
		DATA_STRB	: in bit;
		ID_AM		: out bit;
		DATA_AM		: out bit;
		DDATA_AM	: out bit
	);
end component;

component WF1772IP_CONTROL
	port(
		CLK				: in bit;
		RESETn			: in bit;
		A1, A0			: in bit;
		RWn				: in bit;
		CSn				: in bit;
		DDEn			: in bit;
		DR				: in bit_vector(7 downto 0);
		CMD				: in std_logic_vector(7 downto 0);
		DSR				: in std_logic_vector(7 downto 0);
		TR				: in std_logic_vector(7 downto 0);
		SR				: in std_logic_vector(7 downto 0);
		MO				: out bit;
		WR_PR			: out bit;
		SPINUP_RECTYPE	: out bit;
		SEEK_RNF		: out bit;
		CRC_ERRFLAG		: out bit;
		LOST_DATA_TR00	: out bit;
		DRQ				: out bit;
		DRQ_IPn			: out bit;
		BUSY			: out bit;
		AM_2_DISK		: out bit;
		ID_AM			: in bit;
		DATA_AM			: in bit;
		DDATA_AM		: in bit;
		CRC_ERR			: in bit;
		CRC_PRES		: out bit;
		TR_PRES			: out bit;
		TR_CLR			: out bit;
		TR_INC			: out bit;
		TR_DEC			: out bit;
		SR_LOAD			: out bit;
		SR_INC			: out bit;
		TRACK_NR		: out std_logic_vector(7 downto 0);
		DR_CLR			: out bit;
		DR_LOAD			: out bit;
		SHFT_LOAD_SD	: out bit;
		SHFT_LOAD_ND	: out bit;
		CRC_2_DISK		: out bit;
		DSR_2_DISK		: out bit;
		FF_2_DISK		: out bit;
		PRECOMP_EN		: out bit;
		DATA_STRB 		: in bit;
		DISK_RWn		: out bit;
		WPRTn			: in bit;
		TRACK00n		: in bit;
		IPn				: in bit;
		DIRC			: out bit;
		STEP			: out bit;
		WG				: out bit;
		INTRQ			: out bit
	);
end component;

component WF1772IP_CRC_LOGIC
	port(
		CLK			: in bit;
		RESETn		: in bit;
		DDEn		: in bit;
		DISK_RWn	: in bit;
		ID_AM		: in bit;
		DATA_AM		: in bit;
		DDATA_AM	: in bit;
		SD			: in bit;
		CRC_STRB	: in bit;
		CRC_2_DISK	: in bit;
		CRC_PRES	: in bit;
		CRC_SDOUT	: out bit;
		CRC_ERR		: out bit
	);
end component;

component WF1772IP_DIGITAL_PLL
	port(
		CLK			: in bit;
		RESETn		: in bit;
		DDEn		: in bit;
		HDTYPE		: in bit;
		DISK_RWn	: in bit;
		RDn			: in bit;
		PLL_D		: out bit;
		PLL_DSTRB	: out bit
	);
end component;

component WF1772IP_REGISTERS
	port(
		CLK				: in bit;
		RESETn			: in bit;
		CSn				: in bit;
		ADR				: in bit_vector(1 downto 0);
		RWn				: in bit;
		DATA_IN			: in std_logic_vector (7 downto 0);
		DATA_OUT		: out std_logic_vector (7 downto 0);
		DATA_EN			: out bit;
		CMD				: out std_logic_vector(7 downto 0);
		SR				: out std_logic_vector(7 downto 0);
		TR				: out std_logic_vector(7 downto 0);
		DSR				: out std_logic_vector(7 downto 0);
		DR				: out bit_vector(7 downto 0);
		SD_R			: in bit;
		DATA_STRB		: in bit;
		DR_CLR			: in bit;
		DR_LOAD			: in bit;
		TR_PRES			: in bit;
		TR_CLR			: in bit;
		TR_INC			: in bit;
		TR_DEC			: in bit;
		TRACK_NR 		: in std_logic_vector(7 downto 0);
		SR_LOAD			: in bit;
		SR_INC			: in bit;
		SHFT_LOAD_SD	: in bit;
		SHFT_LOAD_ND	: in bit;
		MOTOR_ON		: in bit;
		WRITE_PROTECT	: in bit;
		SPINUP_RECTYPE	: in bit;
		SEEK_RNF		: in bit;
		CRC_ERRFLAG		: in bit;
		LOST_DATA_TR00	: in bit;
		DRQ				: in bit;
		DRQ_IPn			: in bit;
		BUSY			: in bit;
		DDEn			: in bit
	);
end component;

component WF1772IP_TRANSCEIVER
	port(
		CLK				: in bit;
		RESETn			: in bit;
		DDEn			: in bit;
		HDTYPE			: in bit;
		ID_AM			: in bit;
		DATA_AM			: in bit;
		DDATA_AM		: in bit;
		SHFT_LOAD_SD	: in bit;
		DR				: in bit_vector(7 downto 0);
		PRECOMP_EN		: in bit;
		AM_TYPE			: in bit;
		AM_2_DISK		: in bit;
		CRC_2_DISK		: in bit;
		DSR_2_DISK		: in bit;
		FF_2_DISK		: in bit;
		SR_SDOUT		: in std_logic;
		CRC_SDOUT		: in bit;
		WRn				: out bit;
		PLL_DSTRB		: in bit;
		PLL_D			: in bit;
		WDATA 			: out bit;
		DATA_STRB 		: out bit;
		SD_R			: out bit
	);
end component;
end WF1772IP_PKG;
