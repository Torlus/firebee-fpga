library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity pipeline is port (
	clk, rst : in std_logic;
	register_file_out : out register_file_type

);
end pipeline;

-- TODOs:
-- External memory accesses
-- ROM tables
-- Reading from SSH flag has to modify stack pointer
-- Memory access (x,y,p) and talling accordingly
-- Address Generator: ring buffers are not yet supported

-- List of BUGS:
-- - Reading from address one clock cycle after writing to the same address might result in corrupted data!!
-- - SBC instruction has errorneous carry flag calculation

-- List of probable issues:
-- - Reading from XMEM/YMEM with stalls probably results in corrupted data
-- - ENDDO instruction probably has to flush the pipeline afterwards
-- - Writing to memory occurs twice, when stalls occur

-- Things to optimize: 
--  - RTS/RTI could be executed in the ADGEN Stage already
--  - DO loops always flush the pipeline. This is necessary in case we have a very short loop.
--     The single instruction of the loop then has passed the fetch stage already without the branch


architecture rtl of pipeline is

	signal pipeline_regs : pipeline_type;
	signal stall_flags   : std_logic_vector(PIPELINE_DEPTH-1 downto 0);

	component fetch_stage is port(
		pc_old        : in  unsigned(BW_ADDRESS-1 downto 0);
		pc_new        : out unsigned(BW_ADDRESS-1 downto 0);
		modify_pc     : in  std_logic;
		modified_pc   : in  unsigned(BW_ADDRESS-1 downto 0);
		register_file : in  register_file_type;
		decrement_lc  : out std_logic;
		perform_enddo : out std_logic
	);
	end component fetch_stage;

	signal pc_old, pc_new    : unsigned(BW_ADDRESS-1 downto 0);
	signal fetch_modify_pc   : std_logic;
	signal fetch_modified_pc : unsigned(BW_ADDRESS-1 downto 0);
	signal fetch_perform_enddo: std_logic;
	signal fetch_decrement_lc: std_logic;


	component decode_stage is port(
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
	end component decode_stage;

	signal dec_activate : std_logic;
	signal dec_instr_word      : std_logic_vector(23 downto 0);
	signal dec_dble_word_instr : std_logic;
	signal dec_instr_array     : instructions_type;
	signal dec_act_array       : std_logic_vector(NUM_ACT_SIGNALS-1 downto 0);
	signal dec_reg_wr_addr     : std_logic_vector(5 downto 0);
	signal dec_reg_rd_addr     : std_logic_vector(5 downto 0);
	signal dec_x_bus_wr_addr   : std_logic_vector(1 downto 0);
	signal dec_x_bus_rd_addr   : std_logic_vector(1 downto 0);
	signal dec_y_bus_wr_addr   : std_logic_vector(1 downto 0);
	signal dec_y_bus_rd_addr   : std_logic_vector(1 downto 0);
	signal dec_l_bus_addr      : std_logic_vector(2 downto 0);
	signal dec_adgen_mode_a    : adgen_mode_type;
	signal dec_adgen_mode_b    : adgen_mode_type;
	signal dec_alu_ctrl        : alu_ctrl_type;

	component adgen_stage is port(
		activate_adgen    : in  std_logic;
		activate_x_mem    : in  std_logic;
		activate_y_mem    : in  std_logic;
		activate_l_mem    : in  std_logic;
		instr_word        : in  std_logic_vector(23 downto 0);
		instr_array       : in  instructions_type;
		optional_ea_word  : in  std_logic_vector(23 downto 0);
		register_file     : in  register_file_type;
		adgen_mode_a      : in  adgen_mode_type;
		adgen_mode_b      : in  adgen_mode_type;
		address_out_x     : out unsigned(BW_ADDRESS-1 downto 0);
		address_out_y     : out unsigned(BW_ADDRESS-1 downto 0);
		wr_R_port_A_valid : out std_logic;
		wr_R_port_A       : out addr_wr_port_type;
		wr_R_port_B_valid : out std_logic;
		wr_R_port_B       : out addr_wr_port_type
	);
	end component adgen_stage;

	signal adgen_activate          : std_logic;
	signal adgen_activate_x_mem    : std_logic;
	signal adgen_activate_y_mem    : std_logic;
	signal adgen_activate_l_mem    : std_logic;
	signal adgen_instr_word        : std_logic_vector(23 downto 0);
	signal adgen_instr_array       : instructions_type;
	signal adgen_optional_ea_word  : std_logic_vector(23 downto 0);
	signal adgen_register_file     : register_file_type;
	signal adgen_mode_a            : adgen_mode_type;
	signal adgen_mode_b            : adgen_mode_type;
	signal adgen_address_out_x     : unsigned(BW_ADDRESS-1 downto 0);
	signal adgen_address_out_y     : unsigned(BW_ADDRESS-1 downto 0);
	signal adgen_wr_R_port_A_valid : std_logic;
	signal adgen_wr_R_port_A       : addr_wr_port_type;
	signal adgen_wr_R_port_B_valid : std_logic;
	signal adgen_wr_R_port_B       : addr_wr_port_type;

	component exec_stage_bit_modify is port(
		instr_word        : in  std_logic_vector(23 downto 0);
		instr_array       : in  instructions_type;
		src_operand       : in  std_logic_vector(23 downto 0);
		register_file     : in  register_file_type;
		dst_operand       : out std_logic_vector(23 downto 0);
		bit_cond_met      : out std_logic;
		modify_sr         : out std_logic;
		modified_sr       : out std_logic_vector(15 downto 0)
	);
	end component exec_stage_bit_modify;

	signal exec_bit_modify_instr_word    : std_logic_vector(23 downto 0);
	signal exec_bit_modify_instr_array   : instructions_type;
	signal exec_bit_modify_src_operand   : std_logic_vector(23 downto 0);
	signal exec_bit_modify_dst_operand   : std_logic_vector(23 downto 0);
	signal exec_bit_modify_bit_cond_met  : std_logic;
	signal exec_bit_modify_modify_sr     : std_logic;
	signal exec_bit_modify_modified_sr   : std_logic_vector(15 downto 0);

	component exec_stage_branch is port(
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
	end component exec_stage_branch;

	signal exec_bra_activate     : std_logic;
	signal exec_bra_instr_word   : std_logic_vector(23 downto 0);
	signal exec_bra_instr_array  : instructions_type;
	signal exec_bra_jump_address : unsigned(BW_ADDRESS-1 downto 0);
	signal exec_bra_bit_cond_met : std_logic;
	signal exec_bra_push_stack   : push_stack_type;
	signal exec_bra_pop_stack    : pop_stack_type;
	signal exec_bra_modify_pc    : std_logic;
	signal exec_bra_modified_pc  : unsigned(BW_ADDRESS-1 downto 0);
	signal exec_bra_modify_sr    : std_logic;
	signal exec_bra_modified_sr  : std_logic_vector(15 downto 0);

	component exec_stage_cr_mod is port(
		activate_exec_cr_mod : in  std_logic;
		instr_word           : in  std_logic_vector(23 downto 0);
		instr_array          : in  instructions_type;
		register_file        : in  register_file_type;
		modify_sr            : out std_logic;
		modified_sr          : out std_logic_vector(15 downto 0);
		modify_omr           : out std_logic;
		modified_omr         : out std_logic_vector(7 downto 0)
	);
	end component exec_stage_cr_mod;

	signal exec_cr_mod_activate     : std_logic;
	signal exec_cr_mod_instr_word   : std_logic_vector(23 downto 0);
	signal exec_cr_mod_instr_array  : instructions_type;
	signal exec_cr_mod_modify_sr    : std_logic;
	signal exec_cr_mod_modified_sr  : std_logic_vector(15 downto 0);
	signal exec_cr_mod_modify_omr   : std_logic;
	signal exec_cr_mod_modified_omr : std_logic_vector(7 downto 0);

	component exec_stage_loop is port(
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
	end component exec_stage_loop;

	signal exec_loop_activate : std_logic;
	signal exec_loop_instr_word    : std_logic_vector(23 downto 0);
	signal exec_loop_instr_array   : instructions_type;
	signal exec_loop_iterations    : unsigned(15 downto 0);
	signal exec_loop_address       : unsigned(BW_ADDRESS-1 downto 0);
	signal exec_loop_start_address : unsigned(BW_ADDRESS-1 downto 0);
	signal exec_loop_register_file : register_file_type;
	signal exec_loop_push_stack    : push_stack_type;
	signal exec_loop_pop_stack     : pop_stack_type;
	signal exec_loop_stall_rep     : std_logic;
	signal exec_loop_stall_do      : std_logic;
	signal exec_loop_decrement_lc  : std_logic;
	signal exec_loop_modify_lc     : std_logic;
	signal exec_loop_modified_lc   : unsigned(15 downto 0);
	signal exec_loop_modify_la     : std_logic;
	signal exec_loop_modified_la   : unsigned(BW_ADDRESS-1 downto 0);
	signal exec_loop_modify_pc     : std_logic;
	signal exec_loop_modified_pc   : unsigned(BW_ADDRESS-1 downto 0);
	signal exec_loop_modify_sr     : std_logic;
	signal exec_loop_modified_sr   : std_logic_vector(BW_ADDRESS-1 downto 0);

	component exec_stage_alu is port(
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
	end component exec_stage_alu;

	signal exec_alu_activate      : std_logic;
	signal exec_alu_instr_word    : std_logic_vector(23 downto 0);
	signal exec_alu_ctrl          : alu_ctrl_type;
	signal exec_alu_addr_r_in     : unsigned(BW_ADDRESS-1 downto 0);
	signal exec_alu_addr_r_out    : unsigned(BW_ADDRESS-1 downto 0);
	signal exec_alu_modify_accu   : std_logic;
	signal exec_alu_dst_accu      : std_logic;
	signal exec_alu_modified_accu : signed(55 downto 0);
	signal exec_alu_modify_sr     : std_logic;
	signal exec_alu_modified_sr   : std_logic_vector(15 downto 0);

	signal exec_imm_8bit    : std_logic_vector(23 downto 0);
	signal exec_imm_12bit   : std_logic_vector(23 downto 0);
	signal exec_src_operand : std_logic_vector(23 downto 0);
	signal exec_dst_operand : std_logic_vector(23 downto 0);

	component exec_stage_cc_flag_calc is port(
		instr_word        : in  std_logic_vector(23 downto 0);
		instr_array       : in  instructions_type;
		register_file     : in  register_file_type;
		cc_flag_set       : out std_logic
	);
	end component exec_stage_cc_flag_calc;

	signal exec_cc_flag_calc_instr_word   : std_logic_vector(23 downto 0);
	signal exec_cc_flag_calc_instr_array  : instructions_type;
	signal exec_cc_flag_set : std_logic;

	component reg_file is port(
		clk, rst          : in  std_logic;
		register_file     : out register_file_type;
		wr_R_port_A_valid : in  std_logic;
		wr_R_port_A       : in  addr_wr_port_type;
		wr_R_port_B_valid : in  std_logic;
		wr_R_port_B       : in  addr_wr_port_type;
		alu_wr_valid      : in  std_logic;
		alu_wr_addr       : in  std_logic;
		alu_wr_data       : in  signed(55 downto 0);
		reg_wr_addr       : in  std_logic_vector(5 downto 0);
		reg_wr_addr_valid : in  std_logic;
		reg_wr_data       : in  std_Logic_vector(23 downto 0);
		reg_rd_addr       : in  std_logic_vector(5 downto 0);
		reg_rd_data       : out std_Logic_vector(23 downto 0);
		X_bus_rd_addr     : in  std_logic_vector(1 downto 0);
		X_bus_data_out    : out std_logic_vector(23 downto 0);
		X_bus_wr_addr     : in  std_logic_vector(1 downto 0);
		X_bus_wr_valid    : in  std_logic;
		X_bus_data_in     : in  std_logic_vector(23 downto 0);
		Y_bus_rd_addr     : in  std_logic_vector(1 downto 0);
		Y_bus_data_out    : out std_logic_vector(23 downto 0);
		Y_bus_wr_addr     : in  std_logic_vector(1 downto 0);
		Y_bus_wr_valid    : in  std_logic;
		Y_bus_data_in     : in  std_logic_vector(23 downto 0);
		L_bus_rd_addr     : in  std_logic_vector(2 downto 0);
		L_bus_rd_valid    : in  std_logic;
		L_bus_wr_addr     : in  std_logic_vector(2 downto 0);
		L_bus_wr_valid    : in  std_logic;
		push_stack        : in  push_stack_type;
		pop_stack         : in  pop_stack_type;
		set_sr            : in  std_logic;
		new_sr            : in  std_logic_vector(15 downto 0);
		set_omr           : in  std_logic;
		new_omr           : in  std_logic_vector(7 downto 0);
		set_lc            : in  std_logic;
		new_lc            : in  unsigned(15 downto 0);
		dec_lc            : in  std_logic;
		set_la            : in  std_logic;
		new_la            : in  unsigned(BW_ADDRESS-1 downto 0)
	);
	end component reg_file;

	signal register_file        : register_file_type;
	signal rf_wr_R_port_A_valid : std_logic;
	signal rf_wr_R_port_B_valid : std_logic;
	signal rf_reg_wr_addr       : std_logic_vector(5 downto 0);
	signal rf_reg_wr_addr_valid : std_logic;
	signal rf_reg_wr_data       : std_logic_vector(23 downto 0);
	signal rf_reg_rd_addr       : std_logic_vector(5 downto 0);
	signal rf_reg_rd_data       : std_logic_vector(23 downto 0);
	signal rf_X_bus_rd_addr     : std_logic_vector(1 downto 0);
	signal rf_X_bus_data_out    : std_logic_vector(23 downto 0);
	signal rf_X_bus_wr_addr     : std_logic_vector(1 downto 0);
	signal rf_X_bus_wr_valid    : std_logic;
	signal rf_X_bus_data_in     : std_logic_vector(23 downto 0);
	signal rf_Y_bus_rd_addr     : std_logic_vector(1 downto 0);
	signal rf_Y_bus_data_out    : std_logic_vector(23 downto 0);
	signal rf_Y_bus_wr_addr     : std_logic_vector(1 downto 0);
	signal rf_Y_bus_wr_valid    : std_logic;
	signal rf_Y_bus_data_in     : std_logic_vector(23 downto 0);
	signal rf_L_bus_rd_addr     : std_logic_vector(2 downto 0);
	signal rf_L_bus_rd_valid    : std_logic;
	signal rf_L_bus_wr_addr     : std_logic_vector(2 downto 0);
	signal rf_L_bus_wr_valid    : std_logic;
	signal push_stack           : push_stack_type;
	signal pop_stack            : pop_stack_type;
	signal rf_set_sr            : std_logic;
	signal rf_new_sr            : std_logic_vector(15 downto 0);
	signal rf_set_omr           : std_logic;
	signal rf_new_omr           : std_logic_vector(7 downto 0);
	signal rf_dec_lc            : std_logic;
	signal rf_set_lc            : std_logic;
	signal rf_new_lc            : unsigned(15 downto 0);
	signal rf_set_la            : std_logic;
	signal rf_new_la            : unsigned(BW_ADDRESS-1 downto 0);
	signal rf_alu_wr_valid      : std_logic;

	component memory_management is port (
		clk, rst : in std_logic;
		stall_flags    : in  std_logic_vector(PIPELINE_DEPTH-1 downto 0);
		memory_stall   : out std_logic;
		data_rom_enable: in  std_logic;
		pmem_ctrl_in   : in  mem_ctrl_type_in;
		pmem_ctrl_out  : out mem_ctrl_type_out;
		xmem_ctrl_in   : in  mem_ctrl_type_in;
		xmem_ctrl_out  : out mem_ctrl_type_out;
		ymem_ctrl_in   : in  mem_ctrl_type_in;
		ymem_ctrl_out  : out mem_ctrl_type_out
	);
	end component memory_management;

	signal memory_stall   : std_logic;
	signal pmem_ctrl_in   : mem_ctrl_type_in;
	signal pmem_ctrl_out  : mem_ctrl_type_out;
	signal xmem_ctrl_in   : mem_ctrl_type_in;
	signal xmem_ctrl_out  : mem_ctrl_type_out;
	signal ymem_ctrl_in   : mem_ctrl_type_in;
	signal ymem_ctrl_out  : mem_ctrl_type_out;

	signal pmem_data_out       : std_logic_vector(23 downto 0);
	signal pmem_data_out_valid : std_logic;
	signal xmem_data_out       : std_logic_vector(23 downto 0);
	signal xmem_data_out_valid : std_logic;
	signal ymem_data_out       : std_logic_vector(23 downto 0);
	signal ymem_data_out_valid : std_logic;

begin
	register_file_out <= register_file;

	-- merge all stall sources
	stall_flags(ST_FETCH)  <= '1' when exec_loop_stall_rep   = '1' or 
	                                   memory_stall = '1' or
	                                   exec_loop_stall_do    = '1' else '0';
	stall_flags(ST_FETCH2) <= '1' when exec_loop_stall_rep = '1' or 
	                                   memory_stall = '1' or
	                                   exec_loop_stall_do = '1' else '0';
	stall_flags(ST_DECODE) <= '1' when exec_loop_stall_rep = '1' or
	                                   memory_stall = '1' or
	                                   exec_loop_stall_do = '1' else '0';
	stall_flags(ST_ADGEN)   <= exec_loop_stall_do;
--	stall_flags(ST_ADGEN)  <= '1' when memory_stall = '1' or
--	                                   exec_loop_stall_do = '1' else '0';
--	stall_flags(ST_EXEC)   <= '0';
	stall_flags(ST_EXEC)   <= exec_loop_stall_do;
--	stall_flags(ST_EXEC)   <= '1' when memory_stall = '1' or
--	                                   exec_loop_stall_do = '1' else '0';

	shift_pipeline: process(clk, rst) is
		procedure flush_pipeline_stage(stage: natural) is
		begin
			pipeline_regs(stage).pc <= (others => '1');
			pipeline_regs(stage).instr_word <= (others => '0');
			pipeline_regs(stage).act_array   <= (others => '0');
			pipeline_regs(stage).instr_array <= INSTR_NOP;
			pipeline_regs(stage).dble_word_instr <= '0';
			pipeline_regs(stage).dec_activate <= '0';
			pipeline_regs(stage).adgen_mode_a <= NOP;
			pipeline_regs(stage).adgen_mode_b <= NOP;
			pipeline_regs(stage).reg_wr_addr  <= (others => '0');
			pipeline_regs(stage).reg_rd_addr  <= (others => '0');
			pipeline_regs(stage).x_bus_rd_addr  <= (others => '0');
			pipeline_regs(stage).x_bus_wr_addr  <= (others => '0');
			pipeline_regs(stage).y_bus_rd_addr  <= (others => '0');
			pipeline_regs(stage).y_bus_wr_addr  <= (others => '0');
			pipeline_regs(stage).l_bus_addr     <= (others => '0');
			pipeline_regs(stage).adgen_address_x <= (others => '0');
			pipeline_regs(stage).adgen_address_y <= (others => '0');
			pipeline_regs(stage).RAM_out_x <= (others => '0');
			pipeline_regs(stage).RAM_out_y <= (others => '0');
			pipeline_regs(stage).alu_ctrl.store_result <= '0';
		end procedure flush_pipeline_stage;
	begin
		if rising_edge(clk) then
			if rst = '1' then
				for i in 0 to PIPELINE_DEPTH-1 loop
					flush_pipeline_stage(i);
				end loop;
			else
				-- shift the pipeline registers when no stall applies
				for i in 1 to PIPELINE_DEPTH-1 loop
					if stall_flags(i) = '0' then
						-- do not copy the pipeline registers from a stalled pipeline stage
						-- for REP we do not flush
--						if stall_flags(i-1) = '1' then
						if (stall_flags(i-1) = '1' and exec_loop_stall_rep = '0') or
						   (i = ST_ADGEN and memory_stall = '1' and exec_loop_stall_rep = '1') then
							flush_pipeline_stage(i);
						else
							pipeline_regs(i) <= pipeline_regs(i-1);
						end if;
					end if;
				end loop;
				-- FETCH Pipeline Registers 
				if stall_flags(ST_FETCH) = '0' then
					pipeline_regs(ST_FETCH).pc <= pc_new;
					pipeline_regs(ST_FETCH).dec_activate <= '1';
				end if;

				-- FETCH2 Pipeline Registers
				if stall_flags(ST_FETCH2) = '0' then
					-- Normal pipeline operation?
					-- Buffering of RAM output when stalling is performed in the memory management
					if pmem_data_out_valid = '1' then
						pipeline_regs(ST_FETCH2).instr_word <= pmem_data_out;
					end if;
				end if;

				-- DECODE Pipeline registers
				if stall_flags(ST_DECODE) = '0' then
					pipeline_regs(ST_DECODE).act_array   <= dec_act_array;
					pipeline_regs(ST_DECODE).instr_array <= dec_instr_array;
					pipeline_regs(ST_DECODE).dble_word_instr <= dec_dble_word_instr;
					pipeline_regs(ST_DECODE).reg_wr_addr     <= dec_reg_wr_addr;
					pipeline_regs(ST_DECODE).reg_rd_addr     <= dec_reg_rd_addr;
					pipeline_regs(ST_DECODE).x_bus_wr_addr   <= dec_x_bus_wr_addr;
					pipeline_regs(ST_DECODE).x_bus_rd_addr   <= dec_x_bus_rd_addr;
					pipeline_regs(ST_DECODE).y_bus_wr_addr   <= dec_y_bus_wr_addr;
					pipeline_regs(ST_DECODE).y_bus_rd_addr   <= dec_y_bus_rd_addr;
					pipeline_regs(ST_DECODE).l_bus_addr      <= dec_l_bus_addr;
					pipeline_regs(ST_DECODE).adgen_mode_a    <= dec_adgen_mode_a;
					pipeline_regs(ST_DECODE).adgen_mode_b    <= dec_adgen_mode_b;
					pipeline_regs(ST_DECODE).alu_ctrl        <= dec_alu_ctrl;
				end if;

				-- ADGEN Pipeline registers
				if stall_flags(ST_ADGEN) = '0' then
					pipeline_regs(ST_ADGEN).adgen_address_x <= adgen_address_out_x;
					pipeline_regs(ST_ADGEN).adgen_address_y <= adgen_address_out_y;
				end if;
				if xmem_data_out_valid = '1' then
					pipeline_regs(ST_ADGEN).RAM_out_x <= xmem_data_out;
				end if;
				if ymem_data_out_valid = '1' then
					pipeline_regs(ST_ADGEN).RAM_out_y <= ymem_data_out;
				end if;

				-- EXEC Pipeline stuff
				if exec_bra_modify_pc = '1' or exec_loop_modify_pc = '1' then
					-- clear the following pipeline stages,
					-- since we modified the pc. 
					-- Do not flush ST_FETCH - it will hold the correct pc.
					flush_pipeline_stage(ST_FETCH2);
					flush_pipeline_stage(ST_DECODE);
					flush_pipeline_stage(ST_ADGEN);
				end if;
			end if;
		end if;
	end process shift_pipeline;

	-------------------------------
	-- FETCH STAGE INSTANTIATION
	-------------------------------
	inst_fetch_stage: fetch_stage port map(
		pc_old => pc_old,
		pc_new => pc_new,
		modify_pc => fetch_modify_pc,
		modified_pc => fetch_modified_pc,
		register_file => register_file,
		decrement_lc  => fetch_decrement_lc,
		perform_enddo => fetch_perform_enddo
	);

	pc_old <= pipeline_regs(ST_FETCH).pc;

	fetch_modify_pc <= '1' when exec_bra_modify_pc = '1' or exec_loop_modify_pc = '1' else '0';
	fetch_modified_pc <= exec_bra_modified_pc when exec_bra_modify_pc = '1' else
	                     exec_loop_modified_pc;

	-------------------------------
	-- DECODE STAGE INSTANTIATION
	-------------------------------
	inst_decode_stage : decode_stage port map(
		activate_dec    => dec_activate,
		instr_word      => dec_instr_word,
		dble_word_instr => dec_dble_word_instr,
		instr_array     => dec_instr_array,
		act_array       => dec_act_array,
		reg_wr_addr     => dec_reg_wr_addr,
		reg_rd_addr     => dec_reg_rd_addr,
		x_bus_wr_addr   => dec_x_bus_wr_addr,
		x_bus_rd_addr   => dec_x_bus_rd_addr,
		y_bus_wr_addr   => dec_y_bus_wr_addr,
		y_bus_rd_addr   => dec_y_bus_rd_addr,
		l_bus_addr      => dec_l_bus_addr,
		adgen_mode_a    => dec_adgen_mode_a,
		adgen_mode_b    => dec_adgen_mode_b,
		alu_ctrl        => dec_alu_ctrl
	);

	dec_instr_word <= pipeline_regs(ST_DECODE-1).instr_word;
	-- do not decode, when we have no valid instruction. This can happen when
	--  1) the pipeline just started its operation
	--  2) the pipeline was flushed due to a jump
	--  3) we are processing a instruction that consists of two words
	dec_activate   <= '1' when pipeline_regs(ST_DECODE-1).dec_activate = '1' and pipeline_regs(ST_DECODE).dble_word_instr = '0' else '0';

	-------------------------------
	-- AGU STAGE INSTANTIATION
	-------------------------------
	inst_adgen_stage: adgen_stage port map(
		activate_adgen    => adgen_activate,
		activate_x_mem    => adgen_activate_x_mem,
		activate_y_mem    => adgen_activate_y_mem,
		activate_l_mem    => adgen_activate_l_mem,
		instr_word        => adgen_instr_word,
		instr_array       => adgen_instr_array,
		optional_ea_word  => adgen_optional_ea_word,
		register_file     => register_file,
		adgen_mode_a      => adgen_mode_a,
		adgen_mode_b      => adgen_mode_b,
		address_out_x     => adgen_address_out_x,
		address_out_y     => adgen_address_out_y,
		wr_R_port_A_valid => adgen_wr_R_port_A_valid,
		wr_R_port_A       => adgen_wr_R_port_A,
		wr_R_port_B_valid => adgen_wr_R_port_B_valid,
		wr_R_port_B       => adgen_wr_R_port_B
	);

	adgen_activate          <= pipeline_regs(ST_ADGEN-1).act_array(ACT_ADGEN);
	adgen_activate_x_mem    <= '1' when pipeline_regs(ST_ADGEN-1).act_array(ACT_X_MEM_RD) = '1' or 
	                                    pipeline_regs(ST_ADGEN-1).act_array(ACT_X_MEM_WR) = '1' else '0';
	adgen_activate_y_mem    <= '1' when pipeline_regs(ST_ADGEN-1).act_array(ACT_Y_MEM_RD) = '1' or 
	                                    pipeline_regs(ST_ADGEN-1).act_array(ACT_Y_MEM_WR) = '1' else '0';
	adgen_activate_l_mem    <= '1' when pipeline_regs(ST_ADGEN-1).act_array(ACT_L_BUS_RD) = '1' or 
	                                    pipeline_regs(ST_ADGEN-1).act_array(ACT_L_BUS_WR) = '1' else '0';
	adgen_instr_word        <= pipeline_regs(ST_ADGEN-1).instr_word;
	adgen_instr_array       <= pipeline_regs(ST_ADGEN-1).instr_array;
	adgen_optional_ea_word  <= pipeline_regs(ST_ADGEN-2).instr_word;
	adgen_mode_a            <= pipeline_regs(ST_ADGEN-1).adgen_mode_a;
	adgen_mode_b            <= pipeline_regs(ST_ADGEN-1).adgen_mode_b;

	-------------------------------
	-- EXECUTE STAGE INSTANTIATIONS
	-------------------------------
	inst_exec_stage_alu: exec_stage_alu port map(
		alu_activate  => exec_alu_activate,
		instr_word    => exec_alu_instr_word,
		alu_ctrl      => exec_alu_ctrl,
		register_file => register_file,
		addr_r_in     => exec_alu_addr_r_in,
		addr_r_out    => exec_alu_addr_r_out,
		modify_accu   => exec_alu_modify_accu,
		dst_accu      => exec_alu_dst_accu,
		modified_accu => exec_alu_modified_accu,
		modify_sr     => exec_alu_modify_sr,
		modified_sr   => exec_alu_modified_sr
	);

	exec_alu_activate   <= pipeline_regs(ST_EXEC-1).act_array(ACT_ALU);
	exec_alu_instr_word <= pipeline_regs(ST_EXEC-1).instr_word;
	exec_alu_ctrl       <= pipeline_regs(ST_EXEC-1).alu_ctrl;

	exec_alu_addr_r_in <= unsigned(rf_reg_rd_data(BW_ADDRESS-1 downto 0));

	inst_exec_stage_bit_modify: exec_stage_bit_modify port map(
		instr_word     => exec_bit_modify_instr_word,
		instr_array    => exec_bit_modify_instr_array,
		src_operand    => exec_bit_modify_src_operand,
		register_file  => register_file,
		dst_operand    => exec_bit_modify_dst_operand,
		bit_cond_met   => exec_bit_modify_bit_cond_met,
		modify_sr      => exec_bit_modify_modify_sr,
		modified_sr    => exec_bit_modify_modified_sr
	);

	exec_bit_modify_instr_word   <= pipeline_regs(ST_EXEC-1).instr_word;
	exec_bit_modify_instr_array  <= pipeline_regs(ST_EXEC-1).instr_array;
	exec_bit_modify_src_operand  <= exec_src_operand;

	-- Writing to the register file using the 6 bit addressing scheme
	-- sources are:
	-- 1) X-RAM output
	-- 2) Y-RAM output
	-- 3) register file itself
	-- 4) short immediate value (8 bit stored in instruction word)
	-- 5) long immediate value (from optional effective address extension)
	-- 5) address generated by the address generation unit (LUA instr)
	exec_src_operand <= pipeline_regs(ST_EXEC-1).RAM_out_x  when pipeline_regs(ST_EXEC-1).act_array(ACT_X_MEM_RD)  = '1' else
	                    pipeline_regs(ST_EXEC-1).RAM_out_y  when pipeline_regs(ST_EXEC-1).act_array(ACT_Y_MEM_RD)  = '1' else
	                    rf_reg_rd_data                      when pipeline_regs(ST_EXEC-1).act_array(ACT_REG_RD)    = '1' else
	                    exec_imm_8bit                       when pipeline_regs(ST_EXEC-1).act_array(ACT_IMM_8BIT)  = '1' else
	                    exec_imm_12bit                      when pipeline_regs(ST_EXEC-1).act_array(ACT_IMM_12BIT) = '1' else
	                    pipeline_regs(ST_EXEC-2).instr_word when pipeline_regs(ST_EXEC-1).act_array(ACT_IMM_LONG)  = '1' else
	                    std_logic_vector(resize(pipeline_regs(ST_EXEC-1).adgen_address_x, 24)); -- for LUA instr.

	-- Destination for the register file using the 6 bit addressing scheme.
	-- Either read the bit modified version of the read value
	-- or use the modified Rn in case of a NORM instruction
--	exec_dst_operand <= exec_bit_modify_dst_operand;
	exec_dst_operand <= exec_bit_modify_dst_operand when pipeline_regs(ST_EXEC-1).act_array(ACT_NORM) = '0' else
	                    std_logic_vector(resize(exec_alu_addr_r_out,24));

	-- Unit to check whether cc (in Jcc, JScc, Tcc, ...) is true
	inst_exec_stage_cc_flag_calc: exec_stage_cc_flag_calc port map(
		instr_word        => exec_cc_flag_calc_instr_word,
		instr_array       => exec_cc_flag_calc_instr_array,
		register_file     => register_file,
		cc_flag_set       => exec_cc_flag_set
	);

	exec_cc_flag_calc_instr_word   <= pipeline_regs(ST_EXEC-1).instr_word;
	exec_cc_flag_calc_instr_array  <= pipeline_regs(ST_EXEC-1).instr_array;


	inst_exec_stage_branch : exec_stage_branch port map(
		activate_exec_bra => exec_bra_activate,
		instr_word        => exec_bra_instr_word,
		instr_array       => exec_bra_instr_array,
		register_file     => register_file,
		jump_address      => exec_bra_jump_address,
		bit_cond_met      => exec_bra_bit_cond_met,
		cc_flag_set       => exec_cc_flag_set,
		push_stack        => exec_bra_push_stack,
		pop_stack         => exec_bra_pop_stack,
		modify_pc         => exec_bra_modify_pc,
		modified_pc       => exec_bra_modified_pc,
		modify_sr         => exec_bra_modify_sr,
		modified_sr       => exec_bra_modified_sr
	);

	exec_bra_activate     <= pipeline_regs(ST_EXEC-1).act_array(ACT_EXEC_BRA);
	exec_bra_instr_word   <= pipeline_regs(ST_EXEC-1).instr_word;
	exec_bra_instr_array  <= pipeline_regs(ST_EXEC-1).instr_array;
	exec_bra_jump_address <= pipeline_regs(ST_EXEC-1).adgen_address_x when pipeline_regs(ST_EXEC-1).dble_word_instr = '0' else
	                         unsigned(pipeline_regs(ST_EXEC-2).instr_word(BW_ADDRESS-1 downto 0));
	exec_bra_bit_cond_met <= exec_bit_modify_bit_cond_met;

	inst_exec_stage_cr_mod : exec_stage_cr_mod port map(
		activate_exec_cr_mod => exec_cr_mod_activate,
		instr_word           => exec_cr_mod_instr_word,
		instr_array          => exec_cr_mod_instr_array,
		register_file        => register_file,
		modify_sr            => exec_cr_mod_modify_sr,
		modified_sr          => exec_cr_mod_modified_sr,
		modify_omr           => exec_cr_mod_modify_omr,
		modified_omr         => exec_cr_mod_modified_omr
	);

	exec_cr_mod_activate    <= pipeline_regs(ST_EXEC-1).act_array(ACT_EXEC_CR_MOD);
	exec_cr_mod_instr_word  <= pipeline_regs(ST_EXEC-1).instr_word;
	exec_cr_mod_instr_array <= pipeline_regs(ST_EXEC-1).instr_array;

	inst_exec_stage_loop: exec_stage_loop port map(
		clk                => clk,
		rst                => rst,
		activate_exec_loop => exec_loop_activate,
		instr_word         => exec_loop_instr_word,
		instr_array        => exec_loop_instr_array,
		loop_iterations    => exec_loop_iterations,
		loop_address       => exec_loop_address,
		loop_start_address => exec_loop_start_address,
		register_file      => register_file,
		fetch_perform_enddo=> fetch_perform_enddo,
		memory_stall       => memory_stall,
		push_stack         => exec_loop_push_stack,
		pop_stack          => exec_loop_pop_stack,
		stall_rep          => exec_loop_stall_rep,
		stall_do           => exec_loop_stall_do,
		modify_lc          => exec_loop_modify_lc,
		decrement_lc       => exec_loop_decrement_lc,
		modified_lc        => exec_loop_modified_lc,
		modify_la          => exec_loop_modify_la,
		modified_la        => exec_loop_modified_la,
		modify_pc          => exec_loop_modify_pc,
		modified_pc        => exec_loop_modified_pc,
		modify_sr          => exec_loop_modify_sr,
		modified_sr        => exec_loop_modified_sr
	);

	exec_loop_activate    <= pipeline_regs(ST_EXEC-1).act_array(ACT_EXEC_LOOP);
	exec_loop_instr_word  <= pipeline_regs(ST_EXEC-1).instr_word;
	exec_loop_instr_array <= pipeline_regs(ST_EXEC-1).instr_array;
	exec_loop_iterations  <= unsigned(exec_src_operand(15 downto 0));
	-- from which source is our operand?
	--  - XMEM
	--  - YMEM
	--  - Any register
	--  - Immediate (from instruction word)
--	exec_src_operand      <= unsigned(pipeline_regs(ST_EXEC-1).RAM_out_x(BW_ADDRESS-1 downto 0)) when 
--	                                  pipeline_regs(ST_EXEC-1).act_array(ACT_X_MEM_RD) = '1' else
--	                         unsigned(pipeline_regs(ST_EXEC-1).RAM_out_y(BW_ADDRESS-1 downto 0)) when 
--	                                  pipeline_regs(ST_EXEC-1).act_array(ACT_Y_MEM_RD) = '1' else
--	                         unsigned(rf_reg_rd_data(15 downto 0)) when
--	                                  pipeline_regs(ST_EXEC-1).act_array(ACT_REG_RD) = '1' else
--	                         "00000000" & unsigned(pipeline_regs(ST_EXEC-1).instr_word(15 downto 8));

	-- Loop address is given by the second instruction word of the DO instruction.
	-- This address is available one previous stage within the pipeline
	exec_loop_address     <= unsigned(pipeline_regs(ST_EXEC-2).instr_word(BW_ADDRESS-1 downto 0)) - 1; 
	-- one more stage before we find the programm counter of the first instruction to be executed in a DO loop
	exec_loop_start_address <= unsigned(pipeline_regs(ST_EXEC-3).pc);

	-- For the 8 bit immediate is can be either a fractional (registers x0,x1,y0,y1,a,b) or an unsigned (the rest)
	exec_imm_8bit(23 downto 16) <= (others => '0') when rf_reg_wr_addr(5 downto 2) /= "0001" and rf_reg_wr_addr(5 downto 1) /= "00111" else
	                               pipeline_regs(ST_EXEC-1).instr_word(15 downto 8);
	exec_imm_8bit(15 downto  8) <= (others => '0');
	exec_imm_8bit( 7 downto  0) <= (others => '0') when rf_reg_wr_addr(5 downto 2) = "0001" or rf_reg_wr_addr(5 downto 1) = "00111" else
	                               pipeline_regs(ST_EXEC-1).instr_word(15 downto 8);
	-- The 12 bit immediate stems from the instruction word
	exec_imm_12bit(23 downto 12) <= (others => '0');
	exec_imm_12bit(11 downto  0) <= pipeline_regs(ST_EXEC-1).instr_word(3 downto 0) & pipeline_regs(ST_EXEC-1).instr_word(15 downto 8);
	-----------------
	-- REGISTER FILE 
	-----------------
	inst_reg_file: reg_file port map(
		clk                => clk,
		rst                => rst,
		register_file      => register_file,
		wr_R_port_A_valid  => rf_wr_R_port_A_valid,
		wr_R_port_A        => adgen_wr_R_port_A,
		wr_R_port_B_valid  => rf_wr_R_port_B_valid,
		wr_R_port_B        => adgen_wr_R_port_B,
		reg_wr_addr        => rf_reg_wr_addr,
		reg_wr_addr_valid  => rf_reg_wr_addr_valid,
		reg_wr_data        => rf_reg_wr_data,
		reg_rd_addr        => rf_reg_rd_addr,
		reg_rd_data        => rf_reg_rd_data,
		alu_wr_valid       => rf_alu_wr_valid,
		alu_wr_addr        => exec_alu_dst_accu,
		alu_wr_data        => exec_alu_modified_accu,
		X_bus_rd_addr      => rf_X_bus_rd_addr, 
		X_bus_data_out     => rf_X_bus_data_out,
		X_bus_wr_addr      => rf_X_bus_wr_addr ,
		X_bus_wr_valid     => rf_X_bus_wr_valid,
		X_bus_data_in      => rf_X_bus_data_in ,
		Y_bus_rd_addr      => rf_Y_bus_rd_addr ,
		Y_bus_data_out     => rf_Y_bus_data_out,
		Y_bus_wr_addr      => rf_Y_bus_wr_addr ,
		Y_bus_wr_valid     => rf_Y_bus_wr_valid,
		Y_bus_data_in      => rf_Y_bus_data_in ,
		L_bus_rd_addr      => rf_L_bus_rd_addr ,
		L_bus_rd_valid     => rf_L_bus_rd_valid,
		L_bus_wr_addr      => rf_L_bus_wr_addr ,
		L_bus_wr_valid     => rf_L_bus_wr_valid,
		push_stack         => push_stack,
		pop_stack          => pop_stack,
		set_sr             => rf_set_sr,
		new_sr             => rf_new_sr,
		set_omr            => rf_set_omr,
		new_omr            => rf_new_omr,
		set_la             => rf_set_la,
		new_la             => rf_new_la,
		dec_lc             => rf_dec_lc,
		set_lc             => rf_set_lc,
		new_lc             => rf_new_lc
	);

	-----------------
	-- BUSES (X,Y,L)
	-----------------
	rf_X_bus_wr_valid <= pipeline_regs(ST_EXEC-1).act_array(ACT_X_BUS_WR);
	rf_X_bus_wr_addr  <= pipeline_regs(ST_EXEC-1).x_bus_wr_addr;
	rf_X_bus_rd_addr  <= pipeline_regs(ST_EXEC-1).x_bus_rd_addr;
	rf_X_bus_data_in  <= rf_X_bus_data_out when pipeline_regs(ST_EXEC-1).act_array(ACT_X_BUS_RD) = '1' else
	                     pipeline_regs(ST_EXEC-1).RAM_out_x; -- when pipeline_regs(ST_EXEC-1).act_array(ACT_X_MEM_RD) = '1' else

	rf_Y_bus_wr_valid <= pipeline_regs(ST_EXEC-1).act_array(ACT_Y_BUS_WR);
	rf_Y_bus_wr_addr  <= pipeline_regs(ST_EXEC-1).y_bus_wr_addr;
	rf_Y_bus_rd_addr  <= pipeline_regs(ST_EXEC-1).y_bus_rd_addr;
	rf_Y_bus_data_in  <= rf_Y_bus_data_out when pipeline_regs(ST_EXEC-1).act_array(ACT_Y_BUS_RD) = '1' else
	                     pipeline_regs(ST_EXEC-1).RAM_out_y; -- when pipeline_regs(ST_EXEC-1).act_array(ACT_Y_MEM_RD) = '1' else

	rf_L_bus_wr_valid <= pipeline_regs(ST_EXEC-1).act_array(ACT_L_BUS_WR);
	rf_L_bus_rd_valid <= pipeline_regs(ST_EXEC-1).act_array(ACT_L_BUS_RD);
	rf_L_bus_wr_addr  <= pipeline_regs(ST_EXEC-1).l_bus_addr; -- equal to bits in instruction word
	rf_L_bus_rd_addr  <= pipeline_regs(ST_EXEC-1).l_bus_addr; -- could be simplified by taking these bits..

	-- writing to the R registers within the ADGEN stage has to be prevented when
	-- 1) a jump is currently being executed (which is detected in the exec stage)
	-- 2) stall cycles occur. In this case the write will happen in the last cycle, when we stop stalling.
	-- 3) a memory access results in a stall (e.g. caused by the instruction to REP)
	rf_wr_R_port_A_valid <= '0' when stall_flags(ST_ADGEN) = '1' or 
	                                 exec_bra_modify_pc = '1' or
	                                 memory_stall = '1' else
	                        adgen_wr_R_port_A_valid;
	rf_wr_R_port_B_valid <= '0' when stall_flags(ST_ADGEN) = '1' or 
	                                 exec_bra_modify_pc = '1' or
	                                 memory_stall = '1' else
	                        adgen_wr_R_port_B_valid;


	rf_reg_wr_addr <= pipeline_regs(ST_EXEC-1).reg_wr_addr;
	-- can be set due to
	-- 1) normal write operation (e.g., move)
	-- 2) conditional move (Tcc)
	rf_reg_wr_addr_valid <= '1'              when pipeline_regs(ST_EXEC-1).act_array(ACT_REG_WR) = '1' else
	                        exec_cc_flag_set when pipeline_regs(ST_EXEC-1).act_array(ACT_REG_WR_CC) = '1' else '0';
	rf_reg_wr_data <= exec_dst_operand;

	rf_reg_rd_addr <= pipeline_regs(ST_EXEC-1).reg_rd_addr;

	-- Writing from the ALU can depend on the condition code (Tcc) instruction
	rf_alu_wr_valid <= exec_cc_flag_set when pipeline_regs(ST_EXEC-1).act_array(ACT_ALU_WR_CC) = '1' else
	                   exec_alu_modify_accu;

	push_stack.valid   <= '1' when exec_bra_push_stack.valid = '1' or exec_loop_push_stack.valid = '1' else '0';
	push_stack.content <= exec_bra_push_stack.content when exec_bra_push_stack.valid = '1' else
	                      exec_loop_push_stack.content;
	-- for jump to subroutine store the pc of the subsequent instruction
	push_stack.pc <= pipeline_regs(ST_EXEC-2).pc when exec_bra_push_stack.valid = '1' and pipeline_regs(ST_EXEC-1).dble_word_instr = '0' else
	                 pipeline_regs(ST_EXEC-3).pc when exec_bra_push_stack.valid = '1' and pipeline_regs(ST_EXEC-1).dble_word_instr = '1' else
					 exec_loop_push_stack.pc     when exec_loop_push_stack.valid = '1' else
	                 (others => '0');

	pop_stack.valid <= '1' when exec_bra_pop_stack.valid = '1' or exec_loop_pop_stack.valid = '1' else '0';

	rf_set_sr <= '1' when exec_bra_modify_sr = '1' or 
	                      exec_cr_mod_modify_sr = '1' or 
	                      exec_loop_modify_sr = '1' or 
	                      exec_alu_modify_sr = '1' or 
	                      exec_bit_modify_modify_sr = '1' else '0';
	rf_new_sr <= exec_bra_modified_sr    when exec_bra_modify_sr = '1'    else 
	             exec_cr_mod_modified_sr when exec_cr_mod_modify_sr = '1' else
				 exec_loop_modified_sr   when exec_loop_modify_sr = '1' else
				 exec_alu_modified_sr    when exec_alu_modify_sr = '1' else
	             exec_bit_modify_modified_sr; -- when exec_bit_modify_modify_sr = '1' else

	rf_set_omr <= exec_cr_mod_modify_omr;
	rf_new_omr <= exec_cr_mod_modified_omr;
	rf_set_lc <= exec_loop_modify_lc;
	rf_new_lc <= exec_loop_modified_lc;
	rf_set_la <= exec_loop_modify_la;
	rf_new_la <= exec_loop_modified_la;

	rf_dec_lc <= '1' when exec_loop_decrement_lc = '1' or fetch_decrement_lc = '1' else '0';

	---------------------
	-- MEMORY MANAGEMENT 
	---------------------
	MMU_inst: memory_management port map (
		clk => clk,
		rst => rst,
		stall_flags   => stall_flags,
		memory_stall  => memory_stall,
		data_rom_enable => register_file.omr(2),
		pmem_ctrl_in  => pmem_ctrl_in,
		pmem_ctrl_out => pmem_ctrl_out,
		xmem_ctrl_in  => xmem_ctrl_in,
		xmem_ctrl_out => xmem_ctrl_out,
		ymem_ctrl_in  => ymem_ctrl_in,
		ymem_ctrl_out => ymem_ctrl_out
	);

	------------------
	-- Program Memory
	------------------
	pmem_ctrl_in.rd_addr <= pc_new;
	pmem_ctrl_in.rd_en   <= '1' when stall_flags(ST_FETCH) = '0' else '0';
	-- TODO: Writing to PMEM!
	pmem_ctrl_in.wr_addr <= (others => '0');
	pmem_ctrl_in.wr_en   <= '0';
	pmem_ctrl_in.data_in <= (others => '0');

	pmem_data_out       <= pmem_ctrl_out.data_out;
	pmem_data_out_valid <= pmem_ctrl_out.data_out_valid;


	------------------
	-- X Memory
	------------------
	-- Either take the result of the AGU or use the short absolute value stored in the instruction word
	xmem_ctrl_in.rd_addr <= adgen_address_out_x when pipeline_regs(ST_ADGEN-1).act_array(ACT_ADGEN) = '1' else
	                        "0000000000" &  unsigned(pipeline_regs(ST_ADGEN-1).instr_word(13 downto 8));
	xmem_ctrl_in.rd_en   <=  '1' when pipeline_regs(ST_ADGEN-1).act_array(ACT_X_MEM_RD) = '1' else '0';
	-- Either take the result of the AGU or use the absolute value stored in the instruction word
	xmem_ctrl_in.wr_addr <= pipeline_regs(ST_EXEC-1).adgen_address_x when pipeline_regs(ST_EXEC-1).act_array(ACT_ADGEN) = '1' else
	                        "0000000000" & unsigned(pipeline_regs(ST_EXEC-1).instr_word(13 downto 8));
	xmem_ctrl_in.wr_en   <= '1' when pipeline_regs(ST_EXEC-1).act_array(ACT_X_MEM_WR) = '1' else '0';
	xmem_ctrl_in.data_in <= rf_X_bus_data_out when pipeline_regs(ST_EXEC-1).act_array(ACT_X_BUS_RD) = '1' or 
	                                               pipeline_regs(ST_EXEC-1).act_array(ACT_L_BUS_RD) = '1'  else
	                        exec_dst_operand;

	xmem_data_out       <= xmem_ctrl_out.data_out;
	xmem_data_out_valid <= xmem_ctrl_out.data_out_valid;

	------------------
	-- Y Memory
	------------------
	-- Either take the result of the AGU or use the absolute value stored in the instruction word
	ymem_ctrl_in.rd_addr <= adgen_address_out_y when pipeline_regs(ST_ADGEN-1).act_array(ACT_ADGEN) = '1' else
	                        "0000000000" &  unsigned(pipeline_regs(ST_ADGEN-1).instr_word(13 downto 8));
	ymem_ctrl_in.rd_en   <=  '1' when pipeline_regs(ST_ADGEN-1).act_array(ACT_Y_MEM_RD) = '1' else '0';
	-- Either take the result of the AGU or use the absolute value stored in the instruction word
	ymem_ctrl_in.wr_addr <= pipeline_regs(ST_EXEC-1).adgen_address_y when pipeline_regs(ST_EXEC-1).act_array(ACT_ADGEN) = '1' else
	                        "0000000000" & unsigned(pipeline_regs(ST_EXEC-1).instr_word(13 downto 8));
	ymem_ctrl_in.wr_en   <= '1' when pipeline_regs(ST_EXEC-1).act_array(ACT_Y_MEM_WR) = '1' else '0';
	ymem_ctrl_in.data_in <= rf_Y_bus_data_out when pipeline_regs(ST_EXEC-1).act_array(ACT_Y_BUS_RD) = '1' or
	                                               pipeline_regs(ST_EXEC-1).act_array(ACT_L_BUS_RD) = '1'  else
	                        exec_dst_operand;

	ymem_data_out       <= ymem_ctrl_out.data_out;
	ymem_data_out_valid <= ymem_ctrl_out.data_out_valid;


end architecture rtl;
