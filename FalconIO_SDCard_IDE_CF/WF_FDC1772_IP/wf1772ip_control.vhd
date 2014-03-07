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
---- This is file the control unit providing all signals for the  ----
---- data processing units like registers, addressmark detector,  ----
---- data separator, CRC redundancy checker or transceiver.       ----
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
--   Fixed the polarity of the precompensation flag.
--   The flag is no active '0'. Thanks to Jorma
--   Oksanen for the information.
-- Revision 2K8A  2008/02/26 WF
--   Fixed a bug in the 6ms delay. Thanks to Lyndon Amsdon.
-- Revision 2K8B  2008/12/24 WF
--   Bugfixes to avoid hanging state machine.
--   Changed DELAY_30MS to DELAY_15MS, which is the correct value. Thanks to L. Amsdon for the information.
--   Removed CRC_BUSY.
--   Fixed a bug in the Delay for the state T2_VERIFY_AM.
-- Revision 2K9A  2009/06/20 WF
--   Fix to provide correct LOST_DATA_TR00 flag during seek command.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF1772IP_CONTROL is
	port(
		-- System control:
		CLK		: in bit;
		RESETn	: in bit;

		-- Chip control signals:
		A1, A0	: in bit;
		RWn		: in bit;
		CSn		: in bit;
		DDEn	: in bit;

		-- Registers:
		DR	: in bit_vector(7 downto 0); -- Data register.
		CMD	: in std_logic_vector(7 downto 0); -- Command register.
		DSR	: in std_logic_vector(7 downto 0); -- Shift register.
		TR	: in std_logic_vector(7 downto 0); -- Track register.
		SR	: in std_logic_vector(7 downto 0); -- Sector register.

		-- Status flags:
		MO				: buffer bit; -- Motor on status flag.
		WR_PR			: out bit; -- Write protect status flag.
		SPINUP_RECTYPE	: out bit; -- Spin up / record type status flag.
        SEEK_RNF		: out bit; -- Seek error / record not found status flag.
		CRC_ERRFLAG		: out bit; -- CRC status flag.
		LOST_DATA_TR00	: out bit; -- Status flag indicates lost data or track 00 position.
        DRQ				: out bit; -- Data request.
		DRQ_IPn			: out bit; -- Data request status flag.
		BUSY			: buffer bit; -- BUSY status flag.

		-- Address mark detector controls:
		AM_2_DISK	: out bit;	-- Enables / disables the address mark detector.
		ID_AM		: in bit; 	-- Address mark of the ID field
		DATA_AM		: in bit; 	-- Address mark of the data field
		DDATA_AM	: in bit; 	-- Address mark of a deleted data field

		-- CRC unit controls:
		CRC_ERR		: in bit; 	-- CRC decoder's error.
		CRC_PRES	: out bit;	-- Preset CRC during write operations.

		-- Track register controls:
		TR_PRES		: out bit;	-- Set x"FF".
		TR_CLR		: out bit;	-- Clear.
		TR_INC		: out bit;	-- Increment.
		TR_DEC		: out bit;	-- Decrement.

		-- Sector register control:
		SR_LOAD		: out bit; -- Load.
		SR_INC		: out bit; -- Increment.
		-- The TRACK_NR is required during the type III command
		--  'Read Address'. TRACK_NR is the content of the TRACKMEM.
		TRACK_NR	: out std_logic_vector(7 downto 0);

		-- DATA register control:
		DR_CLR		: out bit; -- Clear.
		DR_LOAD		: out bit; -- LOAD.

		-- Shift register control:
		SHFT_LOAD_ND	: out bit; -- Load normal data.
		SHFT_LOAD_SD	: out bit; -- Load special data.

		-- Transceiver controls:
		CRC_2_DISK	: out bit;	-- Cause the Transceiver to write out CRC data.
		DSR_2_DISK	: out bit;	-- Cause the Transceiver to write normal data.
		FF_2_DISK	: out bit;	-- Cause the Transceiver to write x"FF" bytes.
		PRECOMP_EN	: out bit; 	-- Enables the write precompensation.

		-- Miscellaneous Controls:
		DATA_STRB 	: in bit;	-- Data strobe (read and write operation)
		WPRTn		: in bit; 	-- Write protect flag
		IPn			: in bit; 	-- Index pulse flag
		TRACK00n	: in bit; 	-- Track zero flag
		DISK_RWn	: out bit;  -- This signal reflects the data direction.
		DIRC		: out bit;	-- Step direction control.
		STEP		: out bit;	-- Step pulse.
		WG			: out bit;	-- Write gate control.
		INTRQ		: out bit 	-- Interrupt request flag.
	);
end WF1772IP_CONTROL;

architecture BEHAVIOR of WF1772IP_CONTROL is
-- The control state machine for the three command types I, II and III 
-- (10 commands) has 73 states:
type CMD_STATES is(	IDLE, INIT, SPINUP, DELAY_15MS, DECODE, T1_SEEK_RESTORE, T1_STEPPING, 
					T1_LOAD_SHFT, T1_COMP_TR_DSR, T1_CHECK_DIR, T1_HEAD_CTRL, T1_STEP, T1_TRAP, T1_STEP_DELAY,
					T1_SPINDOWN, T1_SCAN_TRACK, T1_SCAN_CRC, T1_VERIFY_DELAY, T1_VERIFY_CRC, T2_RD_WR_SECT, 
					T2_INIT, T2_SCAN_TRACK, T2_SCAN_SECT, T2_SCAN_LEN, T2_VERIFY_CRC_1, T2_VERIFY_AM, T2_FIRSTBYTE, 
					T2_LOAD_DATA, T2_NEXTBYTE, T2_VERIFY_DRQ_1, T2_RDSTAT, T2_VERIFY_CRC_2, 
					T2_MULTISECT, T2_DELAY_B2, T2_SET_DRQ, T2_DELAY_B8, T2_VERIFY_DRQ_2, 
					T2_DELAY_B1, T2_CHECK_MODE, T2_DELAY_B11, T2_WR_LEADIN, T2_WR_AM, 
					T2_LOAD_SHFT, T2_WR_BYTE, T2_VERIFY_DRQ_3, T2_DATALOST, T2_WRSTAT, T2_WR_CRC, 
					T2_WR_FF, T3_WR, T3_DELAY_B3, T3_VERIFY_DRQ, T3_CHECK_INDEX_1, T3_LOAD_SHFT, 
					T3_WR_DATA, T3_CHECK_INDEX_2, T3_DATALOST, T3_RD_TRACK, T3_SHIFT, 
					T3_CHECK_INDEX_3, T3_DETECT_AM, T3_CHECK_BYTE, T3_CHECK_DR, T3_LOAD_DATA_1, 
					T3_SET_DRQ_1, T3_RD_ADR, T3_VERIFY_AM, T3_SHIFT_ADR, T3_LOAD_DATA_2, 
					T3_SET_DRQ_2, T3_CHECK_RD, T3_LOAD_SR, T3_VERIFY_CRC);
signal CMD_STATE		: CMD_STATES;
signal NEXT_CMD_STATE	: CMD_STATES;
signal DATA_WR			: boolean;
signal DATA_RD			: boolean;
signal CMD_WR			: boolean;
signal STAT_RD			: boolean;
signal DELAY			: boolean;
signal DRQ_I            : bit;
signal INDEX_CNT		: boolean;
signal DIR				: bit;
signal INDEX_MARK		: bit;
signal STEP_TRAP		: boolean;
signal TYPE_IV_BREAK	: boolean;
signal BYTE_RDY			: boolean;
signal SECT_LEN 		: std_logic_vector(10 downto 0);
signal TRACKMEM			: std_logic_vector(7 downto 0);
signal T3_TRADR			: boolean;
signal T3_DATATYPE		: bit_vector(7 downto 0);
begin
	-- The Forced interrupt stops any command at the end of an internal micro instruction.
	-- Forced interrupt waits until ALU operations in progress are complete (CRC calculations,
	-- compares etc.). the TYPE_IV_BREAK controls this behavior.
    TYPE_IV_BREAK <= true when CMD(7 downto 4) = x"D" and DELAY = true else false;

	CMD_REG: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			CMD_STATE <= IDLE;
		elsif CLK = '1' and CLK' event then
			if TYPE_IV_BREAK = true then
				CMD_STATE <= IDLE; -- Forced interrupt break.
			else
				CMD_STATE <= NEXT_CMD_STATE; -- Normal operation.
			end if;
		end if;
	end process CMD_REG;

	CMD_DECODER: process(CMD_STATE, CMD, DSR, TR, SR, INDEX_CNT, IPn, INDEX_MARK, DELAY, DIR, MO, CMD_WR, DRQ_I, 
						 DDEn, CRC_ERR, TRACK00n, STEP_TRAP, ID_AM, DATA_AM, DDATA_AM, WPRTn, SECT_LEN, BYTE_RDY,
						 T3_TRADR)
	begin
		case CMD_STATE is
			--------------------------------------------------------------------
			------------------ type1, -2, -3 command stuff ---------------------
			--------------------------------------------------------------------
			when IDLE =>
				-- The write access to the command register indicates a new command.
				-- Any command received (type1, -2 or -3 but not type4):
				if CMD_WR = true and CMD /= x"FF" and CMD(7 downto 4) /= "1101" then
					NEXT_CMD_STATE <= INIT;
				else
					NEXT_CMD_STATE <= IDLE; -- No CMD detected.
				end if;
			when INIT =>
				-- The process goes on when the CMD_WR flag is released.
				if CMD_WR = false and CMD(3) = '0' and MO = '0' then
					-- Do not enter the SPINUP sequence 
					-- when the motor is already on (MO = '1').
					NEXT_CMD_STATE <= SPINUP;
				elsif CMD_WR = false then
					-- Proceed with the DELAY_15MS when the motor was
					-- already on or when the SPINUP sequence is
					-- disabled (CMD(3) = '1').
					NEXT_CMD_STATE <= DELAY_15MS;
				else
					NEXT_CMD_STATE <= INIT;
				end if;
			when SPINUP =>
				if INDEX_CNT = true then -- proceed after 6 revolutions
					NEXT_CMD_STATE <= DELAY_15MS;
				else
					NEXT_CMD_STATE <= SPINUP;
				end if;
			when DELAY_15MS =>
				if CMD(7) = '0' then -- No delay for type1 commands.
					NEXT_CMD_STATE <= DECODE;
				elsif CMD(7) = '1' and CMD(2) = '0' then -- Delay for type2 and -3 disabled.
					NEXT_CMD_STATE <= DECODE;
				elsif CMD(7) = '1' and CMD(2) = '1' and DELAY = true then -- Delay enabled by CMD(2).
					NEXT_CMD_STATE <= DECODE;
				else
					NEXT_CMD_STATE <= DELAY_15MS;
				end if;
			when DECODE =>
				case CMD(7 downto 5) is 
					when "000" => -- 'restore', 'seek'.
						NEXT_CMD_STATE <= T1_SEEK_RESTORE;
					when "001" |"010" | "011" => -- 'step', 'step in', 'step out'.
						NEXT_CMD_STATE <= T1_STEPPING;
					when "100" | "101" => -- 'read sector', 'write sector'
						NEXT_CMD_STATE <= T2_RD_WR_SECT;
					when "110" => -- 'read address'.
						-- "110" is also used by the 'force interrupt'.
						-- There will result no wrong encoding because
						-- the 'force intterrupt' is predecoded in IDLE.
						NEXT_CMD_STATE <= T3_RD_ADR;
					when "111" => -- 'read track', 'write track'.
						case CMD(4) is
							when '0' =>	NEXT_CMD_STATE <= T3_RD_TRACK;
							when '1' => NEXT_CMD_STATE <= T3_WR;
							when others => NEXT_CMD_STATE <= T3_WR; -- Dummy for U, X, Z, W, H, L, -.
						end case;
					when others => 
						-- The following NEXT_CMD_STATE is chosen to compile fine with
						-- the Xilinx ISE not to produce a latch.
						NEXT_CMD_STATE <= IDLE; -- Never true due to IDLE preselection.
				end case;
			--------------------------------------------------------------------
			------------------ special type1 command stuff ---------------------
			--------------------------------------------------------------------
			when T1_SEEK_RESTORE =>
				-- In this state, the data register and the track register are updated, if the
				-- command is a RESTORE. The update is done further down with the track register
				-- and the data register controls.
				NEXT_CMD_STATE <= T1_LOAD_SHFT;
			when T1_STEPPING =>
				if CMD(4) = '1' then -- '1' means update track register.
					NEXT_CMD_STATE <= T1_CHECK_DIR;
				else
					NEXT_CMD_STATE <= T1_HEAD_CTRL;
				end if;
			when T1_LOAD_SHFT =>
				NEXT_CMD_STATE <= T1_COMP_TR_DSR;
			when T1_COMP_TR_DSR =>
				if DSR = TR then
					NEXT_CMD_STATE <= T1_VERIFY_DELAY;
				else
					-- The direction control is done further down.
					NEXT_CMD_STATE <= T1_CHECK_DIR;
				end if;
			when T1_CHECK_DIR =>
				-- Track register modifications are done in
				-- statements further down.
				-- The delay is to provide the timing of the WD1772 which is DIR to step =
				-- 24us in MFM mode and 48us in FM mode.
				if DELAY = true then
					NEXT_CMD_STATE <= T1_HEAD_CTRL;
				else
					NEXT_CMD_STATE <= T1_CHECK_DIR;
				end if;
			when T1_HEAD_CTRL =>
				if TRACK00n = '0' and DIR = '0' then
					NEXT_CMD_STATE <= T1_VERIFY_DELAY;
				else
					NEXT_CMD_STATE <= T1_STEP;
				end if;
			when T1_STEP =>
				NEXT_CMD_STATE <= T1_TRAP;
			when T1_TRAP =>
				if STEP_TRAP = true then
					NEXT_CMD_STATE <= IDLE; -- Break due to seek error.
				else
					NEXT_CMD_STATE <= T1_STEP_DELAY;
				end if;
			when T1_STEP_DELAY =>
				-- The delay in here is according to the CMD(1 downto 0) as follows:
				-- "11" = 3ms, "10" = 2ms, "01" = 12ms, "00" = 6ms.				
				if DELAY = true then
					case CMD(7 downto 5) is
						when "001" | "010" | "011" => -- STEP - STEP IN - STEP OUT.
							NEXT_CMD_STATE <= T1_VERIFY_DELAY;
						when others => -- Seek or restore command.
							NEXT_CMD_STATE <= T1_LOAD_SHFT;
					end case;
				else
					NEXT_CMD_STATE <= T1_STEP_DELAY;
				end if;
			when T1_VERIFY_DELAY =>
				if CMD(2) = '0' then -- No verify.
					NEXT_CMD_STATE <= IDLE;
				else
					if DELAY = true then -- Wait, if verify is active.
						NEXT_CMD_STATE <= T1_SPINDOWN;
					else
						NEXT_CMD_STATE <= T1_VERIFY_DELAY;
					end if;
				end if;
			when T1_SPINDOWN => -- Detect ID address mark in here.
				if INDEX_CNT = true then
					NEXT_CMD_STATE <= IDLE; -- Break due to timeout.
				elsif ID_AM = '1' then -- Addressmark found.
					NEXT_CMD_STATE <= T1_SCAN_TRACK;
				else
					NEXT_CMD_STATE <= T1_SPINDOWN;
				end if;
			when T1_SCAN_TRACK =>
				if DELAY = true then
					-- Track found if shift register (DSR) equals track register (TR).
					if DSR = TR then
						NEXT_CMD_STATE <= T1_SCAN_CRC;
					else
						NEXT_CMD_STATE <= T1_SPINDOWN;
					end if;
				else
					NEXT_CMD_STATE <= T1_SCAN_TRACK;
				end if;
			when T1_SCAN_CRC =>
				-- Scan the rest of the data header for correct CRC generation (3 Bytes).
				-- Sector number side select byte and data length byte.
				if DELAY = true then
					NEXT_CMD_STATE <= T1_VERIFY_CRC;
				else
					NEXT_CMD_STATE <= T1_SCAN_CRC;
				end if;
			when T1_VERIFY_CRC =>
                -- The CRC logic starts during T1_SPINDOWN (missing clock transitions).
                if DELAY = true then
                    if CRC_ERR = '1' then
                        NEXT_CMD_STATE <= T1_SPINDOWN; -- CRC error.
                    else
                        NEXT_CMD_STATE <= IDLE; -- Operation finished.
                    end if;		
                else
                    NEXT_CMD_STATE <= T1_VERIFY_CRC; -- Wait until CRC logic is ready.
                end if;
			--------------------------------------------------------------------
			------------------ special type2 command stuff ---------------------
			--------------------------------------------------------------------
			when T2_RD_WR_SECT =>
				if CMD(7 downto 5) = "101" and WPRTn = '0' then
					NEXT_CMD_STATE <= IDLE; -- Break due to write protected disk.
				else
					NEXT_CMD_STATE <= T2_INIT;
				end if;
			when T2_INIT =>
				if INDEX_CNT = true then
					NEXT_CMD_STATE <= IDLE; -- Break due to timeout.
				elsif ID_AM = '0' then
					NEXT_CMD_STATE <= T2_INIT; -- Wait for address mark.
				else -- INDEX_CNT = false and ID_AM = '1' -> ID address mark detected
					NEXT_CMD_STATE <= T2_SCAN_TRACK;
				end if;
			when T2_SCAN_TRACK =>
				-- Track found if shift register (DSR) equals track register (TR).
				if DELAY = true then
					if DSR = TR then
						NEXT_CMD_STATE <= T2_SCAN_SECT;
					else
						NEXT_CMD_STATE <= T2_INIT;
					end if;
				else
					NEXT_CMD_STATE <= T2_SCAN_TRACK;
				end if;
			when T2_SCAN_SECT =>
				-- Sector found if shift register (DSR) equals sector register (SR).
				if DELAY = true then
					if DSR = SR then
						NEXT_CMD_STATE <= T2_SCAN_LEN;
					else
						NEXT_CMD_STATE <= T2_INIT;
					end if;
				else
					NEXT_CMD_STATE <= T2_SCAN_SECT;
				end if;
			when T2_SCAN_LEN =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_VERIFY_CRC_1;
				else
					NEXT_CMD_STATE <= T2_SCAN_LEN;
				end if;
			when T2_VERIFY_CRC_1 =>
				-- The CRC logic starts after T2_INIT (missing clock transitions).
				if DELAY = true then
					if CRC_ERR = '1' then
						NEXT_CMD_STATE <= T2_INIT; -- CRC error.
					elsif CRC_ERR = '0' and CMD(7 downto 5) = "101" then
						NEXT_CMD_STATE <= T2_DELAY_B2; -- Comand is a write.
					else -- Command is a read.
						NEXT_CMD_STATE <= T2_VERIFY_AM;
					end if;
				else
					NEXT_CMD_STATE <= T2_VERIFY_CRC_1; -- Wait until CRC logic is ready.
				end if;
			when T2_VERIFY_AM =>
				if DATA_AM = '1' or DDATA_AM = '1' then -- Data address mark detected, go on.
					NEXT_CMD_STATE <= T2_FIRSTBYTE;
				elsif DELAY = false then -- Stay in this state.
					NEXT_CMD_STATE <= T2_VERIFY_AM;
				else
					NEXT_CMD_STATE <= T2_INIT; -- No addressmark detected.
				end if;
			when T2_FIRSTBYTE =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_LOAD_DATA;
				else
					NEXT_CMD_STATE <= T2_FIRSTBYTE;
				end if;
			when T2_LOAD_DATA =>
				NEXT_CMD_STATE <= T2_NEXTBYTE;
			when T2_NEXTBYTE =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_VERIFY_DRQ_1;
				else
					NEXT_CMD_STATE <= T2_NEXTBYTE;
				end if;
			when T2_VERIFY_DRQ_1 =>
				NEXT_CMD_STATE <= T2_RDSTAT;
			when T2_RDSTAT =>
				if SECT_LEN = "00000000000" then
					NEXT_CMD_STATE <= T2_VERIFY_CRC_2;
				else
					NEXT_CMD_STATE <= T2_LOAD_DATA;
				end if;
			when T2_VERIFY_CRC_2 =>
				-- The CRC logic starts after T2_VERIFY_AM (missing clock transitions).
				if DELAY = true then
					if CRC_ERR = '1' then
						NEXT_CMD_STATE <= IDLE; -- Break due to CRC error.
					else
						NEXT_CMD_STATE <= T2_MULTISECT;
					end if;
				else
					NEXT_CMD_STATE <= T2_VERIFY_CRC_2; -- Wait until CRC logic is ready.
				end if;
			when T2_MULTISECT =>
				if  CMD(4) = '1' then
					NEXT_CMD_STATE <= T2_RD_WR_SECT;
				else
					NEXT_CMD_STATE <= IDLE; -- Operation finished.
				end if;
			when T2_DELAY_B2 =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_SET_DRQ;
				else
					NEXT_CMD_STATE <= T2_DELAY_B2;
				end if;
			when T2_SET_DRQ =>
				NEXT_CMD_STATE <= T2_DELAY_B8;
			when T2_DELAY_B8 =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_VERIFY_DRQ_2;
				else
					NEXT_CMD_STATE <= T2_DELAY_B8;
				end if;
			when T2_VERIFY_DRQ_2 =>
				if DRQ_I = '0' then
					NEXT_CMD_STATE <= T2_DELAY_B1;
				else
					NEXT_CMD_STATE <= IDLE; -- Break due to lost data (no new data by host).
				end if;
			when T2_DELAY_B1 => 
				if DELAY = true then
					NEXT_CMD_STATE <= T2_CHECK_MODE;
				else
					NEXT_CMD_STATE <= T2_DELAY_B1;
				end if;
			when T2_CHECK_MODE =>
				if DDEn = '1' then -- FM mode
					NEXT_CMD_STATE <= T2_WR_LEADIN;
				else
					NEXT_CMD_STATE <= T2_DELAY_B11;
				end if;
			when T2_DELAY_B11 =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_WR_LEADIN;
				else
					NEXT_CMD_STATE <= T2_DELAY_B11;
				end if;
			when T2_WR_LEADIN =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_WR_AM;
				else
					NEXT_CMD_STATE <= T2_WR_LEADIN;
				end if;
			when T2_WR_AM => -- Write data address mark.
				if DELAY = true then
					NEXT_CMD_STATE <= T2_LOAD_SHFT;
				else
					NEXT_CMD_STATE <= T2_WR_AM;
				end if;
			when T2_LOAD_SHFT =>
					NEXT_CMD_STATE <= T2_WR_BYTE;
			when T2_WR_BYTE =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_VERIFY_DRQ_3;
				else
					NEXT_CMD_STATE <= T2_WR_BYTE;
				end if;
			when T2_VERIFY_DRQ_3 =>
				if DRQ_I = '0' then
					NEXT_CMD_STATE <= T2_WRSTAT;
				else
					NEXT_CMD_STATE <= T2_DATALOST;
				end if;
			when T2_DATALOST =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_WRSTAT;
				else
					NEXT_CMD_STATE <= T2_DATALOST;
				end if;
			when T2_WRSTAT =>
				if SECT_LEN = "00000000000" then
					NEXT_CMD_STATE <= T2_WR_CRC; -- Write operation finished.
				else
					NEXT_CMD_STATE <= T2_LOAD_SHFT;
				end if;
			when T2_WR_CRC =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_WR_FF;
				else
					NEXT_CMD_STATE <= T2_WR_CRC;
				end if;
			when T2_WR_FF =>
				if DELAY = true then
					NEXT_CMD_STATE <= T2_MULTISECT;
				else
					NEXT_CMD_STATE <= T2_WR_FF;
				end if;
			--------------------------------------------------------------------
			---------------- type3 write track command stuff -------------------
			--------------------------------------------------------------------
			when T3_WR =>
				if WPRTn = '0' then
					NEXT_CMD_STATE <= IDLE; -- Break due to write protected disk.
				else
					NEXT_CMD_STATE <= T3_DELAY_B3;
				end if;
			when T3_DELAY_B3 =>
				if DELAY = true then
					NEXT_CMD_STATE <= T3_VERIFY_DRQ;
				else
					NEXT_CMD_STATE <= T3_DELAY_B3;
				end if;
			when T3_VERIFY_DRQ =>
				if DRQ_I = '0' then
					NEXT_CMD_STATE <= T3_CHECK_INDEX_1;
				else
					NEXT_CMD_STATE <= IDLE; -- Break due to lost data (no new data by host).
				end if;				
			when T3_CHECK_INDEX_1 =>
				if IPn = '0' then
					NEXT_CMD_STATE <= T3_LOAD_SHFT;
				else
					NEXT_CMD_STATE <= T3_CHECK_INDEX_1;
				end if;				
			when T3_LOAD_SHFT =>
				NEXT_CMD_STATE <= T3_WR_DATA;
			when T3_WR_DATA =>
				if DELAY = true then
					NEXT_CMD_STATE <= T3_CHECK_INDEX_2;
				else
					NEXT_CMD_STATE <= T3_WR_DATA;
				end if;
			when T3_CHECK_INDEX_2 =>
				if INDEX_MARK = '1' then
					NEXT_CMD_STATE <= IDLE; -- End of track reached.
				elsif DRQ_I = '0' then -- New data has been loaded.
					NEXT_CMD_STATE <= T3_LOAD_SHFT; -- Fetch new data.
				else
					NEXT_CMD_STATE <= T3_DATALOST; -- Fill in nullbyte.
				end if;
			when T3_DATALOST =>
				if DELAY = true then
					NEXT_CMD_STATE <= T3_CHECK_INDEX_2;
				else
					NEXT_CMD_STATE <= T3_DATALOST;
				end if;
			--------------------------------------------------------------------
			--------------- type3 read track command stuff --------------------
			--------------------------------------------------------------------
			when T3_RD_TRACK =>
				-- wait for index pulse:
				if IPn = '0' then
					NEXT_CMD_STATE <= T3_SHIFT;
				else
					NEXT_CMD_STATE <= T3_RD_TRACK;
				end if;
			when T3_SHIFT =>
				if DELAY = true then
					NEXT_CMD_STATE <= T3_CHECK_INDEX_3;
				else
					NEXT_CMD_STATE <= T3_SHIFT;
				end if;
			when T3_CHECK_INDEX_3 =>
				if INDEX_MARK = '1' then
					NEXT_CMD_STATE <= IDLE; -- End of track reached.
				else
					NEXT_CMD_STATE <= T3_DETECT_AM;
				end if;
			when T3_DETECT_AM => -- Detect for ID address mark.
				if ID_AM = '1' then
					NEXT_CMD_STATE <= T3_CHECK_DR;
				else
					NEXT_CMD_STATE <= T3_CHECK_BYTE;
				end if;
			when T3_CHECK_BYTE =>
				if BYTE_RDY = true then
					NEXT_CMD_STATE <= T3_CHECK_DR;
				else
					NEXT_CMD_STATE <= T3_SHIFT;
				end if;
			when T3_CHECK_DR =>
				NEXT_CMD_STATE <= T3_LOAD_DATA_1;
			when T3_LOAD_DATA_1 =>
				NEXT_CMD_STATE <= T3_SET_DRQ_1;
			when T3_SET_DRQ_1 =>
				NEXT_CMD_STATE <= T3_SHIFT;
			--------------------------------------------------------------------
			---------------- type3 read address command stuff ------------------
			--------------------------------------------------------------------
			when T3_RD_ADR =>
				-- check for 6 index holes
				if INDEX_CNT = true then
					NEXT_CMD_STATE <= IDLE; -- Break due to timeout.
				else
					NEXT_CMD_STATE <= T3_VERIFY_AM;
				end if;
			when T3_VERIFY_AM => -- Check for existing ID address mark
				if ID_AM = '1' then
					NEXT_CMD_STATE <= T3_SHIFT_ADR;
				else
					NEXT_CMD_STATE <= T3_RD_ADR;
				end if;
			when T3_SHIFT_ADR =>
				if DELAY = true then
					NEXT_CMD_STATE <= T3_LOAD_DATA_2;
				else
					NEXT_CMD_STATE <= T3_SHIFT_ADR;
				end if;
			when T3_LOAD_DATA_2 =>
				NEXT_CMD_STATE <= T3_SET_DRQ_2;
			when T3_SET_DRQ_2 =>
				NEXT_CMD_STATE <= T3_CHECK_RD;
			when T3_CHECK_RD =>
				if T3_TRADR = true then
					NEXT_CMD_STATE <= T3_LOAD_SR;
				else
					NEXT_CMD_STATE <= T3_SHIFT_ADR;
				end if;
			when T3_LOAD_SR =>
				NEXT_CMD_STATE <= T3_VERIFY_CRC;
			when T3_VERIFY_CRC =>
				-- The CRC logic starts during T3_VERIFY_AM (missing clock transitions).
				if DELAY = true then
					NEXT_CMD_STATE <= IDLE; -- Operation finished (with or without CRC error).
				else
					NEXT_CMD_STATE <= T3_VERIFY_CRC; -- Wait until CRC logic is ready.
				end if;
		end case;
	end process CMD_DECODER;

	P_DELAY: process(RESETn, CLK, CMD_STATE, T3_DATATYPE, DDEn, CMD)
	-- This process is responsible to control the DELAY signal in the different command
	-- states of the main state machine. These states finish, if the signal DELAY is
	-- asserted. The condition for asserted DELAY is the correct number of data strobes
	-- which are supervised by the DATA_STRB inputs.
	-- Another condition is a time delay required in the following states:
	-- In DELAY_15MS there is a delay of 30ms.
	-- In T1_STEP_PULSE the delay is according to the CMD(1 downto 0) as follows: 
	-- "11" = 3ms, "10" = 2ms, "01" = 12ms, "00" = 6ms.
	-- In T1_VERIFY_DELAY there is a delay of 30ms.
	variable DELCNT : std_logic_vector(19 downto 0);
	begin
		if RESETn = '0' then
			DELCNT := (others => '0');
		elsif CLK = '1' and CLK' event then
			-- Reset the delay right after it occurs:
			if DELAY = true then
				DELCNT := (others => '0');
			elsif DATA_AM = '1' or DDATA_AM = '1' then -- Reset in command state T2_VERIFY_AM.
				DELCNT := (others => '0');
			else
				case CMD_STATE is
					-- Time delays work on CLK edges.
					when DELAY_15MS | T1_CHECK_DIR | T1_STEP_DELAY | T1_VERIFY_DELAY =>
						DELCNT := DELCNT + '1';
					-- Bit count delays work on data strobes.
					-- Read from disk operation:
                    when T1_SCAN_TRACK | T1_SCAN_CRC | T1_VERIFY_CRC | T2_SCAN_TRACK | T2_SCAN_SECT |
						 T2_SCAN_LEN | T2_VERIFY_CRC_1 | T2_VERIFY_AM  | T2_FIRSTBYTE |
						 T2_NEXTBYTE | T2_VERIFY_CRC_2 | T3_SHIFT | T3_SHIFT_ADR | T3_VERIFY_CRC =>
						if DATA_STRB = '1' then
							DELCNT := DELCNT + '1';
						end if;
					-- Write to disk operation:
					when T2_DELAY_B2 | T2_DELAY_B8 | T2_WR_LEADIN |
						 T2_WR_AM | T2_DELAY_B1 |T2_DELAY_B11 | T2_WR_BYTE | T2_DATALOST |
						 T2_WR_CRC | T2_WR_FF | T3_DELAY_B3 | T3_WR_DATA | T3_DATALOST   =>
						if DATA_STRB = '1' then
							DELCNT := DELCNT + '1';
						end if;
					when others =>
						DELCNT := (others => '0'); -- Clear the delay counter if not used.
				end case;
			end if;
		end if;

		case CMD_STATE is
			when DELAY_15MS | T1_VERIFY_DELAY =>
				case DELCNT is
                    --when x"75300" => DELAY <= true; -- 30ms
                    when x"3A980" => DELAY <= true; -- 15ms, thanks to L. Amsdon.
					when others => DELAY <= false;
				end case;
			when T1_CHECK_DIR =>
				if DDEn = '1' and DELCNT = x"00300" then -- 48us in FM
					DELAY <= true;
				elsif DDEn = '0' and DELCNT = x"00180" then -- 24us in MFM.
					DELAY <= true;
				else
					DELAY <= false;
				end if;
			when T1_STEP_DELAY =>
				if CMD(1 downto 0) = "11" and DELCNT >= x"0BB80" then -- 3ms
					DELAY <= true;
				elsif CMD(1 downto 0) = "10" and DELCNT >= x"07D00" then -- 2ms
					DELAY <= true;
				elsif CMD(1 downto 0) = "01" and DELCNT >= x"2EE00"  then -- 12ms
					DELAY <= true;
				elsif CMD(1 downto 0) = "00" and DELCNT >= x"17700" then -- 6ms
					DELAY <= true;
				else
					DELAY <= false;
				end if;			
			when T1_SCAN_TRACK | T2_SCAN_TRACK | T2_SCAN_LEN | T2_FIRSTBYTE | T2_NEXTBYTE |
							T2_WR_BYTE | T2_DATALOST | T2_WR_FF | T3_DATALOST | T3_SHIFT_ADR =>
				case DELCNT is
					when x"00008" => DELAY <= true; -- The delay in this case is 8 bit times.
					when others => DELAY <= false;
				end case;
			when T1_SCAN_CRC =>
				case DELCNT is
                    when x"00018" => DELAY <= true; -- Scan for 3 bytes.
					when others => DELAY <= false;
				end case;
			when T2_WR_AM =>
				if DDEn = '1' and DELCNT = x"00008" then -- Wait for 8 address mark bits (FM mode).
					DELAY <= true;
				elsif DDEn = '0' and DELCNT = x"00020" then -- Wait for 32 sync and address mark bits (MFM mode).
					DELAY <= true;
				else
					DELAY <= false;
				end if;
			when T2_VERIFY_AM =>
                if DDEn = '1' and DELCNT >= x"00148" then -- FM mode.
					DELAY <= true; -- (11+6+1)+1 = 19 Byte Times, plus 10 Byte times uncertainty.
                elsif DDEn = '0' and DELCNT >= x"00188" then -- MFM mode.
					DELAY <= true; -- (22+12+3+1)+1 = 39 Byte Times, plus 10 Byte times uncertainty.
				else
					DELAY <= false;
				end if;
			when T2_WR_LEADIN =>
				if DDEn = '1' and DELCNT = x"00030" then -- Scan for 48 zero bits in FM mode.
					DELAY <= true;
				elsif DDEn = '0' and DELCNT = x"00060" then -- Scan for 96 zero bits in MFM mode.
					DELAY <= true;
				else
					DELAY <= false;
				end if;
			when T2_DELAY_B1 =>
				case DELCNT is
					when x"00008" => DELAY <= true; -- Delay is 1 byte.
					when others => DELAY <= false;
				end case;
			when T3_DELAY_B3 =>
				case DELCNT is
					when x"00018" => DELAY <= true; -- Delay is 3 bytes.
					when others => DELAY <= false;
				end case;
			when T2_DELAY_B8 =>
				case DELCNT is
					when x"00040" => DELAY <= true; -- Delay is 8 bytes.
					when others => DELAY <= false;
				end case;
			when T2_DELAY_B11 =>
				case DELCNT is
					when x"00058" => DELAY <= true; -- Delay is 11 bytes.
					when others => DELAY <= false;
				end case;
			when T2_VERIFY_CRC_2 =>
				-- In this state the original WD1772 state machine causes the CRC data to appear 1 byte
				-- too early. The reason is the construction of the states T2_LOAD_DATA and T2_NEXTBYTE
				-- where the length counter and the DRQ flag are serviced in T2_LOAD_DATA. Therefore the
				-- delay is only 1 byte instead of 2.
				case DELCNT is
					when x"00008" => DELAY <= true; -- Scan for 2 bytes but wait only 1 byte.
					when others => DELAY <= false;
				end case;
            when T1_VERIFY_CRC | T2_SCAN_SECT | T2_VERIFY_CRC_1 | T2_DELAY_B2 | T2_WR_CRC | T3_VERIFY_CRC =>
				case DELCNT is
            when x"00010" => DELAY <= true; -- Scan for 2 bytes (e. g. side and sector in T2_SCAN_SECT).
					when others => DELAY <= false;
				end case;
			when T3_WR_DATA =>
				if T3_DATATYPE = x"F7" and DELCNT = x"00010" then -- Wait for 16 CRC bits.
					DELAY <= true;
				elsif T3_DATATYPE /= x"F7" and DELCNT = x"00008" then -- Wait for 8 data bits.
					DELAY <= true;
				else
					DELAY <= false;
				end if;
			when T3_SHIFT =>
				case DELCNT is
					when x"00001" => DELAY <= true; -- Scan just one data bit.
					when others => DELAY <= false;
				end case;
			when others =>
				DELAY <= false;
			end case;
	end process P_DELAY;

	INDEX_COUNTER: process(RESETn, CLK, CMD_STATE)
	-- This process is intended to control some command states via the index pulse behavior.
	-- In the original WD177x there is foreseen a delay of several index pulses (about 1s). 
	-- It is achieved by counting the index pulses of the disk. This encounters problems, 
	-- if the disk is not inserted. For this reason there is additionally to the index counter 
	-- a timeout which is active if there are no index pulses.
	variable CNT : std_logic_vector(3 downto 0);
	variable TIMEOUT : std_logic_vector(27 downto 0);
	variable LOCK : boolean;
	begin
		if RESETn = '0' then
			CNT := x"0";
			TIMEOUT := (others => '0');
			LOCK := false;
		elsif CLK = '1' and CLK' event then
			case CMD_STATE is
				-- Be aware that there must sometimes checked several states for the presence of IPn!
                when SPINUP | T1_SPINDOWN | T1_SCAN_TRACK | T1_SCAN_CRC | T1_VERIFY_CRC |
                              T2_INIT | T2_SCAN_TRACK | T2_SCAN_SECT |T2_SCAN_LEN | T2_VERIFY_CRC_1 | T3_RD_ADR | T3_VERIFY_AM =>
					if IPn = '0' and LOCK = false then -- Count the index pulses.
						CNT := CNT + '1';
						LOCK := true;
					elsif IPn = '1' then
						LOCK := false;
					end if;
					--
					if TIMEOUT < x"17FFFFF" then -- Timeout of about 1.5s.
						TIMEOUT := TIMEOUT + '1';
					end if;
				when others =>
					CNT := x"0";
					TIMEOUT := (others => '0');
			end case;
		end if;
		--
		if CMD_STATE = SPINUP and (CNT = "110" or TIMEOUT = x"17FFFFF") then -- 6 pulses or timeout.
			INDEX_CNT <= true;
		elsif CMD_STATE = T1_SPINDOWN and (CNT = "110" or TIMEOUT = x"17FFFFF") then -- 6 pulses or timeout.
			INDEX_CNT <= true;
		elsif CMD_STATE = T2_INIT and (CNT = "101" or TIMEOUT = x"17FFFFF") then -- 5 pulses or timeout.
			INDEX_CNT <= true;
		elsif CMD_STATE = T3_RD_ADR and (CNT = "110" or TIMEOUT = x"17FFFFF") then -- 6 pulses or timeout.
			INDEX_CNT <= true;
		else
			INDEX_CNT <= false;
		end if;
	end process INDEX_COUNTER;

	P_INDEX_MARK: process
	-- This process controls the occurence of an index pulse during read track
	-- and write track commands. The flag INDEX_MARK is cleared at the
	-- beginning of these two commands during the first check for an index
	-- pulse and is set right after the next index pulse occurs, which means
	-- track processing has completed.
	variable LOCK: boolean;
	begin
		wait until CLK = '1' and CLK' event;
		if CMD_STATE = T3_RD_TRACK and IPn = '0' then
			INDEX_MARK <= '0'; -- Reset the flag.
			LOCK := true;
		elsif CMD_STATE = T3_CHECK_INDEX_1 and IPn = '0' then
			INDEX_MARK <= '0'; -- Reset the flag.
			LOCK := true;
		elsif IPn = '0' and LOCK = false then
			INDEX_MARK <= '1'; -- Index pulse has passed.
			LOCK := true;
		elsif IPn = '1' then
			LOCK := false;
		end if;
	end process P_INDEX_MARK;
	
	P_T3_DATATYPE: process(RESETn, CLK)
	-- In type 3 write track command, it is necessary to store the information, which data
	-- has to be written to disk (in command state T3_WR_DATA. This information is sampled
	-- in the command state T3_LOAD_SHFT which preceeds the command state T3_WR_DATA.
	begin
		if RESETn = '0' then
			T3_DATATYPE <= x"00";
		elsif CLK = '1' and CLK' event then
			if CMD_STATE = T3_LOAD_SHFT then
				T3_DATATYPE <= DR;
			end if;
		end if;
	end process P_T3_DATATYPE;
	
	CNT_T3BYTES: process(RESETn, CLK, CMD_STATE)
	-- This process counts the bytes read in the type III read address
	-- command during the command states T3_SHIFT_ADR, T3_LOAD_DATA2,
	-- T3_SET_DRQ_2 and T3_CHECK_RD.
	variable CNT 	: std_logic_vector(2 downto 0);
	begin
		if RESETn = '0' then
			CNT := "000";
		elsif CLK = '1' and CLK' event then
			case CMD_STATE is
				when T3_VERIFY_AM =>
					CNT := "000"; -- Clear the counter right befor the count operation.
				when T3_SET_DRQ_2 =>
					CNT := CNT + '1'; -- Increment after each read cycle.
				when others =>
					null;
			end case;
		end if;
		case CNT is
			when "100" => T3_TRADR <= true;
			when others => T3_TRADR <= false;
		end case;
	end process CNT_T3BYTES;

	BYTEASMBLY: process(RESETn, CLK)
	-- This process controls the condition in the CMD_STATE T3_CHECK_DR.
	-- Therefore the bits shifted into the DSR in command state T3_SHIFT are counted.
	-- The count condition is entering the command state T3_CHECK_INDEX_3. The clear
	-- condition is either the command state IDLE or the command state T3_CHECK_DR.
	variable CNT : std_logic_vector(3 downto 0);
	begin
		if RESETn = '0' then
			CNT := x"0";
		elsif CLK = '1' and CLK' event then
			case CMD_STATE is
				when IDLE => CNT := x"0";
				when T3_CHECK_INDEX_3 => CNT := CNT + '1';
				when T3_CHECK_DR => CNT := (others => '0');
				when others => null;
			end case;
		end if;
		case CNT is
			when x"8" => BYTE_RDY <= true;
			when others => BYTE_RDY <= false;
		end case;
	end process BYTEASMBLY;

	P_DIR: process(RESETn, CLK, DIR)
	-- This portion of code is responsible to control the right stepping
	-- direction in type I commands.
	begin
		if RESETn = '0' then
			DIR <= '0';
		elsif CLK = '1' and CLK' event then
			if CMD_STATE = DECODE and CMD(7 downto 5) = "010" then -- Step in.
				DIR <= '1';
			elsif CMD_STATE = DECODE and CMD(7 downto 5) = "011" then -- Step out.
				DIR <= '0';
			elsif CMD_STATE = T1_COMP_TR_DSR and DSR > TR then -- Seek.
				DIR <= '1';
			elsif CMD_STATE = T1_COMP_TR_DSR and DSR < TR then -- Seek.
				DIR <= '0';
			end if;
		end if;
		DIRC <= DIR; -- Copy signal to the output.
	end process P_DIR;

	P_DRQ: process(RESETn, CLK, DRQ_I)
	begin
		if RESETn = '0' then
			DRQ_I <= '0';
		elsif CLK = '1' and CLK' event then
			case CMD_STATE is
				when INIT =>
					DRQ_I <= '0';
				when T2_LOAD_DATA | T2_SET_DRQ | T2_LOAD_SHFT =>
					DRQ_I <= '1';
				when T3_WR | T3_LOAD_SHFT | T3_SET_DRQ_1 | T3_SET_DRQ_2 =>
					DRQ_I <= '1';
				when others =>
					null;
			end case;
			-- The data request bit is also cleared by reading or writing the
			-- data register (direct memory access operation).
			if (DATA_RD = true or DATA_WR = true) then
				DRQ_I <= '0';
			end if;
		end if;
		--
        DRQ <= DRQ_I; -- Copy to entity.
		--
	end process P_DRQ;

	-- The DRQ_IPn detects the index pulse during type I commands and a forced interrupt or 
	-- DRQ during type II and III commands.
	-- The index pulse flag is active high and can be used for the detection of an inserted disk.
	DRQ_IPn <=  not IPn when CMD(7) = '0' else
				not IPn when CMD(7 downto 4) = x"D" and BUSY = '0' else DRQ_I;

	P_BUSY: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			BUSY <= '0';
		elsif CLK = '1' and CLK' event then
			-- During forced interrupt, the busy flag is reset when the command
			-- state machine enters the IDLE state.
			if CMD_STATE = INIT then
				BUSY <= '1'; -- set BUSY flag for all command types I ... III.
			elsif CMD_STATE = IDLE then
				BUSY <= '0'; -- Reset BUSY after entering IDLE in any case.
			end if;
		end if;
	end process P_BUSY;

	P_SEEK_RNF: process(RESETn, CLK)
	-- Seek error or record not found error flag.
	begin
		if RESETn = '0' then
			SEEK_RNF <= '0';
		elsif CLK = '1' and CLK' event then
			if CMD_STATE = INIT then
				SEEK_RNF <= '0'; -- Clear the flag for all command types I ... III.
			elsif CMD_STATE = T1_TRAP and STEP_TRAP = true then
				SEEK_RNF <= '1'; -- Seek error (SEEK).
			elsif CMD_STATE = T1_SPINDOWN and INDEX_CNT = true then
				SEEK_RNF <= '1'; -- Seek error (SEEK).
			elsif CMD_STATE = T2_INIT and INDEX_CNT = true then
				SEEK_RNF <= '1'; -- Record not found (RNF).
			elsif CMD_STATE = T3_RD_ADR and INDEX_CNT = true then
				SEEK_RNF <= '1'; -- Record not found (RNF).
			end if;
		end if;
	end process P_SEEK_RNF;

	P_INTRQ: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			INTRQ <= '0';
		elsif CLK = '1' and CLK' event then
			-- Interrupt reset conditions:
			if STAT_RD = true and CMD /= x"D8" then
				-- No clear during immediately forced interrupt.
				INTRQ <= '0'; -- Clear the flag when status register is read.
			elsif CMD_WR = true and CMD = x"D0" then
				-- Clear with the next write access to the command register after the
				-- forced interrupt x"D0" was written.
				INTRQ <= '0';
			elsif CMD_STATE = INIT and CMD(7 downto 6) /= "11" then
				INTRQ <= '0'; -- Clear the flag for type I and type II commands during start of execution.
            -- Interrupt set conditions.
			elsif CMD = x"D8" and CMD_STATE = IDLE then
				INTRQ <= '1'; -- Force interrupt immediately (after the break took affect).
			elsif CMD = x"D4" and IPn = '0' and CMD_STATE = IDLE then
				INTRQ <= '1'; -- Force interrupt on next index pulse (after the break took affect).
			elsif CMD_STATE = T1_TRAP and STEP_TRAP = true then
				INTRQ <= '1'; -- Indicate interrupt request due to seek error.
			elsif CMD_STATE = T1_VERIFY_DELAY and CMD(2) = '0' then
				INTRQ <= '1'; -- Indicate interrupt: command finished or interrupted.
			elsif CMD_STATE = T1_SPINDOWN and INDEX_CNT = true then
				INTRQ <= '1'; -- Indicate interrupt request, reason: seek error.
			elsif CMD_STATE = T1_VERIFY_CRC and CRC_ERR = '0' then
				INTRQ <= '1'; -- Indicate interrupt request; command correct, no CRC error.
			elsif CMD_STATE = T2_RD_WR_SECT and CMD(7 downto 5) = "101" and WPRTn = '0' then
				INTRQ <= '1'; -- Indicate interrupt request because disk is write protected.
			elsif CMD_STATE = T2_INIT and INDEX_CNT = true then
				INTRQ <= '1'; -- Indicate interrupt request, reason: timeout.
			elsif CMD_STATE = T2_VERIFY_CRC_2 and DELAY = true and CRC_ERR = '1' then
				INTRQ <= '1'; -- Indicate interrupt request due to CRC error.
			elsif CMD_STATE = T2_MULTISECT and CMD(4) = '0' then
				INTRQ <= '1'; -- Indicate interrupt request, command correct finished.
			elsif CMD_STATE = T2_VERIFY_DRQ_2 and DRQ_I = '1' then
				INTRQ <= '1'; -- Indicate interrupt request, reason: lost data.
			elsif CMD_STATE = T3_WR and WPRTn = '0' then
				INTRQ <= '1'; -- Indicate interrupt request, reason: disk is write protected.
			elsif CMD_STATE = T3_VERIFY_DRQ and DRQ_I = '1' then
				INTRQ <= '1'; -- Indicate interrupt request due to lost data.
			elsif CMD_STATE = T3_CHECK_INDEX_2 and INDEX_MARK = '1' then
				INTRQ <= '1'; -- Indicate interrupt request, reason: command finished correctly.
            elsif CMD_STATE = T3_CHECK_INDEX_3 and INDEX_MARK = '1' then
				INTRQ <= '1'; -- Indicate interrupt request, reason: command finished correctly.
			elsif CMD_STATE = T3_RD_ADR and INDEX_CNT = true then
				INTRQ <= '1'; -- Indicate interrupt request because record was not found.
			elsif CMD_STATE = T3_VERIFY_CRC then
				INTRQ <= '1'; -- Indicate interrupt request; command finished with or without CRC error.
			end if;
		end if;
	end process P_INTRQ;

	P_LOST_DATA_TR00: process(RESETn, CLK)
	-- Logic for the status bit number 2:
	-- The TRACK00 flag is used to detect wether a floppy disk drive
	-- is connected or not.
	begin
		if RESETn = '0' then
			LOST_DATA_TR00 <= '0';
		elsif CLK = '1' and CLK' event then
			if CMD(7 downto 4) = x"D" and BUSY = '0' then -- Forced interrupt.
				LOST_DATA_TR00 <= not TRACK00n;
			elsif CMD_STATE = INIT then
				LOST_DATA_TR00 <= '0';
            elsif CMD_STATE = T1_VERIFY_DELAY then
				LOST_DATA_TR00 <= not TRACK00n;
			elsif CMD_STATE = T2_VERIFY_DRQ_1 and DRQ_I = '1' then
				LOST_DATA_TR00 <= '1';
			elsif CMD_STATE = T2_VERIFY_DRQ_2 and DRQ_I = '1' then
				LOST_DATA_TR00 <= '1';
			elsif CMD_STATE = T2_VERIFY_DRQ_3 and DRQ_I = '1' then
				LOST_DATA_TR00 <= '1';
			elsif CMD_STATE = T3_VERIFY_DRQ and DRQ_I = '1' then
				LOST_DATA_TR00 <= '1';
			elsif CMD_STATE = T3_DATALOST then
				LOST_DATA_TR00 <= '1';
			elsif CMD_STATE = T3_CHECK_DR and DRQ_I = '1' then
				LOST_DATA_TR00 <= '1';
			end if;
		end if;
	end process P_LOST_DATA_TR00;

	MOTORSWITCH: process(RESETn, CLK)
	variable INDEXCNT	: std_logic_vector(3 downto 0);
	variable LOCK		: boolean;
	begin
		if RESETn = '0' then
			MO <= '0';
			INDEXCNT := x"0";
			LOCK := false;
		elsif CLK = '1' and CLK' event then
			if CMD_STATE /= IDLE then
				INDEXCNT := x"9"; -- Initialise the index counter.
				LOCK := false;
			elsif LOCK = false and IPn = '0' and INDEXCNT > x"0" then
				INDEXCNT := INDEXCNT - '1'; -- Count the index pulses in the IDLE state.
				LOCK := true;
			elsif IPn = '1' then
				LOCK := false;
			end if;
            --
            if CMD_STATE = INIT and CMD_WR = false then
				MO <= '1'; -- Start the motor for all command types I ... III in this state.
			elsif INDEXCNT = x"0" then
				MO <= '0'; -- The motor stops after 9 index pulses in idle state.
			end if;
		end if;
	end process MOTORSWITCH;

	WRITE_PROTECT: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			WR_PR <= '0';
		elsif CLK = '1' and CLK' event then
			if CMD_STATE = INIT and CMD(7) = '1' then
				WR_PR <= '0'; -- Clear the flag for type II and type III  commands.
			elsif CMD_STATE = T2_RD_WR_SECT and WPRTn = '0' then
				WR_PR <= '1';
			elsif CMD_STATE = T3_WR and WPRTn = '0' then
				WR_PR <= '1';
			end if;
		end if;
	end process WRITE_PROTECT;

	RECTYPE_SPINUP: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			SPINUP_RECTYPE <= '0';
		elsif CLK = '1' and CLK' event then
			if CMD_STATE = INIT then
				SPINUP_RECTYPE <= '0'; -- Clear the flag for type II...III  commands.
			elsif CMD_STATE = SPINUP and CMD(7) = '0' and INDEX_CNT = true then
				SPINUP_RECTYPE <= '1'; -- SPINUP SEQUENCE for type I commands has finished.
			elsif CMD_STATE = T2_VERIFY_AM and (DATA_AM = '1' or DDATA_AM = '1') then
				case DSR is
					when x"F8" => SPINUP_RECTYPE <= '1'; -- Deleted data address mark.
					when x"FB" => SPINUP_RECTYPE <= '0'; -- Normal data address mark.
					when others => null; -- Forbidden, should never appear.
				end case;
			end if;
		end if;
	end process RECTYPE_SPINUP;

	WRITEGATE: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			WG <= '0';
		elsif CLK = '1' and CLK' event then
			case CMD_STATE is
				when T2_WR_LEADIN | T3_LOAD_SHFT =>
					WG <= '1';
				when T2_MULTISECT | IDLE =>
					WG <= '0';
				when others =>
					null;
			end case;
		end if;
	end process WRITEGATE;

	RESTORE_TRAP: process(RESETn, CLK)
	-- This process is responsible to supervise the RESTORE command.
	-- If after 255 stepping pulses no TRACK00n was not detected, the
	-- RESTORE command is terminated and the interrupt request and the
	-- seek error are set.
	variable STEP_CNT : std_logic_vector(7 downto 0);
	begin
		if RESETn = '0' then
			STEP_CNT := (others => '0');
		elsif CLK = '1' and CLK' event then
			if CMD_STATE = IDLE then
				STEP_CNT := x"00";
			elsif CMD(7 downto 4) /= "0000" then -- No RESTORE command.
				STEP_CNT := x"00";
			elsif CMD_STATE = T1_STEP and STEP_CNT < x"FF" then
				STEP_CNT := STEP_CNT + '1';
			end if;
		end if;
		--
		case STEP_CNT is
			when x"FF" => STEP_TRAP <= true;
			when others => STEP_TRAP <= false;
		end case;
	end process RESTORE_TRAP;

	STEPPULSE: process(RESETn, CLK)
	-- The step pulse duration is in the original WD1772 4us in MFM mode and 8 us.
	-- in FM mode This process is responsible to provide the correct pulse lengths.
	variable CNT : std_logic_vector(7 downto 0);
	begin
		if RESETn = '0' then
			CNT := (others => '0');
		elsif CLK = '1' and CLK' event then
			if CMD_STATE = T1_STEP then
				case DDEn is
					when '1' => CNT := x"80"; --Start counter for FM step pulse.
                    when '0' => CNT := x"40"; --Start counter for MFM step pulse.
				end case;
			elsif CNT > x"00" then
				CNT := CNT -1; -- Count 63 or 127 CLK cycles ...
			end if;
			case CNT is
				when x"00" => STEP <= '0';
				when others => STEP <= '1'; --...result in 3.875us or 7.75us pulse.
			end case;
		end if;
	end process STEPPULSE;

	TRACK_MEM: process(RESETn, CLK, TRACKMEM)
	-- This process is necessary to store the actual track number in the
	-- type III command 'read address' because the track number is written
	-- to the sector register some byte times after the detection of the 
	-- track number from disk.
	begin
		if RESETn = '0' then
			TRACKMEM <= x"00";
		elsif CLK = '1' and CLK' event then
			case CMD_STATE is
				when IDLE =>
					TRACKMEM <= x"00"; -- Clear the Track memory.
				when T3_LOAD_DATA_2 =>
					TRACKMEM <= DSR; -- Store the actual track number.
				when others =>
					null;
			end case;
		end if;
		TRACK_NR <= TRACKMEM; -- Output the TRACKMEM.
	end process TRACK_MEM;

	SECT_LENGTH: process(RESETn, CLK, SECT_LEN)
	-- This process supervises the read sector and write sector
	-- commands. If the sector read or write are equal to the
	-- sector length, the commands read sector and write sector
	-- are ready.
	begin
		if RESETn = '0' then
			SECT_LEN <= "00000000000";
		elsif CLK = '1' and CLK' event then
			case CMD_STATE is
				when T2_SCAN_LEN =>
					-- Bring in the correct sector length.
					case DSR(1 downto 0) is
						when "00" => SECT_LEN <= "00010000000"; -- 128 Byte per sector.
						when "01" => SECT_LEN <= "00100000000"; -- 256 Byte per sector.
						when "10" => SECT_LEN <= "01000000000"; -- 512 Byte per sector.
						when "11" => SECT_LEN <= "10000000000"; -- 1024 Byte per sector.
						when others => SECT_LEN <= "10000000000"; -- Dummy for U, X, Z, W, H, L, -.
					end case;
				when T2_LOAD_DATA | T2_LOAD_SHFT =>
					SECT_LEN <= SECT_LEN - '1';
				when others =>
					null;
			end case;
		end if;
	end process SECT_LENGTH;

	P_CRC_ERR: process(RESETn, CLK)
	-- This code checks the CRC status in the right command states
	-- and sets or resets the CRC error status flag.
	begin
		if RESETn = '0' then
			CRC_ERRFLAG <= '0';
		elsif CLK = '1' and CLK' event then
			case CMD_STATE is
				when INIT =>
					if CMD(7) = '0' then
						CRC_ERRFLAG <= '0'; -- Reset for type I commands only.
					end if;
				when T1_VERIFY_CRC | T2_VERIFY_CRC_1  =>
					if CRC_ERR = '1' and DELAY = true then
						CRC_ERRFLAG <= '1'; -- Set CRC error flag...
					elsif CRC_ERR = '0' and DELAY = true then
						CRC_ERRFLAG <= '0'; -- ... or reset CRC error flag.
					end if;
				when T2_VERIFY_CRC_2 | T3_VERIFY_CRC =>
					if CRC_ERR = '1' and DELAY = true then
						-- Set CRC error flag but no reset in here.
						-- The CRC is already reset by the previous checks.
						CRC_ERRFLAG <= '1';
					end if;
				when others =>
					null;
			end case;
		end if;
	end process P_CRC_ERR;

    CMD_WR <= true when CSn = '0' and A1 = '0' and A0 = '0' and RWn = '0' else false; -- Command register write.
	STAT_RD <= true when CSn = '0' and A1 = '0' and A0 = '0' and RWn = '1' else false; -- Status register read.
	DATA_WR <= true when CSn = '0' and A1 = '1' and A0 = '1' and RWn = '0' else false; -- Data register write.
	DATA_RD <= true when CSn = '0' and A1 = '1' and A0 = '1' and RWn = '1' else false; -- Data register read.

	-- Track register arithmetics controls:
	TR_PRES <= '1' when CMD_STATE = T1_SEEK_RESTORE and CMD(7 downto 4) = "0000" else '0'; -- Restore command.
	TR_CLR 	<= '1' when CMD_STATE = T1_HEAD_CTRL and TRACK00n = '0' and DIR = '0' else '0';
	TR_INC	<= '1' when CMD_STATE = T1_CHECK_DIR and DELAY = true and DIR = '1' else '0';
	TR_DEC	<= '1' when CMD_STATE = T1_CHECK_DIR and DELAY = true and DIR = '0' else '0';

	-- Sector register arithmetics:
	SR_INC	<= '1' when CMD_STATE = T2_MULTISECT and CMD(4) = '1' else '0'; -- Multi sector enabled.
	SR_LOAD <= '1' when CMD_STATE = T3_LOAD_SR else '0';

	-- Data register arithmetics controls:
	DR_CLR 	<= 	'1' when CMD_STATE = T1_SEEK_RESTORE and CMD(7 downto 4) = "0000" else '0'; -- Restore command.
	DR_LOAD <= 	'1' when CMD_STATE = T2_LOAD_DATA else
				'1' when CMD_STATE = T3_LOAD_DATA_1 else
				'1' when CMD_STATE = T3_LOAD_DATA_2 else '0';
	
	-- Shift register arithmetics controls:
	-- During type I and type II commands all characters are allowed as data.
	-- During the type III write track command, there are some special characters
	-- which may not appear as normal data. See the register file for more information.
	SHFT_LOAD_SD <= '1' when CMD_STATE = T3_LOAD_SHFT else '0'; -- Special data.
	SHFT_LOAD_ND <= '1' when CMD_STATE = T1_LOAD_SHFT else 
				 	'1' when CMD_STATE = T2_LOAD_SHFT else '0'; -- Normal data.
	
	P_CRC_PRES: process(RESETn, CLK)
	-- CRC preset during write sector and write track commands.
	variable LOCK : boolean;
	begin
		if RESETn = '0' then
			CRC_PRES <= '0';
			LOCK := false;
		elsif CLK = '1' and CLK' event then
			-- In write track command, the CRC is initialised at the beginning of the
			-- first A1 data and released during shifting the CRC out.
			if CMD_STATE = T2_WR_AM and LOCK = false then
				CRC_PRES <= '1'; -- Write sector command.
				LOCK := true;
			elsif CMD_STATE = T3_LOAD_SHFT and DR = x"F5" and LOCK = false then -- x"F5" means write A1.
				CRC_PRES <= '1'; -- Write track command.
				LOCK := true;
			elsif CMD_STATE = T2_WR_CRC then
				CRC_PRES <= '0'; -- Write sector command.
				LOCK := false;
			elsif CMD_STATE = T3_LOAD_SHFT and DR = x"F7" then
				CRC_PRES <= '0'; -- Write track command.
				LOCK := false;
			else
				CRC_PRES <= '0';
			end if;
		end if;
	end process P_CRC_PRES;
	
	-- Write control signals:
	AM_2_DISK <= 	'1' when CMD_STATE = T2_WR_AM else '0';
	FF_2_DISK <= 	'1' when CMD_STATE = T2_WR_FF else '0';
	DSR_2_DISK <= 	'1' when CMD_STATE = T2_WR_BYTE else
					'1' when CMD_STATE = T3_WR_DATA and T3_DATATYPE /= x"F7" else '0'; -- not during CRC.
	CRC_2_DISK <= 	'1' when CMD_STATE = T2_WR_CRC else 
					'1' when CMD_STATE = T3_WR_DATA and T3_DATATYPE = x"F7" else '0';

	-- Write precompensation control:
	PRECOMP_EN <= 	'1' when CMD(7 downto 4) = x"A" and CMD(1) = '0' else -- Write single sector.
					'1' when CMD(7 downto 4) = x"B" and CMD(1) = '0' else -- Write multiple sector.
					'1' when CMD(7 downto 4) = x"F" and CMD(1) = '0' else '0'; -- Write track.

	-- Disk data flow direction:
	DISK_RWn <= -- Write sector command:
				'0' when CMD_STATE = T2_WR_LEADIN else
				'0' when CMD_STATE = T2_WR_AM else
				'0' when CMD_STATE = T2_LOAD_SHFT else
				'0' when CMD_STATE = T2_WR_BYTE else
				'0' when CMD_STATE = T2_VERIFY_DRQ_3 else
				'0' when CMD_STATE = T2_DATALOST else
				'0' when CMD_STATE = T2_WRSTAT else
				'0' when CMD_STATE = T2_WR_CRC else
				'0' when CMD_STATE = T2_WR_FF else
				-- Write track command:
				'0' when CMD_STATE = T3_LOAD_SHFT else
				'0' when CMD_STATE = T3_WR_DATA else
				'0' when CMD_STATE = T3_CHECK_INDEX_2 else
				'0' when CMD_STATE = T3_DATALOST else '1';
end BEHAVIOR;