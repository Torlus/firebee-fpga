----------------------------------------------------------------------
----                                                              ----
---- WF5380 IP Core                                               ----
----                                                              ----
---- Description:                                                 ----
---- This model provides an asynchronous SCSI interface compa-    ----
---- tible to the DP5380 from National Semiconductor and others.  ----
----                                                              ----
---- This file is the 5380's system controller.                   ----
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF5380_CONTROL is
	port (
        -- System controls:
		CLK			: in bit;
		RESETn	    : in bit; -- System reset.
		
        -- System controls:
        BSY_INn     : in bit; -- SCSI BSY_INn bit.
        BSY_OUTn    : out bit; -- SCSI BSY_INn bit.
        DATA_EN     : out bit; -- Enable the SCSI data lines.
        SEL_INn     : in bit; -- SCSI SEL_INn bit.
        ARB_EN      : in bit; -- Arbitration enable.
        BSY_DISn    : in bit; -- BSY monitoring enable.
		RSTn	    : in bit; -- SCSI reset.
        
        ARB         : out bit; -- Arbitration flag.
        AIP         : out bit; -- Arbitration in progress flag.
        LA          : out bit; -- Lost arbitration flag.

        ACK_INn     : in bit;
        ACK_OUTn    : out bit;
        REQ_INn     : in bit;
        REQ_OUTn    : out bit;

        DACKn       : in bit; -- Data acknowledge.
        READY       : out bit;
        DRQ         : out bit; -- Data request.

        TARG        : in bit; -- Target mode indicator.
        BLK         : in bit; -- Block mode indicator.
        PINT_EN     : in bit; -- Parity interrupt enable.
        SPER        : in bit; -- Parity error.
        SER_ID      : in bit; -- SER matches ODR bits.
        RPI         : in bit; -- Reset interrupts.
        DMA_EN      : in bit; -- DMA mode enable.
		SDS         : in bit; -- Start DMA send, write only.
		SDT         : in bit; -- Start DMA target receive, write only.
		SDI         : in bit; -- Start DMA initiator receive, write only.
        EOP_EN      : in bit; -- EOP interrupt enable.
        EOPn        : in bit; -- End of process indicator.
        PHSM        : in bit; -- Phase match flag.

        INT         : out bit; -- Interrupt.
        IDR_WR      : out bit; -- Write input data register during DMA.
        ODR_WR      : out bit; -- Write output data register, during DMA.
        CHK_PAR     : out bit; -- Check Parity during DMA operation.
        BSY_ERR     : out bit; -- Busy monitoring error.
        DMA_SND     : out bit; -- Indicates direction of target DMA.
        DMA_ACTIVE  : out bit -- DMA is active.
    );
end entity WF5380_CONTROL;
	
architecture BEHAVIOUR of WF5380_CONTROL is
type CTRL_STATES is (IDLE, WAIT_800ns, WAIT_2200ns, DMA_SEND, DMA_TARG_RCV, DMA_INIT_RCV);
type DMA_STATES is (IDLE, DMA_STEP_1, DMA_STEP_2, DMA_STEP_3, DMA_STEP_4);
signal CTRL_STATE       : CTRL_STATES;
signal NEXT_CTRL_STATE  : CTRL_STATES;
signal DMA_STATE        : DMA_STATES;
signal NEXT_DMA_STATE   : DMA_STATES;
signal BUS_FREE         : bit;
signal DELAY_800ns      : boolean;
signal DELAY_2200ns     : boolean;
signal DMA_ACTIVE_I     : bit;
signal EOP_In           : bit;
begin
    IN_BUFFER: process
    -- This buffer shall prevent some signals against
    -- setup hold effects and thus the state machine
    -- against unpredictable behaviour.
    begin
        wait until CLK = '1' and CLK' event;
        EOP_In <= EOPn;
    end process IN_BUFFER;

    STATE_REGISTERS: process(RESETn, CLK)
    -- This is the controller's state machine register.
    variable BSY_LOCK   : boolean;
    begin
        if RESETn = '0' then
            CTRL_STATE <= IDLE;
            DMA_STATE <= IDLE;
        elsif CLK = '1' and CLK' event then
            if RSTn = '0' then -- SCSI reset.
                CTRL_STATE <= IDLE;
                DMA_STATE <= IDLE;
            else
                CTRL_STATE <= NEXT_CTRL_STATE;
                DMA_STATE <= NEXT_DMA_STATE;
            end if;
            --
            if DMA_EN = '0' then
                DMA_STATE <= IDLE;
            end if;
        end if;
    end process STATE_REGISTERS;

    CTRL_DECODER: process(CTRL_STATE, ARB_EN, BUS_FREE, DELAY_800ns, SEL_INn, DMA_ACTIVE_I, SDS, SDT, SDI)
    -- This is the controller's state machine decoder.
    variable BSY_LOCK   : boolean;
    begin
        -- Defaults.
        DMA_SND <= '0';
        --
        case CTRL_STATE is
            when IDLE =>
                if ARB_EN = '1' and BUS_FREE = '1' then
                    NEXT_CTRL_STATE <= WAIT_800ns;
                else
                    NEXT_CTRL_STATE <= IDLE;
                end if;
            when WAIT_800ns =>
                if DELAY_800ns = true then
                    NEXT_CTRL_STATE <= WAIT_2200ns;
                else
                    NEXT_CTRL_STATE <= WAIT_800ns;
                end if;
            when WAIT_2200ns =>
                -- In this state the delay is provided by the
                -- microprocessor and is at least 2.2us. The
                -- delay is released by deasserting SELn.
                if SEL_INn = '1' and SDS = '1' then
                    NEXT_CTRL_STATE <= DMA_SEND;
                elsif SEL_INn = '1' and SDT = '1' then
                    NEXT_CTRL_STATE <= DMA_TARG_RCV;
                elsif SEL_INn = '1' and SDI = '1' then
                    NEXT_CTRL_STATE <= DMA_INIT_RCV;
                else
                    NEXT_CTRL_STATE <= WAIT_2200ns;
                end if;
            when DMA_SEND =>
                if DMA_ACTIVE_I = '0' then
                    NEXT_CTRL_STATE <= IDLE;
                else
                    NEXT_CTRL_STATE <= DMA_SEND;
                end if;
                --
                DMA_SND <= '1';
            when DMA_TARG_RCV =>
                if DMA_ACTIVE_I = '0' then
                    NEXT_CTRL_STATE <= IDLE;
                else
                    NEXT_CTRL_STATE <= DMA_TARG_RCV;
                end if;
            when DMA_INIT_RCV =>
                if DMA_ACTIVE_I = '0' then
                    NEXT_CTRL_STATE <= IDLE;
                else
                    NEXT_CTRL_STATE <= DMA_INIT_RCV;
                end if;
        end case;
    end process CTRL_DECODER;

    DMA_DECODER: process(CTRL_STATE, DMA_STATE, TARG, BLK, DACKn, REQ_INn, ACK_INn)
    -- This is the DMA state machine decoder.
    begin
        -- Defaults:
        IDR_WR <= '0';
        ODR_WR <= '0';
        CHK_PAR <= '0';
        --
        case DMA_STATE is
            when IDLE =>
                if CTRL_STATE = DMA_SEND then
                    NEXT_DMA_STATE <= DMA_STEP_1;
                elsif CTRL_STATE = DMA_INIT_RCV then
                    NEXT_DMA_STATE <= DMA_STEP_1;
                elsif CTRL_STATE = DMA_TARG_RCV then
                    NEXT_DMA_STATE <= DMA_STEP_1;
                else
                    NEXT_DMA_STATE <= IDLE;
                end if;
        when DMA_STEP_1 =>
            -- Initiator modes:
            if CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '0' and DACKn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_2; -- Wait for DACKn asserted.
                ODR_WR <= '1';
            elsif CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' and DACKn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_2; -- Wait for DACKn asserted.
                ODR_WR <= '1';
            elsif CTRL_STATE = DMA_INIT_RCV and BLK = '0' and REQ_INn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_2; -- Wait for REQn asserted.
                IDR_WR <= '1';
            elsif CTRL_STATE = DMA_INIT_RCV and BLK = '1' and REQ_INn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_2; -- Wait for REQn asserted.
                IDR_WR <= '1';
            -- Target modes:
            elsif CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '0' and DACKn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_2; -- Wait for DACKn asserted.
                ODR_WR <= '1';
            elsif CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' and DACKn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_2; -- Wait for DACKn asserted.
                ODR_WR <= '1';
            elsif CTRL_STATE = DMA_TARG_RCV and BLK = '0' and ACK_INn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_2; -- Wait for ACKn asserted.
                IDR_WR <= '1';
            elsif CTRL_STATE = DMA_TARG_RCV and BLK = '1' and ACK_INn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_2; -- Wait for ACKn asserted.
                IDR_WR <= '1';
            else
                NEXT_DMA_STATE <= DMA_STEP_1;
            end if;
        when DMA_STEP_2 =>
            -- Initiator modes:
            if CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '0' and DACKn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_3; -- Wait for DACKn deasserted.
            elsif CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' and DACKn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_3; -- Wait for DACKn deasserted.
            elsif CTRL_STATE = DMA_INIT_RCV and BLK = '0' and REQ_INn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_3; -- Wait for REQn deasserted.
            elsif CTRL_STATE = DMA_INIT_RCV and BLK = '1' and REQ_INn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_3; -- Wait for REQn deasserted.
            -- Target modes:
            elsif CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '0' and DACKn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_3; -- Wait for DACKn deasserted.
            elsif CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' and DACKn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_3; -- Wait for DACKn deasserted.
            elsif CTRL_STATE = DMA_TARG_RCV and BLK = '0' and ACK_INn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_3; -- Wait for ACKn deasserted.
            elsif CTRL_STATE = DMA_TARG_RCV and BLK = '1' and ACK_INn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_3; -- Wait for ACKn deasserted.
            else
                NEXT_DMA_STATE <= DMA_STEP_2;
            end if;
        when DMA_STEP_3 =>
            -- Initiator modes:
            if CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '0' and REQ_INn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_4; -- Wait REQn asserted.
            elsif CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' and REQ_INn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_4; -- Wait REQn asserted.
            elsif CTRL_STATE = DMA_INIT_RCV and BLK = '0' and DACKn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_4; -- Wait DACKn asserted.
                CHK_PAR <= '1';
            elsif CTRL_STATE = DMA_INIT_RCV and BLK = '1' and DACKn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_4; -- Wait DACKn asserted.
                CHK_PAR <= '1';
            -- Target modes:
            elsif CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '0' and ACK_INn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_4; -- Wait ACKn asserted.
            elsif CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '1' and ACK_INn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_4; -- Wait ACKn asserted.
            elsif CTRL_STATE = DMA_TARG_RCV and BLK = '0' and DACKn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_4; -- Wait DACKn asserted.
                CHK_PAR <= '1';
            elsif CTRL_STATE = DMA_TARG_RCV and BLK = '1' and DACKn = '0' then
                NEXT_DMA_STATE <= DMA_STEP_4; -- Wait DACKn asserted.
                CHK_PAR <= '1';
            else
                NEXT_DMA_STATE <= DMA_STEP_3;
            end if;
        when DMA_STEP_4 =>
            -- Initiator modes:
            if CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '0' and REQ_INn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_1; -- Wait REQn deasserted.
            elsif CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' and REQ_INn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_1; -- Wait REQn deasserted.
            elsif CTRL_STATE = DMA_INIT_RCV and BLK = '0' and DACKn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_1; -- Wait DACKn deasserted.
            elsif CTRL_STATE = DMA_INIT_RCV and BLK = '1' and DACKn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_1; -- Wait DACKn deasserted.
            -- Target modes:
            elsif CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '0' and ACK_INn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_1; -- Wait ACKn deasserted.
            elsif CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '1' and ACK_INn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_1; -- Wait ACKn deasserted.
            elsif CTRL_STATE = DMA_TARG_RCV and BLK = '0' and DACKn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_1; -- Wait DACKn deasserted.
            elsif CTRL_STATE = DMA_TARG_RCV and BLK = '1' and DACKn = '1' then
                NEXT_DMA_STATE <= DMA_STEP_1; -- Wait DACKn deasserted.
            else
                NEXT_DMA_STATE <= DMA_STEP_4;
            end if;
        end case;
    end process DMA_DECODER;

    P_REQn: process(DMA_STATE, CTRL_STATE, TARG, BLK)
    -- This logic controls the REQn output in target mode.
    begin
        if DMA_STATE = DMA_STEP_1 and CTRL_STATE = DMA_TARG_RCV and BLK = '0' then
            REQ_OUTn <= '0';
        elsif DMA_STATE = DMA_STEP_1 and CTRL_STATE = DMA_TARG_RCV and BLK = '1' then
            REQ_OUTn <= '0';
        elsif DMA_STATE = DMA_STEP_3 and CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '0' then
            REQ_OUTn <= '0';
        elsif DMA_STATE = DMA_STEP_3 and CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '1' then
            REQ_OUTn <= '0';
        else
            REQ_OUTn <= '1';
        end if;
    end process P_REQn;
    
    P_ACKn: process(DMA_STATE, CTRL_STATE, TARG, BLK)
    -- This logic controls the ACKn output in initiator mode.
    begin
        if DMA_STATE = DMA_STEP_2 and CTRL_STATE = DMA_INIT_RCV and BLK = '0' then
            ACK_OUTn <= '0';
        elsif DMA_STATE = DMA_STEP_2 and CTRL_STATE = DMA_INIT_RCV and BLK = '1' then
            ACK_OUTn <= '0';
        elsif DMA_STATE = DMA_STEP_4 and CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '0' then
            ACK_OUTn <= '0';
        elsif DMA_STATE = DMA_STEP_4 and CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' then
            ACK_OUTn <= '0';
        else
            ACK_OUTn <= '1';
        end if;
    end process P_ACKn;

    P_READY: process(DMA_STATE, CTRL_STATE, TARG, BLK)
    -- This logic controls the READY output in initiator and target block mode.
    begin
        if DMA_STATE = DMA_STEP_1 and CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '1' then
            READY <= '1';
        elsif DMA_STATE = DMA_STEP_1 and CTRL_STATE = DMA_TARG_RCV and BLK = '1' then
            READY <= '1';
        elsif DMA_STATE = DMA_STEP_3 and CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' then
            READY <= '1';
        elsif DMA_STATE = DMA_STEP_3 and CTRL_STATE = DMA_INIT_RCV and BLK = '1' then
            READY <= '1';
        else
            READY <= '0';
        end if;
    end process P_READY;
    
    P_DRQ: process(RESETn, CLK)
    -- This flip flop controls the DRQ flag during all initiator and all target modes
    -- for both block mode and non block mode operation.
    variable LOCK   : boolean;
    begin
        if RESETn = '0' then
            DRQ <= '0';
            LOCK := false;
        elsif CLK = '1' and CLK' event then
            -- Initiator modes:
            if DMA_STATE = DMA_STEP_1 and CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '0' then
                DRQ <= '1';
            elsif DMA_STATE = DMA_STEP_1 and CTRL_STATE = DMA_SEND and TARG = '0' and BLK = '1' and LOCK = false then
                DRQ <= '1';
                LOCK := true;
            elsif DMA_STATE = DMA_STEP_3 and CTRL_STATE = DMA_INIT_RCV and BLK = '0' then
                DRQ <= '1';
            elsif DMA_STATE = DMA_STEP_3 and CTRL_STATE = DMA_INIT_RCV and BLK = '1' then
                DRQ <= '1';
                LOCK := true;
            -- Target modes:
            elsif DMA_STATE = DMA_STEP_3 and CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '0' then
                DRQ <= '1';
            elsif DMA_STATE = DMA_STEP_3 and CTRL_STATE = DMA_SEND and TARG = '1' and BLK = '1' then
                DRQ <= '1';
                LOCK := true;
            elsif DMA_STATE = DMA_STEP_1 and CTRL_STATE = DMA_TARG_RCV and BLK = '0' then
                DRQ <= '1';
            elsif DMA_STATE = DMA_STEP_1 and CTRL_STATE = DMA_TARG_RCV and BLK = '1' then
                DRQ <= '1';
                LOCK := true;
            elsif DACKn = '0' and LOCK = false then
                DRQ <= '0';
            elsif EOPn = '0' and DACKn = '0' then
                DRQ <= '0';
                LOCK := false;
            end if;
        end if;
    end process P_DRQ;

    P_BUSFREE: process(RESETn, CLK)
    -- This is the logic for the bus free signal.
    -- A bus free is valid if the BSY_INn signal is
    -- at least 437.5ns inactive ans SEL_INn is inactive.
    -- The delay are 7 clock cycles of 16MHz.
    variable TMP    : std_logic_vector(2 downto 0);
    begin
        if RESETn = '0' then
            BUS_FREE <= '0';
            TMP := "000";
        elsif CLK = '1' and CLK' event then
            if BSY_INn = '1' and TMP < x"111" then
                TMP := TMP + '1';
            elsif BSY_INn = '0' then
                TMP := "000";
            end if;
            --
            if RSTn = '0' then -- SCSI reset.
                BUS_FREE <= '0';
            elsif SEL_INn = '1' and TMP = "111" then
                BUS_FREE <= '1';
            else
                BUS_FREE <= '0';
            end if;
        end if;
    end process P_BUSFREE;

    DELAY_800: process(RESETn, CLK)
    -- This is the delay of 812.5ns.
    -- It is derived from 13 16MHz clock cycles.
    variable TMP    : std_logic_vector(3 downto 0);
    begin
        if RESETn = '0' then
            DELAY_800ns <= false;
            TMP := x"0";
        elsif CLK = '1' and CLK' event then
            if CTRL_STATE /= WAIT_800ns then
                TMP := x"0";
            elsif TMP <= x"D" then
                TMP := TMP + '1';
            end if;
            --
            if TMP = x"D" then
                DELAY_800ns <= true;
            else
                DELAY_800ns <= false;
            end if;
        end if;
    end process DELAY_800;

    P_ARB: process(RESETn, CLK)
    -- This flip flop controls the ARB flag read back
    -- by the microcontroller.
    begin
        if RESETn = '0' then
            ARB <= '0';
        elsif CLK = '1' and CLK' event then
            if CTRL_STATE /= WAIT_800ns and NEXT_CTRL_STATE = WAIT_800ns then
                ARB <= '1';
            elsif ARB_EN = '0' then
                ARB <= '0';
            end if;
        end if;
    end process P_ARB;

    P_AIP: process(RESETn, CLK)
    -- This flip flop controls the AIP flag read back
    -- by the microcontroller.
    begin
        if RESETn = '0' then
            AIP <= '0';
        elsif CLK = '1' and CLK' event then
            if CTRL_STATE = WAIT_800ns and NEXT_CTRL_STATE /= WAIT_800ns then
                AIP <= '1';
            elsif ARB_EN = '0' then
                AIP <= '0';
            end if;
        end if;
    end process P_AIP;
    
    P_BSY: process
    -- This flip flop controls the BSYn output
    -- to the SCSI bus.
    begin
        wait until CLK = '1' and CLK' event;
        if RESETn = '0' then
            BSY_OUTn <= '1';
        elsif CTRL_STATE = WAIT_800ns and NEXT_CTRL_STATE /= WAIT_800ns then
            BSY_OUTn <= '0';
        elsif ARB_EN = '0' then
            BSY_OUTn <= '1';
        end if;
    end process P_BSY;
    
    P_DATA_EN: process(RESETn, CLK)
    -- This flip flop controls the data enable
    -- of the SCSI bus.
    begin
        if RESETn = '0' then
            DATA_EN <= '0';
        elsif CLK = '1' and CLK' event then
            if CTRL_STATE = WAIT_800ns and NEXT_CTRL_STATE /= WAIT_800ns then
                DATA_EN <= '1';
            elsif ARB_EN = '0' then
                DATA_EN <= '0';
            end if;
        end if;
    end process P_DATA_EN;
    
    P_LA: process(RESETn, CLK)
    -- This flip flop controls the LA
    -- (lost arbitration) flag.
    begin
        if RESETn = '0' then
            LA <= '0';
        elsif CLK = '1' and CLK' event then
            if (CTRL_STATE = WAIT_800ns or CTRL_STATE = WAIT_2200ns) and SEL_INn = '0' then
                LA <= '1';
            elsif ARB_EN = '0' then
                LA <= '0';
            end if;
        end if;
    end process P_LA;

    P_DMA_ACTIVE: process(RESETn, CLK, DMA_ACTIVE_I)
    -- This is the Flip Flop indicating if there is DMA
    -- operation.
    begin
        if RESETn = '0' then
            DMA_ACTIVE_I <= '0';
        elsif CLK = '1' and CLK' event then
            if DMA_EN = '1' and SDS = '1' then
                DMA_ACTIVE_I <= '1'; -- Start DMA send.
            elsif DMA_EN = '1' and SDT = '1' then
                DMA_ACTIVE_I <= '1'; -- Start DMA target receive.
            elsif DMA_EN = '1' and SDI = '1' then
                DMA_ACTIVE_I <= '1'; -- Start DMA initiator receive.
            elsif DMA_EN = '0' then
                DMA_ACTIVE_I <= '0'; -- Halt DMA via DMA flag in MR2.
            elsif EOP_In = '0' then
                DMA_ACTIVE_I <= '0'; -- Halt DMA via EOPn.
            elsif PHSM = '0' then
                DMA_ACTIVE_I <= '0'; -- Halt DMA via phase mismatch.
            end if;
        end if;
        --
        DMA_ACTIVE <= DMA_ACTIVE_I;
    end process P_DMA_ACTIVE;

    INTERRUPTS: process(RESETn, CLK)
    -- This is the logic for all DP5380's interrupt sources.
    -- A busy interrupt occurs if the BSY_INn signal is at 
    -- least 437.5ns inactive. The delay are 7 clock cycles
    -- of 16MHz. This logic also provides the respective 
    -- error flags for the BSR.
    variable TMP    : std_logic_vector(2 downto 0);
    begin
        if RESETn = '0' then
            INT <= '0';
            BSY_ERR <= '0';
            TMP := "000";
        elsif CLK = '1' and CLK' event then
            if SPER = '1' and PINT_EN = '1' then
                INT <= '1'; -- Parity interrupt.
            elsif RPI = '0' then -- Reset interrupts.
                INT <= '0';
            end if;
            --
            if EOP_In = '0' and CTRL_STATE = DMA_SEND then
                BSY_ERR <= '1'; -- End of DMA error.
            elsif EOP_In = '0' and CTRL_STATE = DMA_TARG_RCV then
                BSY_ERR <= '1'; -- End of DMA error.
            elsif EOP_In = '0' and CTRL_STATE = DMA_INIT_RCV then
                BSY_ERR <= '1'; -- End of DMA error.
            elsif DMA_EN = '0' then -- Reset error.
                INT <= '0';
            end if;
            --
            if EOP_EN = '1' and EOP_In = '0' and CTRL_STATE = DMA_SEND then
                INT <= '1'; -- End of DMA interrupt.
            elsif EOP_EN = '1' and EOP_In = '0' and CTRL_STATE = DMA_TARG_RCV then
                INT <= '1'; -- End of DMA interrupt.
            elsif EOP_EN = '1' and EOP_In = '0' and CTRL_STATE = DMA_INIT_RCV then
                INT <= '1'; -- End of DMA interrupt.
            elsif DMA_EN = '0' then -- Reset interrupt.
                INT <= '0';
            end if;

            --
            if PHSM = '0' then
                INT <= '1'; -- Phase mismatch interrupt.
            elsif DMA_EN = '0' then -- Reset interrupts.
                INT <= '0';
            end if;
            --
            if SEL_INn = '0' and BSY_INn = '1' and SER_ID = '1' then
                INT <= '1'; -- (Re)Selection interrupt.
            elsif RPI = '1' then -- Reset interrupts.
                INT <= '0';
            end if;
            --
            if BSY_INn = '1' and TMP < x"111" then
                TMP := TMP + '1'; -- Bus settle delay.
            elsif BSY_INn = '0' then
                TMP := "000";
            end if;
            --
            if BSY_DISn = '1' and BSY_INn = '1' and TMP = x"111" then
                INT <= '1'; -- Busy monitoring interrupt.
                BSY_ERR <= '1';
            elsif RPI = '1' then -- Reset interrupts.
                INT <= '0';
                BSY_ERR <= '0';
            end if;
            --
        end if;
    end process INTERRUPTS;
end BEHAVIOUR;