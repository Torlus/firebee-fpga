----------------------------------------------------------------------
----                                                              ----
---- WF5380 IP Core                                               ----
----                                                              ----
---- Description:                                                 ----
---- This model provides an asynchronous SCSI interface compa-    ----
---- tible to the DP5380 from National Semiconductor and others.  ----
----                                                              ----
---- This file is the top level file with tree state buses.       ----
----                                                              ----
----                                                              ----
----                                                              ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Wolfgang Foerster                         ----
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
-- Revision 2K9A  2009/06/20 WF
--   Initial Release.
-- 

library work;
use work.wf5380_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF5380_TOP is
	port (
        -- System controls:
		CLK			: in bit;
		RESETn	    : in bit;
		
		-- Address and data:
		ADR			: in std_logic_vector(2 downto 0);
		DATA		: inout std_logic_vector(7 downto 0);

		-- Bus and DMA controls:
		CSn			: in bit;
		RDn		    : in bit;
		WRn	        : in bit;
		EOPn        : in bit;
		DACKn	    : in bit;
		DRQ		    : out bit;
		INT		    : out bit;
		READY       : out bit;
		
		-- SCSI bus:
		DBn		    : inout std_logic_vector(7 downto 0);
		DBPn        : inout std_logic;
		RSTn        : inout std_logic;
		BSYn        : inout std_logic;
		SELn        : inout std_logic;
		ACKn        : inout std_logic;
		ATNn        : inout std_logic;
		REQn        : inout std_logic;
		IOn         : inout std_logic;
		CDn         : inout std_logic;
		MSGn        : inout std_logic
	);
end entity WF5380_TOP;
	
architecture STRUCTURE of WF5380_TOP is
component WF5380_TOP_SOC
	port (
        -- System controls:
		CLK			: in bit;
		RESETn	    : in bit;
		ADR			: in bit_vector(2 downto 0);
		DATA_IN		: in bit_vector(7 downto 0);
		DATA_OUT	: out bit_vector(7 downto 0);
		DATA_EN		: out bit;
		CSn			: in bit;
		RDn		    : in bit;
		WRn	        : in bit;
		EOPn        : in bit;
		DACKn	    : in bit;
		DRQ		    : out bit;
		INT		    : out bit;
		READY       : out bit;
		DB_INn		: in bit_vector(7 downto 0);
		DB_OUTn		: out bit_vector(7 downto 0);
		DB_EN       : out bit;
		DBP_INn		: in bit;
		DBP_OUTn	: out bit;
		DBP_EN      : out bit;
		RST_INn     : in bit;
		RST_OUTn    : out bit;
		RST_EN      : out bit;
		BSY_INn     : in bit;
		BSY_OUTn    : out bit;
		BSY_EN      : out bit;
		SEL_INn     : in bit;
		SEL_OUTn    : out bit;
		SEL_EN      : out bit;
		ACK_INn     : in bit;
		ACK_OUTn    : out bit;
		ACK_EN      : out bit;
		ATN_INn     : in bit;
		ATN_OUTn    : out bit;
		ATN_EN      : out bit;
		REQ_INn     : in bit;
		REQ_OUTn    : out bit;
		REQ_EN      : out bit;
		IOn_IN      : in bit;
		IOn_OUT     : out bit;
		IO_EN       : out bit;
		CDn_IN      : in bit;
		CDn_OUT     : out bit;
		CD_EN       : out bit;
		MSG_INn     : in bit;
		MSG_OUTn    : out bit;
		MSG_EN      : out bit
	);
end component;
--
signal ADR_IN       : bit_vector(2 downto 0);
signal DATA_IN      : bit_vector(7 downto 0);
signal DATA_OUT     : bit_vector(7 downto 0);
signal DATA_EN      : bit;
signal DB_INn	    : bit_vector(7 downto 0);
signal DB_OUTn	    : bit_vector(7 downto 0);
signal DB_EN        : bit;
signal DBP_INn	    : bit;
signal DBP_OUTn	    : bit;
signal DBP_EN       : bit;
signal RST_INn      : bit;
signal RST_OUTn     : bit;
signal RST_EN       : bit;
signal BSY_INn      : bit;
signal BSY_OUTn     : bit;
signal BSY_EN       : bit;
signal SEL_INn      : bit;
signal SEL_OUTn     : bit;
signal SEL_EN       : bit;
signal ACK_INn      : bit;
signal ACK_OUTn     : bit;
signal ACK_EN       : bit;
signal ATN_INn      : bit;
signal ATN_OUTn     : bit;
signal ATN_EN       : bit;
signal REQ_INn      : bit;
signal REQ_OUTn     : bit;
signal REQ_EN       : bit;
signal IOn_IN       : bit;
signal IOn_OUT      : bit;
signal IO_EN        : bit;
signal CDn_IN       : bit;
signal CDn_OUT      : bit;
signal CD_EN        : bit;
signal MSG_INn      : bit;
signal MSG_OUTn     : bit;
signal MSG_EN       : bit;
begin
    ADR_IN <= To_BitVector(ADR);

    DATA_IN <= To_BitVector(DATA);
    DATA <= To_StdLogicVector(DATA_OUT) when DATA_EN = '1' else (others => 'Z');

    DB_INn <= To_BitVector(DBn);
    DBn <= To_StdLogicVector(DB_OUTn) when DB_EN = '1' else (others => 'Z');

    DBP_INn <= To_Bit(DBPn);

    RST_INn <= To_Bit(RSTn);
    BSY_INn <= To_Bit(BSYn);
    SEL_INn <= To_Bit(SELn);
    ACK_INn <= To_Bit(ACKn);
    ATN_INn <= To_Bit(ATNn);
    REQ_INn <= To_Bit(REQn);
    IOn_IN <= To_Bit(IOn);
    CDn_IN <= To_Bit(CDn);
    MSG_INn <= To_Bit(MSGn);

    DBPn <= '1' when DBP_OUTn = '1' and DBP_EN = '1' else
            '0' when DBP_OUTn = '0' and DBP_EN = '1' else 'Z';
    RSTn <= '1' when RST_OUTn = '1' and RST_EN = '1'else
            '0' when RST_OUTn = '0' and RST_EN = '1' else 'Z';
    BSYn <= '1' when BSY_OUTn = '1' and BSY_EN = '1' else
            '0' when BSY_OUTn = '0' and BSY_EN = '1' else 'Z';
    SELn <= '1' when SEL_OUTn = '1' and SEL_EN = '1' else
            '0' when SEL_OUTn = '0' and SEL_EN = '1' else 'Z';
    ACKn <= '1' when ACK_OUTn = '1' and ACK_EN = '1' else
            '0' when ACK_OUTn = '0' and ACK_EN = '1' else 'Z';
    ATNn <= '1' when ATN_OUTn = '1' and ATN_EN = '1' else
            '0' when ATN_OUTn = '0' and ATN_EN = '1' else 'Z';
    REQn <= '1' when REQ_OUTn = '1' and REQ_EN = '1' else
            '0' when REQ_OUTn = '0' and REQ_EN = '1' else 'Z';
    IOn <=  '1' when IOn_OUT = '1' and IO_EN = '1' else
            '0' when IOn_OUT = '0' and IO_EN = '1' else 'Z';
    CDn <=  '1' when CDn_OUT = '1' and CD_EN = '1' else
            '0' when CDn_OUT = '0' and CD_EN = '1' else 'Z';
    MSGn <= '1' when MSG_OUTn = '1' and MSG_EN = '1' else
            '0' when MSG_OUTn = '0' and MSG_EN = '1' else 'Z';

    I_5380: WF5380_TOP_SOC
        port map(
            CLK			=> CLK,
            RESETn	    => RESETn,
            ADR			=> ADR_IN,
            DATA_IN		=> DATA_IN,
            DATA_OUT	=> DATA_OUT,
            DATA_EN		=> DATA_EN,
            CSn			=> CSn,
            RDn		    => RDn,
            WRn	        => WRn,
            EOPn        => EOPn,
            DACKn	    => DACKn,
            DRQ		    => DRQ,
            INT		    => INT,
            READY       => READY,
            DB_INn		=> DB_INn,
            DB_OUTn		=> DB_OUTn,
            DB_EN       => DB_EN,
            DBP_INn     => DBP_INn,
            DBP_OUTn    => DBP_OUTn,
            DBP_EN      => DBP_EN,
            RST_INn     => RST_INn,
            RST_OUTn    => RST_OUTn,
            RST_EN      => RST_EN,
            BSY_INn     => BSY_INn,
            BSY_OUTn    => BSY_OUTn,
            BSY_EN      => BSY_EN,
            SEL_INn     => SEL_INn,
            SEL_OUTn    => SEL_OUTn,
            SEL_EN      => SEL_EN,
            ACK_INn     => ACK_INn,
            ACK_OUTn    => ACK_OUTn,
            ACK_EN      => ACK_EN,
            ATN_INn     => ATN_INn,
            ATN_OUTn    => ATN_OUTn,
            ATN_EN      => ATN_EN,
            REQ_INn     => REQ_INn,
            REQ_OUTn    => REQ_OUTn,
            REQ_EN      => REQ_EN,
            IOn_IN      => IOn_IN,
            IOn_OUT     => IOn_OUT,
            IO_EN       => IO_EN,
            CDn_IN      => CDn_IN,
            CDn_OUT     => CDn_OUT,
            CD_EN       => CD_EN,
            MSG_INn     => MSG_INn,
            MSG_OUTn    => MSG_OUTn,
            MSG_EN      => MSG_EN
        );
end STRUCTURE;
