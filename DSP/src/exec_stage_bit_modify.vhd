library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity exec_stage_bit_modify is port(
	instr_word        : in  std_logic_vector(23 downto 0);
	instr_array       : in  instructions_type;
	src_operand       : in  std_logic_vector(23 downto 0);
	register_file     : in  register_file_type;
	dst_operand       : out std_logic_vector(23 downto 0);
	bit_cond_met      : out std_logic;
	modify_sr         : out std_logic;
	modified_sr       : out std_logic_vector(15 downto 0)
);
end entity;


architecture rtl of exec_stage_bit_modify is 

	signal operand_bit : std_logic;
	signal src_operand_32 : std_logic_vector(31 downto 0);

begin

	-- this is just a helper signal to prevent the simulator
	-- to stop when accessing a bit > 23.
	src_operand_32 <= "00000000" & src_operand;
	-- read the bit we want to test (and modify)
	operand_bit <= src_operand_32(to_integer(unsigned(instr_word(4 downto 0))));

	-- modify the Carry flag only for the bit modify instructions!
	modify_sr <= '1' when instr_array = INSTR_BCLR or instr_array = INSTR_BSET or instr_array = INSTR_BCHG or instr_array = INSTR_BTST else '0';
	modified_sr <= register_file.sr(15 downto 1) & operand_bit;

	bit_operation: process(instr_word, instr_array, src_operand, operand_bit) is
		variable new_bit : std_logic;
	begin
		-- do nothing by default!
		dst_operand <= src_operand;
		bit_cond_met <= '0';

		-- determine which bit to write
		if instr_array = INSTR_BCLR then
			new_bit := '0';
		elsif instr_array = INSTR_BSET then
			new_bit := '1';
		else -- BCHG
			new_bit := not operand_bit;
		end if;

		if instr_array = INSTR_BCLR or instr_array = INSTR_BSET or instr_array = INSTR_BCHG then
			dst_operand(to_integer(unsigned(instr_word(4 downto 0)))) <= new_bit;
		end if;


		-- check for the jump instructions whether condition is met or not!
		if instr_array = INSTR_JCLR or instr_array = INSTR_JSCLR then
			if operand_bit = '0' then
				bit_cond_met <= '1';
			else
				bit_cond_met <= '0';
			end if;
		end if;
		if instr_array = INSTR_JSET or instr_array = INSTR_JSSET then
			if operand_bit = '0' then
				bit_cond_met <= '0';
			else
				bit_cond_met <= '1';
			end if;
		end if;

	end process;


end architecture;
