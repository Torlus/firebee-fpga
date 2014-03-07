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
---- This is the top level file.                                  ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- - Test of the FM portion of the code (if there is any need). ----
---- - Test of the read track command.                            ----
---- - Test of the read address command.                          ----
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
-- Revision 2006A  2006/06/03 WF
--   Initial Release: the MFM portion for HD and DD floppies is tested.
--   The FM mode (DDEn = '1') is not completely tested due to the lack 
--   of FM drives.
-- Revision 2K6B  2006/11/05 WF
--   Modified Source to compile with the Xilinx ISE.
--   Fixed the polarity of the precompensation flag.
--   The flag is no active '0'. Thanks to Jorma
--   Oksanen for the information.
-- Revision 2K7B  2006/12/29 WF
--   Introduced several improvements based on a very good examination
--   of the pll code by Jean Louis-Guerin.
-- Revision 2K8B  2008/12/24 WF
--   Rewritten this top level file as a wrapper for the top_soc file.

library work;
use work.WF1772IP_PKG.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF1772IP_TOP is
	port (
		CLK			: in bit; -- 16MHz clock!
		MRn			: in bit;
		CSn			: in bit;
		RWn			: in bit;
		A1, A0		: in bit;
		DATA		: inout std_logic_vector(7 downto 0);
		RDn			: in bit;
		TR00n		: in bit;
		IPn			: in bit;
		WPRTn		: in bit;
		DDEn		: in bit;
		HDTYPE		: in bit; -- '0' = DD disks, '1' = HD disks.
		MO			: out bit;
		WG			: out bit;
		WD			: out bit;
		STEP		: out bit;
		DIRC		: out bit;
		DRQ			: out bit;
		INTRQ		: out bit
	);
end entity WF1772IP_TOP;
	
architecture STRUCTURE of WF1772IP_TOP is
component WF1772IP_TOP_SOC
	port (
		CLK			: in bit;
		RESETn		: in bit;
		CSn			: in bit;
		RWn			: in bit;
		A1, A0		: in bit;
		DATA_IN		: in std_logic_vector(7 downto 0);
		DATA_OUT	: out std_logic_vector(7 downto 0);
		DATA_EN		: out bit;
		RDn			: in bit;
		TR00n		: in bit;
		IPn			: in bit;
		WPRTn		: in bit;
		DDEn		: in bit;
		HDTYPE		: in bit;
		MO			: out bit;
		WG			: out bit;
		WD			: out bit;
		STEP		: out bit;
		DIRC		: out bit;
		DRQ			: out bit;
		INTRQ		: out bit
	);
end component;
signal DATA_OUT : std_logic_vector(7 downto 0);
signal DATA_EN  : bit;
begin
    DATA <= DATA_OUT when DATA_EN = '1' else (others => 'Z');

    I_1772: WF1772IP_TOP_SOC
        port map(
            CLK         => CLK,
            RESETn      => MRn,
            CSn         => CSn,
            RWn         => RWn,
            A1          => A1,
            A0          => A0,
            DATA_IN     => DATA,
            DATA_OUT    => DATA_OUT,
            DATA_EN     => DATA_EN,
            RDn         => RDn,
            TR00n       => TR00n,
            IPn         => IPn,
            WPRTn       => WPRTn,
            DDEn        => DDEn,
            HDTYPE      => HDTYPE,
            MO          => MO,
            WG          => WG,
            WD          => WD,
            STEP        => STEP,
            DIRC        => DIRC,
            DRQ         => DRQ,
            INTRQ       => INTRQ
        );
end architecture STRUCTURE;