LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.vcomponents.ALL;
USE work.custom_types_pkg.ALL;

ENTITY final_project_top IS
	PORT (
		clk : IN STD_LOGIC;
		left_btn : IN STD_LOGIC;
		right_btn : IN STD_LOGIC;
		place_btn : IN STD_LOGIC;
		pwr : OUT STD_LOGIC;
		tx : OUT STD_LOGIC;
		red : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		green : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		blue : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		hsync : OUT STD_LOGIC;
		vsync : OUT STD_LOGIC
	);
END final_project_top;

ARCHITECTURE arch OF final_project_top IS
	COMPONENT logic IS
		PORT (
			clk : IN STD_LOGIC;
			left_btn : IN STD_LOGIC;
			right_btn : IN STD_LOGIC;
			place_btn : IN STD_LOGIC;
			board : OUT board_type;
			col_selected : OUT INTEGER;
			current_game_state : OUT game_state
		);
	END COMPONENT;

	COMPONENT vga IS
		PORT (
			clk : IN STD_LOGIC;
			board : IN board_type; -- pipeling this stage?
			current_game_state : IN game_state;
			col_selected : IN INTEGER;
			tx : OUT STD_LOGIC;
			red : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			green : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			blue : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			hsync : OUT STD_LOGIC;
			vsync : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT button IS 
		PORT (
			clk:   in  std_logic;
			btn_i: in std_logic;
    	btn_o: out std_logic;
			level_o : out std_logic
		);
	END COMPONENT;

	SIGNAL board : board_type;
	SIGNAL current_game_state : game_state;

	SIGNAL clkfb : STD_LOGIC;
	SIGNAL clkfx : STD_LOGIC;
	SIGNAL col_selected : INTEGER;

	SIGNAL left_btn_o_sig : STD_LOGIC;
	SIGNAL right_btn_o_sig : STD_LOGIC;
	SIGNAL place_btn_o_sig : STD_LOGIC;

BEGIN
	pwr <= '1';
	------------------------------------------------------------------`
	-- Clock management tile
	--
	-- Input clock: 12 MHz
	-- Output clock: 25.2 MHz -> VGA clk!
	--
	-- CLKFBOUT_MULT_F: 50.875
	-- CLKOUT0_DIVIDE_F: 24.250
	-- DIVCLK_DIVIDE: 1
	------------------------------------------------------------------
	cmt : MMCME2_BASE GENERIC MAP(
		-- Jitter programming (OPTIMIZED, HIGH, LOW)
		BANDWIDTH => "OPTIMIZED",
		-- Multiply value for all CLKOUT (2.000-64.000).
		CLKFBOUT_MULT_F => 50.875,
		-- Phase offset in degrees of CLKFB (-360.000-360.000).
		CLKFBOUT_PHASE => 0.0,
		-- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
		CLKIN1_PERIOD => 83.333,
		-- Divide amount for each CLKOUT (1-128)
		CLKOUT1_DIVIDE => 1,
		CLKOUT2_DIVIDE => 1,
		CLKOUT3_DIVIDE => 1,
		CLKOUT4_DIVIDE => 1,
		CLKOUT5_DIVIDE => 1,
		CLKOUT6_DIVIDE => 1,
		-- Divide amount for CLKOUT0 (1.000-128.000):
		CLKOUT0_DIVIDE_F => 24.250,
		-- Duty cycle for each CLKOUT (0.01-0.99):
		CLKOUT0_DUTY_CYCLE => 0.5,
		CLKOUT1_DUTY_CYCLE => 0.5,
		CLKOUT2_DUTY_CYCLE => 0.5,
		CLKOUT3_DUTY_CYCLE => 0.5,
		CLKOUT4_DUTY_CYCLE => 0.5,
		CLKOUT5_DUTY_CYCLE => 0.5,
		CLKOUT6_DUTY_CYCLE => 0.5,
		-- Phase offset for each CLKOUT (-360.000-360.000):
		CLKOUT0_PHASE => 0.0,
		CLKOUT1_PHASE => 0.0,
		CLKOUT2_PHASE => 0.0,
		CLKOUT3_PHASE => 0.0,
		CLKOUT4_PHASE => 0.0,
		CLKOUT5_PHASE => 0.0,
		CLKOUT6_PHASE => 0.0,
		-- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
		CLKOUT4_CASCADE => FALSE,
		-- Master division value (1-106)
		DIVCLK_DIVIDE => 1,
		-- Reference input jitter in UI (0.000-0.999).
		REF_JITTER1 => 0.0,
		-- Delays DONE until MMCM is locked (FALSE, TRUE)
		STARTUP_WAIT => FALSE
		) PORT MAP (
		-- User Configurable Clock Outputs:
		CLKOUT0 => clkfx, -- 1-bit output: CLKOUT0
		CLKOUT0B => OPEN, -- 1-bit output: Inverted CLKOUT0
		CLKOUT1 => OPEN, -- 1-bit output: CLKOUT1
		CLKOUT1B => OPEN, -- 1-bit output: Inverted CLKOUT1
		CLKOUT2 => OPEN, -- 1-bit output: CLKOUT2
		CLKOUT2B => OPEN, -- 1-bit output: Inverted CLKOUT2
		CLKOUT3 => OPEN, -- 1-bit output: CLKOUT3
		CLKOUT3B => OPEN, -- 1-bit output: Inverted CLKOUT3
		CLKOUT4 => OPEN, -- 1-bit output: CLKOUT4
		CLKOUT5 => OPEN, -- 1-bit output: CLKOUT5
		CLKOUT6 => OPEN, -- 1-bit output: CLKOUT6
		-- Clock Feedback Output Ports:
		CLKFBOUT => clkfb, -- 1-bit output: Feedback clock
		CLKFBOUTB => OPEN, -- 1-bit output: Inverted CLKFBOUT
		-- MMCM Status Ports:
		LOCKED => OPEN, -- 1-bit output: LOCK
		-- Clock Input:
		CLKIN1 => clk, -- 1-bit input: Clock
		-- MMCM Control Ports:
		PWRDWN => '0', -- 1-bit input: Power-down
		RST => '0', -- 1-bit input: Reset
		-- Clock Feedback Input Port:
		CLKFBIN => clkfb -- 1-bit input: Feedback clock
	);
	left_btn_module : button PORT MAP(
		clk => clkfx,
		btn_i => left_btn,
		btn_o => left_btn_o_sig,
		level_o => open
	);

	right_btn_module : button PORT MAP(
		clk => clkfx,
		btn_i => right_btn,
		btn_o => right_btn_o_sig,
		level_o => open
	);

	place_btn_module : button PORT MAP(
		clk => clkfx,
		btn_i => place_btn,
		btn_o => place_btn_o_sig,
		level_o => open
	);

	logic_module : logic PORT MAP(
		clk => clkfx,
		left_btn => left_btn_o_sig,
		right_btn => right_btn_o_sig,
		place_btn => place_btn_o_sig,
		board => board,
		col_selected => col_selected,
		current_game_state => current_game_state
	);

	vga_module : vga PORT MAP(
		clk => clkfx,
		board => board,
		col_selected => col_selected,
		current_game_state => current_game_state,
		tx => tx,
		red => red,
		green => green,
		blue => blue,
		hsync => hsync,
		vsync => vsync
	);
END arch;