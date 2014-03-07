library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;


entity fetch_stage is port(

	pc_old        : in  unsigned(BW_ADDRESS-1 downto 0);
	pc_new        : out unsigned(BW_ADDRESS-1 downto 0);
	modify_pc     : in  std_logic;
	modified_pc   : in  unsigned(BW_ADDRESS-1 downto 0);
	register_file : in  register_file_type;
	decrement_lc  : out std_logic;
	perform_enddo : out std_logic

);
end fetch_stage;


architecture rtl of fetch_stage is


begin

	pc_calculation: process(pc_old, modify_pc, modified_pc, register_file)  is
	begin
		decrement_lc  <= '0';
		perform_enddo <= '0';

		-- by default increment pc by one
		pc_new <= pc_old + 1;
		if modify_pc = '1' then
			pc_new <= modified_pc;
		end if;
		-- Loop Flag set?
		if register_file.sr(15) = '1' then
			if register_file.la = pc_old then
				-- Loop not finished?
				-- => start from the beginning if necessary
				if register_file.lc /= 1 then
					-- if the last address was LA and the loop is not finished yet, we have to 
					-- read now from the beginning of the loop again
					pc_new <= unsigned(register_file.current_ssh(BW_ADDRESS-1 downto 0));
					-- decrement loop counter
					decrement_lc <= '1';
				else
					-- loop done!
					-- => tell the loop controller in the exec stage to perform the enddo operation
					-- (without flushing of the pipeline!)
					perform_enddo <= '1';
				end if;
		   	end if;
		end if;
	end process pc_calculation;

end architecture rtl;

