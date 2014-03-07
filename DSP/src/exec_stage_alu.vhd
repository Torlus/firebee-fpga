library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity exec_stage_alu is port(
	alu_activate      : in  std_logic;
	instr_word        : in  std_logic_vector(23 downto 0);
	alu_ctrl          : in  alu_ctrl_type;
	register_file     : in  register_file_type;
	addr_r_in         : in  unsigned(BW_ADDRESS-1 downto 0);
	addr_r_out        : out unsigned(BW_ADDRESS-1 downto 0);
	modify_accu       : out std_logic;
	dst_accu          : out std_logic;
	modified_accu     : out signed(55 downto 0);
	modify_sr         : out std_logic;
	modified_sr       : out std_logic_vector(15 downto 0)
);
end entity;

architecture rtl of exec_stage_alu is 

	signal alu_shifter_out          : signed(55 downto 0);
	signal alu_shifter_carry_out    : std_logic;
	signal alu_shifter_overflow_out : std_logic;

	signal alu_logic_conj        : signed(55 downto 0);
	signal alu_multiplier_out    : signed(55 downto 0);
	signal alu_src_op            : signed(55 downto 0);
	signal alu_add_result        : signed(56 downto 0);
	signal alu_add_carry_out     : std_logic;
	signal alu_post_adder_result : signed(56 downto 0);

	signal scaling_mode          : std_logic_vector(1 downto 0);

	signal modified_accu_int     : signed(55 downto 0);

	signal norm_instr_asl  : std_logic;
	signal norm_instr_asr  : std_logic;
	signal norm_instr_nop  : std_logic;
	signal norm_update_ccr : std_logic; 

begin


	-- store calculated value?
	modify_accu <= alu_ctrl.store_result;
	modified_accu <= modified_accu_int;
	-- for the norm instruction we first need to determine whether we have to
	-- update the CCR register or not
	modify_sr <= alu_activate when alu_ctrl.norm_instr = '0' else
	             norm_update_ccr;
	dst_accu <= alu_ctrl.dst_accu;

	scaling_mode <= register_file.sr(11 downto 10);


	calcule_ccr_flags: process(register_file, alu_ctrl, alu_shifter_carry_out,
	                           alu_post_adder_result, modified_accu_int, alu_add_carry_out) is
	begin
		-- by default do not modify the flags in the status register
		modified_sr <= register_file.sr;
		
		-- Carry flag generation
		-------------------------
		case alu_ctrl.ccr_flags_ctrl(C_FLAG) is
			when CLEAR  => modified_sr(C_FLAG) <= '0';
			when SET    => modified_sr(C_FLAG) <= '1';
			when MODIFY =>
				-- the carry flag can stem from the shifter or from the post adder
				-- in case we shift and add only a zero to the shift result (ASL, ASR, LSL, LSR, ROL, ROR)
				-- take the carry flag from the shifter, else from the post adder
				if (alu_ctrl.shift_mode = SHIFT_LEFT or alu_ctrl.shift_mode = SHIFT_RIGHT) and
				    alu_ctrl.add_src_stage_2 = "00" then -- add zero after shifting?
					modified_sr(C_FLAG) <= alu_shifter_carry_out;
				elsif alu_ctrl.div_instr = '1' then
					modified_sr(C_FLAG) <= not std_logic(alu_post_adder_result(55));
				else
--					modified_sr(C_FLAG) <= std_logic(alu_post_adder_result(57));
					modified_sr(C_FLAG) <= alu_add_carry_out;
				end if;
			when others => -- Don't touch
		end case;

		-- Overflow flag generation
		----------------------------
		case alu_ctrl.ccr_flags_ctrl(V_FLAG) is
			when CLEAR  => modified_sr(V_FLAG) <= '0';
			when SET    => modified_sr(V_FLAG) <= '1';
			when MODIFY =>
				-- There are two sources for the overflow flag:
				-- 1)
				-- in case the result cannot be represented using 56 bits set
				-- the overflow flag. this is the case when the two MSBs of 
				-- the 57 bit result are different
				-- 2)
				-- The shifter circuit performs a 56 bit left shift. In case the 
				-- two MSBs of the operand are different set the overflow flag as well
				if (alu_ctrl.div_instr = '0' and alu_post_adder_result(56) /= alu_post_adder_result(55)) or
			   	   (alu_ctrl.shift_mode = SHIFT_LEFT and alu_ctrl.word_24_update = '0' and 
				    alu_shifter_overflow_out = '1' ) then
					modified_sr(V_FLAG) <= '1';
				else
					modified_sr(V_FLAG) <= '0';
				end if;
			when others => -- Don't touch
		end case;
		
		-- Zero flag generation
		----------------------------
		case alu_ctrl.ccr_flags_ctrl(Z_FLAG) is
			when CLEAR  => modified_sr(Z_FLAG) <= '0';
			when SET    => modified_sr(Z_FLAG) <= '1';
			when MODIFY =>
				-- in case the result is zero set this flag
				-- distinguish between 24 bit and 56 bit ALU operations
				-- 24 bit instructions are LSL, LSR, ROR, ROL, OR, EOR, NOT, AND
				if (alu_ctrl.word_24_update = '1' and modified_accu_int(47 downto 24) = 0) or
				   (alu_ctrl.word_24_update = '0' and modified_accu_int(55 downto  0) = 0) then
					modified_sr(Z_FLAG) <= '1';
				else
					modified_sr(Z_FLAG) <= '0';
				end if;
			when others => -- Don't touch
		end case;

		-- Negative flag generation
		----------------------------
		case alu_ctrl.ccr_flags_ctrl(N_FLAG) is
			when CLEAR  => modified_sr(N_FLAG) <= '0';
			when SET    => modified_sr(N_FLAG) <= '1';
			when MODIFY =>
				-- in case the result is negative set this flag
				-- distinguish between 24 bit and 56 bit ALU operations
				-- 24 bit instructions are LSL, LSR, ROR, ROL, OR, EOR, NOT, AND
				if alu_ctrl.word_24_update = '1' then
					modified_sr(N_FLAG) <= std_logic(modified_accu_int(47));
				else
					modified_sr(N_FLAG) <= std_logic(modified_accu_int(55));
				end if;
			when others => -- Don't touch
		end case;

		-- Unnormalized flag generation
		----------------------------
		case alu_ctrl.ccr_flags_ctrl(U_FLAG) is
			when CLEAR  => modified_sr(U_FLAG) <= '0';
			when SET    => modified_sr(U_FLAG) <= '1';
			when MODIFY =>
				-- Set unnormalized bit according to the scaling mode
				if (scaling_mode = "00" and alu_post_adder_result(47) = alu_post_adder_result(46)) or
				   (scaling_mode = "01" and alu_post_adder_result(48) = alu_post_adder_result(47)) or
				   (scaling_mode = "10" and alu_post_adder_result(46) = alu_post_adder_result(45)) then
					modified_sr(U_FLAG) <= '1';
				else
					modified_sr(U_FLAG) <= '0';
				end if;
			when others => -- Don't touch
		end case;

		-- Extension flag generation
		----------------------------
		case alu_ctrl.ccr_flags_ctrl(E_FLAG) is
			when CLEAR  => modified_sr(E_FLAG) <= '0';
			when SET    => modified_sr(E_FLAG) <= '1';
			when MODIFY =>
				-- Set extension flag by default
				modified_sr(E_FLAG) <= '1';
				-- Clear extension flag according to the scaling mode
				case scaling_mode is
					when "00" =>
						if alu_post_adder_result(55 downto 47) = "111111111" or alu_post_adder_result(55 downto 47) = "000000000" then
							modified_sr(E_FLAG) <= '0';
						end if;
					when "01" =>
						if alu_post_adder_result(55 downto 48) = "11111111" or alu_post_adder_result(55 downto 48) = "00000000" then
							modified_sr(E_FLAG) <= '0';
						end if;
					when "10" =>
						if alu_post_adder_result(55 downto 46) = "1111111111" or alu_post_adder_result(55 downto 46) = "0000000000" then
							modified_sr(E_FLAG) <= '0';
						end if;
					when others =>
						modified_sr(E_FLAG) <= '0';
				end case;
			when others => -- Don't touch
		end case;

		-- Limit flag generation (equals overflow flag generaton!)
		-- Clearing of the Limit flag has to be done by the user!
		-----------------------------------------------------------
		case alu_ctrl.ccr_flags_ctrl(L_FLAG) is
			when CLEAR  => modified_sr(L_FLAG) <= '0';
			when SET    => modified_sr(L_FLAG) <= '1';
			when MODIFY =>
				-- There are two sources for the overflow flag:
				-- 1)
				-- in case the result cannot be represented using 56 bits set
				-- the overflow flag. this is the case when the two MSBs of 
				-- the 57 bit result are different
				-- 2)
				-- The shifter circuit performs a 56 bit left shift. In case the 
				-- two MSBs of the operand are different set the overflow flag as well
				if (alu_ctrl.div_instr = '0' and alu_post_adder_result(56) /= alu_post_adder_result(55)) or
			   	   (alu_ctrl.shift_mode = SHIFT_LEFT and alu_ctrl.word_24_update = '0' and 
				    alu_shifter_overflow_out = '1' ) then
					modified_sr(L_FLAG) <= '1';
				end if;
			when others => -- Don't touch
		end case;

		-- Scaling flag generation (DSP56002 and up)
		--------------------------------------------
		-- Scaling flag is not generated in the ALU, but when A or B are read to the XDB or YDB

	end process;


	src_operand_select: process(register_file, alu_ctrl) is
	begin
		-- decoding according similar to JJJ representation
		case alu_ctrl.add_src_stage_1 is 
			when "000" =>
				-- select depending on destination accu
				if alu_ctrl.dst_accu = '0' then
					alu_src_op <= register_file.a;
				else
					alu_src_op <= register_file.b;
				end if;
			when "001" => -- A,B or B,A
				-- select depending on destination accu
				if alu_ctrl.dst_accu = '0' then
					alu_src_op <= register_file.b;
				else
					alu_src_op <= register_file.a;
				end if;
			when "010" =>  -- X
				alu_src_op(55 downto 48) <= (others => register_file.x1(23));
				alu_src_op(47 downto  0) <= register_file.x1 & register_file.x0;
			when "011" =>  -- Y
				alu_src_op(55 downto 48) <= (others => register_file.y1(23));
				alu_src_op(47 downto  0) <= register_file.y1 & register_file.y0;
			when "100" =>  -- x0
				alu_src_op(55 downto 48) <= (others => register_file.x0(23));
				alu_src_op(47 downto 24) <= register_file.x0;
				alu_src_op(23 downto  0) <= (others => '0');
			when "101" =>  -- y0
				alu_src_op(55 downto 48) <= (others => register_file.y0(23));
				alu_src_op(47 downto 24) <= register_file.y0;
				alu_src_op(23 downto  0) <= (others => '0');
			when "110" =>  -- x1
				alu_src_op(55 downto 48) <= (others => register_file.x1(23));
				alu_src_op(47 downto 24) <= register_file.x1;
				alu_src_op(23 downto  0) <= (others => '0');
			when "111" =>  -- y1
				alu_src_op(55 downto 48) <= (others => register_file.y1(23));
				alu_src_op(47 downto 24) <= register_file.y1;
				alu_src_op(23 downto  0) <= (others => '0');
			when others =>
		end case;
	end process;

	alu_logical_functions: process(alu_ctrl, alu_src_op, alu_shifter_out) is
	begin
		alu_logic_conj <= alu_shifter_out;
		case alu_ctrl.logic_function is
			when "110" =>
				alu_logic_conj(47 downto 24) <= alu_shifter_out(47 downto 24) and alu_src_op(47 downto 24);
			when "010" =>
				alu_logic_conj(47 downto 24) <= alu_shifter_out(47 downto 24) or  alu_src_op(47 downto 24);
			when "011" =>
				alu_logic_conj(47 downto 24) <= alu_shifter_out(47 downto 24) xor alu_src_op(47 downto 24);
			when "111" =>
				alu_logic_conj(47 downto 24) <= not alu_shifter_out(47 downto 24);
			when others =>
		end case;
	end process;

	alu_adder : process(alu_ctrl, alu_src_op, alu_multiplier_out, alu_shifter_out) is
		variable add_src_op_1 : signed(56 downto 0);
		variable add_src_op_2 : signed(56 downto 0);
		variable carry_const  : signed(56 downto 0);
		variable alu_shifter_out_57 : signed(56 downto 0);
		variable alu_add_result_58  : signed(57 downto 0);
		variable alu_add_result_interm : signed(56 downto 0);
		variable invert_carry_flag : std_logic;
	begin

		-- by default do not invert the carry
		invert_carry_flag := '0';

		-- determine whether to use multiplier output, the operand defined above, or zeros!
		-- resizing is done here already. Like that we can see whether an overflow
		-- occurs due to negating the source operand
		case alu_ctrl.add_src_stage_2 is
			when "00" => add_src_op_1 := (others => '0');
			when "10" => add_src_op_1 := resize(alu_multiplier_out, 57);
			when others => add_src_op_1 := resize(alu_src_op, 57);
		end case;

		-- determine the sign for the 1st operand!
		case alu_ctrl.add_src_sign is
			-- normal operation
			when "00" => add_src_op_1 := add_src_op_1;
			-- negative sign
			when "01" => add_src_op_1 := - add_src_op_1;
			             invert_carry_flag := not invert_carry_flag;
			-- change according to sign
			-- performs - | accu | for the CMPM instruction
			when "10" =>
				-- we subtract in any case, so invert the carry!
				invert_carry_flag := not invert_carry_flag;
				if add_src_op_1(55) = '0' then 
					add_src_op_1 := - add_src_op_1;
				else
					add_src_op_1 :=   add_src_op_1;
				end if;
			-- div instruction!
			-- sign dependant of D[55] XOR S[23], if 1 => positive , if 0 => negative
			-- add_src_op_1 holds S[23] (sign extension!)
			when others => 
				if (alu_ctrl.shift_src = '0' and add_src_op_1(55) /= register_file.a(55)) or
			   	   (alu_ctrl.shift_src = '1' and add_src_op_1(55) /= register_file.b(55)) then 
					add_src_op_1 :=   add_src_op_1;
				else
					add_src_op_1 := - add_src_op_1;
--					invert_carry_flag := not invert_carry_flag;
				end if;
		end case;

		alu_shifter_out_57 := resize(alu_shifter_out, 57);

		-- determine the sign for the 2nd operand (coming from the shifter)!
		case alu_ctrl.shift_src_sign is
			-- negative sign
			when "01" =>
			   	add_src_op_2 := - alu_shifter_out_57;
			-- change according to sign
			-- this allows to build the magnitude (ABS, CMPM)
			when "10" =>
				if alu_shifter_out(55) = '1' then 
					add_src_op_2 := - alu_shifter_out_57;
				else
					add_src_op_2 :=   alu_shifter_out_57;
				end if;
			when others =>
			   	add_src_op_2 := alu_shifter_out_57;
		end case;

		-- determine whether carry flag has to be added or subtracted
		if alu_ctrl.rounding_used = "10" then
			-- add carry flag
			carry_const(0) := register_file.sr(C_FLAG);
		elsif alu_ctrl.rounding_used = "11" then
			-- subtract carry flag
			carry_const := (others => register_file.sr(0)); -- carry flag
		else
			carry_const := (others => '0');
		end if;

		-- add the values and calculate the carry bit
		alu_add_result_interm := ('0' & add_src_op_1(55 downto 0)) + 
		                         ('0' & add_src_op_2(55 downto 0)) +
		                         ('0' & carry_const(55 downto 0));

		-- here pops the new carry out of the adder
		if invert_carry_flag = '0' then
			alu_add_carry_out <= alu_add_result_interm(56);
		else 
			alu_add_carry_out <= not alu_add_result_interm(56);
		end if;

		-- calculate the last bit (56), in order to test for overflow later on
		alu_add_result(55 downto 0) <= alu_add_result_interm(55 downto 0);
--		alu_add_result(56) <= add_src_op_1(56) xor add_src_op_2(56) xor alu_add_result_interm(56);
		alu_add_result(56) <= add_src_op_1(56) xor add_src_op_2(56) 
		                      xor carry_const(56) xor alu_add_result_interm(56);

	end process alu_adder;


	-- Adder after the normal arithmetic adder
	-- This adder is responsible for
--	-- 1) carry addition
--	-- 2) carry subtration
	-- 3) convergent rounding
	alu_post_adder: process(alu_add_result, scaling_mode, alu_ctrl) is
		variable post_adder_constant : signed(56 downto 0);
		variable testing_constant    : signed(24 downto 0);
	begin
		-- by default add nothing
		post_adder_constant := (others => '0');

		case alu_ctrl.rounding_used is
			-- rounding dependant on scaling bits
			when "01" =>
				case scaling_mode is 
					-- no scaling
					when "00" => testing_constant := alu_add_result(23 downto 0) & '0';
					-- scale down
					when "01" => testing_constant := alu_add_result(24 downto 0);
					-- scale up
					when "10" => testing_constant := alu_add_result(22 downto 0) & "00";
					when others =>
					             testing_constant := alu_add_result(23 downto 0) & '0';
				end case;

				-- Special case!
				if testing_constant(24) = '1' and testing_constant(23 downto 0) = X"000000" then
					-- add depending on bit left to the rounding position
					case scaling_mode is
						-- no scaling
						when "00" => post_adder_constant(23) := alu_add_result(24);
						-- scale down
						when "01" => post_adder_constant(24) := alu_add_result(25);
						-- scale up
						when "10" => post_adder_constant(22) := alu_add_result(23);
						when others =>
					end case;
				else -- testing_constant /= X"1000000" 
					-- add rounding constant depending on scaling mode
					-- results in round up if MSB of testing constant is set, else nothing happens
					case scaling_mode is
						-- no scaling
						when "00" => post_adder_constant(23) := '1';
						-- scale down
						when "01" => post_adder_constant(24) := '1';
						-- scale up
						when "10" => post_adder_constant(22) := '1';
						when others =>
					end case;
				end if;
			-- no rounding
			when others =>
				post_adder_constant := (others => '0');

		end case;

		-- Add the result of the first adder to the constant (e.g., carry flag)
		alu_post_adder_result <= alu_add_result + post_adder_constant;

		-- When rounding is used set 24 LSBs to zero!
		if alu_ctrl.rounding_used = "01" then
			alu_post_adder_result(23 downto 0) <= (others => '0');
		end if;
	end process;



	alu_select_new_accu: process(alu_post_adder_result, alu_logic_conj, alu_ctrl) is
	begin
		if alu_ctrl.logic_function /= "000" then
			modified_accu_int <= alu_logic_conj;
		else
			modified_accu_int <= alu_post_adder_result(55 downto 0);
		end if;
	end process;


	-- contains the 24*24 bit fractional multiplier
	alu_multiplier : process(register_file, alu_ctrl) is
		variable src_op1: signed(23 downto 0);
		variable src_op2: signed(23 downto 0);
		variable mul_result_interm : signed(47 downto 0);
	begin
		-- select source operands for multiplication
		case alu_ctrl.mul_op1 is
			when "00"   => src_op1 := register_file.x0;
			when "01"   => src_op1 := register_file.x1;
			when "10"   => src_op1 := register_file.y0;
			when others => src_op1 := register_file.y1;
		end case;
		case alu_ctrl.mul_op2 is
			when "00"   => src_op2 := register_file.x0;
			when "01"   => src_op2 := register_file.x1;
			when "10"   => src_op2 := register_file.y0;
			when others => src_op2 := register_file.y1;
		end case;

		-- perform integer multiplication
		mul_result_interm := src_op1 * src_op2;

		-- sign extension of result
		alu_multiplier_out(55 downto 48) <= (others => mul_result_interm(47));
		-- convert from two's complement representation to fractional format
		-- signed integer multiplication delivers twice the sign bit, but only one is needed for the
		-- fractional multiplication, so remove one and append a zero to the result
		alu_multiplier_out(47 downto 0) <= mul_result_interm(46 downto 0) & '0';

	end process alu_multiplier;


	-- contains the data shifter
	alu_shifter: process(register_file, alu_ctrl, norm_instr_asl, norm_instr_asr) is
		variable src_accu : signed(55 downto 0);
		variable shift_to_perform : alu_shift_mode;
	begin
		-- read source accumulator
		if alu_ctrl.shift_src = '0' then
			src_accu := register_file.a;
		else
			src_accu := register_file.b;
		end if;

		alu_shifter_carry_out <= '0';
		alu_shifter_overflow_out <= '0';

		-- NORM instruction determines the shift value just
		-- in time, so overwrite the flag from the alu_ctrl
 		-- for this instruction by the calculated value
		if alu_ctrl.norm_instr = '0' then
			shift_to_perform := alu_ctrl.shift_mode;
		else
			if norm_instr_asl = '1' then
				shift_to_perform := SHIFT_LEFT;
			elsif norm_instr_asr = '1' then
				shift_to_perform := SHIFT_RIGHT;
			else
				shift_to_perform := NO_SHIFT;
			end if;
		end if;

		case shift_to_perform is
			when NO_SHIFT => 
				alu_shifter_out <= src_accu;
			when SHIFT_LEFT => 
				-- ASL, ADDL, DIV?
				if alu_ctrl.word_24_update = '0' then
					-- special handling for div instruction required
					if alu_ctrl.div_instr = '1' then
						alu_shifter_out <= src_accu(54 downto 0) & register_file.sr(C_FLAG);
					else
						alu_shifter_out <= src_accu(54 downto 0) & '0';
					end if;
					alu_shifter_carry_out <= src_accu(55);
					-- detect overflow that results from left shifting 
					-- Needed for ASL, ADDL, DIV instructions
					if src_accu(55) /= src_accu(54) then
						alu_shifter_overflow_out <= '1';
					end if;
				-- LSL/ROL?
				elsif alu_ctrl.word_24_update = '1' then
					alu_shifter_out(55 downto 48) <= src_accu(55 downto 48);
					alu_shifter_out(23 downto  0) <= src_accu(23 downto  0);
					alu_shifter_carry_out <= src_accu(47);
					if alu_ctrl.rotate = '0' then -- LSL ?
						alu_shifter_out(47 downto 24) <= src_accu(46 downto 24) & '0';
					else -- ROL ?
						alu_shifter_out(47 downto 24) <= src_accu(46 downto 24) & register_file.sr(C_FLAG);
					end if;
				end if;
			when SHIFT_RIGHT => 
				-- ASR?
				if alu_ctrl.word_24_update = '0' then
					alu_shifter_out <= src_accu(55) & src_accu(55 downto 1);
					alu_shifter_carry_out <= src_accu(0);
				-- LSR/ROR?
				elsif alu_ctrl.word_24_update = '1' then
					alu_shifter_out(55 downto 48) <= src_accu(55 downto 48);
					alu_shifter_out(23 downto  0) <= src_accu(23 downto  0);
					alu_shifter_carry_out <= src_accu(24);
					if alu_ctrl.rotate = '0' then -- LSR
						alu_shifter_out(47 downto 24) <= '0' & src_accu(47 downto 25);
					else -- ROR
						alu_shifter_out(47 downto 24) <= register_file.sr(C_FLAG) & src_accu(47 downto 25);
					end if;
				end if;
			when ZEROS =>
				alu_shifter_out <= (others => '0');
		end case;
	end process alu_shifter;


	-- Special handling for NORM instruction
 	-- Determine which case occurs (see User's Manual for more information)
	norm_instr_logic: process(register_file, addr_r_in) is
	begin
		norm_instr_asl <= '0';
		norm_instr_asr <= '0';

		-- Either left shift
		if register_file.sr(E_FLAG) = '0' and
		   register_file.sr(U_FLAG) = '1' and
		   register_file.sr(Z_FLAG) = '0' then
			norm_instr_asl <= '1';
			norm_update_ccr <= '1';
			addr_r_out <= addr_r_in - 1;
		-- Or right shift
		elsif register_file.sr(E_FLAG) = '1' then
			norm_instr_asr <= '1';
			norm_update_ccr <= '1';
			addr_r_out <= addr_r_in + 1;
		-- Or do nothing!
		else 
			norm_update_ccr <= '0';
			addr_r_out <= addr_r_in;
		end if;
	end process;

end architecture;
