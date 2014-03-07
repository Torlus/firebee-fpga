library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity memory_management is port (
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
end memory_management;


architecture rtl of memory_management is


	component mem_control is 
	generic(
		mem_type : memory_type
	);
	port(
		clk, rst        : in std_logic;
		rd_addr         : in unsigned(BW_ADDRESS-1 downto 0);
		rd_en           : in std_logic;
		data_out        : out std_logic_vector(23 downto 0);
		data_out_valid  : out std_logic;
		wr_addr         : in  unsigned(BW_ADDRESS-1 downto 0);
		wr_en           : in  std_logic;
		wr_accomplished : out std_logic;
		data_in         : in  std_logic_vector(23 downto 0)
	);
	end component mem_control;

	signal pmem_data_out        : std_logic_vector(23 downto 0);
	signal pmem_data_out_valid  : std_logic;

	signal pmem_rd_addr   : unsigned(BW_ADDRESS-1 downto 0);
	signal pmem_rd_en     : std_logic;

	signal xmem_rd_en          : std_logic;
	signal xmem_data_out       : std_logic_vector(23 downto 0);
	signal xmem_data_out_valid : std_logic;
	signal xmem_rd_polling : std_logic;

	signal ymem_rd_en          : std_logic;
	signal ymem_data_out       : std_logic_vector(23 downto 0);
	signal ymem_data_out_valid : std_logic;
	signal ymem_rd_polling : std_logic;

	signal pmem_stall_buffer : std_logic_vector(23 downto 0);
	signal pmem_stall_buffer_valid : std_logic;
	signal xmem_stall_buffer : std_logic_vector(23 downto 0);
	signal ymem_stall_buffer : std_logic_vector(23 downto 0);

	signal stall_flags_d    : std_logic_vector(PIPELINE_DEPTH-1 downto 0);

begin

	-- here it is necessary to store the output of the pmem/xmem/ymem when the pipeline enters a stall
	-- when the pipeline wakes up, this temporal result is inserted into the pipeline
	stall_buffer: process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				pmem_stall_buffer <= (others => '0');
				pmem_stall_buffer_valid <= '0';
				xmem_stall_buffer <= (others => '0');
				ymem_stall_buffer <= (others => '0');
				stall_flags_d <= (others => '0');
			else
				stall_flags_d <= stall_flags;
				if stall_flags(ST_FETCH2) = '1' and stall_flags_d(ST_FETCH2) = '0' then
					if pmem_data_out_valid = '1' then
						pmem_stall_buffer <= pmem_data_out;
						pmem_stall_buffer_valid <= '1';
					end if;
				end if;
				if stall_flags(ST_FETCH2) = '0' and stall_flags_d(ST_FETCH2) = '1' then
						pmem_stall_buffer_valid <= '0';
				end if;


			end if;
		end if;
	end process stall_buffer;
	
	memory_stall <= '1' when ( xmem_rd_en = '1' or (xmem_rd_polling = '1' and xmem_data_out_valid = '0') ) or
	                         ( ymem_rd_en = '1' or (ymem_rd_polling = '1' and ymem_data_out_valid = '0') ) else
	                '0';

	-------------------------------
	-- PMEM CONTROLLER
	-------------------------------
	inst_pmem_ctrl : mem_control 
	generic map(
		mem_type => P_MEM
	)
	port map(
		clk => clk,
		rst => rst,
		rd_addr => pmem_ctrl_in.rd_addr,
		rd_en   => pmem_ctrl_in.rd_en,
		data_out => pmem_data_out,
		data_out_valid => pmem_data_out_valid,
		wr_addr => pmem_ctrl_in.wr_addr,
		wr_en   => pmem_ctrl_in.wr_en,
		data_in => pmem_ctrl_in.data_in
	);

	-- In case we wake up from a stall use the buffered value
	pmem_ctrl_out.data_out <= pmem_stall_buffer when stall_flags(ST_FETCH2) = '0' and 
	                                                 stall_flags_d(ST_FETCH2) = '1' and 
	                                                 pmem_stall_buffer_valid = '1'  else
	                          pmem_data_out;

	pmem_ctrl_out.data_out_valid <= pmem_stall_buffer_valid when stall_flags(ST_FETCH2) = '0' and 
	                                                             stall_flags_d(ST_FETCH2) = '1' else
	                                '0'                     when stall_flags(ST_FETCH2) = '1' else
	                                pmem_data_out_valid;

	-------------------------------
	-- XMEM CONTROLLER
	-------------------------------
	inst_xmem_ctrl : mem_control 
	generic map(
		mem_type => X_MEM
	)
	port map(
		clk => clk,
		rst => rst,
		rd_addr => xmem_ctrl_in.rd_addr,
		rd_en   => xmem_rd_en,
		data_out => xmem_data_out,
		data_out_valid => xmem_data_out_valid,
		wr_addr => xmem_ctrl_in.wr_addr,
		wr_en   => xmem_ctrl_in.wr_en,
		data_in => xmem_ctrl_in.data_in
	);

	xmem_rd_en <= '1' when xmem_rd_polling = '0' and xmem_ctrl_in.rd_en = '1' else '0';

	xmem_ctrl_out.data_out <= xmem_data_out;
	xmem_ctrl_out.data_out_valid <= xmem_data_out_valid;

	-------------------------------
	-- YMEM CONTROLLER
	-------------------------------
	inst_ymem_ctrl : mem_control 
	generic map(
		mem_type => Y_MEM
	)
	port map(
		clk => clk,
		rst => rst,
		rd_addr => ymem_ctrl_in.rd_addr,
		rd_en   => ymem_rd_en,
		data_out => ymem_data_out,
		data_out_valid => ymem_data_out_valid,
		wr_addr => ymem_ctrl_in.wr_addr,
		wr_en   => ymem_ctrl_in.wr_en,
		data_in => ymem_ctrl_in.data_in
	);

	ymem_rd_en <= '1' when ymem_rd_polling = '0' and ymem_ctrl_in.rd_en = '1' else '0';

	ymem_ctrl_out.data_out <= ymem_data_out;
	ymem_ctrl_out.data_out_valid <= ymem_data_out_valid;

	mem_stall_control: process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				xmem_rd_polling <= '0';
				ymem_rd_polling <= '0';
			else
				if xmem_rd_en = '1' then
					xmem_rd_polling <= '1';
				end if;

				if xmem_data_out_valid = '1' then
					xmem_rd_polling <= '0';
				end if;

				if ymem_rd_en = '1' then
					ymem_rd_polling <= '1';
				end if;

				if ymem_data_out_valid = '1' then
					ymem_rd_polling <= '0';
				end if;

			end if;
		end if;
	end process;
end architecture;

