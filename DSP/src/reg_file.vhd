library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;
use work.constants_pkg.all;

entity reg_file is port(
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
	dec_lc            : in  std_logic;
	set_lc            : in  std_logic;
	new_lc            : in  unsigned(15 downto 0);
	set_la            : in  std_logic;
	new_la            : in  unsigned(BW_ADDRESS-1 downto 0)
);
end entity;


architecture rtl of reg_file is

	signal addr_r : addr_array;
	signal addr_m : addr_array;
	signal addr_n : addr_array;

	signal loop_address : unsigned(BW_ADDRESS-1 downto 0);
	signal loop_counter : unsigned(15 downto 0);

	-- condition code register
	signal ccr : std_logic_vector(7 downto 0);
	-- mode register
	signal mr  : std_logic_vector(7 downto 0);
	-- status register = mode register + condition code register
	signal sr  : std_logic_vector(15 downto 0);
	-- operation mode register
	signal omr : std_logic_vector(7 downto 0);

	signal stack_pointer    : unsigned(5 downto 0);
	signal system_stack_ssh : stack_array_type;
	signal system_stack_ssl : stack_array_type;

	signal x0 : signed(23 downto 0);
	signal x1 : signed(23 downto 0);
	signal y0 : signed(23 downto 0);
	signal y1 : signed(23 downto 0);

	signal a0 : signed(23 downto 0);
	signal a1 : signed(23 downto 0);
	signal a2 : signed(7 downto 0);

	signal b0 : signed(23 downto 0);
	signal b1 : signed(23 downto 0);
	signal b2 : signed(7 downto 0);
	
	signal limited_a1 : signed(23 downto 0);
	signal limited_b1 : signed(23 downto 0);
	signal limited_a0 : signed(23 downto 0);
	signal limited_b0 : signed(23 downto 0);
	signal set_limiting_flag  : std_logic;
	signal X_bus_rd_limited_a : std_logic;
	signal X_bus_rd_limited_b : std_logic;
	signal Y_bus_rd_limited_a : std_logic;
	signal Y_bus_rd_limited_b : std_logic;
	signal reg_rd_limited_a   : std_logic;
	signal reg_rd_limited_b   : std_logic;
	signal rd_limited_a       : std_logic;
	signal rd_limited_b       : std_logic;

begin



	sr <= mr & ccr;

	register_file.addr_r <= addr_r;
	register_file.addr_n <= addr_n;
	register_file.addr_m <= addr_m;
	register_file.lc <= loop_counter;
	register_file.la <= loop_address;
	register_file.ccr <= ccr;
	register_file.mr <= mr;
	register_file.sr <= sr;
	register_file.omr <= omr;
	register_file.stack_pointer <= stack_pointer;
	register_file.current_ssh <= system_stack_ssh(to_integer(stack_pointer(3 downto 0)));
	register_file.current_ssl <= system_stack_ssl(to_integer(stack_pointer(3 downto 0)));
	register_file.a  <= a2 & a1 & a0;
	register_file.b  <= b2 & b1 & b0;
	register_file.x0 <= x0;
	register_file.x1 <= x1;
	register_file.y0 <= y0;
	register_file.y1 <= y1;


	global_register_file: process(clk) is
		variable stack_pointer_plus_1 : unsigned(3 downto 0);
		variable reg_addr : integer range 0 to 7;
	begin
		if rising_edge(clk) then
			if rst = '1' then
				addr_r <= (others => (others => '0'));
				addr_n <= (others => (others => '0'));
				addr_m <= (others => (others => '1'));
				ccr    <= (others => '0');
				mr     <= (others => '0');
				omr    <= (others => '0');
				system_stack_ssl <= (others => (others => '0'));
				system_stack_ssh <= (others => (others => '0'));
				stack_pointer    <= (others => '0');
				loop_counter <= (others => '0');
				loop_address <= (others => '0');
				x0 <= (others => '0');
				x1 <= (others => '0');
				y0 <= (others => '0');
				y1 <= (others => '0');
				a0 <= (others => '0');
				a1 <= (others => '0');
				a2 <= (others => '0');
				b0 <= (others => '0');
				b1 <= (others => '0');
				b2 <= (others => '0');
			else
				reg_addr := to_integer(unsigned(reg_wr_addr(2 downto 0)));
				-----------------------------------------------------------------------
				-- General write port to register file using 6 bit addressing scheme
				-----------------------------------------------------------------------
				if reg_wr_addr_valid = '1' then
					case reg_wr_addr(5 downto 3) is
						-- X0, X1, Y0, Y1
						when "000" =>
							case reg_wr_addr(2 downto 0) is
								when "100" =>
									x0 <= signed(reg_wr_data);
								when "101" =>
									x1 <= signed(reg_wr_data);
								when "110" =>
									y0 <= signed(reg_wr_data);
								when "111" =>
									y1 <= signed(reg_wr_data);
								when others =>
							end case;

						-- A0, B0, A2, B2, A1, B1, A, B
						when "001" =>
							case reg_wr_addr(2 downto 0) is
								when "000" =>
									a0 <= signed(reg_wr_data);
								when "001" =>
									b0 <= signed(reg_wr_data);
								when "010" =>
									a2 <= signed(reg_wr_data(7 downto 0));
								when "011" =>
									b2 <= signed(reg_wr_data(7 downto 0));
								when "100" =>
									a1 <= signed(reg_wr_data);
								when "101" =>
									b1 <= signed(reg_wr_data);
								when "110" =>
									a2 <= (others => reg_wr_data(23));
									a1 <= signed(reg_wr_data);
									a0 <= (others => '0');
								when "111" =>
									b2 <= (others => reg_wr_data(23));
									b1 <= signed(reg_wr_data);
									b0 <= (others => '0');
								when others =>
							end case;

						-- R0-R7
						when "010" =>
							addr_r(reg_addr) <= unsigned(reg_wr_data(BW_ADDRESS-1 downto 0));

						-- N0-N7
						when "011" =>
							addr_n(reg_addr) <= unsigned(reg_wr_data(BW_ADDRESS-1 downto 0));

						-- M0-M7
						when "100" =>
							addr_m(reg_addr) <= unsigned(reg_wr_data(BW_ADDRESS-1 downto 0));

						-- SR, OMR, SP, SSH, SSL, LA, LC
						when "111" =>
							case reg_wr_addr(2 downto 0) is
								-- SR
								when "001" =>
									mr  <= reg_wr_data(15 downto 8);
									ccr <= reg_wr_data( 7 downto 0);

								-- OMR
								when "010" =>
									omr  <= reg_wr_data(7 downto 0);

								-- SP
								when "011" =>
									stack_pointer <= unsigned(reg_wr_data(5 downto 0));

								-- SSH
								when "100" =>
									system_stack_ssh(to_integer(stack_pointer_plus_1)) <= reg_wr_data(BW_ADDRESS-1 downto 0);
									-- increase stack after writing
									stack_pointer(3 downto 0) <= stack_pointer_plus_1;
									-- test whether stack is full, if so set the stack error flag (SE)
									if stack_pointer(3 downto 0) = "1111" then
										stack_pointer(4) <= '1';
									end if;

								-- SSL
								when "101" =>
									system_stack_ssl(to_integer(stack_pointer)) <= reg_wr_data(BW_ADDRESS-1 downto 0);

								-- LA
								when "110" =>
									loop_address <= unsigned(reg_wr_data(BW_ADDRESS-1 downto 0));

								-- LC
								when "111" =>
									loop_counter <= unsigned(reg_wr_data(15 downto 0));

								when others =>
							end case;
						when others =>
					end case;
				end if;

				----------------
				-- X BUS Write
				----------------
				if X_bus_wr_valid = '1' then
					case X_bus_wr_addr is
						when "00" =>
							x0 <= signed(X_bus_data_in);
						when "01" =>
							x1 <= signed(X_bus_data_in);
						when "10" =>
							a2 <= (others => X_bus_data_in(23));
							a1 <= signed(X_bus_data_in);
							a0 <= (others => '0');
						when others =>
							b2 <= (others => X_bus_data_in(23));
							b1 <= signed(X_bus_data_in);
							b0 <= (others => '0');
					end case;
				end if;
				----------------
				-- Y BUS Write
				----------------
				if Y_bus_wr_valid = '1' then
					case Y_bus_wr_addr is
						when "00" =>
							y0 <= signed(Y_bus_data_in);
						when "01" =>
							y1 <= signed(Y_bus_data_in);
						when "10" =>
							a2 <= (others => Y_bus_data_in(23));
							a1 <= signed(Y_bus_data_in);
							a0 <= (others => '0');
						when others =>
							b2 <= (others => Y_bus_data_in(23));
							b1 <= signed(Y_bus_data_in);
							b0 <= (others => '0');
					end case;
				end if;
				------------------
				-- L BUS Write
				------------------
				if L_bus_wr_valid = '1' then
					case L_bus_wr_addr is
						-- A10
						when "000" =>
							a1 <= signed(X_bus_data_in);
							a0 <= signed(Y_bus_data_in);
						-- B10
						when "001" =>
							b1 <= signed(X_bus_data_in);
							b0 <= signed(Y_bus_data_in);
						-- X
						when "010" =>
							x1 <= signed(X_bus_data_in);
							x0 <= signed(Y_bus_data_in);
						-- Y
						when "011" =>
							y1 <= signed(X_bus_data_in);
							y0 <= signed(Y_bus_data_in);
						-- A
						when "100" =>
							a2 <= (others => X_bus_data_in(23));
							a1 <= signed(X_bus_data_in);
							a0 <= signed(Y_bus_data_in);
						-- B
						when "101" =>
							b2 <= (others => X_bus_data_in(23));
							b1 <= signed(X_bus_data_in);
							b0 <= signed(Y_bus_data_in);
						-- AB
						when "110" =>
							a2 <= (others => X_bus_data_in(23));
							a1 <= signed(X_bus_data_in);
							a0 <= (others => '0');
							b2 <= (others => Y_bus_data_in(23));
							b1 <= signed(Y_bus_data_in);
							b0 <= (others => '0');
						-- BA
						when others =>
							a2 <= (others => Y_bus_data_in(23));
							a1 <= signed(Y_bus_data_in);
							a0 <= (others => '0');
							b2 <= (others => X_bus_data_in(23));
							b1 <= signed(X_bus_data_in);
							b0 <= (others => '0');
					end case;
				end if;

				---------------------
				-- STATUS REGISTERS
				---------------------
				if set_sr = '1' then
					ccr <= new_sr( 7 downto 0);
					mr  <= new_sr(15 downto 8);
				end if;
				if set_omr = '1' then
					omr <= new_omr;
				end if;
				-- data limiter active?
				-- listing this statement after the set_sr test results
				-- in the correct behaviour for ALU operations with parallel move
				if set_limiting_flag = '1' then
					ccr(6) <= '1';
				end if;

				--------------------
				-- LOOP REGISTERS 
				--------------------
				if set_la = '1' then
					loop_address <= new_la;
				end if;
				if set_lc = '1' then
					loop_counter <= new_lc;
				end if;
				if dec_lc = '1' then
					loop_counter <= loop_counter - 1;
				end if;

				---------------------
				-- ADDRESS REGISTER
				---------------------
				if wr_R_port_A_valid = '1' then
					addr_r(to_integer(wr_R_port_A.reg_number)) <= wr_R_port_A.reg_value;
				end if;
				if wr_R_port_B_valid = '1' then
					addr_r(to_integer(wr_R_port_B.reg_number)) <= wr_R_port_B.reg_value;
				end if;

				-------------------------
				-- ALU ACCUMULATOR WRITE
				-------------------------
				if alu_wr_valid = '1' then
					if alu_wr_addr = '0' then
						a2 <= alu_wr_data(55 downto 48);
						a1 <= alu_wr_data(47 downto 24);
						a0 <= alu_wr_data(23 downto  0);
					else
						b2 <= alu_wr_data(55 downto 48);
						b1 <= alu_wr_data(47 downto 24);
						b0 <= alu_wr_data(23 downto  0);
					end if;
				end if;

				---------------------
				-- STACK CONTROLLER 
				---------------------
				stack_pointer_plus_1 := stack_pointer(3 downto 0) + 1;
				if push_stack.valid = '1' then
					-- increase stack after writing
					stack_pointer(3 downto 0) <= stack_pointer_plus_1;
					-- test whether stack is full, if so set the stack error flag (SE)
					if stack_pointer(3 downto 0) = "1111" then
						stack_pointer(4) <= '1';
					end if;
					case push_stack.content is
						when PC =>
							system_stack_ssh(to_integer(stack_pointer_plus_1)) <= std_logic_vector(push_stack.pc);

						when PC_AND_SR =>
							system_stack_ssh(to_integer(stack_pointer_plus_1)) <= std_logic_vector(push_stack.pc);
							system_stack_ssl(to_integer(stack_pointer_plus_1)) <= SR;

						when LA_AND_LC =>
							system_stack_ssh(to_integer(stack_pointer_plus_1)) <= std_logic_vector(loop_address);
							system_stack_ssl(to_integer(stack_pointer_plus_1)) <= std_logic_vector(loop_counter);

					end case;
				end if;

				-- decrease stack pointer
				if pop_stack.valid = '1' then
					stack_pointer(3 downto 0) <= stack_pointer(3 downto 0) - 1;
					-- if stack is empty set the underflow flag (bit 5, UF) and the stack error flag (bit 4, SE)
					if stack_pointer(3 downto 0) = "0000" then
						stack_pointer(5) <= '1';
						stack_pointer(4) <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;


	x_bus_rd_port: process(X_bus_rd_addr,x0,x1,a1,b1,limited_a1,limited_b1,
	                       L_bus_rd_addr,L_bus_rd_valid,y1) is
	begin
		X_bus_rd_limited_a <= '0';
		X_bus_rd_limited_b <= '0';
		case X_bus_rd_addr is
			when "00" =>   X_bus_data_out <= std_logic_vector(x0);
			when "01" =>   X_bus_data_out <= std_logic_vector(x1);
			when "10" =>   X_bus_data_out <= std_logic_vector(limited_a1); X_bus_rd_limited_a <= '1';
			when others => X_bus_data_out <= std_logic_vector(limited_b1); X_bus_rd_limited_b <= '1';
		end case;
		if L_bus_rd_valid = '1' then
			case L_bus_rd_addr is
				when "000" =>  X_bus_data_out <= std_logic_vector(a1);
				when "001" =>  X_bus_data_out <= std_logic_vector(b1);
				when "010" =>  X_bus_data_out <= std_logic_vector(x1);
				when "011" =>  X_bus_data_out <= std_logic_vector(y1);
				when "100" =>  X_bus_data_out <= std_logic_vector(limited_a1); X_bus_rd_limited_a <= '1';
				when "101" =>  X_bus_data_out <= std_logic_vector(limited_b1); X_bus_rd_limited_b <= '1';
				when "110" =>  X_bus_data_out <= std_logic_vector(limited_a1); X_bus_rd_limited_a <= '1';
				when others => X_bus_data_out <= std_logic_vector(limited_b1); X_bus_rd_limited_b <= '1';
			end case;
		end if;
	end process x_bus_rd_port;

	y_bus_rd_port: process(Y_bus_rd_addr,y0,y1,a1,b1,limited_a1,limited_b1,
	                       L_bus_rd_addr,L_bus_rd_valid,a0,b0,x0,limited_a0,limited_b0) is
	begin
		Y_bus_rd_limited_a <= '0';
		Y_bus_rd_limited_b <= '0';
		case Y_bus_rd_addr is
			when "00" =>   Y_bus_data_out <= std_logic_vector(y0);
			when "01" =>   Y_bus_data_out <= std_logic_vector(y1);
			when "10" =>   Y_bus_data_out <= std_logic_vector(limited_a1); Y_bus_rd_limited_a <= '1';
			when others => Y_bus_data_out <= std_logic_vector(limited_b1); Y_bus_rd_limited_b <= '1';
		end case;
		if L_bus_rd_valid = '1' then
			case L_bus_rd_addr is
				when "000" =>  Y_bus_data_out <= std_logic_vector(a0);
				when "001" =>  Y_bus_data_out <= std_logic_vector(b0);
				when "010" =>  Y_bus_data_out <= std_logic_vector(x0);
				when "011" =>  Y_bus_data_out <= std_logic_vector(y0);
				when "100" =>  Y_bus_data_out <= std_logic_vector(limited_a0); Y_bus_rd_limited_a <= '1';
				when "101" =>  Y_bus_data_out <= std_logic_vector(limited_b0); Y_bus_rd_limited_b <= '1';
				when "110" =>  Y_bus_data_out <= std_logic_vector(limited_b1); Y_bus_rd_limited_b <= '1';
				when others => Y_bus_data_out <= std_logic_vector(limited_a1); Y_bus_rd_limited_a <= '1';
			end case;
		end if;
	end process y_bus_rd_port;


	reg_rd_port: process(reg_rd_addr, x0,x1,y0,y1,a0,a1,a2,b0,b1,b2,
	                     omr,ccr,mr,addr_r,addr_n,addr_m,stack_pointer,
	                     loop_address,loop_counter,system_stack_ssl,system_stack_ssh) is
		variable reg_addr : integer range 0 to 7;
	begin
		reg_addr := to_integer(unsigned(reg_rd_addr(2 downto 0)));
		reg_rd_data <= (others => '0');
		reg_rd_limited_a <= '0';
		reg_rd_limited_b <= '0';

		case reg_rd_addr(5 downto 3) is
			-- X0, X1, Y0, Y1
			when "000" =>
				case reg_rd_addr(2 downto 0) is
					when "100" =>
						reg_rd_data <= std_logic_vector(x0);
					when "101" =>
						reg_rd_data <= std_logic_vector(x1);
					when "110" =>
						reg_rd_data <= std_logic_vector(y0);
					when "111" =>
						reg_rd_data <= std_logic_vector(y1);
					when others =>
				end case;

			-- A0, B0, A2, B2, A1, B1, A, B
			when "001" =>
				case reg_rd_addr(2 downto 0) is
					when "000" =>
						reg_rd_data <= std_logic_vector(a0);
					when "001" =>
						reg_rd_data <= std_logic_vector(b0);
					when "010" =>
						-- MSBs are read as zero!
						reg_rd_data(23 downto 8) <= (others => '0');
						reg_rd_data(7 downto 0) <= std_logic_vector(a2);
					when "011" =>
						-- MSBs are read as zero!
						reg_rd_data(23 downto 8) <= (others => '0');
						reg_rd_data(7 downto 0) <= std_logic_vector(b2);
					when "100" =>
						reg_rd_data <= std_logic_vector(a1);
					when "101" =>
						reg_rd_data <= std_logic_vector(b1);
					when "110" =>
						reg_rd_data <= std_logic_vector(limited_a1);
						reg_rd_limited_a <= '1';
					when "111" =>
						reg_rd_data <= std_logic_vector(limited_b1);
						reg_rd_limited_b <= '1';
					when others =>
				end case;

			-- R0-R7
			when "010" =>
				reg_rd_data <= std_logic_vector(resize(addr_r(reg_addr), 24));

			-- N0-N7
			when "011" =>
				reg_rd_data <= std_logic_vector(resize(addr_n(reg_addr), 24));

			-- M0-M7
			when "100" =>
				reg_rd_data <= std_logic_vector(resize(addr_m(reg_addr), 24));

			-- SR, OMR, SP, SSH, SSL, LA, LC
			when "111" =>
				case reg_wr_addr(2 downto 0) is
					-- SR
					when "001" =>
						reg_rd_data(23 downto 16) <= (others => '0');
						reg_rd_data(15 downto  0) <= mr & ccr;

					-- OMR
					when "010" =>
						reg_rd_data(23 downto 8) <= (others => '0');
						reg_rd_data( 7 downto 0) <= omr;

					-- SP
					when "011" =>
						reg_rd_data(23 downto 6) <= (others => '0');
						reg_rd_data(5 downto 0) <= std_logic_vector(stack_pointer);

					-- SSH
					when "100" =>
-- TODO!
--						system_stack_ssh(to_integer(stack_pointer_plus_1)) <= reg_wr_data(BW_ADDRESS-1 downto 0);
--						-- increase stack after writing
--						stack_pointer(3 downto 0) <= stack_pointer_plus_1;
--						-- test whether stack is full, if so set the stack error flag (SE)
--						if stack_pointer(3 downto 0) = "1111" then
--							stack_pointer(4) <= '1';
--						end if;

					-- SSL
					when "101" =>
						reg_rd_data <= (others => '0');
						reg_rd_data(BW_ADDRESS-1 downto 0) <= std_logic_vector(system_stack_ssl(to_integer(stack_pointer)));

					-- LA
					when "110" =>
						reg_rd_data <= (others => '0');
						reg_rd_data(BW_ADDRESS-1 downto 0) <= std_logic_vector(loop_address);

					-- LC
					when "111" =>
						reg_rd_data <= (others => '0');
						reg_rd_data(15 downto 0) <= std_logic_vector(loop_counter);

					when others =>
				end case;
			when others =>
		end case;
	end process;

	rd_limited_a <= '1' when reg_rd_limited_a = '1' or X_bus_rd_limited_a = '1' or Y_bus_rd_limited_a = '1' else '0';
	rd_limited_b <= '1' when reg_rd_limited_b = '1' or X_bus_rd_limited_b = '1' or Y_bus_rd_limited_b = '1' else '0';

	data_shifter_limiter: process(a2,a1,a0,b2,b1,b0,sr,rd_limited_a,rd_limited_b) is
		variable scaled_a : signed(55 downto 0);
		variable scaled_b : signed(55 downto 0);
	begin

		set_limiting_flag <= '0';
		-----------------
		-- DATA SCALING
		-----------------
		-- test against scaling bits S1, S0
		case sr(11 downto 10) is
			-- scale down (right shift)
			when "01" =>
				scaled_a := a2(7) & a2 & a1 & a0(23 downto 1);
				scaled_b := b2(7) & b2 & b1 & b0(23 downto 1);
			-- scale up (arithmetic left shift)
			when "10" =>
				scaled_a := a2(6 downto 0) & a1 & a0 & '0';
				scaled_b := b2(6 downto 0) & b1 & b0 & '0';
			-- "00" do not scale!
			when others =>
				scaled_a := a2 & a1 & a0;
				scaled_b := b2 & b1 & b0;
		end case;

		-- only sign extension stored in a2?
		-- Yes: No limiting needed!
		if scaled_a(55 downto 47) = "111111111" or scaled_a(55 downto 47) = "000000000" then
			limited_a1 <= scaled_a(47 downto 24);
			limited_a0 <= scaled_a(23 downto  0);
		else
			-- positive value in a?
			if scaled_a(55) = '0' then
				limited_a1 <= X"7FFFFF";
				limited_a0 <= X"FFFFFF";
			-- negative value in a?
			else
				limited_a1 <= X"800000";
				limited_a0 <= X"000000";
			end if;
			-- set the limit flag in the status register
			if rd_limited_a = '1' then
				set_limiting_flag <= '1';
			end if;
		end if;
		-- only sign extension stored in b2?
		-- Yes: No limiting needed!
		if scaled_b(55 downto 47) = "111111111" or scaled_b(55 downto 47) = "000000000" then
			limited_b1 <= scaled_b(47 downto 24);
			limited_b0 <= scaled_b(23 downto  0);
		else
			-- positive value in b?
			if scaled_b(55) = '0' then
				limited_b1 <= X"7FFFFF";
				limited_b0 <= X"FFFFFF";
			-- negative value in b?
			else
				limited_b1 <= X"800000";
				limited_b0 <= X"000000";
			end if;
			-- set the limit flag in the status register
			if rd_limited_b = '1' then
				set_limiting_flag <= '1';
			end if;
		end if;

	end process;


end architecture rtl;
