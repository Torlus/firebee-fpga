----------------------------------------------------------------------
----                                                              ----
---- WF5380 IP Core                                               ----
----                                                              ----
---- Description:                                                 ----
---- This model provides an asynchronous SCSI interface compa-    ----
---- tible to the DP5380 from National Semiconductor and others.  ----
----                                                              ----
---- Some remarks to the required input clock:                    ----
---- This core is provided for a 16MHz input clock. To use other  ----
---- frequencies, it is necessary to modify the following proces- ----
---- ses in the control file section:                             ----
---- P_BUSFREE, DELAY_800, INTERRUPTS.                            ----
----                                                              ----
---- This file is the top level file without tree state buses for ----
---- use in 'systems on chip' designs.                            ----
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

entity WF5380_TOP_SOC is
	port (
        -- System controls:
		CLK			: in bit; -- Use a 16MHz Clock.
		RESETn	    : in bit;
		
		-- Address and data:
		ADR			: in bit_vector(2 downto 0);
		DATA_IN		: in bit_vector(7 downto 0);
		DATA_OUT	: out bit_vector(7 downto 0);
		DATA_EN		: out bit;

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
end entity WF5380_TOP_SOC;
	
architecture STRUCTURE of WF5380_TOP_SOC is
signal ACK_OUT_CTRLn    : bit;
signal AIP              : bit;
signal ARB              : bit;
signal ARB_EN           : bit;
signal BLK              : bit;
signal BSR              : bit_vector(7 downto 0);
signal BSY_DISn         : bit;
signal BSY_ERR          : bit;
signal BSY_OUT_CTRLn    : bit;
signal CHK_PAR          : bit;
signal CSD              : bit_vector(7 downto 0);
signal CSB              : bit_vector(7 downto 0);
signal DATA_EN_CTRL     : bit;
signal DB_EN_I          : bit;
signal DMA_ACTIVE       : bit;
signal DMA_EN           : bit;
signal DMA_DIS          : bit;
signal DMA_SND          : bit;
signal DRQ_I            : bit;
signal EDMA             : bit;
signal EOP_EN           : bit;
signal ICR              : bit_vector(7 downto 0);
signal IDR_WR           : bit;
signal INT_I            : bit;
signal LA               : bit;
signal ODR              : bit_vector(7 downto 0);
signal ODR_WR           : bit;
signal PCHK             : bit;
signal PHSM             : bit;
signal PINT_EN          : bit;
signal REQ_OUT_CTRLn    : bit;
signal RPI              : bit;
signal RST              : bit;
signal SDI              : bit;
signal SDS              : bit;
signal SDT              : bit;
signal SER              : bit_vector(7 downto 0);
signal SER_ID           : bit;
signal SPER             : bit;
signal TARG             : bit;
signal TCR              : bit_vector(3 downto 0);
begin
    EDMA <= '1' when EOPn = '0' and DACKn = '0' and RDn = '0' else
            '1' when EOPn = '0' and DACKn = '0' and WRn = '0' else '0';

    PHSM <= '1' when DMA_ACTIVE = '0' else -- Always true, if there is no DMA.
            '1' when DMA_ACTIVE = '1' and REQ_INn = '0' and CDn_In = TCR(1) and IOn_IN = TCR(0) and MSG_INn = TCR(2) else '0'; -- Phasematch.

    DMA_DIS <= '1' when DMA_ACTIVE = '1' and BSY_INn = '1' else '0';

    SER_ID <= '1' when SER /= x"00" and SER = not CSD else '0';

    DRQ <= DRQ_I;
    INT <= INT_I;

    -- Pay attention: the SCSI bus is driven with inverted signals.
    ACK_OUTn <= ACK_OUT_CTRLn when DMA_ACTIVE = '1' else not ICR(4); -- Valid in initiator mode.
    REQ_OUTn <= REQ_OUT_CTRLn when DMA_ACTIVE = '1' else not TCR(3);  -- Valid in Target mode.
    BSY_OUTn <= '0' when BSY_OUT_CTRLn = '0' and TARG = '0' else -- Valid in initiator mode.
                '0' when ICR(3) = '1' else '1';
    ATN_OUTn <= not ICR(1); -- Valid in initiator mode.
    SEL_OUTn <= not ICR(2); -- Valid in initiator mode.
    IOn_OUT <= not TCR(0);  -- Valid in Target mode.
    CDn_OUT <= not TCR(1);  -- Valid in Target mode.
    MSG_OUTn <= not TCR(2);  -- Valid in Target mode.
    RST_OUTn <= not RST;

    DB_OUTn <= not ODR;
    DBP_OUTn <= not SPER; 

    CSD <= not DB_INn;
    CSB <= not RST_INn & not BSY_INn & not REQ_INn & not MSG_INn & not CDn_IN & not IOn_IN & not SEL_INn & not DBP_INn;
    BSR <= EDMA & DRQ_I & SPER & INT_I & PHSM & BSY_ERR & not ATN_INn & not ACK_INn;

    -- Hi impedance control:
    ATN_EN <= '1' when TARG = '0' else '0'; -- Initiator mode.
    SEL_EN <= '1' when TARG = '0' else '0'; -- Initiator mode.
    BSY_EN <= '1' when TARG = '0' else '0'; -- Initiator mode.
    ACK_EN <= '1' when TARG = '0' else '0'; -- Initiator mode.
    IO_EN <= '1' when TARG = '1' else '0'; -- Target mode.
    CD_EN <= '1' when TARG = '1' else '0'; -- Target mode.
    MSG_EN <= '1' when TARG = '1' else '0'; -- Target mode.
    REQ_EN <= '1' when TARG = '1' else '0'; -- Target mode.
    RST_EN <= '1' when RST = '1' else '0'; -- Open drain control.
    
    -- Data enables:
    DB_EN_I <= '1' when DATA_EN_CTRL = '1' else -- During Arbitration.
               '1' when ICR(0) = '1' and TARG = '1' and DMA_SND = '1' else -- Target 'Send' mode.
               '1' when ICR(0) = '1' and TARG = '0' and IOn_IN = '0' and PHSM = '1' else 
               '1' when ICR(6) = '1' else '0'; -- Test mode enable.

    DB_EN <= DB_EN_I;
    DBP_EN <= DB_EN_I;

    I_REGISTERS: WF5380_REGISTERS
        port map(
            CLK			=> CLK,
            RESETn	    => RESETn,
            ADR			=> ADR,
            DATA_IN		=> DATA_IN,
            DATA_OUT	=> DATA_OUT,
            DATA_EN		=> DATA_EN,
            CSn			=> CSn,
            RDn		    => RDn,
            WRn	        => WRn,
            RSTn	    => RST_INn,
            RST         => RST,
            ARB_EN      => ARB_EN,
            DMA_ACTIVE  => DMA_ACTIVE,
            DMA_EN      => DMA_EN,
            BSY_DISn    => BSY_DISn,
            EOP_EN      => EOP_EN,
            PINT_EN     => PINT_EN,
            SPER        => SPER,
            TARG        => TARG,
            BLK         => BLK,
            DMA_DIS     => DMA_DIS,
            IDR_WR      => IDR_WR,
            ODR_WR      => ODR_WR,
            CHK_PAR     => CHK_PAR,
            AIP         => AIP,
            ARB         => ARB,
            LA          => LA,
            CSD         => CSD,
            CSB         => CSB,
            BSR         => BSR,
            ODR_OUT     => ODR,
            ICR_OUT     => ICR,
            TCR_OUT     => TCR,
            SER_OUT     => SER,
            SDS         => SDS,
            SDT         => SDT,
            SDI         => SDI,
            RPI         => RPI
        );

    I_CONTROL: WF5380_CONTROL
        port map(
            CLK			=> CLK,
            RESETn	    => RESETn,
            BSY_INn     => BSY_INn,
            BSY_OUTn    => BSY_OUT_CTRLn,
            DATA_EN     => DATA_EN_CTRL,
            SEL_INn     => SEL_INn,
            ARB_EN      => ARB_EN,
            BSY_DISn    => BSY_DISn,
            RSTn	    => RST_INn,
            ARB         => ARB,
            AIP         => AIP,
            LA          => LA,
            ACK_INn     => ACK_INn,
            ACK_OUTn    => ACK_OUT_CTRLn,
            REQ_INn     => REQ_INn,
            REQ_OUTn    => REQ_OUT_CTRLn,
            DACKn       => DACKn,
            READY       => READY,
            DRQ         => DRQ_I,
            TARG        => TARG,
            BLK         => BLK,
            PINT_EN     => PINT_EN,
            SPER        => SPER,
            SER_ID      => SER_ID,
            RPI         => RPI,
            DMA_EN      => DMA_EN,
            SDS         => SDS,
            SDT         => SDT,
            SDI         => SDI,
            EOP_EN      => EOP_EN,
            EOPn        => EOPn,
            PHSM        => PHSM,
            INT         => INT_I,
            IDR_WR      => IDR_WR,
            ODR_WR      => ODR_WR,
            CHK_PAR     => CHK_PAR,
            BSY_ERR     => BSY_ERR,
            DMA_SND     => DMA_SND,
            DMA_ACTIVE  => DMA_ACTIVE
        );
end STRUCTURE;
