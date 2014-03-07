library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.parameter_pkg.all;
use work.types_pkg.all;


package constants_pkg is

	-------------------------
	-- Flags in CCR register
	-------------------------
	constant C_FLAG : natural := 0;
	constant V_FLAG : natural := 1;
	constant Z_FLAG : natural := 2;
	constant N_FLAG : natural := 3;
	constant U_FLAG : natural := 4;
	constant E_FLAG : natural := 5;
	constant L_FLAG : natural := 6;
	constant S_FLAG : natural := 7;

	-------------------
	-- Pipeline stages
	-------------------
	constant ST_FETCH  : natural := 0;
	constant ST_FETCH2 : natural := 1;
	constant ST_DECODE : natural := 2;
	constant ST_ADGEN  : natural := 3;
	constant ST_EXEC   : natural := 4;

	----------------------
	-- Activation signals
	----------------------
	constant ACT_ADGEN       : natural := 0; -- Run the address generator
	constant ACT_ALU         : natural := 1; -- Activation of ALU results in modification of the status register
	constant ACT_EXEC_BRA    : natural := 2; -- Branch (in execute stage)
	constant ACT_EXEC_CR_MOD : natural := 3; -- Control Register Modification (in execute stage)
	constant ACT_EXEC_LOOP   : natural := 4; -- Loop instruction (REP, DO)
	constant ACT_X_MEM_RD    : natural := 5; -- Init read from X memory
	constant ACT_Y_MEM_RD    : natural := 6; -- Init read from Y memory
	constant ACT_P_MEM_RD    : natural := 7; -- Init read from P memory
	constant ACT_X_MEM_WR    : natural := 8; -- Init write to  X memory
	constant ACT_Y_MEM_WR    : natural := 9; -- Init write to  Y memory
	constant ACT_P_MEM_WR    : natural := 10; -- Init write to P memory
	constant ACT_REG_RD      : natural := 11; -- Read from register (6 bit addressing)
	constant ACT_REG_WR      : natural := 12; -- Write to register (6 bit addressing)
	constant ACT_IMM_8BIT    : natural := 13; -- 8 bit  immediate operand (in instruction word)
	constant ACT_IMM_12BIT   : natural := 14; -- 12 bit immediate operand (in instruction word)
	constant ACT_IMM_LONG    : natural := 15; -- 24 bit immediate operant (in optional instruction word)
	constant ACT_X_BUS_RD    : natural := 16; -- Read  data via X-bus (from x0,x1,a,b)
	constant ACT_X_BUS_WR    : natural := 17; -- Write data via X-bus (to   x0,x1,a,b)
	constant ACT_Y_BUS_RD    : natural := 18; -- Read  data via Y-bus (from y0,y1,a,b)
	constant ACT_Y_BUS_WR    : natural := 19; -- Write data via Y-bus (to   y0,y1,a,b)
	constant ACT_L_BUS_RD    : natural := 20; -- Read  data via L-bus (from a10, b10,x,y,a,b,ab,ba)
	constant ACT_L_BUS_WR    : natural := 21; -- Write data via L-bus (to   a10, b10,x,y,a,b,ab,ba)
	constant ACT_BIT_MOD_WR  : natural := 22; -- Bit modify write (to set for BSET, BCLR, BCHG)
	constant ACT_REG_WR_CC   : natural := 23; -- Write to register file conditionally (Tcc)
	constant ACT_ALU_WR_CC   : natural := 24; -- Write ALU result conditionally (Tcc)
	constant ACT_NORM        : natural := 25; -- NORM instruction needs special handling

end package constants_pkg;
