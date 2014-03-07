library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity exec_stage_cc_flag_calc is port(
	instr_word        : in  std_logic_vector(23 downto 0);
	instr_array       : in  instructions_type;
	register_file     : in  register_file_type;
	cc_flag_set       : out std_logic
);
end entity;


architecture rtl of exec_stage_cc_flag_calc is


begin

	calculate_cc_flag : process(instr_word, instr_array, register_file)

		variable cc_select : std_logic_vector(3 downto 0);

		procedure calculate_cc_flag(cc: std_logic_vector(3 downto 0)) is
			variable c_flag : std_logic := register_file.ccr(0);
			variable v_flag : std_logic := register_file.ccr(1);
			variable z_flag : std_logic := register_file.ccr(2);
			variable n_flag : std_logic := register_file.ccr(3);
			variable u_flag : std_logic := register_file.ccr(4);
			variable e_flag : std_logic := register_file.ccr(5);
			variable l_flag : std_logic := register_file.ccr(6);

		begin
			if (cc = "0000" and c_flag = '0')  or -- CC: carry clear 
			   (cc = "1000" and c_flag = '1')  or -- CS: carry set
			   (cc = "0101" and e_flag = '0')  or -- EC: extension clear
			   (cc = "1010" and z_flag = '1')  or -- EQ: equal
			   (cc = "1101" and e_flag = '1')  or -- ES: extension set
			   (cc = "0001" and (n_flag = v_flag))  or -- GE: greater than or equal
			   (cc = "0001" and ((n_flag xor v_flag) or z_flag) = '0')  or -- GT: greater than
			   (cc = "0110" and l_flag = '0')  or -- LC: limit clear 
			   (cc = "1111" and ((n_flag xor v_flag) or z_flag ) = '1')  or -- LE: less or equal
			   (cc = "1110" and l_flag = '1')  or -- LS: limit set
			   (cc = "1001" and (n_flag /= v_flag))  or -- LT: less than
			   (cc = "1011" and n_flag = '1')  or -- MI: minus
			   (cc = "0010" and z_flag = '0')  or -- NE: not equal
			   (cc = "1100" and (( not u_flag and not  e_flag) or z_flag) = '1') or -- NR: normalized
			   (cc = "0011" and n_flag = '0')  or -- PL: plus
			   (cc = "0100" and (( not u_flag and not e_flag ) or z_flag) = '0')   -- NN: not normalized
			then
				cc_flag_set <= '1';
			end if;
		end procedure;
	
	begin

		cc_flag_set <= '0';

		-- Rip the flags we have to test for from the instruction word
		if (instr_array = INSTR_JCC and instr_word(18) = '0') or
		   (instr_array = INSTR_JSCC) then
			   cc_select := instr_word(3 downto 0);
		else
			   cc_select := instr_word(15 downto 12);
		end if;
	
		calculate_cc_flag(cc_select);

	end process;


end architecture;
