library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity exec_stage_cr_mod is port (
	activate_exec_cr_mod : in  std_logic;
	instr_word           : in  std_logic_vector(23 downto 0);
	instr_array          : in  instructions_type;
	register_file        : in  register_file_type;
	modify_sr            : out std_logic;
	modified_sr          : out std_logic_vector(15 downto 0);
	modify_omr           : out std_logic;
	modified_omr         : out std_logic_vector(7 downto 0)
);
end exec_stage_cr_mod;


architecture rtl of exec_stage_cr_mod is

begin

	process(activate_exec_cr_mod, instr_word, instr_array, register_file) is
		variable imm8 : std_logic_vector(7 downto 0);
		variable op8  : std_logic_vector(7 downto 0);
		variable res8 : std_logic_vector(7 downto 0);
	begin
		modify_sr    <= '0';
		modify_omr   <= '0';
		modified_sr  <= (others => '0');
		modified_omr <= (others => '0');

		imm8 := instr_word(15 downto 8);
		if instr_word(1 downto 0) = "00" then
			-- read MR
			op8 := register_file.mr;
		elsif instr_word(1 downto 0) = "01" then
			-- read CCR
			op8 := register_file.ccr;
		else  -- instr_word(1 downto 0) = "10"
			-- read OMR
			op8 := register_file.omr;
		end if;

		if instr_array = INSTR_ANDI then
			res8 := imm8 and op8;
		else -- instr_array = INSTR_ORI
			res8 := imm8 or op8;
		end if;

		-- only write the result when activated
		if activate_exec_cr_mod = '1' then
			if instr_word(1 downto 0) = "00" then
				-- update MR
				modify_sr    <= '1';
				modified_sr  <= res8 & register_file.ccr;
			elsif instr_word(1 downto 0) = "01" then
				-- update CCR
				modify_sr    <= '1';
				modified_sr  <= register_file.mr & res8;
			elsif instr_word(1 downto 0) = "10" then
				-- update OMR
				modify_omr   <= '1';
				modified_omr <= res8;
			end if;
		end if;
	end process;

end architecture;
