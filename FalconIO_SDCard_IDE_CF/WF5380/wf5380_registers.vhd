----------------------------------------------------------------------
----                                                              ----
---- WF5380 IP Core                                               ----
----                                                              ----
---- Description:                                                 ----
---- This model provides an asynchronous SCSI interface compa-    ----
---- tible to the DP5380 from National Semiconductor and others.  ----
----                                                              ----
---- This file is the 5380's register model.                      ----
----                                                              ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Register description (for more information see the DP5380    ----
---- data sheet:                                                  ----
----   ODR (address 0) Output data register, write only.          ----
----   CSD (address 0) Current SCSI data, read only.              ----
----   ICR (address 1) Initiator command register, read/write.    ----
----   MR2 (address 2) Mode register 2, read/write.               ----
----   TCR (address 3) Target command register, read/write.       ----
----   SER (address 4) Select enable register, write only.        ----
----   CSB (address 4) Current SCSI bus status, read only.        ----
----   BSR (address 5) Start DMA send, write only.                ----
----   SDS (address 5) Bus and status, read only.                 ----
----   SDT (address 6) Start DMA target receive, write only.      ----
----   IDR (address 6) Input data register, read only.            ----
----   SDI (address 7) Start DMA initiator recive, write only.    ----
----   RPI (address 7) Reset parity / interrupts, read only.      ----
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF5380_REGISTERS is
	port (
        -- System controls:
		CLK			: in bit;
		RESETn	    : in bit; -- System reset.
		
		-- Address and data:
		ADR			: in bit_vector(2 downto 0);
		DATA_IN		: in bit_vector(7 downto 0);
		DATA_OUT	: out bit_vector(7 downto 0);
		DATA_EN		: out bit;

		-- Bus and DMA controls:
		CSn			: in bit;
		RDn		    : in bit;
		WRn	        : in bit;

        -- Core controls:
		RSTn	    : in bit; -- SCSI reset.
		RST         : out bit; -- Programmed SCSI reset.
        ARB_EN      : out bit; -- Arbitration enable.
        DMA_ACTIVE  : in bit; -- DMA is running.
        DMA_EN      : out bit; -- DMA mode enable.
        BSY_DISn    : out bit; -- BSY monitoring enable.
        EOP_EN      : out bit; -- EOP interrupt enable.
        PINT_EN     : out bit; -- Parity interrupt enable.
        SPER        : out bit; -- Parity error.
        TARG        : out bit; -- Target mode.
        BLK         : out bit; -- Block DMA mode.
        DMA_DIS     : in bit; -- Reset the DMA_EN by this signal.
        IDR_WR      : in bit; -- Write input data register during DMA.
        ODR_WR      : in bit; -- Write output data register, during DMA.
        CHK_PAR     : in bit; -- Check Parity during DMA operation.
        AIP         : in bit; -- Arbitration in progress.
        ARB         : in bit; -- Arbitration.
        LA          : in bit; -- Lost arbitration.

        CSD         : in bit_vector(7 downto 0); -- SCSI data.
        CSB         : in bit_vector(7 downto 0); -- Current SCSI bus status.
        BSR         : in bit_vector(7 downto 0); -- Bus and status.

        ODR_OUT     : out bit_vector(7 downto 0); -- This is the ODR register.
        ICR_OUT     : out bit_vector(7 downto 0); -- This is the ICR register.
        TCR_OUT     : out bit_vector(3 downto 0); -- This is the TCR register.
        SER_OUT     : out bit_vector(7 downto 0); -- This is the SER register.
        
		SDS         : out bit; -- Start DMA send, write only.
		SDT         : out bit; -- Start DMA target receive, write only.
		SDI         : out bit; -- Start DMA initiator receive, write only.
		RPI         : out bit
    );
end entity WF5380_REGISTERS;
	
architecture BEHAVIOUR of WF5380_REGISTERS is
signal ICR  : bit_vector(7 downto 0); -- Initiator command register, read/write.
signal IDR  : bit_vector(7 downto 0); -- Input data register.
signal MR2  : bit_vector(7 downto 0); -- Mode register 2, read/write.
signal ODR  : bit_vector(7 downto 0); -- Output data register, write only.
signal SER  : bit_vector(7 downto 0); -- Select enable register, write only.
signal TCR  : bit_vector(3 downto 0); -- Target command register, read/write.
begin
    REGISTERS: process(RESETn, CLK)
    -- This process reflects all registers in the 5380.
    variable BSY_LOCK   : boolean;
    begin
        if RESETn = '0' then
            ODR <= (others => '0');
            ICR <= (others => '0');
            MR2 <= (others => '0');
            TCR <= (others => '0');
            SER <= (others => '0');
            BSY_LOCK  := false;
        elsif CLK = '1' and CLK' event then
            if RSTn = '0' then -- SCSI reset.
                ODR <= (others => '0');
                ICR(6 downto 0) <= (others => '0');
                MR2(7) <= '0';
                MR2(5 downto 0) <= (others => '0');
                TCR <= (others => '0');
                SER <= (others => '0');
                BSY_LOCK  := false;
            elsif ADR = "000" and CSn = '0' and WRn = '0' then
                ODR <= DATA_IN;
            elsif ADR = "001" and CSn = '0' and WRn = '0' then
                ICR <= DATA_IN;
            elsif ADR = "010" and CSn = '0' and WRn = '0' then
                MR2 <= DATA_IN;
            elsif ADR = "011" and CSn = '0' and WRn = '0' then
                TCR <= DATA_IN(3 downto 0);
            elsif ADR = "100" and CSn = '0' and WRn = '0' then
                SER <= DATA_IN;
            end if;
            --
            if ODR_WR = '1' then
                ODR <= DATA_IN;
            end if;
            --
            -- This reset function is edge triggered on the 'Monitor Busy'
            -- MR2(2).
            if MR2(2) = '1' and BSY_LOCK = false then
                ICR(5 downto 0) <= "000000";
                BSY_LOCK := true;
            elsif MR2(2) = '0' then
                BSY_LOCK := false;
            end if;
            --
            if DMA_DIS = '1' then
                MR2(1) <= '0';
            end if;
        end if;
    end process REGISTERS;
    
    IDR_REGISTER: process(RESETn, CLK)
    begin
        if RESETn = '0' then
            IDR <= x"00";
        elsif CLK = '1' and CLK' event then
            if RSTn = '0' or ICR(7) = '1' then
                IDR <= x"00"; -- SCSI reset.
            elsif IDR_WR = '1' then
                IDR <= CSD;
            end if;
        end if;
    end process IDR_REGISTER;
    
    PARITY: process(RESETn, CLK)
    -- This is the parity generating logic with it's related
    -- error generation.
	variable PAR_VAR : bit;
	variable LOCK : boolean;
    begin
        if RESETn = '0' then
            SPER <= '0';
            LOCK := false;
        elsif CLK = '1' and CLK' event then
            -- Parity checked during 'Read from CSD' 
            -- (registered I/O and selection/reselection):
            if ADR = "000" and CSn = '0' and RDn = '0' and LOCK = false then
                for i in 1 to 7 loop
                    PAR_VAR := CSD(i) xor CSD(i-1);
                end loop;
                SPER <= not PAR_VAR;
                LOCK := true;
            end if;
            --
            -- Parity checking during DMA operation:
            if DMA_ACTIVE = '1' and CHK_PAR = '1' then
                for i in 1 to 7 loop
                    PAR_VAR := IDR(i) xor IDR(i-1);
                end loop;
                SPER <= not PAR_VAR;
                LOCK := true;
            end if;
            --
            -- Reset parity flag:
            if MR2(5) <= '0' then -- MR2(5) = PCHK (disabled).
                SPER <= '0';
            elsif ADR = "111" and CSn = '0' and RDn = '0' then -- Reset parity/interrupts.
                SPER <= '0';
                LOCK := false;
            end if;
        end if;
    end process PARITY;

    DATA_EN <= '1' when ADR < "101" and CSn = '0' and WRn = '0' else '0';

    SDS <= '1' when ADR = "101" and CSn = '0' and WRn = '0' else '0';
    SDT <= '1' when ADR = "110" and CSn = '0' and WRn = '0' else '0';
    SDI <= '1' when ADR = "111" and CSn = '0' and WRn = '0' else '0';
    
    ICR_OUT <= ICR;
    TCR_OUT <= TCR;
    SER_OUT <= SER;
    ODR_OUT <= ODR;
    
    ARB_EN  <= MR2(0);
    DMA_EN  <= MR2(1);
    BSY_DISn  <= MR2(2);
    EOP_EN  <= MR2(3);
    PINT_EN <= MR2(4);
    TARG    <= MR2(6);
    BLK     <= MR2(7);
    
    RST     <= ICR(7);
       
    -- Readback, unused bit positions are read back zero.
    DATA_OUT <= CSD when ADR = "000" and CSn = '0' and RDn = '0' else -- Current SCSI data.
                ICR(7) & AIP & LA & ICR(4 downto 0) when ADR = "001" and CSn = '0' and RDn = '0' else
                MR2 when ADR = "010" and CSn = '0' and RDn = '0' else
                x"0" & TCR when ADR = "011" and CSn = '0' and RDn = '0' else
                CSB when ADR = "100" and CSn = '0' and RDn = '0' else -- Current SCSI bus status.
                BSR when ADR = "101" and CSn = '0' and RDn = '0' else -- Bus and status.
                IDR when ADR = "110" and CSn = '0' and RDn = '0' else x"00"; -- Input data register.

    RPI <= '1' when ADR = "111" and CSn = '0' and RDn = '0' else '0'; -- Reset parity/interrupts.
end BEHAVIOUR;