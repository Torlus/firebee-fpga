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
---- This is the SUSKA MFP IP core interrupt logic file.          ----
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
-- Revision 2K8A  2008/06/03 WF
--   Fixed Pending register logic.
-- Revision 2K9A  2009/06/20 WF
--   Fixed interrupt polarity for TA_I and TB_I.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF68901IP_INTERRUPTS is
	port (  -- System control:
			CLK			: in bit;
			RESETn		: in bit;
			
			-- Asynchronous bus control:
			DSn			: in bit;
			CSn			: in bit;
			RWn			: in bit;
			
			-- Data and Adresses:
			RS			: in bit_vector(5 downto 1);
			DATA_IN		: in bit_vector(7 downto 0);
			DATA_OUT	: out bit_vector(7 downto 0);
			DATA_OUT_EN	: out bit;

			-- Interrupt control:
			IACKn		: in bit;
			IEIn		: in bit;
			IEOn		: out bit;
			IRQn		: out bit;
			
			-- Interrupt sources:
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
end entity WF68901IP_INTERRUPTS;

architecture BEHAVIOR of WF68901IP_INTERRUPTS is
-- Interrupt state machine:
type INT_STATES is (SCAN, REQUEST, VECTOR_OUT);
signal INT_STATE : INT_STATES;
-- The registers:
signal IERA			: bit_vector(7 downto 0);
signal IERB			: bit_vector(7 downto 0);
signal IPRA			: bit_vector(7 downto 0);
signal IPRB			: bit_vector(7 downto 0);
signal ISRA			: bit_vector(7 downto 0);
signal ISRB			: bit_vector(7 downto 0);
signal IMRA			: bit_vector(7 downto 0);
signal IMRB			: bit_vector(7 downto 0);
signal VR			: bit_vector(7 downto 3);
-- Interconnect:
signal VECT_NUMBER	: bit_vector(7 downto 0);
signal INT_SRC		: bit_vector(15 downto 0);
signal INT_SRC_EDGE	: bit_vector(15 downto 0);
signal INT_ENA		: bit_vector(15 downto 0);
signal INT_MASK		: bit_vector(15 downto 0);
signal INT_PENDING	: bit_vector(15 downto 0);
signal INT_SERVICE	: bit_vector(15 downto 0);
signal INT_PASS		: bit_vector(15 downto 0);
signal INT_OUT		: bit_vector(15 downto 0);
signal GP_INT_4		: bit;
signal GP_INT_3		: bit;
begin
	-- Interrupt source for the GPI_4 and GPI_3 is normally the respective port pin.
	-- But when the timers operate in their PWM modes, the GPI_4 and GPI_3 are associated
	-- to timer A and timer B.
	-- The xor logic provides polarity control for the interrupt transition. Be aware,
	-- that the PWM signals cause an interrupt on the opposite transition like the
	-- respective GPIP port pins (with the same AER settings).
    --GP_INT_4 <= GP_INT(4) when TA_PWM = '0' else TAI xor AER_4;
    --GP_INT_3 <= GP_INT(3) when TB_PWM = '0' else TBI xor AER_3;
    GP_INT_4 <= GP_INT(4) when TA_PWM = '0' else TAI xnor AER_4; -- This should be correct.
    GP_INT_3 <= GP_INT(3) when TB_PWM = '0' else TBI xnor AER_3;


	-- Interrupt source priority sorted (15 = highest):
    INT_SRC <= 	GP_INT(7 downto 6) & TIMER_A_INT & RCV_BUF_F & RCV_ERR & TRM_BUF_E & TRM_ERR & TIMER_B_INT & 
    GP_INT(5) & GP_INT_4 & TIMER_C_INT & TIMER_D_INT & GP_INT_3 & GP_INT(2 downto 0);

	INT_ENA 	<= IERA & IERB;
	INT_MASK 	<= IMRA & IMRB;
	INT_PENDING <= IPRA & IPRB;
	INT_SERVICE <= ISRA & ISRB;
	INT_OUT 	<= INT_PENDING and INT_MASK; -- Masking:

	-- Enable the daisy chain, if there is no pending interrupt and
	-- the interrupt state machine is not in service.
	IEOn <= '0' when INT_OUT = x"0000" and INT_STATE = SCAN else '1';

	-- Interrupt request:
	IRQn <= '0' when INT_OUT /= x"0000" and INT_STATE = REQUEST else '1';

	EDGE_ENA: process(RESETn, CLK)
	-- These are the 16 edge detectors of the 16 interrupt input sources. This
	-- process also provides the disabling or enabling via the IERA and IERB registers.
	variable LOCK : bit_vector(15 downto 0);
	begin
		if RESETn = '0' then
			INT_SRC_EDGE <= x"0000";
			LOCK := x"0000";
		elsif CLK = '1' and CLK' event then
			for i in 15 downto 0 loop
				if INT_SRC(i) = '1' and INT_ENA(i) = '1' and LOCK(i) = '0' then
					LOCK(i) := '1';
					INT_SRC_EDGE(i) <= '1';
				elsif INT_SRC(i) = '0' then
					LOCK(i) := '0';
					INT_SRC_EDGE(i) <= '0';
				else
					INT_SRC_EDGE(i) <= '0';
				end if;
			end loop;
		end if;
	end process EDGE_ENA;
	
	INT_REGISTERS: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			IERA <= (others => '0');
			IERB <= (others => '0');
			IPRA <= (others => '0');
			IPRB <= (others => '0');
			ISRA <= (others => '0');
			ISRB <= (others => '0');
			IMRA <= (others => '0');
			IMRB <= (others => '0');
		elsif CLK = '1' and CLK' event then
			if 	CSn = '0' and DSn = '0' and RWn = '0' then
				case RS is
					when "00011"	=> IERA <= DATA_IN; -- Enable A.
					when "00100"	=> IERB <= DATA_IN; -- Enable B.
					when "00101"	=>
						-- Only a '0' can be written to the pending register.
						for i in 7 downto 0 loop
							if DATA_IN(i) = '0' then
								IPRA(i) <= '0'; -- Pending A.
							end if;
						end loop;
					when "00110"	=>
						-- Only a '0' can be written to the pending register.
						for i in 7 downto 0 loop
							if DATA_IN(i) = '0' then
								IPRB(i) <= '0'; -- Pending B.
							end if;
						end loop;
					when "00111"	=> 
						-- Only a '0' can be written to the in service register.
						for i in 7 downto 0 loop
							if DATA_IN(i) = '0' then
								ISRA(i) <= '0'; -- In Service A.
							end if;
						end loop;
					when "01000"	=>
						-- Only a '0' can be written to the in service register.
						for i in 7 downto 0 loop
							if DATA_IN(i) = '0' then
								ISRB(i) <= '0'; -- In Service B.
							end if;
						end loop;
					when "01001"	=> IMRA <= DATA_IN; -- Mask A.
					when "01010"	=> IMRB <= DATA_IN; -- Mask B.
					when "01011"	=> VR <= DATA_IN(7 downto 3); -- Vector register.
					when others		=> null;
				end case;
			end if;

			-- Pending register:
			-- set and clear bit logic.
			for i in 15 downto 8 loop
				if INT_SRC_EDGE(i) = '1' then
					IPRA(i-8) <= '1';
				elsif INT_ENA(i) = '0' then
					IPRA(i-8) <= '0'; -- Clear by disabling the channel.
				elsif INT_PASS(i) = '1' then
					IPRA(i-8) <= '0'; -- Clear by passing the interrupt.
				end if;
			end loop;
			for i in 7 downto 0 loop
				if INT_SRC_EDGE(i) = '1' then
					IPRB(i) <= '1';
				elsif INT_ENA(i) = '0' then
					IPRB(i) <= '0'; -- Clear by disabling the channel.
				elsif INT_PASS(i) = '1' then
					IPRB(i) <= '0'; -- Clear by passing the interrupt.
				end if;
			end loop;

			-- In-Service register:
			-- Set bit logic, VR(3) is the service register enable.
			for i in 15 downto 8 loop
				if INT_OUT(i) = '1' and INT_PASS(i) = '1' and VR(3) = '1' then
					ISRA(i-8) <= '1';
				end if;
			end loop;
			for i in 7 downto 0 loop
				if INT_OUT(i) = '1' and INT_PASS(i) = '1' and VR(3) = '1' then
					ISRB(i) <= '1';
				end if;
			end loop;
		end if;
	end process INT_REGISTERS;
	DATA_OUT_EN <= '1' when CSn = '0' and DSn = '0' and RWn = '1' and RS > "00010" and RS <= "01011" else 																	 '1' when INT_STATE = VECTOR_OUT else '0';

	DATA_OUT <= IERA when CSn = '0' and DSn = '0' and RWn = '1' and RS = "00011" else
				IERB when CSn = '0' and DSn = '0' and RWn = '1' and RS = "00100" else
				IPRA when CSn = '0' and DSn = '0' and RWn = '1' and RS = "00101" else
				IPRB when CSn = '0' and DSn = '0' and RWn = '1' and RS = "00110" else
				ISRA when CSn = '0' and DSn = '0' and RWn = '1' and RS = "00111" else
				ISRB when CSn = '0' and DSn = '0' and RWn = '1' and RS = "01000" else
				IMRA when CSn = '0' and DSn = '0' and RWn = '1' and RS = "01001" else
				IMRB when CSn = '0' and DSn = '0' and RWn = '1' and RS = "01010" else
				VR & "000" when CSn = '0' and DSn = '0' and RWn = '1' and RS = "01011" else
				VECT_NUMBER when INT_STATE = VECTOR_OUT else x"00";

	P_INT_STATE	: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			INT_STATE <= SCAN;
		elsif CLK = '1' and CLK' event then
			case INT_STATE is
				when SCAN =>
					INT_PASS <= x"0000";
					-- Automatic End of Interrupt mode. Service register disabled.
					-- The MFP does not respond for an interrupt acknowledge cycle for an uninitialized
					-- vector number (VR(7 downto 4) = x"0").
					if INT_OUT /= x"0000" and VR(7 downto 4) /= x"0" and VR(3) = '0' and IEIn = '0' then
						INT_STATE <= REQUEST; -- Non masked interrupt is pending.
					-- The following 16 are the Software end of interrupt mode. Service register enabled.
					-- The MFP does not respond for an interrupt acknowledge cycle for an uninitialized
					-- vector number (VR(7 downto 4) = x"0"). The interrupts are prioritized.
					elsif INT_OUT /= x"0000" and VR(7 downto 4) /= x"0" and VR(3) = '1' and IEIn = '0' then
						if INT_OUT (15) = '1' and INT_SERVICE(15) = '0' then
							INT_STATE <= REQUEST;
						elsif INT_OUT (14) = '1' and INT_SERVICE(15 downto 14) = "00" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (13) = '1' and INT_SERVICE(15 downto 13) = "000" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (12) = '1' and INT_SERVICE(15 downto 12) = x"0" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (11) = '1' and INT_SERVICE(15 downto 11) = x"0" & '0' then
							INT_STATE <= REQUEST;
						elsif INT_OUT (10) = '1' and INT_SERVICE(15 downto 10) = x"0" & "00" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (9) = '1' and INT_SERVICE(15 downto 9) = x"0" & "000" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (8) = '1' and INT_SERVICE(15 downto 8) = x"00" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (7) = '1' and INT_SERVICE(15 downto 7) = x"00" & '0' then
							INT_STATE <= REQUEST;
						elsif INT_OUT (6) = '1' and INT_SERVICE(15 downto 6) = x"00" & "00" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (5) = '1' and INT_SERVICE(15 downto 5) = x"00" & "000" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (4) = '1' and INT_SERVICE(15 downto 4) = x"000" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (3) = '1' and INT_SERVICE(15 downto 3) = x"000" & '0' then
							INT_STATE <= REQUEST;
						elsif INT_OUT (2) = '1' and INT_SERVICE(15 downto 2) = x"000" & "00" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (1) = '1' and INT_SERVICE(15 downto 1) = x"000" & "000" then
							INT_STATE <= REQUEST;
						elsif INT_OUT (0) = '1' and INT_SERVICE(15 downto 0) = x"0000" then
							INT_STATE <= REQUEST;
						else
							INT_STATE <= SCAN; -- Wait for interrupt.
						end if;
					else
						INT_STATE <= SCAN;
					end if;
				when REQUEST =>
					if IACKn = '0' and DSn = '0' then -- Vectored interrupt mode.
						INT_STATE <= VECTOR_OUT; -- Non masked interrupt is pending.
						if INT_OUT(15) = '1' then 
							INT_PASS(15) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"F"; -- GPI 7.
						elsif INT_OUT(14) = '1' then 
							INT_PASS(14) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"E"; -- GPI 6.
						elsif INT_OUT(13) = '1' then 
							INT_PASS(13) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"D"; -- TIMER A.
						elsif INT_OUT(12) = '1' then 
							INT_PASS(12) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"C"; -- Receive buffer full.
						elsif INT_OUT(11) = '1' then 
							INT_PASS(11) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"B"; -- Receiver error.
						elsif INT_OUT(10) = '1' then 
							INT_PASS(10) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"A"; -- Transmit buffer empty.
						elsif INT_OUT(9) = '1' then 
							INT_PASS(9) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"9"; -- Transmit error.
						elsif INT_OUT(8) = '1' then 
							INT_PASS(8) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"8"; -- Timer B.
						elsif INT_OUT(7) = '1' then 
							INT_PASS(7) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"7"; -- GPI 5.
						elsif INT_OUT(6) = '1' then 
							INT_PASS(6) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"6"; -- GPI 4.
						elsif INT_OUT(5) = '1' then 
							INT_PASS(5) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"5"; -- Timer C.
						elsif INT_OUT(4) = '1' then 
							INT_PASS(4) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"4"; -- Timer D.
						elsif INT_OUT(3) = '1' then 
							INT_PASS(3) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"3"; -- GPI 3.
						elsif INT_OUT(2) = '1' then 
							INT_PASS(2) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"2"; -- GPI 2.
						elsif INT_OUT(1) = '1' then 
							INT_PASS(1) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"1"; -- GPI 1.
						elsif INT_OUT(0) = '1' then 
							INT_PASS(0) <= '1'; VECT_NUMBER <= VR(7 downto 4) & x"0"; -- GPI 0.
						end if;
					 -- Polled interrupt mode: End of interrupt by writing to the pending registers.
					elsif CSn = '0' and DSn = '0' and RWn = '0' and (RS = "00101" or RS = "00110") then
						INT_STATE <= SCAN;
					else
						INT_STATE <= REQUEST; -- Wait.
					end if;
				when VECTOR_OUT =>
					INT_PASS <= x"0000";
					if DSn = '1' or IACKn = '1' then
						INT_STATE <= SCAN; -- Finished.
					else
						INT_STATE <= VECTOR_OUT; -- Wait for processor to read the vector.
					end if;
			end case;
		end if;
	end process P_INT_STATE;
end architecture BEHAVIOR;
