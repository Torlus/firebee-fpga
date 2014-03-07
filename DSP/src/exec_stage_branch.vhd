library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity exec_stage_branch is port(
	activate_exec_bra : in  std_logic;
	instr_word        : in  std_logic_vector(23 downto 0);
	instr_array       : in  instructions_type;
	register_file     : in  register_file_type;
	jump_address      : in  unsigned(BW_ADDRESS-1 downto 0);
	bit_cond_met      : in  std_logic;
	cc_flag_set       : in  std_logic;
	push_stack        : out push_stack_type;
	pop_stack         : out pop_stack_type;
	modify_pc         : out std_logic;
	modified_pc       : out unsigned(BW_ADDRESS-1 downto 0);
	modify_sr         : out std_logic;
	modified_sr       : out std_logic_vector(15 downto 0)
);
end entity;


architecture rtl of exec_stage_branch is 

	signal branch_condition_met : std_logic;
	signal modify_pc_int        : std_logic;

begin

	modify_pc_int <= '1' when activate_exec_bra = '1' and branch_condition_met = '1' else '0';
	modify_pc     <= modify_pc_int;

	calculate_branch_condition : process(instr_word, instr_array, register_file, bit_cond_met)
	begin
		branch_condition_met <= '0';

		-- unconditional jumps
		if instr_array = INSTR_JMP or 
		   instr_array = INSTR_JSR or
		   instr_array = INSTR_RTI or
		   instr_array = INSTR_RTS then
			-- jump always
			branch_condition_met <= '1';
		end if;
		--  then see whether the branch condition is satisfied
		if instr_array = INSTR_JCC or instr_array = INSTR_JSCC then
			branch_condition_met <= cc_flag_set;
		end if;
		-- jmp that is executed according to a certain bit condition
		if instr_array = INSTR_JCLR or instr_array = INSTR_JSCLR or
		   instr_array = INSTR_JSET or instr_array = INSTR_JSSET then 
			branch_condition_met <= bit_cond_met;
		end if;
	end process calculate_branch_condition;


	calculate_branch_target : process(instr_array, instr_word, jump_address)
	begin
		modified_pc <= jump_address;

		-- address calculation is the same for the following instructions
		if instr_array = INSTR_JMP  or 
		   instr_array = INSTR_JCC  or 
		   instr_array = INSTR_JSCC or
		   instr_array = INSTR_JSR then
			if instr_word(18) = '1' then
				-- short jump address included in opcode (bits 11 downto 0)
				modified_pc(11 downto 0) <= unsigned(instr_word(11 downto 0));
			elsif instr_word(18) = '0' then
				-- effective address defined by opcode and coming from address generator unit
				modified_pc <= jump_address;
			end if;
		end if;

		-- jump address contains the obligatory address of the second
		-- instruction word
		if instr_array = INSTR_JCLR or
		   instr_array = INSTR_JSET or
		   instr_array = INSTR_JSCLR or
		   instr_array = INSTR_JSSET then
			   modified_pc <= jump_address;
		end if;

		-- target address is stored on the stack
		if instr_array = INSTR_RTS or
		   instr_array = INSTR_RTI then
			   modified_pc <= unsigned(register_file.current_ssh);
		end if;
	end process calculate_branch_target;

	-- Subroutine functions need to store PC and SR on the stack
	push_stack.valid <= '1' when modify_pc_int = '1' and (instr_array = INSTR_JSCC  or instr_array = INSTR_JSR or 
	                                                      instr_array = INSTR_JSCLR or instr_array = INSTR_JSSET) else '0';
	push_stack.content <= PC_AND_SR;
	-- pc is set externally!
	push_stack.pc <= (others => '0');

	-- RTI/RTS instructions need to read from the stack
	pop_stack.valid <= '1' when modify_pc_int = '1' and (instr_array = INSTR_RTI or instr_array = INSTR_RTS) else '0';

	-- some instructions require to set the SR 
	calculate_status_register : process(instr_array)
	begin
		modify_sr <= '0';
		modified_sr <= (others => '0');
		if instr_array = INSTR_RTI then
			modify_sr <= '1';
			modified_sr <= register_file.current_ssl;
		end if;
	end process calculate_status_register;


end architecture rtl;
