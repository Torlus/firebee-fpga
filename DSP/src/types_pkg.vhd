library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;



package types_pkg is

	-- the different addressing modes
	type adgen_mode_type is (NOP, POST_MIN_N, POST_PLUS_N, POST_MIN_1, POST_PLUS_1, INDEXED_N, PRE_MIN_1, ABSOLUTE, IMMEDIATE);
	------------------------
	-- Decoded instructions
	------------------------
	type instructions_type is (
	INSTR_NOP     ,
	INSTR_RTI     ,
	INSTR_ILLEGAL ,
	INSTR_SWI     ,
	INSTR_RTS     ,
	INSTR_RESET   ,
	INSTR_WAIT    ,
	INSTR_STOP    ,
	INSTR_ENDDO   ,
	INSTR_ANDI    ,
	INSTR_ORI     ,
	INSTR_DIV     ,
	INSTR_NORM    ,
	INSTR_LUA     ,
	INSTR_MOVEC   ,
	INSTR_REP     ,
	INSTR_DO      ,
	INSTR_MOVEM   ,
	INSTR_MOVEP   ,
	INSTR_PM_MOVEM,
	INSTR_BCLR    ,
	INSTR_BSET    ,
	INSTR_JCLR    ,
	INSTR_JSET    ,
	INSTR_JMP     ,
	INSTR_JCC     ,
	INSTR_BCHG    ,
	INSTR_BTST    ,
	INSTR_JSCLR   ,
	INSTR_JSSET   ,
	INSTR_JSR     ,
	INSTR_JSCC    );

	type addr_array is array(0 to 7) of unsigned(BW_ADDRESS-1 downto 0);

	type alu_shift_mode is (NO_SHIFT, SHIFT_LEFT, SHIFT_RIGHT, ZEROS);
	type alu_ccr_flag is (DONT_TOUCH, CLEAR, MODIFY, SET);
	type alu_ccr_flag_array is array(7 downto 0) of alu_ccr_flag;

	type alu_ctrl_type is record
		mul_op1 : std_logic_vector(1 downto 0); -- x0,x1,y0,y1
		mul_op2 : std_logic_vector(1 downto 0); -- x0,x1,y0,y1
		shift_src  : std_logic; -- a,b
		shift_src_sign : std_logic_vector(1 downto 0); -- 00: pos, 01: neg, 10: sign dependant, 11: reserved
		shift_mode : alu_shift_mode;
		rotate     : std_logic;  -- 0: logical shift, 1: rotate shift
		add_src_stage_1  : std_logic_vector(2 downto 0); -- x0,x1,y0,y1,x,y,a,b
		add_src_stage_2  : std_logic_vector(1 downto 0); -- 00: 0 , 01: add_src_1, 10: mul_result, 11: reserved
		add_src_sign   : std_logic_vector(1 downto 0); -- 00: pos, 01: neg, 10: sign dependant, 11: reserved
		logic_function : std_logic_vector(2 downto 0);  -- 000: none, 001: and, 010: or, 011: eor, 100: not
		word_24_update : std_logic;  -- only accumulator bits 47 downto 24 affected?
		rounding_used  : std_logic_vector(1 downto 0); -- 00: no rounding, 01: rounding, 10: add carry, 11: subtract carry
		store_result   : std_logic; -- 0: do not update accumulator, 1: update accumulator
		dst_accu       : std_logic; -- 0: a, 1: b
		div_instr      : std_logic; -- DIV instruction? Special ALU operations needed!
		norm_instr     : std_logic; -- NORM instruction? Special ALU operations needed!
		ccr_flags_ctrl : alu_ccr_flag_array;
	end record;

	type pipeline_signals is record
		instr_word: std_logic_vector(23 downto 0);
		pc        : unsigned(BW_ADDRESS-1 downto 0);
		dble_word_instr : std_logic;
		instr_array     : instructions_type;
		act_array       : std_logic_vector(NUM_ACT_SIGNALS-1 downto 0);
		dec_activate    : std_logic;
		adgen_mode_a    : adgen_mode_type;
		adgen_mode_b    : adgen_mode_type;
		reg_wr_addr     : std_logic_vector(5 downto 0);
		reg_rd_addr     : std_logic_vector(5 downto 0);
		x_bus_rd_addr   : std_logic_vector(1 downto 0);
		x_bus_wr_addr   : std_logic_vector(1 downto 0);
		y_bus_rd_addr   : std_logic_vector(1 downto 0);
		y_bus_wr_addr   : std_logic_vector(1 downto 0);
		l_bus_addr      : std_logic_vector(2 downto 0);
		adgen_address_x : unsigned(BW_ADDRESS-1 downto 0);
		adgen_address_y : unsigned(BW_ADDRESS-1 downto 0);
		RAM_out_x       : std_logic_vector(23 downto 0);
		RAM_out_y       : std_logic_vector(23 downto 0);
		alu_ctrl        : alu_ctrl_type;
	end record;

	type pipeline_type is array(0 to PIPELINE_DEPTH-1) of pipeline_signals;


	type register_file_type is record 
		a            : signed(55 downto 0);
		b            : signed(55 downto 0);
		x0           : signed(23 downto 0);
		x1           : signed(23 downto 0);
		y0           : signed(23 downto 0);
		y1           : signed(23 downto 0);
		la           : unsigned(BW_ADDRESS-1 downto 0);
		lc           : unsigned(15 downto 0);
		addr_r       : addr_array;
		addr_n       : addr_array;
		addr_m       : addr_array;
		ccr          : std_logic_vector(7 downto 0);
		mr           : std_logic_vector(7 downto 0);
		sr           : std_logic_vector(15 downto 0);
		omr          : std_logic_vector(7 downto 0);
		stack_pointer    : unsigned(5 downto 0);
--		system_stack_ssh : stack_array_type;
--		system_stack_ssl : stack_array_type;
		current_ssh      : std_logic_vector(BW_ADDRESS-1 downto 0);
		current_ssl      : std_logic_vector(BW_ADDRESS-1 downto 0);

	end record;

	type addr_wr_port_type is record
--		write_valid : std_logic;
		reg_number  : unsigned(2 downto 0);
		reg_value   : unsigned(15 downto 0);
	end record;

	type mem_ctrl_type_in is record
		rd_addr   : unsigned(BW_ADDRESS-1 downto 0);
		rd_en     : std_logic;
		wr_addr   : unsigned(BW_ADDRESS-1 downto 0);
		wr_en     : std_logic;
		data_in   : std_logic_vector(23 downto 0);
	end record;

	type mem_ctrl_type_out is record
		data_out       : std_logic_vector(23 downto 0);
		data_out_valid : std_logic;
	end record;

	type memory_type is (X_MEM, Y_MEM, P_MEM);
	---------------
	-- STACK TYPES
	---------------
	type stack_array_type is array(0 to 15) of std_logic_vector(BW_ADDRESS-1 downto 0);

	type push_stack_content_type is (PC, PC_AND_SR, LA_AND_LC);

	type push_stack_type is record
		valid   : std_logic;
		pc      : unsigned(BW_ADDRESS-1 downto 0);
		content : push_stack_content_type;
	end record;

--	type pop_stack_content_type is (PC, PC_AND_SR, SR, LA_AND_LC);

--	type pop_stack_type is std_logic;
	type pop_stack_type is record
		valid : std_logic;
--		content : pop_stack_content_type;
	end record;

end package types_pkg;
