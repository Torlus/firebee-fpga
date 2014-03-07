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
---- The digital PLL is responsible to detect the incoming serial ----
---- data stream and provide a system clock synchronous signal    ----
---- containing the data and clock information.                   ----
---- To understand how the code works in detail refer to the free ----
---- US patent no. 4,780,844.                                     ----
----                                                              ----
---- Attention: The settings for TOP and BOTTOM, which control    ----
---- the PLL frequency and for PHASE_CORR which control the PLL   ----
---- phase are rather critical for a good read condition! To test ----
---- the PLL in the WD1772 compatible core do the following:      ----
---- Sample on an oscilloscope on one channel the falling edge of ----
---- the RDn pulse and on the other channel the PLL_DSTRB. The    ----
---- RDn must be located exactly between the PLL_DSTRB pulses.    ----
---- Otherwise, the parameters TOP, BOTTOM and PHASE_CORR have to ----
---- be optimized.                                                ----
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
--   Initial Release: the MFM portion for HD and DD floppies is tested.
--   The FM mode (DDEn = '1') is not completely tested due to lack of FM
--   drives.
-- Revision 2K6B  2006/11/05 WF
--   Modified Source to compile with the Xilinx ISE.
-- Revision 2K7B  2006/12/29 WF
--   Introduced several improvements based on a very good examination
--   of the pll code by Jean Louis-Guerin.
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
-- Revision 2K8B  2008/12/24 WF
--   Improvement of the INPORT process.
--   Bugfix of the FREQ_AMOUNT counter: now stops if its value is zero.
--   Several changes concerning the PLL parameters to improve the
--     stability of the PLL.
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF1772IP_DIGITAL_PLL is
	generic(
		-- The valid range of the period counter of the PLL is given by the TOP and BOTTOM 
		-- limits. The counter range is therefore BOTTOM <= counter value <= TOP.
		-- The generic PHASE_CORR is responsible fo the center setting of PLL_DSTRB concerning
		-- the RDn period.
		-- The nominal frequency setting is 128. So it is recommended to use TOP and BOTTOM
		-- settings symmetrically around 128. If TOP = BOTTOM = 128, the frequency control 
        -- is disabled. TOP + PHASE_CORR may not exceed a value of 255. BOTTOM - PHASE_CORR
        -- may not drop below zero.
        TOP			: integer range 0 to 255 := 152; -- +18.0%
        BOTTOM		: integer range 0 to 255 := 104; -- -18.0%
        PHASE_CORR	: integer range 0 to 128 := 75
	);
	port(
		-- System control
		CLK		: in bit; -- 16MHz clock.
		RESETn	: in bit;

		-- Controls
		DDEn		: in bit; -- Double density enable.
		HDTYPE		: in bit; -- This control is '1' when HD disks are inserted.
		DISK_RWn	: in bit; -- Read write control.

		-- Data and clock lines
		RDn			: in bit; -- Read signal from the disk.
		PLL_D		: out bit; -- Synchronous read signal.
		PLL_DSTRB	: out bit -- Read strobe.
	);
end WF1772IP_DIGITAL_PLL;

architecture BEHAVIOR of WF1772IP_DIGITAL_PLL is
signal RD_In				: bit;
signal UP, DOWN				: bit;
signal PHASE_DECREASE		: bit;
signal PHASE_INCREASE		: bit;
signal HI_STOP, LOW_STOP	: bit;
signal PER_CNT				: std_logic_vector(7 downto 0);
signal ADDER_IN				: std_logic_vector(7 downto 0);
signal ADDER_MSBs			: bit_vector(2 downto 0);
signal RD_PULSE				: bit;
signal ROLL_OVER			: bit;
signal HISTORY_REG			: bit_vector(1 downto 0);
signal ERROR_HISTORY		: integer range 0 to 2;
begin
	INPORT: process
	-- This process is necessary due to the poor quality of the rising
	-- edge of RDn. Let it work on the negative clock edge.
	begin
        wait until CLK = '0' and CLK' event;
         RD_In <= RDn;
	end process INPORT;

	EDGEDETECT: process(RESETn, CLK)
    -- This process forms a falling edge detector for the incoming
	-- data read port. The output (RD_PULSE) goes high for exactly
	-- one clock period after the RDn is low and the positive
	-- clock edge is detected.
	variable LOCK : boolean;
	begin
		if RESETn = '0' then
			RD_PULSE <= '0';
			LOCK := false;
        elsif CLK = '1' and CLK' event then
			if DISK_RWn = '0' then -- Disable detector in write mode.
				RD_PULSE <= '0';
            elsif RD_In = '0' and LOCK = false then
				RD_PULSE <= '1'; -- READ_PULSE is inverted against RDn
				LOCK := true;
            elsif RD_In = '1' then
				LOCK := false;
				RD_PULSE <= '0';
			else
				RD_PULSE <= '0';
			end if;
		end if;
	end process EDGEDETECT;

	PERIOD_CNT: process(RESETn, CLK)
	-- This process provides the nominal variable added to the adder. To achieve a good 
    -- settling time of the PLL in all cases, the period counter is controlled via the DDEn
    -- and HDTYPE flags respective to its added value. Be aware, that in case of adding "10"
    -- or "11", the TOP value may be exceeded or the period counter may drop below the BOTTOM
	-- value. The higher the value added, the faster will be the settling time of phase locked
	-- loop .
	begin
		if RESETn = '0' then
			PER_CNT <= "10000000"; -- Initial value is 128.
		elsif CLK = '1' and CLK' event then
            if UP = '1' then
                PER_CNT <= PER_CNT + '1';
            elsif DOWN = '1' then
                PER_CNT <= PER_CNT - '1';
			end if;
		end if;
	end process PERIOD_CNT;

    HI_STOP <= 	'1' when PER_CNT >= TOP else '0';
    LOW_STOP <= '1' when PER_CNT <= BOTTOM else '0';

	ADDER_IN <= -- This DISK_RWn = '0' implementation keeps the last phase information
				-- of the PLL in read from disk mode. It should be a good solution concer-
				-- ning alternative read write cycles.
				"10000000" when DISK_RWn = '0' else -- Nominal value for write to disk. 
                PER_CNT + PHASE_CORR when PHASE_INCREASE = '1' else -- Phase lags.
                PER_CNT - PHASE_CORR when PHASE_DECREASE = '1' else -- Phase leeds.
				PER_CNT; -- No phase correction;

	ADDER: process(RESETn, CLK, DDEn, HDTYPE)
	-- Clock adjustment: The clock cycle is 62.5ns for the 16MHz system clock. 
	-- The offset (LSBs) of the adder input is chosen to be conform with the required
	-- rollover period in the different DDEn and HDTYPE modi as follows:
	-- With a nominal adder input term of 128:
	-- The adder rolls over every 4us for DDEn = 1 and HDTYPE = 0.
	-- The adder rolls over every 2us for DDEn = 1 and HDTYPE = 1.
	-- The adder rolls over every 2us for DDEn = 0 and HDTYPE = 0.
	-- The adder rolls over every 1us for DDEn = 0 and HDTYPE = 1.
	-- The given times are the half of a data period time in MFM or FM.
	variable ADDER_DATA	: std_logic_vector(12 downto 0);
	begin
		if RESETn = '0' then
			ADDER_DATA := (others => '0');
		elsif CLK = '1' and CLK' event then
			ADDER_DATA := ADDER_DATA + ADDER_IN;
		end if;
		--
		case DDEn & HDTYPE is
			when "01" => -- MFM mode using HD disks, results in 1us inspection period:
				ADDER_MSBs <= To_BitVector(ADDER_DATA(10 downto 8));
			when "00" => -- MFM mode using DD disks, results in 2us inspection period:
				ADDER_MSBs <= To_BitVector(ADDER_DATA(11 downto 9));
			when "11" => -- FM mode using HD disks, results in 2us inspection period:
				ADDER_MSBs <= To_BitVector(ADDER_DATA(11 downto 9));
			when "10" => -- FM mode using DD disks, results in 4us inspection period:
				ADDER_MSBs <= To_BitVector(ADDER_DATA(12 downto 10));
		end case;
	end process ADDER;

	ROLLOVER: process(RESETn, CLK)
	-- This process forms a falling edge detector for the detection
	-- of the adder's rollover time. The output goes low for exactly
	-- one clock period after the rollover is detected and the positive
	-- clock edge appears.
	variable LOCK : boolean;
	begin
		if RESETn = '0' then
			ROLL_OVER <= '0';
			LOCK := false;
		elsif CLK = '1' and CLK' event then
			if ADDER_MSBs /= "111" and LOCK = false then
				ROLL_OVER <= '1';
				LOCK := true;
			elsif ADDER_MSBs = "111" then
				LOCK := false;
				ROLL_OVER <= '0';
			else
				ROLL_OVER <= '0';
			end if;
		end if;
	end process ROLLOVER;
	PLL_DSTRB <= ROLL_OVER;

	DATA_FLIP_FLOP: process(RESETn, CLK, RD_PULSE)
	-- This flip-flop is responsible for 'catching' the read pulses of the
	-- serial data input. 
	begin
		if RESETn = '0' then
			PLL_D <= '0'; -- Asynchronous reset.
		elsif CLK = '1' and CLK' event then
			if RD_PULSE = '1' then
				PLL_D <= '1'; -- Read pulse detected.
			elsif ROLL_OVER = '1' then
				PLL_D <= '0';
			end if;
		end if;
	end process DATA_FLIP_FLOP;

	WIN_HISTORY: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			HISTORY_REG <= "00";
		elsif CLK = '1' and CLK' event then
			if RD_PULSE = '1' then
				HISTORY_REG <= ADDER_MSBs(2) & HISTORY_REG(1);
			end if;
		end if;
	end process WIN_HISTORY;
	
	-- Error history:
	-- This signal indicates the number of consequtive levels of the adder's
	-- MSB and the history register as shown in the following table. The default
	-- setting of 0 was added to compile with the Xilinx ISE.
	ERROR_HISTORY <= 	2 when ADDER_MSBs(2) = '0' and HISTORY_REG = "00" else -- Speed strongly up.
						1 when ADDER_MSBs(2) = '0' and HISTORY_REG = "01" else -- Speed up.
						0 when ADDER_MSBs(2) = '0' and HISTORY_REG = "10" else -- o.k.
						0 when ADDER_MSBs(2) = '0' and HISTORY_REG = "11" else -- Now adjusted.
						0 when ADDER_MSBs(2) = '1' and HISTORY_REG = "00" else -- Now adjusted.
						0 when ADDER_MSBs(2) = '1' and HISTORY_REG = "01" else -- o.k.
						1 when ADDER_MSBs(2) = '1' and HISTORY_REG = "10" else -- Slow down.
						2 when ADDER_MSBs(2) = '1' and HISTORY_REG = "11" else 0; -- Slow strongly down.

	FREQUENCY_DECODER: process(RESETn, CLK, HI_STOP, LOW_STOP)
	-- The frequency decoder controls the period of the data inspection window respective to the
	-- ERROR_HISTORY for the 11 bit adder is as follows:
	-- ERROR_HISTORY = 0: 
	--						-> no correction necessary <-
	-- ERROR_HISTORY = 1:
	-- MSBs input:			7	6	5	4	3	2	1	0
	-- Correction output:  -3  -2  -1   0   0  +1  +2  +3
	-- ERROR_HISTORY = 2:
	-- MSBs input:			7	6	5	4	3	2	1	0
	-- Correction output:  -4  -3  -2  -1  +1  +2  +3  +4
	-- The most significant bit of the FREQ_AMOUNT controls incrementation or decrementation
	-- of the adder (0 is up).
	variable FREQ_AMOUNT: std_logic_vector(3 downto 0);
	begin
		if RESETn = '0' then
			FREQ_AMOUNT := "0000";
		elsif CLK = '1' and CLK' event then
            if RD_PULSE = '1' then -- Load the frequency amount register.
				case ERROR_HISTORY is
					when 2 =>
						case ADDER_MSBs is
							when "000" => FREQ_AMOUNT := "0100";
							when "001" => FREQ_AMOUNT := "0011";
							when "010" => FREQ_AMOUNT := "0010";
							when "011" => FREQ_AMOUNT := "0001";
							when "100" => FREQ_AMOUNT := "1001";
							when "101" => FREQ_AMOUNT := "1010";
							when "110" => FREQ_AMOUNT := "1011";
							when "111" => FREQ_AMOUNT := "1100";
						end case;
					when 1 =>
						case ADDER_MSBs is
							when "000" => FREQ_AMOUNT := "0011";
							when "001" => FREQ_AMOUNT := "0010";
							when "010" => FREQ_AMOUNT := "0001";
							when "011" => FREQ_AMOUNT := "0000";
							when "100" => FREQ_AMOUNT := "1000";
							when "101" => FREQ_AMOUNT := "1001";
							when "110" => FREQ_AMOUNT := "1010";
							when "111" => FREQ_AMOUNT := "1011";
						end case;
					when others =>
						FREQ_AMOUNT := "0000";
				end case;
            elsif FREQ_AMOUNT(2 downto 0) > "000" then
				FREQ_AMOUNT := FREQ_AMOUNT - '1'; -- Modify the frequency amount register.
			end if;
		end if;
		--
		if FREQ_AMOUNT(3) = '0' and FREQ_AMOUNT(2 downto 0) /= "000" and HI_STOP = '0' then
		-- FREQ_AMOUNT(3) = '0' means Frequency is too low. Count up when counter is not at HI_STOP.
			UP <= '1';
			DOWN <= '0';
		elsif FREQ_AMOUNT(3) = '1' and FREQ_AMOUNT (2 downto 0) /= "000" and LOW_STOP = '0' then
		-- FREQ_AMOUNT(3) = '1' means Frequency is too high. Count down when counter is not at LOW_STOP.
			UP <= '0';
			DOWN <= '1';
		else
			UP <= '0';
			DOWN <= '0';
		end if;
	end process FREQUENCY_DECODER;

	PHASE_DECODER: process(RESETn, CLK)
	-- The phase decoder depends on the value of ADDER_MSBs. If the phase leeds, the most significant bit
	-- of PHASE_AMOUNT indicates with a '0', that the next rollover should appear earlier. In case of a
	-- phase lag, the next rollover should come later (indicated by a '1' of the most significant bit of
	-- PHASE_AMOUNT).
	-- This implementation gives the freedom to adjust the phase amount individually for every mode
	-- depending on DDEn and HDTYPE.
	variable PHASE_AMOUNT: std_logic_vector(5 downto 0);
	begin
		if RESETn = '0' then
			PHASE_AMOUNT := "000000";
		elsif CLK = '1' and CLK' event then
            if RD_PULSE = '1' and DDEn = '1' and HDTYPE = '0' then -- FM mode, single density.
				case ADDER_MSBs is -- Multiplier: 4.
					when "000" => PHASE_AMOUNT := "010000";
					when "001" => PHASE_AMOUNT := "001101";
					when "010" => PHASE_AMOUNT := "001000";
					when "011" => PHASE_AMOUNT := "000100";
					when "100" => PHASE_AMOUNT := "100100";
					when "101" => PHASE_AMOUNT := "101000";
					when "110" => PHASE_AMOUNT := "101100";
					when "111" => PHASE_AMOUNT := "110000";
				end case;
			elsif RD_PULSE = '1' and DDEn = '1' and HDTYPE = '1' then -- FM mode, double density
				case ADDER_MSBs is -- Multiplier: 2.
					when "000" => PHASE_AMOUNT := "001000";
					when "001" => PHASE_AMOUNT := "000110";
					when "010" => PHASE_AMOUNT := "000100";
					when "011" => PHASE_AMOUNT := "000010";
					when "100" => PHASE_AMOUNT := "100010";
					when "101" => PHASE_AMOUNT := "100100";
					when "110" => PHASE_AMOUNT := "100110";
					when "111" => PHASE_AMOUNT := "101000";
				end case;
            elsif RD_PULSE = '1' and DDEn = '0' and HDTYPE = '0' then -- MFM mode, single density
				case ADDER_MSBs is -- Multiplier: 2.
					when "000" => PHASE_AMOUNT := "000110";
					when "001" => PHASE_AMOUNT := "000100";
					when "010" => PHASE_AMOUNT := "000011";
					when "011" => PHASE_AMOUNT := "000010";
					when "100" => PHASE_AMOUNT := "100010";
					when "101" => PHASE_AMOUNT := "100011";
					when "110" => PHASE_AMOUNT := "100100";
					when "111" => PHASE_AMOUNT := "100110";
				end case;
			elsif RD_PULSE = '1' and DDEn = '0' and HDTYPE = '1' then -- MFM mode, double density.
				case ADDER_MSBs is -- Multiplier: 1.
					when "000" => PHASE_AMOUNT := "000100";
					when "001" => PHASE_AMOUNT := "000011";
					when "010" => PHASE_AMOUNT := "000010";
					when "011" => PHASE_AMOUNT := "000001";
					when "100" => PHASE_AMOUNT := "100001";
					when "101" => PHASE_AMOUNT := "100010";
					when "110" => PHASE_AMOUNT := "100011";
					when "111" => PHASE_AMOUNT := "100100";
				end case;
			else -- Modify phase amount register:
                if PHASE_AMOUNT(4 downto 0) > x"0" then
                    PHASE_AMOUNT := PHASE_AMOUNT - 1;
				end if;
			end if;
		end if;
		--
        if PHASE_AMOUNT(5) = '0' and PHASE_AMOUNT(4 downto 0) > x"0" then
		-- PHASE_AMOUNT(5) = '0' means, that the phase leeds.
			PHASE_INCREASE <= '1'; -- Speed phase up, accelerate next rollover.
			PHASE_DECREASE <= '0';
        elsif PHASE_AMOUNT(5) = '1' and PHASE_AMOUNT(4 downto 0) > x"0" then
		-- PHASE_AMOUNT(5) = '1' means, that the phase lags.
			PHASE_INCREASE <= '0';
			PHASE_DECREASE <= '1'; -- Speed phase down, delay of next rollover.
		else
			PHASE_INCREASE <= '0';
			PHASE_DECREASE <= '0';
		end if;
	end process PHASE_DECODER;
end architecture BEHAVIOR;