library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity decode_stage is port(
	activate_dec    : in  std_logic;
	instr_word      : in  std_logic_vector(23 downto 0);
	dble_word_instr : out std_logic;
	instr_array     : out instructions_type;
	act_array       : out std_logic_vector(NUM_ACT_SIGNALS-1 downto 0);
	reg_wr_addr     : out std_logic_vector(5 downto 0);
	reg_rd_addr     : out std_logic_vector(5 downto 0);
	x_bus_rd_addr   : out std_logic_vector(1 downto 0); 
	x_bus_wr_addr   : out std_logic_vector(1 downto 0); 
	y_bus_rd_addr   : out std_logic_vector(1 downto 0); 
	y_bus_wr_addr   : out std_logic_vector(1 downto 0); 
	l_bus_addr      : out std_logic_vector(2 downto 0); 
	adgen_mode_a    : out adgen_mode_type;
	adgen_mode_b    : out adgen_mode_type;
	alu_ctrl        : out alu_ctrl_type
);
end entity;


architecture rtl of decode_stage is

	signal instr_array_int : instructions_type;
--	signal activate_pm_int : std_logic;
	type adgen_bittype_type is (NOP, SINGLE_X, SINGLE_X_SHORT, DOUBLE_X_Y);
	-- SINGLE_X       : MMMRRR
	-- SINGLE_X_SHORT :  MMRRR
	-- DOUBLE_X_Y     : mmrrMMRRR
	signal adgen_bittype : adgen_bittype_type;

	signal ea_extension_available : std_logic;

	signal alu_tcc_decoded : std_logic;
	signal alu_div_decoded : std_logic;
	signal alu_norm_decoded : std_logic;

begin


	-- output the decoded instruction
	instr_array <= instr_array_int;

	-- calculate whether this is a double word instruction
	dble_word_instr <= '1' when ea_extension_available = '1'  or 
	                            instr_array_int = INSTR_DO    or 
	                            instr_array_int = INSTR_JCLR  or
	                            instr_array_int = INSTR_JSCLR or
	                            instr_array_int = INSTR_JSET  or
	                            instr_array_int = INSTR_JSSET else
	                   '0';

	alu_instruction_decoder: process(instr_word, activate_dec, alu_tcc_decoded,
	                                 alu_div_decoded, alu_norm_decoded) is
		variable instr_word_var : std_logic_vector(23 downto 0);
	begin
		if activate_dec = '1' then
			instr_word_var := instr_word;
		else
			instr_word_var := (others => '0');
		end if;
		
		alu_ctrl.mul_op1 <= (others => '0');
		alu_ctrl.mul_op2 <= (others => '0');
		alu_ctrl.rotate <= '0';
		alu_ctrl.div_instr <= '0';
		alu_ctrl.norm_instr <= '0';
		alu_ctrl.shift_src <= '0';
		alu_ctrl.shift_src_sign <= (others => '0');
		alu_ctrl.shift_mode <= ZEROS;
		alu_ctrl.add_src_stage_1 <= (others => '0');
		alu_ctrl.add_src_stage_2 <= (others => '0');
		alu_ctrl.add_src_sign    <= (others => '0');
		alu_ctrl.logic_function  <= (others => '0');
		alu_ctrl.word_24_update  <= '0';
		alu_ctrl.rounding_used   <= (others => '0');
		alu_ctrl.store_result    <= '0';
		for i in 0 to 7 loop -- by default do not touch any of the ccr flags (L;E;U;N;Z;V;C)
			alu_ctrl.ccr_flags_ctrl(i) <= DONT_TOUCH;
		end loop;
		alu_ctrl.dst_accu <= instr_word_var(3); -- default value for all alu operations

		-- check wether instruction that allows parallel moves 
		-- has to be decoded, then it is an ALU operation in the 8 LSBs
		-- Only exceptions are DIV, NORM, and Tcc
		if instr_word_var(23 downto 20) /= "0000" then
			-- ABS
			if instr_word_var(7 downto 4) = "0010" and instr_word_var(2 downto 0) = "110" then
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- source/dst are the same register 
				alu_ctrl.shift_src_sign <= "10";  -- the sign of the operand depends on the operand 
				                                  -- negative operand will negate the content of the accu as
				                                  -- needed by the ABS instruction
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero
				alu_ctrl.store_result <= '1';     -- store the result
				-- set all flags but carry
				for i in 1 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- ADC
			if instr_word_var(7 downto 5) = "001" and instr_word_var(2 downto 0) = "001" then
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= "01" & instr_word_var(4); -- X or Y
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "00"; -- with original sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "10"; -- add carry to result of addition
				-- set all flags
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- ADD
			if instr_word_var(7) = '0' and instr_word_var(2 downto 0) = "000" and instr_word_var(6 downto 4) /= "000" then
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding)
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "00"; -- with original sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set all flags
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- ADDL
			if instr_word_var(7 downto 4) = "0001" and instr_word_var(2 downto 0) = "010" then
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_LEFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding) (here: A,B)
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "00"; -- with original sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set all flags
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- ADDR
			if instr_word_var(7 downto 4) = "0000" and instr_word_var(2 downto 0) = "010" then
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_RIGHT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 5) & '1'; -- source register (JJJ encoding) (here: A,B)
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "00"; -- with original sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set all flags
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- AND / OR / EOR
			if instr_word_var(7 downto 6) = "01" and (instr_word_var(2 downto 0) = "110" or -- and
			                                          instr_word_var(2 downto 0) = "010" or -- or
				                                      instr_word_var(2 downto 0) = "011") then -- eor
				alu_ctrl.logic_function <= instr_word_var(2 downto 0);  -- 000: none, 110: and, 010: or, 011: eor, 111: not
				alu_ctrl.word_24_update <= '1';  -- only accumulator bits 47 downto 24 affected?
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding) (here: A,B)
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "00"; -- with original sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set following flags
				alu_ctrl.ccr_flags_ctrl(N_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(Z_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(V_FLAG) <= CLEAR;
			end if;
			-- ASL
			if instr_word_var(7 downto 4) = "0011" and instr_word_var(2 downto 0) = "010" then
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_LEFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				-- Read S
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero as operand
				alu_ctrl.add_src_sign    <= "00"; -- with original sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set all flags
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- ASR
			if instr_word_var(7 downto 4) = "0010" and instr_word_var(2 downto 0) = "010" then
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_RIGHT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				-- Read S
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero as operand
				alu_ctrl.add_src_sign    <= "00"; -- with original sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set following flags
--				alu_ctrl.ccr_flags_ctrl(S_FLAG) <= MODIFY;
--				alu_ctrl.ccr_flags_ctrl(E_FLAG) <= MODIFY;
--				alu_ctrl.ccr_flags_ctrl(U_FLAG) <= MODIFY;
--				alu_ctrl.ccr_flags_ctrl(N_FLAG) <= MODIFY;
--				alu_ctrl.ccr_flags_ctrl(Z_FLAG) <= MODIFY;
--				alu_ctrl.ccr_flags_ctrl(V_FLAG) <= CLEAR;
--				alu_ctrl.ccr_flags_ctrl(C_FLAG) <= MODIFY;
				-- set all flags, V-flag will be cleared due to shifting
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- CLR
			if instr_word_var(7 downto 4) = "0001" and instr_word_var(2 downto 0) = "011" then
				-- Read accu
				alu_ctrl.shift_mode <= ZEROS;
				-- Read S
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero as operand
				alu_ctrl.add_src_sign    <= "00"; -- with original sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set following flags
				alu_ctrl.ccr_flags_ctrl(S_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(E_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(U_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(N_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(Z_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(V_FLAG) <= CLEAR;
			end if;
			-- CMP
			if instr_word_var(7) = '0' and instr_word_var(6 downto 5) /= "01" and 
			   instr_word_var(2 downto 0) = "101" then
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				-- Read S
				if instr_word_var(6) = '1' then
					alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding) x0,x1,y0,y1
				else
					alu_ctrl.add_src_stage_1 <= "001"; -- select opposite accu (JJJ encoding)
				end if;
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "01"; -- with negative sign
				alu_ctrl.store_result    <= '0';  -- do not store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set all flags
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- CMPM
			if instr_word_var(7) = '0' and instr_word_var(6 downto 5) /= "01" and 
		       instr_word_var(2 downto 0) = "111" then
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "10";          -- with the sign dependant sign (magnitude!)
				-- Read S
				if instr_word_var(6) = '1' then
					alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding) x0,x1,y0,y1
				else
					alu_ctrl.add_src_stage_1 <= "001"; -- select opposite accu (JJJ encoding)
				end if;
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "10"; -- with sign dependant sign (magnitude!)
				alu_ctrl.store_result    <= '0';  -- do not store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set all flags
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- LSL
			if instr_word_var(7 downto 4) = "0011" and instr_word_var(2 downto 0) = "011" then
				alu_ctrl.word_24_update <= '1';
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_LEFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero as second operand
				-- set N,Z,V,C flags
				for i in 0 to 3 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- LSR
			if instr_word_var(7 downto 4) = "0010" and instr_word_var(2 downto 0) = "011" then
				alu_ctrl.word_24_update <= '1';
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_RIGHT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero as second operand
				-- set N,Z,V,C flags
				for i in 0 to 3 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- MPY, MPYR, MAC, MACR
			if instr_word_var(7) = '1' then
				case instr_word_var(6 downto 4) is
					when "000"  => alu_ctrl.mul_op1 <= "00"; alu_ctrl.mul_op2 <= "00"; -- x0,x0
					when "001"  => alu_ctrl.mul_op1 <= "10"; alu_ctrl.mul_op2 <= "10"; -- y0,y0
					when "010"  => alu_ctrl.mul_op1 <= "01"; alu_ctrl.mul_op2 <= "00"; -- x1,x0
					when "011"  => alu_ctrl.mul_op1 <= "11"; alu_ctrl.mul_op2 <= "10"; -- y1,y0
					when "100"  => alu_ctrl.mul_op1 <= "00"; alu_ctrl.mul_op2 <= "11"; -- x0,y1
					when "101"  => alu_ctrl.mul_op1 <= "10"; alu_ctrl.mul_op2 <= "00"; -- y0,x0
					when "110"  => alu_ctrl.mul_op1 <= "01"; alu_ctrl.mul_op2 <= "10"; -- x1,y0
					when others => alu_ctrl.mul_op1 <= "11"; alu_ctrl.mul_op2 <= "01"; -- y1,x1
				end case;
				alu_ctrl.store_result    <= '1';  -- store result in accu
				alu_ctrl.add_src_stage_2 <= "10"; -- select mul out for adder!
				alu_ctrl.add_src_sign    <= '0' & instr_word_var(2); -- select +/-
				alu_ctrl.rounding_used   <= '0' & instr_word_var(0); -- rounding is determined by that bit!
				if instr_word_var(1) = '0' then -- MPY(R)
					alu_ctrl.shift_mode <= ZEROS;
				else -- MAC(R)
					alu_ctrl.shift_mode <= NO_SHIFT;
					alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
					alu_ctrl.shift_src_sign <= "00";          -- with the original sign
				end if;
				-- set all flags but carry!
				for i in 1 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- NEG
			if instr_word_var(7 downto 4) = "0011" and instr_word_var(2 downto 0) = "110" then
				-- Read accu
				alu_ctrl.shift_mode <= ZEROS;
--				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
--				alu_ctrl.shift_src_sign <= "01";          -- with negative sign
				-- Read Accu
				alu_ctrl.add_src_stage_1 <= "000"; -- source register equal to dst_register
				alu_ctrl.add_src_stage_2 <= "01"; -- select register as operand
				alu_ctrl.add_src_sign    <= "01"; -- with negative sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set all flags but carry!
				for i in 1 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- NOT
			if instr_word_var(7 downto 4) = "0001" and instr_word_var(2 downto 0) = "111" then
				alu_ctrl.word_24_update <= '1';
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				alu_ctrl.logic_function  <= instr_word_var(2 downto 0); -- select not operation
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				-- set following flags
				alu_ctrl.ccr_flags_ctrl(N_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(Z_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(V_FLAG) <= CLEAR;
			end if;
			-- RND
			if instr_word_var(7 downto 4) = "0001" and instr_word_var(2 downto 0) = "001" then
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "01"; -- normal rounding needed
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero as second operand
				-- set all flags but carry!
				for i in 1 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- ROL
			if instr_word_var(7 downto 4) = "0011" and instr_word_var(2 downto 0) = "111" then
				alu_ctrl.word_24_update <= '1';
				alu_ctrl.rotate <= '1';
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_LEFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero as second operand
				-- set the following flags
				alu_ctrl.ccr_flags_ctrl(C_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(V_FLAG) <= CLEAR;
				alu_ctrl.ccr_flags_ctrl(Z_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(N_FLAG) <= MODIFY;
			end if;
			-- ROR
			if instr_word_var(7 downto 4) = "0010" and instr_word_var(2 downto 0) = "111" then
				alu_ctrl.word_24_update <= '1';
				alu_ctrl.rotate <= '1';
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_RIGHT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				alu_ctrl.store_result    <= '1';  -- store the result
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero as second operand
				-- set the following flags
				alu_ctrl.ccr_flags_ctrl(C_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(V_FLAG) <= CLEAR;
				alu_ctrl.ccr_flags_ctrl(Z_FLAG) <= MODIFY;
				alu_ctrl.ccr_flags_ctrl(N_FLAG) <= MODIFY;
			end if;
			-- SBC
			if instr_word_var(7 downto 5) = "001" and instr_word_var(2 downto 0) = "101" then
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding) X,Y
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "01"; -- with negative sign
				alu_ctrl.rounding_used   <= "11"; -- subtract carry
				alu_ctrl.store_result    <= '1';  -- store the result
				-- set all flags!
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- SUB
			if instr_word_var(7) = '0' and instr_word_var(2 downto 0) = "100" then
				-- Read accu
				alu_ctrl.shift_mode <= NO_SHIFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding)
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "01"; -- with negative sign
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.store_result    <= '1';  -- store the result
				-- set all flags!
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- SUBL
			if instr_word_var(7 downto 4) = "0001" and instr_word_var(2 downto 0) = "110" then
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_LEFT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding)
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "01"; -- with negative sign
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.store_result    <= '1';  -- store the result
				-- set all flags!
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- SUBR
			if instr_word_var(7 downto 4) = "0000" and instr_word_var(2 downto 0) = "110" then
				-- Read accu
				alu_ctrl.shift_mode <= SHIFT_RIGHT;
				alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
				alu_ctrl.shift_src_sign <= "00";          -- with normal sign
				-- Read S
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 5) & '1'; -- source register (JJJ encoding)
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "01"; -- with negative sign
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.store_result    <= '1';  -- store the result
				-- set all flags!
				for i in 0 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
			-- TFR 
			if instr_word_var(7) = '0' and instr_word_var(6 downto 5) /= "01" and 
			   instr_word_var(6 downto 4) /= "001" and instr_word_var(2 downto 0) = "001" then
				-- do not read accu
				alu_ctrl.shift_mode <= ZEROS;
				-- Read S
				if instr_word_var(6) = '1' then
					alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding)
				else
					alu_ctrl.add_src_stage_1 <= "001"; -- B,A or A,B (depending on dest. accu)
				end if;
				alu_ctrl.add_src_stage_2 <= "01"; -- select the register source
				alu_ctrl.add_src_sign    <= "00"; -- with positive sign
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.store_result    <= '1';  -- store the result
				-- do not set any flag at all!
			end if;
			-- TST
			if instr_word_var(7 downto 4) = "0000" and instr_word_var(2 downto 0) = "011" then
				-- do not read accu
				alu_ctrl.shift_mode <= NO_SHIFT;          -- no shift
				alu_ctrl.shift_src  <= instr_word_var(3); -- read source accu
				alu_ctrl.shift_src_sign  <= "00";         -- sign unchanged
				-- Read S
				alu_ctrl.add_src_stage_2 <= "00"; -- select zero
				alu_ctrl.add_src_sign    <= "00"; -- with positive sign
				alu_ctrl.rounding_used   <= "00"; -- no rounding needed
				alu_ctrl.store_result    <= '0';  -- do not store the result
				-- set all flags but carry!
				for i in 1 to 7 loop
					alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
				end loop;
			end if;
		end if; -- Parallel move ALU instructions

		-- Tcc
		if alu_tcc_decoded = '1' then
			-- Read source
			if instr_word_var(6) = '1' then
				alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding)
			else
				alu_ctrl.add_src_stage_1 <= "001"; -- B,A or A,B (depending on dest. accu)
			end if;
			alu_ctrl.add_src_stage_2 <= "01"; -- select the registers as source
			-- The .store_result flag is generated in the execute stage
			-- depending on the condition codes
			-- do not set any flag at all!
		end if;
--mul_op1 : std_logic_vector(1 downto 0); -- x0,x1,y0,y1
--mul_op2 : std_logic_vector(1 downto 0); -- x0,x1,y0,y1
--shift_src  : std_logic; -- a,b
--shift_src_sign : std_logic_vector(1 downto 0); -- 00: pos, 01: neg, 10: sign dependant, 11: reserved
--shift_mode : alu_shift_mode;
--add_src_stage_1  : std_logic_vector(2 downto 0); -- x0,x1,y0,y1,x,y,a,b
--add_src_stage_2  : std_logic_vector(1 downto 0); -- 00: 0 , 01: add_src_1, 10: mul_result, 11: reserved
--add_src_sign   : std_logic_vector(1 downto 0); -- 00: pos, 01: neg, 10: sign dependant, 11: div instruction!
--logic_function : std_logic_vector(2 downto 0);  -- 000: none, 110: and, 010: or, 011: eor, 111: not
--word_24_update : std_logic;  -- only accumulator bits 47 downto 24 affected?
--rounding_used  : std_logic_vector(1 downto 0); -- 00: no rounding, 01: rounding, 10: add carry, 11: subtract carry
--store_result   : std_logic; -- 0: do not update accumulator, 1: update accumulator
--dst_accu       : std_logic; -- 0: a, 1: b
		-- DIV
		if alu_div_decoded = '1' then
			alu_ctrl.store_result    <= '1';          -- do store the result
			-- shifter operation
			alu_ctrl.shift_mode <= SHIFT_LEFT;        -- shift left
			alu_ctrl.shift_src  <= instr_word_var(3); -- read source accu
			alu_ctrl.div_instr  <= '1';               -- this is THE div instruction, special handling needed
			-- source operand loading
			alu_ctrl.add_src_stage_1 <= instr_word_var(6 downto 4); -- source register (JJJ encoding)
			alu_ctrl.add_src_stage_2 <= "01"; -- select the registers as source
			alu_ctrl.add_src_sign    <= "11"; -- div instruction, sign dependant on D[55] XOR S[23] 
			                                  -- if 1: positive, if 0: negative
			alu_ctrl.ccr_flags_ctrl(C_FLAG) <= MODIFY;
			alu_ctrl.ccr_flags_ctrl(V_FLAG) <= MODIFY;
			alu_ctrl.ccr_flags_ctrl(L_FLAG) <= MODIFY;
		end if;
		-- NORM
		if alu_norm_decoded = '1' then
			-- set all alu-ctrl signals to ASL/ASR already here
			-- depending on the condition code registers the flags
			-- will be completed in the execute stage
			alu_ctrl.norm_instr <= '1';
			-- Read accu
			--alu_ctrl.shift_mode <= SHIFT_RIGHT/SHIFT_LEFT/NO_SHIFT;
			alu_ctrl.shift_src  <= instr_word_var(3); -- accumulate to the same register we want to write to
			alu_ctrl.shift_src_sign <= "00";          -- with the original sign
			-- Read S
			alu_ctrl.add_src_stage_2 <= "00"; -- select zero as operand
			alu_ctrl.add_src_sign    <= "00"; -- with original sign
			alu_ctrl.store_result    <= '1';  -- store the result
			alu_ctrl.rounding_used   <= "00"; -- no rounding needed
			-- set all flags, V-flag will be cleared due to shifting
			for i in 0 to 7 loop
				alu_ctrl.ccr_flags_ctrl(i) <= MODIFY;
			end loop;

		end if;
	end process;


	instruction_decoder: process(instr_word, activate_dec) is
		variable instr_word_var : std_logic_vector(23 downto 0);
		procedure activate_AGU is
		begin
			-- check for immediate long addressing
			if instr_word_var(13 downto 8) = "110100" then
				act_array(ACT_IMM_LONG) <= '1';
				act_array(ACT_X_MEM_RD) <= '0'; -- No memory accesses for Immediate addressing!
				act_array(ACT_Y_MEM_RD) <= '0';
				act_array(ACT_X_MEM_WR) <= '0';
				act_array(ACT_Y_MEM_WR) <= '0';
			else
				act_array(ACT_ADGEN) <= '1';
			end if;
		end procedure activate_AGU;
	begin
		instr_array_int <= INSTR_NOP;
		act_array   <= (others => '0');
		adgen_bittype <= NOP;
		reg_rd_addr <= (others => '0');
		reg_wr_addr <= (others => '0');
		x_bus_rd_addr <= (others => '0');
		x_bus_wr_addr <= (others => '0');
		y_bus_rd_addr <= (others => '0');
		y_bus_wr_addr <= (others => '0');
		l_bus_addr <= instr_word_var(19) & instr_word_var(17 downto 16);

		alu_tcc_decoded <= '0';
		alu_div_decoded <= '0';
		alu_norm_decoded <= '0';

		-- in case the decoding is not activated we insert a nop
		if activate_dec = '1' then
			instr_word_var := instr_word;
		else
			instr_word_var := (others => '0');
		end if;

		if instr_word_var(23 downto 16) = X"00" then
			case instr_word_var(15 downto 0) is
				when X"0000" => instr_array_int <= INSTR_NOP;
				when X"0004" => instr_array_int <= INSTR_RTI; act_array(ACT_EXEC_BRA) <= '1';
				when X"0005" => instr_array_int <= INSTR_ILLEGAL;
				when X"0006" => instr_array_int <= INSTR_SWI;
				when X"000C" => instr_array_int <= INSTR_RTS; act_array(ACT_EXEC_BRA) <= '1';
				when X"0084" => instr_array_int <= INSTR_RESET;
				when X"0086" => instr_array_int <= INSTR_WAIT;
				when X"0087" => instr_array_int <= INSTR_STOP;
				when X"008C" => instr_array_int <= INSTR_ENDDO;
				                act_array(ACT_EXEC_LOOP) <= '1';
				when others =>
					act_array(ACT_EXEC_CR_MOD) <= '1'; -- modify control register
					if instr_word_var(7 downto 2) = "101110" then
						instr_array_int <= INSTR_ANDI;
					elsif instr_word_var(7 downto 2) = "111110" then
						instr_array_int <= INSTR_ORI;
					end if;
			end case;
		end if;
		---------------------------------------------------------
		-- DIV and NORM
		---------------------------------------------------------
		if instr_word_var(23 downto 16) = X"01" then
			-- DIV
			if instr_word_var(15 downto 6) = "1000000001" and instr_word_var(2 downto 0) = "000" then
				alu_div_decoded <= '1';
				act_array(ACT_ALU) <= '1'; -- force ALU to update status register
			end if;
			-- NORM
			if instr_word_var(15 downto 11) = "11011" and instr_word_var(7 downto 4) = "0001" and
		   	   instr_word_var(2 downto 0) = "101" then
				alu_norm_decoded <= '1';
				act_array(ACT_NORM) <= '1'; -- NORM instruction decoded, 
				                            -- special handling in exec-stage is caused
				act_array(ACT_REG_RD) <= '1';
				reg_rd_addr <= instr_word_var(13 downto 12) & '0' & instr_word_var(10 downto 8); -- Write same Rn
				act_array(ACT_REG_WR) <= '1';
				reg_wr_addr <= instr_word_var(13 downto 12) & '0' & instr_word_var(10 downto 8); -- Write same Rn
			end if;
		end if;
		---------------------------------------------------------
		-- Tcc
		---------------------------------------------------------
		if instr_word_var(23 downto 16) = X"02" or instr_word_var(23 downto 16) = X"03" then
			-- Tcc S1, D1  S2, D2 (ALU/Reg file)
			if instr_word_var(16) = '0' and instr_word_var(11 downto 7) = "00000" and
		       instr_word_var(2 downto 0) = "000" then
				act_array(ACT_ALU_WR_CC) <= '1';
				alu_tcc_decoded <= '1';
			-- Tcc S1, D1  S2, D2 (ALU/Reg file)
			elsif instr_word_var(16) = '1' and instr_word_var(11) = '0' and 
		   	      instr_word_var(7) = '0' then
				act_array(ACT_ALU_WR_CC) <= '1';
				alu_tcc_decoded <= '1';
				act_array(ACT_REG_WR_CC) <= '1';
				reg_rd_addr <= "010" & instr_word_var(10 downto 8); -- Read Rn
				reg_wr_addr <= "010" & instr_word_var( 2 downto 0); -- Write to other Rn
			end if;
		end if;
		---------------------------------------------------------
		-- MOVEC and LUA instruction with registers
		---------------------------------------------------------
		if instr_word_var(23 downto 16) = X"04" then
			act_array(ACT_REG_WR) <= '1';
			-- LUA instruction
			if instr_word_var(15 downto 13) = "010" and instr_word_var(7 downto 4) = "0001" then
				instr_array_int <= INSTR_LUA;
				act_array(ACT_ADGEN) <= '1';
				adgen_bittype <= SINGLE_X_SHORT;
				reg_wr_addr <= instr_word_var(5 downto 0);
			end if;
			-- MOVEC instruction (S1, D2) or (S2, D1)
			if instr_word_var(14) = '1' and instr_word_var(7 downto 5) = "101" then
				instr_array_int <= INSTR_MOVEC;
				act_array(ACT_REG_RD) <= '1';
				-- Write D1
				if instr_word_var(15) = '1' then
					reg_wr_addr <= instr_word_var(5 downto 0);
					reg_rd_addr <= instr_word_var(13 downto 8);
				-- Read S1
				else
					reg_wr_addr <= instr_word_var(13 downto 8);
					reg_rd_addr <= instr_word_var(5 downto 0);
				end if;
			end if;
		end if;
		-------------------------------------------------------------------------
		-- MOVEC instruction with memory access/absolute address
		-------------------------------------------------------------------------
		if instr_word_var(23 downto 16) = X"05" and 
		   instr_word_var(7) = '0' and instr_word_var(5) = '1' then
			
			instr_array_int <= INSTR_MOVEC;
			-- read from memory, write to register
			if instr_word_var(15) = '1' then
				act_array(ACT_REG_WR) <= '1';
				reg_wr_addr <= instr_word_var(5 downto 0);
				-- X Memory read?
				if instr_word_var(6) = '0' then
					act_array(ACT_X_MEM_RD) <= '1';
				-- Y Memory read?
				else
					act_array(ACT_Y_MEM_RD) <= '1';
				end if;
			-- write to memory, read register
			else
				act_array(ACT_REG_RD) <= '1';
				reg_rd_addr <= instr_word_var(5 downto 0);
				-- X Memory write?
				if instr_word_var(6) = '0' then
					act_array(ACT_X_MEM_WR) <= '1';
				-- Y Memory write?
				else
					act_array(ACT_Y_MEM_WR) <= '1';
				end if;
			end if;
			-- AGU needed?
			if instr_word_var(14) = '1' then
				-- detect whether two word instruction!
				adgen_bittype <= SINGLE_X;
				-- check for immediate long addressing
				if instr_word_var(13 downto 8) = "110100" then
					act_array(ACT_IMM_LONG) <= '1';
					act_array(ACT_X_MEM_RD) <= '0'; -- No memory accesses for Immediate addressing!
					act_array(ACT_Y_MEM_RD) <= '0';
					act_array(ACT_X_MEM_WR) <= '0';
					act_array(ACT_Y_MEM_WR) <= '0';
				else
					act_array(ACT_ADGEN) <= '1';
				end if;
			else
				-- X:/Y:aa short is done in the adgen-stage automatically
			end if;
		end if;
		-------------------------------------------------------------------------
		-- MOVEC instruction with immediate
		-------------------------------------------------------------------------
		if instr_word_var(23 downto 16) = X"05" and instr_word_var(7 downto 5) = "101" then
			instr_array_int <= INSTR_MOVEC;
			act_array(ACT_IMM_8BIT) <= '1';
			act_array(ACT_REG_WR) <= '1';
			reg_wr_addr <= instr_word_var(5 downto 0);
		end if;
		---------------------------------
		-- REP or DO loop?
		---------------------------------
		if instr_word_var(23 downto 16) = X"06" then
			-- Instruction encoding is the same for both except of this bit
			if instr_word_var(5) = '1' then
				instr_array_int <= INSTR_REP;
			else
				instr_array_int <= INSTR_DO;
			end if;
			act_array(ACT_EXEC_LOOP) <= '1';
			-- Init reading of loop counter from memory
			if instr_word_var(15) = '0' and instr_word_var(7) = '0' then
				-- X/Y: ea?
				if instr_word_var(14) = '1' then
					act_array(ACT_ADGEN) <= '1';
				end if;
				-- X/Y: aa?
				-- Done automatically in the ADGEN stage by testing whether the ADGEN unit activated or not!
				-- If not the absolute address stored in the instruction word is used.
				-------
				-- only a single memory access is required
				adgen_bittype <= SINGLE_X;
				-- X/Y as source?
				if instr_word_var(6) = '0' then
					act_array(ACT_X_MEM_RD) <= '1';
				else 
					act_array(ACT_Y_MEM_RD) <= '1';
				end if;
			elsif instr_word_var(15) = '1' and instr_word_var(7) = '0' then
				-- S (register as source)
				reg_rd_addr <= instr_word_var(13 downto 8);
				act_array(ACT_REG_RD) <= '1';
				-- #xxx ,12 bit immediate
			elsif instr_word_var(7 downto 6) = "10" and instr_word_var(4) = '0' then
				act_array(ACT_IMM_12BIT) <= '1';
			end if;
		end if;
		--------------------------------
		-- MOVEM (Program memory move)
		--------------------------------
		if instr_word_var(23 downto 16) = X"07" then
			-- read memory, write reg
			if instr_word_var(15) = '1' then
				act_array(ACT_REG_WR) <= '1';
				reg_wr_addr <= instr_word_var(5 downto 0);
				act_array(ACT_P_MEM_RD) <= '1';
			-- read reg, write memory
			elsif instr_word_var(15) = '0' then
				act_array(ACT_REG_RD) <= '1';
				reg_rd_addr <= instr_word_var(5 downto 0);
				act_array(ACT_P_MEM_WR) <= '1';
			end if;
			-- AGU needed?
			if instr_word_var(14) = '1' and instr_word_var(7 downto 6) = "10" then
				adgen_bittype <= SINGLE_X;
				-- activate AGU and test whether immediate data is used
				activate_AGU;
			elsif instr_word_var(14) = '0' and instr_word_var(7 downto 6) = "00" then
				-- X:/Y:aa short is done in the adgen-stage automatically
			end if;
		end if;
		--------------------------------
		-- MOVEP (Peripheral memory move)
		--------------------------------
		if instr_word_var(23 downto 16) = "0000100-" then
			-- TODO?? Why parallel moves in software model??
			case instr_word_var(15 downto 0) is
--				when "-1------1-------" => instr_array_int(INSTR_MOVEP) <= '1';
--				when "-1------01------" => instr_array_int(INSTR_MOVEP) <= '1';
--				when "-1------00------" => instr_array_int(INSTR_MOVEP) <= '1';
				when others =>
			end case;
		end if;
		-- BSET, BCLR, BCHG, BTST, JCLR, JSET, JSCLR, JSSET, JMP, JCC, JSCC, JSR
		if instr_word_var(23 downto 16) = X"0A" or instr_word_var(23 downto 16) = X"0B" then

			reg_rd_addr <= instr_word_var(13 downto 8);
			reg_wr_addr <= instr_word_var(13 downto 8);

			if instr_word_var(16) = '0' then
				if instr_word_var(7) = '0' and instr_word_var(5) = '0' then
					instr_array_int <= INSTR_BCLR;
				elsif instr_word_var(7) = '0' and instr_word_var(5) = '1' then
					instr_array_int <= INSTR_BSET;
				elsif instr_word_var(7) = '1' and instr_word_var(5) = '0' then
					instr_array_int <= INSTR_JCLR;
				elsif instr_word_var(7) = '1' and instr_word_var(5) = '1' then
					instr_array_int <= INSTR_JSET;
				end if;
			elsif instr_word_var(16) = '1' then
				if instr_word_var(7) = '0' and instr_word_var(5) = '0' then
					instr_array_int <= INSTR_BCHG;
				elsif instr_word_var(7) = '0' and instr_word_var(5) = '1' then
					instr_array_int <= INSTR_BTST;
				elsif instr_word_var(7) = '1' and instr_word_var(5) = '0' then
					instr_array_int <= INSTR_JSCLR;
				elsif instr_word_var(7) = '1' and instr_word_var(5) = '1' then
					instr_array_int <= INSTR_JSSET;
				end if;
			end if;
			if instr_word_var(7) = '1' then
				act_array(ACT_EXEC_BRA) <= '1';
			end if;

			-- memory access?
			if instr_word_var(15) = '0' then
				-- X:
				if instr_word_var(6) = '0' then
					act_array(ACT_X_MEM_RD) <= '1';
					-- if not a jump instruction and not BTST write back the result
					if instr_word_var(7) = '0' and not(instr_word_var(16) = '1' and instr_word_var(5) = '1') then
						act_array(ACT_X_MEM_WR) <= '1';
					end if;
				-- Y:
				else
					act_array(ACT_Y_MEM_RD) <= '1';
					-- if not a jump instruction and not BTST write back the result
					if instr_word_var(7) = '0' and not(instr_word_var(16) = '1' and instr_word_var(5) = '1') then
						act_array(ACT_Y_MEM_WR) <= '1';
					end if;
				end if;
			end if;

			case instr_word_var(15 downto 14) is
				-- X:/Y: aa
				when "00" =>

				-- X:/Y: ea
				when "01" =>
					act_array(ACT_ADGEN) <= '1';
					adgen_bittype <= SINGLE_X;

				-- X:/Y: pp 
				-- TODO!
				when "10" =>

				when others => -- "11"
					if instr_word_var(7 downto 0) = "10000000" then
						-- JMP/JSR ea
						act_array(ACT_EXEC_BRA) <= '1';
						act_array(ACT_ADGEN) <= '1';
						adgen_bittype <= SINGLE_X;
						if instr_word_var(16) = '0' then
							instr_array_int <= INSTR_JMP;
						elsif instr_word_var(16) = '1' then
							instr_array_int <= INSTR_JSR;
						end if;
					elsif instr_word_var(7 downto 4) = "1010" then
						-- JCC/JSCC ea
						act_array(ACT_EXEC_BRA) <= '1';
						act_array(ACT_ADGEN) <= '1';
						adgen_bittype <= SINGLE_X;
						if instr_word_var(16) = '0' then
							instr_array_int <= INSTR_JCC;
						elsif instr_word_var(16) = '1' then
							instr_array_int <= INSTR_JSCC;
						end if;
					-- JSCLR,JSET,JCLR,JSSET,BTST,BCLR,BSET,BCHG S/D
					else
						act_array(ACT_REG_RD) <= '1';
						-- if not a jump instruction and not BTST write back the result
						if instr_word_var(7) = '0' and not(instr_word_var(16) = '1' and instr_word_var(5) = '1') then
							act_array(ACT_REG_WR) <= '1';
						end if;
					end if;
			end case;
		end if;
		-- JMP xxx (absoulute short)
		if instr_word_var(23 downto 16) = X"0C" then
			if instr_word_var(15 downto 12) = "0000" then
				instr_array_int <= INSTR_JMP;
				act_array(ACT_EXEC_BRA) <= '1';
			end if;
		end if;
		-- JSR xxx (absolute short)
		if instr_word_var(23 downto 16) = X"0D" then
			if instr_word_var(15 downto 12) = "0000" then
				instr_array_int <= INSTR_JSR;
				act_array(ACT_EXEC_BRA) <= '1';
			end if;
		end if;
		-- JCC xxx (absolute short)
		if instr_word_var(23 downto 16) = X"0E" then
			instr_array_int <= INSTR_JCC;
			act_array(ACT_EXEC_BRA) <= '1';
		end if;
		-- JSCC xxx (absolute short)
		if instr_word_var(23 downto 16) = X"0F" then
			instr_array_int <= INSTR_JSCC;
			act_array(ACT_EXEC_BRA) <= '1';
		end if;

		------------------------------------------------
		-- PARALLEL MOVE SECTION!!
		------------------------------------------------
		-- Here are the ALU operations that allow for parallel moves
		if instr_word_var(23 downto 20) /= "0000" then
			act_array(ACT_ALU) <= '1'; -- force ALU to update status register
		end if;
		-- PM: I
		if instr_word_var(23 downto 21) = "001" and instr_word_var(20 downto 18) /= "000" then
			act_array(ACT_IMM_8BIT) <= '1';
			act_array(ACT_REG_WR) <= '1';
			reg_wr_addr <= '0' & instr_word_var(20 downto 16);
		end if;
		-- PM: R
		if instr_word_var(23 downto 18) = "001000" then
			act_array(ACT_REG_WR) <= '1';
			reg_wr_addr <= '0' & instr_word_var(12 downto  8);
			act_array(ACT_REG_RD) <= '1';
			reg_rd_addr <= '0' & instr_word_var(17 downto 13);
		end if;
		-- PM: U
		if instr_word_var(23 downto 13) = "00100000010" then
			act_array(ACT_ADGEN) <= '1';
			adgen_bittype <= SINGLE_X_SHORT;
		end if;
		-- PM: X or PM:Y
		if instr_word_var(23 downto 22) = "01" and 
		   -- Check whether L: type parallel move. If so do not enter this branch!
		   not (instr_word_var(21 downto 20) = "00" and instr_word_var(18) = '0') then
			-- read memory, write reg
			if instr_word_var(15) = '1' then
				act_array(ACT_REG_WR) <= '1';
				reg_wr_addr <= '0' & instr_word_var(21 downto 20) & instr_word_var(18 downto 16); -- TODO: CHECK!!
				-- X Memory read?
				if instr_word_var(19) = '0' then
					act_array(ACT_X_MEM_RD) <= '1';
				-- Y Memory read?
				else
					act_array(ACT_Y_MEM_RD) <= '1';
				end if;
			-- read reg, write memory
			elsif instr_word_var(15) = '0' then
				act_array(ACT_REG_RD) <= '1';
				reg_rd_addr <= '0' & instr_word_var(21 downto 20) & instr_word_var(18 downto 16); -- TODO: CHECK!!
				-- X Memory write?
				if instr_word_var(19) = '0' then
					act_array(ACT_X_MEM_WR) <= '1';
				-- Y Memory write?
				else
					act_array(ACT_Y_MEM_WR) <= '1';
				end if;
			end if;
			-- AGU needed?
			if instr_word_var(14) = '1' then
				-- detect whether two word instruction!
				adgen_bittype <= SINGLE_X;
				-- activate AGU and test whether immediate data is used
				activate_AGU;
			else
				-- X:/Y:aa short is done in the adgen-stage automatically
			end if;
		end if;
		-- PM: X:R or R:Y (Class I)
		if instr_word_var(23 downto 20) = "0001" then
			adgen_bittype <= SINGLE_X;
			-- X:R
			if instr_word_var(14) = '0' then
				x_bus_rd_addr <= instr_word_var(19 downto 18);
				x_bus_wr_addr <= instr_word_var(19 downto 18);
				y_bus_rd_addr <= '1' & instr_word_var(17);
				y_bus_wr_addr <= '0' & instr_word_var(16); -- TODO: Check encoding, manual uses three fs!
				-- S2,D2 in any case!
				act_array(ACT_Y_BUS_RD) <= '1';
				act_array(ACT_Y_BUS_WR) <= '1';
				-- Write D1?
				if instr_word_var(15) = '1' then
					act_array(ACT_X_MEM_RD) <= '1';
					act_array(ACT_X_BUS_WR) <= '1';
				else
				-- Read S1?
					act_array(ACT_X_MEM_WR) <= '1';
					act_array(ACT_X_BUS_RD) <= '1';
				end if;
			-- R:Y
			elsif instr_word_var(14) = '1' then
				x_bus_rd_addr <= '1' & instr_word_var(19);
				x_bus_wr_addr <= '0' & instr_word_var(18);
				y_bus_rd_addr <= instr_word_var(17 downto 16);
				y_bus_wr_addr <= instr_word_var(17 downto 16);
				-- S1,D1 in any case!
				act_array(ACT_X_BUS_RD) <= '1';
				act_array(ACT_X_BUS_WR) <= '1';
				-- Write D1?
				if instr_word_var(15) = '1' then
					act_array(ACT_Y_MEM_RD) <= '1';
					act_array(ACT_Y_BUS_WR) <= '1';
				else
				-- Read S1?
					act_array(ACT_Y_MEM_WR) <= '1';
					act_array(ACT_Y_BUS_RD) <= '1';
				end if;

			end if;
			-- detect whether two word instruction!
			adgen_bittype <= SINGLE_X;
			-- activate AGU and test whether immediate data is used
			activate_AGU;
		end if;
		-- PM: X:R or R:Y (Class II)
		if instr_word_var(23 downto 17) = "0000100" and instr_word_var(14) = '0' then
			act_array(ACT_REG_RD) <= '1';
			-- X:R
			if instr_word_var(15) = '0' then
				reg_rd_addr <= "00111" & instr_word_var(16); -- read A or B
				act_array(ACT_X_MEM_WR) <= '1'; -- and store it in X memory
				x_bus_rd_addr <= "00"; -- read x0
				x_bus_wr_addr <= '1' & instr_word_var(16); -- and write to A or B
				act_array(ACT_X_BUS_RD) <= '1';
				act_array(ACT_X_BUS_WR) <= '1';
			-- R:Y
			elsif instr_word_var(15) = '1' then
				reg_rd_addr <= "00111" & instr_word_var(16); -- read A or B
				act_array(ACT_Y_MEM_WR) <= '1'; -- and store it in Y memory
				y_bus_rd_addr <= "00"; -- read y0
				y_bus_wr_addr <= '1' & instr_word_var(16); -- and write to A or B
				act_array(ACT_Y_BUS_RD) <= '1';
				act_array(ACT_Y_BUS_WR) <= '1';
			end if;
			-- detect whether two word instruction!
			adgen_bittype <= SINGLE_X;
			-- activate AGU and test whether immediate data is used
			activate_AGU;
		end if;
		-- PM: L:
		l_bus_addr <= instr_word_var(19) & instr_word_var(17 downto 16);
		if instr_word_var(23 downto 20) = "0100" and instr_word_var(18) = '0' then
			-- Read S?
			if instr_word_var(15) = '0' then
				act_array(ACT_L_BUS_RD) <= '1';
				act_array(ACT_X_MEM_WR) <= '1';
				act_array(ACT_Y_MEM_WR) <= '1';
			else -- Write D
				act_array(ACT_L_BUS_WR) <= '1';
				act_array(ACT_X_MEM_RD) <= '1';
				act_array(ACT_Y_MEM_RD) <= '1';
			end if;
			if instr_word_var(14) = '1' then
				adgen_bittype <= SINGLE_X;
				activate_AGU;
			else
				-- L:aa automatically performed in ADGEN stage
			end if;
		end if;
		-- PM: X: Y:
		if instr_word_var(23) = '1' then
			adgen_bittype <= DOUBLE_X_Y;
			-- No immediate value allowed, so activate in any case!
			act_array(ACT_ADGEN) <= '1';
			-- S1, X:
			if instr_word_var(15) = '0' then
				act_array(ACT_X_BUS_RD) <= '1';
				x_bus_rd_addr <= instr_word_var(19 downto 18);
				act_array(ACT_X_MEM_WR) <= '1'; 
			-- X:, D1
			else
				act_array(ACT_X_BUS_WR) <= '1';
				x_bus_wr_addr <= instr_word_var(19 downto 18);
				act_array(ACT_X_MEM_RD) <= '1'; 
			end if;
			-- S2, Y:
			if instr_word_var(22) = '0' then
				act_array(ACT_Y_BUS_RD) <= '1';
				y_bus_rd_addr <= instr_word_var(17 downto 16);
				act_array(ACT_Y_MEM_WR) <= '1'; 
			-- Y:, D2
			else
				act_array(ACT_Y_BUS_WR) <= '1';
				y_bus_wr_addr <= instr_word_var(17 downto 16);
				act_array(ACT_Y_MEM_RD) <= '1'; 
			end if;
		end if;
	end process;

	adgen_decoder: process(adgen_bittype, instr_word) is
	begin
		adgen_mode_a <= NOP;
		adgen_mode_b <= NOP;
		ea_extension_available <= '0';

		case adgen_bittype is
			when SINGLE_X =>
				case instr_word(13 downto 11) is
					when "000" => adgen_mode_a <= POST_MIN_N;
					when "001" => adgen_mode_a <= POST_PLUS_N;
					when "010" => adgen_mode_a <= POST_MIN_1;
					when "011" => adgen_mode_a <= POST_PLUS_1;
					when "100" => adgen_mode_a <= NOP;
					when "101" => adgen_mode_a <= INDEXED_N;
					when "111" => adgen_mode_a <= PRE_MIN_1;
					when "110" => 
						if instr_word(10 downto 8) = "000" then
							adgen_mode_a <= ABSOLUTE;
							ea_extension_available <= '1';
						elsif instr_word(10 downto 8) = "100" then
							adgen_mode_a <= IMMEDIATE;
							ea_extension_available <= '1';
						else 
							adgen_mode_a <= NOP; -- INVALID OPCODE!
						end if;
					when others =>
				end case;
			when SINGLE_X_SHORT =>
				case instr_word(12 downto 11) is
					when "00" => adgen_mode_a <= POST_MIN_N;
					when "01" => adgen_mode_a <= POST_PLUS_N;
					when "10" => adgen_mode_a <= POST_MIN_1;
					when "11" => adgen_mode_a <= POST_PLUS_1;
					when others => 
				end case;
			when DOUBLE_X_Y =>
				case instr_word(12 downto 11) is
					when "00" => adgen_mode_a <= NOP;
					when "01" => adgen_mode_a <= POST_PLUS_N;
					when "10" => adgen_mode_a <= POST_MIN_1;
					when "11" => adgen_mode_a <= POST_PLUS_1;
					when others =>
				end case;
				case instr_word(21 downto 20) is
					when "00" => adgen_mode_b <= NOP;
					when "01" => adgen_mode_b <= POST_PLUS_N;
					when "10" => adgen_mode_b <= POST_MIN_1;
					when "11" => adgen_mode_b <= POST_PLUS_1;
					when others =>
				end case;
			when others =>
		end case;
	end process adgen_decoder;

end architecture rtl;

