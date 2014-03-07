library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity exec_stage_loop is port(
	clk, rst           : in  std_logic;
	activate_exec_loop : in  std_logic;
	instr_word        : in  std_logic_vector(23 downto 0);
	instr_array       : in  instructions_type;
	loop_iterations   : in  unsigned(15 downto 0);
	loop_address      : in  unsigned(BW_ADDRESS-1 downto 0);
	loop_start_address: in  unsigned(BW_ADDRESS-1 downto 0);
	register_file     : in  register_file_type;
	fetch_perform_enddo: in std_logic;
	memory_stall      : in  std_logic;
	push_stack        : out push_stack_type;
	pop_stack         : out pop_stack_type;
	stall_rep         : out std_logic;
	stall_do          : out std_logic;
	decrement_lc      : out std_logic;
	modify_lc         : out std_logic;
	modified_lc       : out unsigned(15 downto 0);
	modify_la         : out std_logic;
	modified_la       : out unsigned(15 downto 0);
	modify_pc         : out std_logic;
	modified_pc       : out unsigned(BW_ADDRESS-1 downto 0);
	modify_sr         : out std_logic;
	modified_sr       : out std_logic_vector(15 downto 0)
);
end entity;


architecture rtl of exec_stage_loop is

	signal rep_loop_polling : std_logic;
	signal do_loop_polling  : std_logic;
	signal enddo_polling    : std_logic;
	signal lc_temp          : unsigned(15 downto 0);
	signal rf_lc_eq_1       : std_logic;
	signal memory_stall_t   : std_logic;

begin

	modified_pc <= loop_start_address;


	-- loop counter in register file equal to 1?
	rf_lc_eq_1 <= '1' when register_file.lc = 1 else '0';

	process(activate_exec_loop, instr_array, register_file, fetch_perform_enddo,
	        rep_loop_polling, loop_iterations, rf_lc_eq_1, loop_start_address) is
	begin
		stall_rep <= '0';
		stall_do  <= '0';

		modify_la <= '0';
		modify_lc <= '0';
		modify_pc <= '0';
		modify_sr <= '0';
		modified_la <= loop_address;
		modified_lc <= loop_iterations; -- default
		-- set the loop flag LF (bit 15) of Status register
		modified_sr(15) <= '1';
		modified_sr(14 downto 0) <= register_file.sr(14 downto 0);

		push_stack.valid <= '0'; -- push PC and SR on the stack
		push_stack.pc    <= loop_start_address;
		push_stack.content <= LA_AND_LC;

		pop_stack.valid <= '0';
		decrement_lc <= '0';
		------------------
		-- DO instruction
		------------------
		if activate_exec_loop = '1' and instr_array = INSTR_DO then
			-- first instruction of the do loop instruction?
			if do_loop_polling = '0' then
				stall_do <= '1';
				modify_lc <= '1'; -- store the new loop counter
				modify_la <= '1'; -- store the new loop address 
				push_stack.valid <= '1'; -- push LA and LC on the stack
				push_stack.content <= LA_AND_LC;
			else  -- second clock cycle of the do loop instruction ?
				push_stack.valid <= '1'; -- push PC and SR on the stack
				push_stack.pc    <= loop_start_address;
				push_stack.content <= PC_AND_SR;
				-- set the PC to the first instruction of the loop
				-- the already fetched instruction are flushed from the pipeline
				-- this prevents problems, when the loop consists of only one or two instructions
				modify_pc   <= '1';
				-- set the loop flag
				modify_sr   <= '1';
			end if;
		end if;
		-----------------------------------------------
		-- ENDDO instruction / loop end in fetch stage
		-----------------------------------------------
		if (activate_exec_loop = '1' and instr_array = INSTR_ENDDO) or fetch_perform_enddo = '1' or enddo_polling = '1' then
			pop_stack.valid <= '1';
			if enddo_polling = '0' then
				-- only restore the LF from the stack
				modified_sr(15) <= register_file.current_ssl(15);
				modify_sr <= '1';
				stall_do <= '1'; -- stall one clock cycle 
			else
				-- restore loop counter and loop address in second clock cycle
				modified_lc <= unsigned(register_file.current_ssl);
				modify_lc <= '1';
				modified_la <= unsigned(register_file.current_ssh);
				modify_la <= '1';
			end if;
		end if;
		-------------------
		-- REP instruction
		-------------------
		if activate_exec_loop = '1' and instr_array = INSTR_REP then
			-- only do something when there are more than 1 iterations
			-- the first execution is already on the way
			if loop_iterations /= 1 then
				stall_rep <= '1'; -- stall the fetch and decode stages
				modify_lc <= '1'; -- store the loop counter
				modified_lc <= loop_iterations - 1;
			end if;
		end if;

		-- keep processing the single instruction
		if rep_loop_polling = '1' then
			stall_rep <= '1';
			-- if the REP instruction cause a  stall do not modify the lc!
			if memory_stall_t = '0' then
				if rf_lc_eq_1 = '0' then
					decrement_lc <= '1';
				-- when the instruction to repeat caused a memory stall
				-- do not continue!
				else
					-- finish the REP instruction by restoring the LC
					stall_rep <= '0';
					modify_lc <= '1';
					modified_lc <= lc_temp;
				end if;
			end if;
		end if;
	end process;


	-- process that allows to remember that we are processing a REP/DO instruction
	-- even though the REP instruction is not available in the pipeline anymore
	-- also store the old loop counter
	process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				rep_loop_polling <= '0';
				do_loop_polling  <= '0';
				enddo_polling    <= '0';
				lc_temp <= (others => '0');
				memory_stall_t <= '0';
			else
				memory_stall_t <= memory_stall;

				if activate_exec_loop = '1' and instr_array = INSTR_REP then
					-- only do something when there are more than 1 iterations
					-- the first execution is already on the way
					if loop_iterations /= 1 then
						rep_loop_polling <= '1';
						lc_temp <= register_file.lc;
					end if;
				end if;
				-- test whether the REP instruction has been executed
				if rep_loop_polling = '1' and rf_lc_eq_1 = '1' and memory_stall_t = '0'  then
					rep_loop_polling <= '0';
				end if;

				-- do loop execution takes two clock cycles
				-- in the first  clock cycle we store loop address and loop counter on the stack
				-- in the second clock cycle we store programm counter and status register on the stack
				if activate_exec_loop = '1' and instr_array = INSTR_DO then
					do_loop_polling <= '1';
				end if;
				-- clear the flag immediately again (only two cycles execution time!)
				if do_loop_polling = '1' then
					do_loop_polling <= '0';
				end if;

				-- ENDDO instructions take two clock cycles as well!
				if (activate_exec_loop = '1' and instr_array = INSTR_ENDDO) or fetch_perform_enddo = '1' then
					enddo_polling <= '1';
				end if;
				if enddo_polling = '1' then
					enddo_polling <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture;
