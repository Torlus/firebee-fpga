----------------------------------------------------------------------
----                                                              ----
---- Atari Coldfire IP Core				                          ----
----                                                              ----
---- This file is part of the Atari Coldfire project.             ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
----                                                              ----
----                                                              ----
----                                                              ----
----                                                              ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Wolfgang Foerster                         ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/lgpl.html                   ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 1.0 Initial Release, 20090925.
-- 

library ieee;
use ieee.std_logic_1164.all;

package FalconIO_SDCard_IDE_CF_PKG is
	component WF25915IP_TOP_V1_SOC -- GLUE.
		port (
		    -- Clock system:
			GL_CLK		: in std_logic; -- Originally 8MHz.
			GL_CLK_016	: in std_logic; -- One sixteenth of GL_CLK.
			
            -- Core address select:
            GL_ROMSEL_FC_E0n    : in std_logic;
            EN_RAM_14MB         : in std_logic;
			-- Adress decoder outputs:
			GL_ROM_6n	: out std_logic;	-- STE.
			GL_ROM_5n	: out std_logic;	-- STE.
			GL_ROM_4n	: out std_logic;	-- ST.
			GL_ROM_3n	: out std_logic;	-- ST.
			GL_ROM_2n	: out std_logic;
			GL_ROM_1n	: out std_logic;
			GL_ROM_0n	: out std_logic;
			
			GL_ACIACS	: out std_logic;
			GL_MFPCSn	: out std_logic;
			GL_SNDCSn	: out std_logic;
			GL_FCSn		: out std_logic;

			GL_STE_SNDCS	: out std_logic; 	-- STE: Sound chip select.
			GL_STE_SNDIR	: out std_logic; 	-- STE: Data flow direction control.

			GL_STE_RTCCSn	: out std_logic; 	--STE only.
			GL_STE_RTC_WRn	: out std_logic; 	--STE only.
			GL_STE_RTC_RDn	: out std_logic;	--STE only.

			-- 6800 peripheral control, 
			GL_VPAn			: out std_logic;
			GL_VMAn 		: in std_logic;
			
			GL_DMA_SYNC		: in std_logic;
			GL_DEVn			: out std_logic;
			GL_RAMn			: out std_logic;
			GL_DMAn			: out std_logic;
			
			-- Interrupt system:
			-- Comment out GL_AVECn for CPUs which do not provide the VMAn signal.
			GL_AVECn		: out std_logic;
			GL_STE_FDINT	: in std_logic; 	-- Floppy disk interrupt; STE only.
			GL_STE_HDINTn	: in std_logic; 	-- Hard disk interrupt; STE only.
			GL_MFPINTn		: in std_logic; 	-- ST.
			GL_STE_EINT3n	: in std_logic; 	--STE only.
			GL_STE_EINT5n	: in std_logic; 	--STE only.
			GL_STE_EINT7n	: in std_logic; 	--STE only.
			GL_STE_DINTn	: out std_logic; 	-- Disk interrupt (floppy or hard disk); STE only.
			GL_IACKn		: out std_logic; 	-- ST.
			GL_STE_IPL2n	: out std_logic; 	--STE only.
			GL_STE_IPL1n	: out std_logic; 	--STE only.
			GL_STE_IPL0n	: out std_logic; 	--STE only.
			
			-- Video timing:
			GL_BLANKn		: out std_logic;
			GL_DE			: out std_logic;
			GL_MULTISYNC	: in std_logic_vector(3 downto 2);
            GL_VIDEO_HIMODE : out std_logic;
			GL_HSYNC_INn	: in std_logic;
			GL_HSYNC_OUTn	: out std_logic;
			GL_VSYNC_INn	: in std_logic;
			GL_VSYNC_OUTn	: out std_logic;
			GL_SYNC_OUT_EN	: out std_logic;
			
			-- Bus arstd_logicration control:
			GL_RDY_INn		: in std_logic;
			GL_RDY_OUTn		: out std_logic;
			GL_BRn			: out std_logic;
			GL_BGIn			: in std_logic;
			GL_BGOn			: out std_logic;
			GL_BGACK_INn	: in std_logic;
			GL_BGACK_OUTn	: out std_logic;

			-- Adress and data bus:
			GL_ADDRESS		: in std_logic_vector(23 downto 1);
			-- ST: put the data bus to 1 downto 0. 
			-- STE: put the data out bus to 15 downto 0. 
			GL_DATA_IN		: in std_logic_vector(7 downto 0);
			GL_DATA_OUT		: out std_logic_vector(15 downto 0);
			GL_DATA_EN		: out std_logic;
			
			-- Asynchronous bus control:
			GL_RWn_IN		: in std_logic;
			GL_RWn_OUT		: out std_logic;
			GL_AS_INn		: in std_logic;
			GL_AS_OUTn		: out std_logic;
			GL_UDS_INn		: in std_logic;
			GL_UDS_OUTn		: out std_logic;
			GL_LDS_INn		: in std_logic;
			GL_LDS_OUTn		: out std_logic;
			GL_DTACK_INn	: in std_logic;
			GL_DTACK_OUTn	: out std_logic;
			GL_CTRL_EN		: out std_logic;
			
			-- System control:
			GL_RESETn		: in std_logic;
			GL_BERRn		: out std_logic;
			
			-- Processor function codes:
			GL_FC	: in std_logic_vector(2 downto 0);

			-- STE enhancements:
			GL_STE_FDDS		: out std_logic; 		-- Floppy type select (HD or DD).
			GL_STE_FCCLK	: out std_logic; 		-- Floppy controller clock select.
			GL_STE_JOY_RHn	: out std_logic; 		-- Read only FF9202 high byte.
			GL_STE_JOY_RLn	: out std_logic; 		-- Read only FF9202 low byte.
			GL_STE_JOY_WL	: out std_logic; 		-- Write only FF9202 low byte.
			GL_STE_JOY_WEn	: out std_logic; 		-- Write only FF9202 output enable.
			GL_STE_BUTTONn	: out std_logic; 		-- Read only FF9000 low byte.		
			GL_STE_PAD0Xn	: in std_logic; 		-- Counter input for the Paddle 0X.
			GL_STE_PAD0Yn	: in std_logic; 		-- Counter input for the Paddle 0Y.
			GL_STE_PAD1Xn	: in std_logic; 		-- Counter input for the Paddle 1X.
			GL_STE_PAD1Yn	: in std_logic; 		-- Counter input for the Paddle 1Y.
			GL_STE_PADRSTn	: out std_logic; 		-- Paddle monoflops reset.
			GL_STE_PENn		: in std_logic; 		-- Input of the light pen.
			GL_STE_SCCn		: out std_logic;	-- Select signal for the STE or TT SCC chip.
			GL_STE_CPROGn	: out std_logic	-- Select signal for the STE's cache processor.
			);
	end component WF25915IP_TOP_V1_SOC;

    component WF5380_TOP_SOC
        port (
            CLK			: in std_logic;
            RESETn	    : in std_logic;
            ADR			: in std_logic_vector(2 downto 0);
            DATA_IN		: in std_logic_vector(7 downto 0);
            DATA_OUT	: out std_logic_vector(7 downto 0);
            DATA_EN		: out std_logic;
            CSn			: in std_logic;
            RDn		    : in std_logic;
            WRn	        : in std_logic;
            EOPn        : in std_logic;
            DACKn	    : in std_logic;
            DRQ		    : out std_logic;
            INT		    : out std_logic;
            READY       : out std_logic;
            DB_INn		: in std_logic_vector(7 downto 0);
            DB_OUTn		: out std_logic_vector(7 downto 0);
            DB_EN       : out std_logic;
            DBP_INn		: in std_logic;
            DBP_OUTn	: out std_logic;
            DBP_EN      : out std_logic;
            RST_INn     : in std_logic;
            RST_OUTn    : out std_logic;
            RST_EN      : out std_logic;
            BSY_INn     : in std_logic;
            BSY_OUTn    : out std_logic;
            BSY_EN      : out std_logic;
            SEL_INn     : in std_logic;
            SEL_OUTn    : out std_logic;
            SEL_EN      : out std_logic;
            ACK_INn     : in std_logic;
            ACK_OUTn    : out std_logic;
            ACK_EN      : out std_logic;
            ATN_INn     : in std_logic;
            ATN_OUTn    : out std_logic;
            ATN_EN      : out std_logic;
            REQ_INn     : in std_logic;
            REQ_OUTn    : out std_logic;
            REQ_EN      : out std_logic;
            IOn_IN      : in std_logic;
            IOn_OUT     : out std_logic;
            IO_EN       : out std_logic;
            CDn_IN      : in std_logic;
            CDn_OUT     : out std_logic;
            CD_EN       : out std_logic;
            MSG_INn     : in std_logic;
            MSG_OUTn    : out std_logic;
            MSG_EN      : out std_logic
        );
    end component WF5380_TOP_SOC;

	component WF1772IP_TOP_SOC -- FDC.
		port (
			CLK			: in std_logic; -- 16MHz clock!
			RESETn		: in std_logic;
			CSn			: in std_logic;
			RWn			: in std_logic;
			A1, A0		: in std_logic;
			DATA_IN		: in std_logic_vector(7 downto 0);
			DATA_OUT	: out std_logic_vector(7 downto 0);
			DATA_EN		: out std_logic;
			RDn			: in std_logic;
			TR00n		: in std_logic;
			IPn			: in std_logic;
			WPRTn		: in std_logic;
			DDEn		: in std_logic;
			HDTYPE		: in std_logic; -- '0' = DD disks, '1' = HD disks.
			MO			: out std_logic;
			WG			: out std_logic;
			WD			: out std_logic;
			STEP		: out std_logic;
			DIRC		: out std_logic;
			DRQ			: out std_logic;
			INTRQ		: out std_logic
		);
	end component WF1772IP_TOP_SOC;

	component WF68901IP_TOP_SOC -- MFP.
		port (  -- System control:
				CLK			: in std_logic;
				RESETn		: in std_logic;
				
				-- Asynchronous bus control:
				DSn			: in std_logic;
				CSn			: in std_logic;
				RWn			: in std_logic;
				DTACKn		: out std_logic;
				
				-- Data and Adresses:
				RS			: in std_logic_vector(5 downto 1);
				DATA_IN		: in std_logic_vector(7 downto 0);
				DATA_OUT	: out std_logic_vector(7 downto 0);
				DATA_EN		: out std_logic;
				GPIP_IN		: in std_logic_vector(7 downto 0);
				GPIP_OUT	: out std_logic_vector(7 downto 0);
				GPIP_EN		: out std_logic_vector(7 downto 0);
				
				-- Interrupt control:
				IACKn		: in std_logic;
				IEIn		: in std_logic;
				IEOn		: out std_logic;
				IRQn		: out std_logic;
				
				-- Timers and timer control:
				XTAL1		: in std_logic; -- Use an oszillator instead of a quartz.
				TAI			: in std_logic;
				TBI			: in std_logic;
				TAO			: out std_logic;			
				TBO			: out std_logic;			
				TCO			: out std_logic;			
				TDO			: out std_logic;			
				
				-- Serial I/O control:
				RC			: in std_logic;
				TC			: in std_logic;
				SI			: in std_logic;
				SO			: out std_logic;
				SO_EN		: out std_logic;
				
				-- DMA control:
				RRn			: out std_logic;
				TRn			: out std_logic			
		);
	end component WF68901IP_TOP_SOC;

	component WF2149IP_TOP_SOC -- Sound.
		port(
			
			SYS_CLK		: in std_logic; -- Read the inforation in the header!
			RESETn   	: in std_logic;

			WAV_CLK		: in std_logic; -- Read the inforation in the header!
			SELn		: in std_logic;
			
			BDIR		: in std_logic;
			BC2, BC1	: in std_logic;

			A9n, A8		: in std_logic;
			DA_IN		: in std_logic_vector(7 downto 0);
			DA_OUT		: out std_logic_vector(7 downto 0);
			DA_EN		: out std_logic;
			
			IO_A_IN		: in std_logic_vector(7 downto 0);
			IO_A_OUT	: out std_logic_vector(7 downto 0);
			IO_A_EN		: out std_logic;
			IO_B_IN		: in std_logic_vector(7 downto 0);
			IO_B_OUT	: out std_logic_vector(7 downto 0);
			IO_B_EN		: out std_logic;

			OUT_A		: out std_logic; -- Analog (PWM) outputs.
			OUT_B		: out std_logic;
			OUT_C		: out std_logic
		);
	end component WF2149IP_TOP_SOC;

	component WF6850IP_TOP_SOC -- ACIA.
	  port (
			CLK					: in std_logic;
	        RESETn				: in std_logic;

	        CS2n, CS1, CS0		: in std_logic;
	        E		       		: in std_logic;   
	        RWn              	: in std_logic;
	        RS					: in std_logic;

	        DATA_IN		        : in std_logic_vector(7 downto 0);   
	        DATA_OUT	        : out std_logic_vector(7 downto 0);   
			DATA_EN				: out std_logic;

	        TXCLK				: in std_logic;
	        RXCLK				: in std_logic;
	        RXDATA				: in std_logic;
	        CTSn				: in std_logic;
	        DCDn				: in std_logic;
	        
	        IRQn				: out std_logic;
	        TXDATA				: out std_logic;   
	        RTSn				: out std_logic
	       );                                              
	end component WF6850IP_TOP_SOC;

	component WF_SD_CARD
		port (
			RESETn			: in std_logic;
			CLK				: in std_logic;
			ACSI_A1			: in std_logic;
			ACSI_CSn		: in std_logic;
			ACSI_ACKn		: in std_logic;
			ACSI_INTn		: out std_logic;
			ACSI_DRQn		: out std_logic;
			ACSI_D_IN		: in std_logic_vector(7 downto 0);
			ACSI_D_OUT		: out std_logic_vector(7 downto 0);
			ACSI_D_EN		: out std_logic;
			MC_DO			: in std_logic;
			MC_PIO_DMAn		: in std_logic;
			MC_RWn			: in std_logic;
			MC_CLR_CMD		: in std_logic;
			MC_DONE			: out std_logic;
			MC_GOT_CMD		: out std_logic;
			MC_D_IN			: in std_logic_vector(7 downto 0);
			MC_D_OUT		: out std_logic_vector(7 downto 0);
			MC_D_EN			: out std_logic
	      );
	end component WF_SD_CARD;

	component dcfifo0 
		PORT (
			aclr			: IN STD_LOGIC ;
			data			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdclk			: IN STD_LOGIC ;
			rdreq			: IN STD_LOGIC ;
			wrclk			: IN STD_LOGIC ;
			wrreq			: IN STD_LOGIC ;
			q				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			wrusedw			: OUT STD_LOGIC_VECTOR (9 DOWNTO 0) 
	);
	end component dcfifo0;
	
	component dcfifo1
		PORT (
			aclr			: IN STD_LOGIC ;
			data			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			rdclk			: IN STD_LOGIC ;
			rdreq			: IN STD_LOGIC ;
			wrclk			: IN STD_LOGIC ;
			wrreq			: IN STD_LOGIC ;
			q				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdusedw			: OUT STD_LOGIC_VECTOR (9 DOWNTO 0) 
		);
	end component;


end FalconIO_SDCard_IDE_CF_PKG;
