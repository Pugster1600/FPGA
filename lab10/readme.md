## part A
mutlicycle path constraint
we are using a counter for this part of the assimgnet
the upper 2 bits are connected to the LED so that the synthesizer does not optimize this stuff away

the constant $\texttt{bits}$ is used to define the number of bits in the counter

There is a toggle flipflop to generate a clock enable signal


1. number of bits before it fails
## part B
input and output constraints



## part C
placement constraints

indexing into the array
- the first x0y0 is them right next to each other
x65 is all the way right
y165 is all the way up

constraints
--------
part1
1. find clock period pass timing at 6 bits
2. keep that clock timing then increase it to how much as possible 
3. multipath show the ports -> it is all of the led ports stuff

part2
1. max output delay for tx
2. min output delay for tx
3. max input delay for rx
4. min input delay for rx

part3
- min period right next to each other
- 

MAKE R HP << R_LOWPASS so that they minimize interaction as per the impedance rules
-> this is since the impedances actually mess with each other
- the smaller the imepdnace since the things are in parallel as per combing impedances, the smaller one over powers
- so its as seen from the input of the filter

4. Testing in practice

Build the circuit and measure with a function generator + oscilloscope.

Sweep the input frequency and watch when the output drops by ~3 dB → that’s your real cutoff.

Adjust R or C accordingly:

If cutoff is too low → reduce R or C

If cutoff is too high → increase R or C

6. Consider parasitic effects

PCB traces, op-amp input impedance, and wiring capacitance can shift your cutoff slightly.

For high frequencies (>1 kHz), keep wiring short and avoid large parasitic capacitances.
-----------------------------------
in veirlog the name of the module is derived form the file name
- htis is because there is no entity declaration in verilog

FIR filter implementation
- like understandign the pipelined thing with the various input parameters 
- like the combinatoric circuit required and stuff
- 

-----------------------
Your brain says:

Compute zone

Compute dx/dy

Decide color

Output color

FPGA says:

“All of these are happening at the same time unless you add registers.”

That's why proper pipeline stages matter.

For VGA-like systems:

Compute row/col FIRST, then dx/dy, then color assignment.

Only register what needs temporal history.
-- anything that you need the past information of!!!

make sure to bound the integer range


DRAW THE PIPELINE STAGES!!!
- 3 stage pipeline or something
-- need to also delay the vga stuff

if you are only using the data one time and you do not need it in the future, then use combinational logic

3. When do you need a register?

Ask yourself:

❓ Does this value need to be remembered in the next cycle?

→ If YES → register it.
→ If NO → combinational is fine.

❓ Will this combinational path be too long for timing?

→ If YES → break it with a register.
→ If NO → combinational is fine.

❓ Is this part of a pipeline?

→ If YES → register it.

❓ Is this value used to generate a pixel in sync with VGA timing?

→ If YES → register the inputs (hcount/vcount)
→ You may register the output too, as long as the pipeline stages match.
---------------------------
PIPELINE DESIGN

current_pixel -> dx,dy -> circle
-> 3 stage pipeline, so need to delay by 2 clk cycles

hcount -> hcount1 -> hcount2

register everything used down the stream

-- you have something you want to do ie high level
-- if you dont konw how to translate that to hdl then just ai

-- avoid unneeded registered logic to make pipelining stuff way easier
-- like this only changes every like 32 clk cycles
-- THINK IN PIPELINES NOT IN CODE ORDER EXECUTION (ie rather than sequential logic, think of everything in parallel and stages getting pipelined)
-- “Registers update at the clock. The right-hand side reads old values.”
-- avoid expensive operations unless constant
-- deafult assignment always
-- dx <= circle_center_lookup(current_row, current_col)(COORDINATE_COL_INDEX) - to_integer(hcount);-- col aka hcount
-- dy <= circle_center_lookup(current_row, current_col)(COORDINATE_ROW_INDEX) - to_integer(vcount);-- row aka vcount

-- process to update the grid placements aka logic.vhd
-- you can compute position completely in the clk cycle but that might be too long
-- or you can pipeline ie just delay by a bit

-- combinational stuff -> pipeline bug here, need to make sure you are using the appropriate current_row and col values
-- its fine if delayed by a second as long as the values used are right
-- solution: use variables instead ie combinational logic before the clk
-- dx <= circle_center_lookup(current_row, current_col)(COORDINATE_COL_INDEX) - to_integer(hcount);-- col aka hcount
-- dy <= circle_center_lookup(current_row, current_col)(COORDINATE_ROW_INDEX) - to_integer(vcount);-- row aka vcount
-- pipeline ordering is very important -> determine the pipeline order and stick with it

	-- since each section is 32 bits wide, this is just shift by 5 bits
	-- also, division is costly only if the divisor is a variable
	-- if it is not a variable then it is actually quite cheap to implement
	-- so can do a comparision chain like if divisor is 30, then 0-29, 30-59 are all sections


  ------------------------
  library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;
use work.custom_types_pkg.all;

entity vga is
	port(
		clk:   in    std_logic;
		board: in 	 board_type; -- pipeling this stage?
		current_game_state: in game_state;
		tx:    out   std_logic;
		red:   out   std_logic_vector(1 downto 0);
		green: out   std_logic_vector(1 downto 0);
		blue:  out   std_logic_vector(1 downto 0);
		hsync: out   std_logic;
		vsync: out   std_logic
	);
end vga;

architecture arch of vga is
	signal clkfb:    std_logic;
	signal clkfx:    std_logic;
	signal hcount:   unsigned(9 downto 0);
	signal vcount:   unsigned(9 downto 0);
	signal blank:    std_logic;
	signal frame:    std_logic;
	signal obj1_red: std_logic_vector(1 downto 0);
	signal obj1_grn: std_logic_vector(1 downto 0);
	signal obj1_blu: std_logic_vector(1 downto 0);
	signal dx : integer := 0;
	signal dy : integer := 0;

	signal dx_squared : integer := 0;
	signal dy_squared : integer := 0;

	constant ROWS : integer := 15; --15 * 32 = 480
  constant COLS : integer := 20; -- 20 * 32 = 640
	constant RADIUS : integer := 12; -- integers are unsigned by default
	constant SLOT_SIZE : integer := 32;
	constant SLOT_CENTER : integer := 16; -- 32/2 = 16
	constant RADIUS_SQUARED : integer := RADIUS * RADIUS; --avoid using square root which is very expensive
	constant COORDINATE_ROW_INDEX : integer := 1; --row, col aka b1, b0
	constant COORDINATE_COL_INDEX : integer := 0;

	function init_circle_center return circle_center_type is
    variable t : circle_center_type;
		begin
		    for i in 0 to ROWS - 1 loop
		        for j in 0 to COLS - 1 loop
								t(i, j)(COORDINATE_ROW_INDEX) := i * SLOT_SIZE + SLOT_CENTER;  -- row: row, col 
		            t(i, j)(COORDINATE_COL_INDEX) := j * SLOT_SIZE + SLOT_CENTER;  -- col: row, col
		        end loop;
		    end loop;
		    return t;
		end function;

	function init_board return board_type is
    variable t : board_type;
		begin
		    for i in 0 to ROWS - 1 loop
		        for j in 0 to COLS - 1 loop
								if i rem 2 = 0 then -- std_logic_vector(to_unsigned(i, 5))(0) = '0' then --check if even or odd
									t(i, j) := RED_PIECE; 
								else 
									t(i, j) := BLUE_PIECE; 
								end if;
		        end loop;
		    end loop;
		    return t;
		end function;

	--constant board: board_type := init_board;
	--constant current_game_state : game_state := in_progress_state;

	--signal board : board_type := (others => (others => EMPTY)); --initialize to empty

	signal current_row0 : integer := 0;
	signal current_col0 : integer := 0;
	signal current_row1 : integer := 0;
	signal current_col1 : integer := 0;
	signal current_row2 : integer := 0;
	signal current_col2 : integer := 0;
	signal current_row3 : integer := 0;
	signal current_col3 : integer := 0;

	signal current_row_section_pixel0 : integer := 0;
	signal current_col_section_pixel0 : integer := 0;

	signal circle_center_lookup : circle_center_type := init_circle_center;
	signal center : integer := 0;

	signal is_in_range : std_logic := '0';

	signal hcount1 : unsigned(9 downto 0);
	signal vcount1 : unsigned(9 downto 0);

	signal frame_pipeline : std_logic_vector(3 downto 0) := (others => '0');


begin
	tx<='1';

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
	cmt: MMCME2_BASE generic map (
		-- Jitter programming (OPTIMIZED, HIGH, LOW)
		BANDWIDTH=>"OPTIMIZED",
		-- Multiply value for all CLKOUT (2.000-64.000).
		CLKFBOUT_MULT_F=>50.875,
		-- Phase offset in degrees of CLKFB (-360.000-360.000).
		CLKFBOUT_PHASE=>0.0,
		-- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
		CLKIN1_PERIOD=>83.333,
		-- Divide amount for each CLKOUT (1-128)
		CLKOUT1_DIVIDE=>1,
		CLKOUT2_DIVIDE=>1,
		CLKOUT3_DIVIDE=>1,
		CLKOUT4_DIVIDE=>1,
		CLKOUT5_DIVIDE=>1,
		CLKOUT6_DIVIDE=>1,
		-- Divide amount for CLKOUT0 (1.000-128.000):
		CLKOUT0_DIVIDE_F=>24.250,
		-- Duty cycle for each CLKOUT (0.01-0.99):
		CLKOUT0_DUTY_CYCLE=>0.5,
		CLKOUT1_DUTY_CYCLE=>0.5,
		CLKOUT2_DUTY_CYCLE=>0.5,
		CLKOUT3_DUTY_CYCLE=>0.5,
		CLKOUT4_DUTY_CYCLE=>0.5,
		CLKOUT5_DUTY_CYCLE=>0.5,
		CLKOUT6_DUTY_CYCLE=>0.5,
		-- Phase offset for each CLKOUT (-360.000-360.000):
		CLKOUT0_PHASE=>0.0,
		CLKOUT1_PHASE=>0.0,
		CLKOUT2_PHASE=>0.0,
		CLKOUT3_PHASE=>0.0,
		CLKOUT4_PHASE=>0.0,
		CLKOUT5_PHASE=>0.0,
		CLKOUT6_PHASE=>0.0,
		-- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
		CLKOUT4_CASCADE=>FALSE,
		-- Master division value (1-106)
		DIVCLK_DIVIDE=>1,
		-- Reference input jitter in UI (0.000-0.999).
		REF_JITTER1=>0.0,
		-- Delays DONE until MMCM is locked (FALSE, TRUE)
		STARTUP_WAIT=>FALSE
	) port map (
		-- User Configurable Clock Outputs:
		CLKOUT0=>clkfx,  -- 1-bit output: CLKOUT0
		CLKOUT0B=>open,  -- 1-bit output: Inverted CLKOUT0
		CLKOUT1=>open,   -- 1-bit output: CLKOUT1
		CLKOUT1B=>open,  -- 1-bit output: Inverted CLKOUT1
		CLKOUT2=>open,   -- 1-bit output: CLKOUT2
		CLKOUT2B=>open,  -- 1-bit output: Inverted CLKOUT2
		CLKOUT3=>open,   -- 1-bit output: CLKOUT3
		CLKOUT3B=>open,  -- 1-bit output: Inverted CLKOUT3
		CLKOUT4=>open,   -- 1-bit output: CLKOUT4
		CLKOUT5=>open,   -- 1-bit output: CLKOUT5
		CLKOUT6=>open,   -- 1-bit output: CLKOUT6
		-- Clock Feedback Output Ports:
		CLKFBOUT=>clkfb,-- 1-bit output: Feedback clock
		CLKFBOUTB=>open, -- 1-bit output: Inverted CLKFBOUT
		-- MMCM Status Ports:
		LOCKED=>open,    -- 1-bit output: LOCK
		-- Clock Input:
		CLKIN1=>clk,   -- 1-bit input: Clock
		-- MMCM Control Ports:
		PWRDWN=>'0',     -- 1-bit input: Power-down
		RST=>'0',        -- 1-bit input: Reset
		-- Clock Feedback Input Port:
		CLKFBIN=>clkfb  -- 1-bit input: Feedback clock
	);

	------------------------------------------------------------------
	-- VGA display counters
	--
	-- Pixel clock: 25.175 MHz (actual: 25.2 MHz)
	-- Horizontal count (active low sync):
	--     0 to 639: Active video
	--     640 to 799: Horizontal blank
	--     656 to 751: Horizontal sync (active low)
	-- Vertical count (active low sync):
	--     0 to 479: Active video
	--     480 to 524: Vertical blank
	--     490 to 491: Vertical sync (active low)
	------------------------------------------------------------------
	process(clkfx)
	begin
    --keeping track of current pixel since everything is based on the clock
    -- NOTE: hcount and vcount already gives us the appropriate positions -> they already take into account the deadtime and actually tell us where we are 
		if rising_edge(clkfx) then
			-- Pixel position counters
			if (hcount>=to_unsigned(799,10)) then --each row takes 800 pixels = front porch + pixels per row + back porch + hsync pulse  (end of row)
				hcount<=(others=>'0');
				if (vcount>=to_unsigned(524,10)) then --vertically speaking, 33 row front pixel, 480 row vertical video, 10 row back port and 2row vsync = 525 rows = 60 hz -> vertical timing is per frame since that is which row are we on?
					vcount<=(others=>'0'); --31.5k pixels for each row that can be completed aka hcount/ vcount reset that takes 525 rows = 60hz (end of frame)
				else --vccount takes more time to readjust beam than hcount just per the standard
					vcount<=vcount+1;
				end if;
			else
				hcount<=hcount+1;
			end if;
			-- Sync, blank and frame
			if (hcount>=to_unsigned(656,10)) and
				(hcount<=to_unsigned(751,10)) then --
				hsync<='0';
			else
				hsync<='1';
			end if;
			if (vcount>=to_unsigned(490,10)) and
				(vcount<=to_unsigned(491,10)) then
				vsync<='0';
			else
				vsync<='1';
			end if;
			if (hcount>=to_unsigned(640,10)) or
				(vcount>=to_unsigned(480,10)) then
				blank<='1';
			else
				blank<='0';
			end if;
			if (hcount=to_unsigned(640,10)) and
				(vcount=to_unsigned(479,10)) then
				frame<='1';
			else
				frame<='0';
			end if;
		end if;
	end process;

	------------------------------------------------------------------
	-- VGA output with blanking
	------------------------------------------------------------------
	red<=b"00" when blank='1' else obj1_red; --blank = 0 means output pixels, 1 means dont output pixel ie during the dead time
	green<=b"00" when blank='1' else obj1_grn;
	blue<=b"00" when blank='1' else obj1_blu;

grid_update : process(clkfx)
begin
  -- saying that when this is the current pixel, make obj1_red, obj1_grn etc
  if rising_edge(clkfx) then 
    --1. UPDATE PIXELS:  this means frame is done so we can update the pixels again
    if frame = '1' then
			null;
		end if;
  end if;
end process;

-- stage 1 pipeline
pipeline_1 : process(clkfx)
begin
	if rising_edge(clkfx) then
		current_row0 <= to_integer(vcount) / SLOT_SIZE; -- to_integer(shift_right(vcount, 5)); optimized to shift right by 5 
		current_col0 <= to_integer(hcount) / SLOT_SIZE;
		hcount1 <= hcount;
		vcount1 <= vcount;
		frame_pipeline(0) <= frame;
	end if;
end process;

-- stage 2 pipeline
pipeline_2 : process(clkfx)
begin
	if rising_edge(clkfx) then
		dx <= circle_center_lookup(current_row0, current_col0)(COORDINATE_COL_INDEX) - to_integer(hcount1);-- col aka hcount
		dy <= circle_center_lookup(current_row0, current_col0)(COORDINATE_ROW_INDEX) - to_integer(vcount1);-- row aka vcount
		current_row1 <= current_row0;
		current_col1 <= current_col0;
		frame_pipeline(1) <= frame_pipeline(0);
	end if;
end process;

-- stage 3 pipeline
pipeline_3 : process(clkfx)
begin
	if rising_edge(clkfx) then
		current_row2 <= current_row1;
		current_col2 <= current_col1;
		frame_pipeline(2) <= frame_pipeline(1);

		dx_squared <= dx * dx;
		dy_squared <= dy * dy;
	end if;
end process;

-- stage 4 pipeline
pipeline_4 : process(clkfx)
begin
	if rising_edge(clk) then
		current_row3 <= current_row2;
		current_col3 <= current_col2;
		frame_pipeline(3) <= frame_pipeline(2);

		if dx_squared + dy_squared < RADIUS_SQUARED then
			is_in_range <= '1';
		else
			is_in_range <= '0';
		end if;
	end if;
end process;

-- stage 5 pipeline: output of stage 3 feeds into input of stage 4
pipeline_5 : process (clkfx)
begin
	if rising_edge(clkfx) then
		-- 2. DRAW PIXELS: this means we are at a certain pixel so we can draw it if needed
		if frame_pipeline(3) = '0' then
			-- default behavior
			obj1_red <= "00";
  	  obj1_grn <= "00";
  	  obj1_blu <= "00";
			case current_game_state is
				when START_STATE =>
					obj1_red <= "00";
  	    	obj1_grn <= "11";
  	    	obj1_blu <= "00";
				when IN_PROGRESS_STATE =>
					case board(current_row3, current_col3) is
						when RED_PIECE =>
							-- if within range ie r**2 - (dx**2 + dy**2) > 0
							if is_in_range = '1' then
								obj1_red <= "11";
  	    				obj1_grn <= "00";
  	    				obj1_blu <= "00";
							end if;

						when BLUE_PIECE =>
							if is_in_range = '1' then
								obj1_red <= "00";
  	    				obj1_grn <= "00";
  	    				obj1_blu <= "11";
							end if;

						when EMPTY =>
							null;

						when others =>
							null;

					end case;

				when BLUE_WIN_STATE =>
					-- place holder
					obj1_red <= "00";
  	    	obj1_grn <= "00";
  	    	obj1_blu <= "11";

				when RED_WIN_STATE =>
					-- place holder
					obj1_red <= "11";
  	    	obj1_grn <= "00";
  	    	obj1_blu <= "00";

				when TIE_STATE =>
				-- place holder
					obj1_red <= "11";
  	    	obj1_grn <= "11";
  	    	obj1_blu <= "11";
				
				when others =>
					null;
				end case;
				
  	end if;
	end if;
end process;
end arch;

----------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;
use work.custom_types_pkg.all;

entity vga is
	port(
		clk:   in    std_logic;
		board: in 	 board_type; -- pipeling this stage?
		current_game_state: in game_state;
		tx:    out   std_logic;
		red:   out   std_logic_vector(1 downto 0);
		green: out   std_logic_vector(1 downto 0);
		blue:  out   std_logic_vector(1 downto 0);
		hsync: out   std_logic;
		vsync: out   std_logic
	);
end vga;

architecture arch of vga is
	signal clkfb:    std_logic;
	signal clkfx:    std_logic;
	signal hcount:   unsigned(9 downto 0);
	signal vcount:   unsigned(9 downto 0);
	signal blank:    std_logic;
	signal frame:    std_logic;
	signal obj1_red: std_logic_vector(1 downto 0);
	signal obj1_grn: std_logic_vector(1 downto 0);
	signal obj1_blu: std_logic_vector(1 downto 0);
	signal dx : integer := 0;
	signal dy : integer := 0;

	constant ROWS : integer := 15; --15 * 32 = 480
  constant COLS : integer := 20; -- 20 * 32 = 640
	constant RADIUS : integer := 12; -- integers are unsigned by default
	constant SLOT_SIZE : integer := 32;
	constant SLOT_CENTER : integer := 16; -- 32/2 = 16
	constant RADIUS_SQUARED : integer := RADIUS * RADIUS; --avoid using square root which is very expensive
	constant COORDINATE_ROW_INDEX : integer := 1; --row, col aka b1, b0
	constant COORDINATE_COL_INDEX : integer := 0;

	function init_circle_center return circle_center_type is
    variable t : circle_center_type;
		begin
		    for i in 0 to ROWS - 1 loop
		        for j in 0 to COLS - 1 loop
								t(i, j)(COORDINATE_ROW_INDEX) := i * SLOT_SIZE + SLOT_CENTER;  -- row: row, col 
		            t(i, j)(COORDINATE_COL_INDEX) := j * SLOT_SIZE + SLOT_CENTER;  -- col: row, col
		        end loop;
		    end loop;
		    return t;
		end function;

	function init_board return board_type is
    variable t : board_type;
		begin
		    for i in 0 to ROWS - 1 loop
		        for j in 0 to COLS - 1 loop
								if i rem 2 = 0 then -- std_logic_vector(to_unsigned(i, 5))(0) = '0' then --check if even or odd
									t(i, j) := RED_PIECE; 
								else 
									t(i, j) := BLUE_PIECE; 
								end if;
		        end loop;
		    end loop;
		    return t;
		end function;

	--constant board: board_type := init_board;
	--constant current_game_state : game_state := in_progress_state;

	--signal board : board_type := (others => (others => EMPTY)); --initialize to empty

	signal current_row0 : integer := 0;
	signal current_col0 : integer := 0;
	signal current_row1 : integer := 0;
	signal current_col1 : integer := 0;
	signal current_row2 : integer := 0;
	signal current_col2 : integer := 0;

	signal current_row_section_pixel0 : integer := 0;
	signal current_col_section_pixel0 : integer := 0;

	signal circle_center_lookup : circle_center_type := init_circle_center;
	signal center : integer := 0;

	signal is_in_range : std_logic := '0';

	signal hcount1 : unsigned(9 downto 0);
	signal vcount1 : unsigned(9 downto 0);

	signal frame_pipeline : std_logic_vector(3 downto 0) := (others => '0');


begin
	tx<='1';

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
	cmt: MMCME2_BASE generic map (
		-- Jitter programming (OPTIMIZED, HIGH, LOW)
		BANDWIDTH=>"OPTIMIZED",
		-- Multiply value for all CLKOUT (2.000-64.000).
		CLKFBOUT_MULT_F=>50.875,
		-- Phase offset in degrees of CLKFB (-360.000-360.000).
		CLKFBOUT_PHASE=>0.0,
		-- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
		CLKIN1_PERIOD=>83.333,
		-- Divide amount for each CLKOUT (1-128)
		CLKOUT1_DIVIDE=>1,
		CLKOUT2_DIVIDE=>1,
		CLKOUT3_DIVIDE=>1,
		CLKOUT4_DIVIDE=>1,
		CLKOUT5_DIVIDE=>1,
		CLKOUT6_DIVIDE=>1,
		-- Divide amount for CLKOUT0 (1.000-128.000):
		CLKOUT0_DIVIDE_F=>24.250,
		-- Duty cycle for each CLKOUT (0.01-0.99):
		CLKOUT0_DUTY_CYCLE=>0.5,
		CLKOUT1_DUTY_CYCLE=>0.5,
		CLKOUT2_DUTY_CYCLE=>0.5,
		CLKOUT3_DUTY_CYCLE=>0.5,
		CLKOUT4_DUTY_CYCLE=>0.5,
		CLKOUT5_DUTY_CYCLE=>0.5,
		CLKOUT6_DUTY_CYCLE=>0.5,
		-- Phase offset for each CLKOUT (-360.000-360.000):
		CLKOUT0_PHASE=>0.0,
		CLKOUT1_PHASE=>0.0,
		CLKOUT2_PHASE=>0.0,
		CLKOUT3_PHASE=>0.0,
		CLKOUT4_PHASE=>0.0,
		CLKOUT5_PHASE=>0.0,
		CLKOUT6_PHASE=>0.0,
		-- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
		CLKOUT4_CASCADE=>FALSE,
		-- Master division value (1-106)
		DIVCLK_DIVIDE=>1,
		-- Reference input jitter in UI (0.000-0.999).
		REF_JITTER1=>0.0,
		-- Delays DONE until MMCM is locked (FALSE, TRUE)
		STARTUP_WAIT=>FALSE
	) port map (
		-- User Configurable Clock Outputs:
		CLKOUT0=>clkfx,  -- 1-bit output: CLKOUT0
		CLKOUT0B=>open,  -- 1-bit output: Inverted CLKOUT0
		CLKOUT1=>open,   -- 1-bit output: CLKOUT1
		CLKOUT1B=>open,  -- 1-bit output: Inverted CLKOUT1
		CLKOUT2=>open,   -- 1-bit output: CLKOUT2
		CLKOUT2B=>open,  -- 1-bit output: Inverted CLKOUT2
		CLKOUT3=>open,   -- 1-bit output: CLKOUT3
		CLKOUT3B=>open,  -- 1-bit output: Inverted CLKOUT3
		CLKOUT4=>open,   -- 1-bit output: CLKOUT4
		CLKOUT5=>open,   -- 1-bit output: CLKOUT5
		CLKOUT6=>open,   -- 1-bit output: CLKOUT6
		-- Clock Feedback Output Ports:
		CLKFBOUT=>clkfb,-- 1-bit output: Feedback clock
		CLKFBOUTB=>open, -- 1-bit output: Inverted CLKFBOUT
		-- MMCM Status Ports:
		LOCKED=>open,    -- 1-bit output: LOCK
		-- Clock Input:
		CLKIN1=>clk,   -- 1-bit input: Clock
		-- MMCM Control Ports:
		PWRDWN=>'0',     -- 1-bit input: Power-down
		RST=>'0',        -- 1-bit input: Reset
		-- Clock Feedback Input Port:
		CLKFBIN=>clkfb  -- 1-bit input: Feedback clock
	);

	------------------------------------------------------------------
	-- VGA display counters
	--
	-- Pixel clock: 25.175 MHz (actual: 25.2 MHz)
	-- Horizontal count (active low sync):
	--     0 to 639: Active video
	--     640 to 799: Horizontal blank
	--     656 to 751: Horizontal sync (active low)
	-- Vertical count (active low sync):
	--     0 to 479: Active video
	--     480 to 524: Vertical blank
	--     490 to 491: Vertical sync (active low)
	------------------------------------------------------------------
	process(clkfx)
	begin
    --keeping track of current pixel since everything is based on the clock
    -- NOTE: hcount and vcount already gives us the appropriate positions -> they already take into account the deadtime and actually tell us where we are 
		if rising_edge(clkfx) then
			-- Pixel position counters
			if (hcount>=to_unsigned(799,10)) then --each row takes 800 pixels = front porch + pixels per row + back porch + hsync pulse  (end of row)
				hcount<=(others=>'0');
				if (vcount>=to_unsigned(524,10)) then --vertically speaking, 33 row front pixel, 480 row vertical video, 10 row back port and 2row vsync = 525 rows = 60 hz -> vertical timing is per frame since that is which row are we on?
					vcount<=(others=>'0'); --31.5k pixels for each row that can be completed aka hcount/ vcount reset that takes 525 rows = 60hz (end of frame)
				else --vccount takes more time to readjust beam than hcount just per the standard
					vcount<=vcount+1;
				end if;
			else
				hcount<=hcount+1;
			end if;
			-- Sync, blank and frame
			if (hcount>=to_unsigned(656,10)) and
				(hcount<=to_unsigned(751,10)) then --
				hsync<='0';
			else
				hsync<='1';
			end if;
			if (vcount>=to_unsigned(490,10)) and
				(vcount<=to_unsigned(491,10)) then
				vsync<='0';
			else
				vsync<='1';
			end if;
			if (hcount>=to_unsigned(640,10)) or
				(vcount>=to_unsigned(480,10)) then
				blank<='1';
			else
				blank<='0';
			end if;
			if (hcount=to_unsigned(640,10)) and
				(vcount=to_unsigned(479,10)) then
				frame<='1';
			else
				frame<='0';
			end if;
		end if;
	end process;

	------------------------------------------------------------------
	-- VGA output with blanking
	------------------------------------------------------------------
	red<=b"00" when blank='1' else obj1_red; --blank = 0 means output pixels, 1 means dont output pixel ie during the dead time
	green<=b"00" when blank='1' else obj1_grn;
	blue<=b"00" when blank='1' else obj1_blu;

grid_update : process(clkfx)
begin
  -- saying that when this is the current pixel, make obj1_red, obj1_grn etc
  if rising_edge(clkfx) then 
    --1. UPDATE PIXELS:  this means frame is done so we can update the pixels again
    if frame = '1' then
			null;
		end if;
  end if;
end process;

-- stage 1 pipeline
pipeline_1 : process(clkfx)
begin
	if rising_edge(clkfx) then
		current_row0 <= to_integer(vcount) / SLOT_SIZE; -- to_integer(shift_right(vcount, 5)); optimized to shift right by 5 
		current_col0 <= to_integer(hcount) / SLOT_SIZE;
		hcount1 <= hcount;
		vcount1 <= vcount;
		frame_pipeline(0) <= frame;
	end if;
end process;

-- stage 2 pipeline
pipeline_2 : process(clkfx)
begin
	if rising_edge(clkfx) then
		dx <= circle_center_lookup(current_row0, current_col0)(COORDINATE_COL_INDEX) - to_integer(hcount1);-- col aka hcount
		dy <= circle_center_lookup(current_row0, current_col0)(COORDINATE_ROW_INDEX) - to_integer(vcount1);-- row aka vcount
		current_row1 <= current_row0;
		current_col1 <= current_col0;
		frame_pipeline(1) <= frame_pipeline(0);
	end if;
end process;

-- stage 3 pipeline
pipeline_3 : process(clkfx)
begin
	if rising_edge(clkfx) then
		current_row2 <= current_row1;
		current_col2 <= current_col1;
		frame_pipeline(2) <= frame_pipeline(1);
		if dx**2 + dy**2 < RADIUS_SQUARED then
			is_in_range <= '1';
		else
			is_in_range <= '0';
		end if;
	end if;
end process;

-- stage 4 pipeline: output of stage 3 feeds into input of stage 4
pipeline_4 : process (clkfx)
begin
	if rising_edge(clkfx) then
		-- 2. DRAW PIXELS: this means we are at a certain pixel so we can draw it if needed
		if frame_pipeline(2) = '0' then
			-- default behavior
			obj1_red <= "00";
  	  obj1_grn <= "00";
  	  obj1_blu <= "00";
			case current_game_state is
				when START_STATE =>
					obj1_red <= "00";
  	    	obj1_grn <= "11";
  	    	obj1_blu <= "00";
				when IN_PROGRESS_STATE =>
					case board(current_row2, current_col2) is
						when RED_PIECE =>
							-- if within range ie r**2 - (dx**2 + dy**2) > 0
							if is_in_range = '1' then
								obj1_red <= "11";
  	    				obj1_grn <= "00";
  	    				obj1_blu <= "00";
							end if;

						when BLUE_PIECE =>
							if is_in_range = '1' then
								obj1_red <= "00";
  	    				obj1_grn <= "00";
  	    				obj1_blu <= "11";
							end if;

						when EMPTY =>
							null;

						when others =>
							null;

					end case;

				when BLUE_WIN_STATE =>
					-- place holder
					obj1_red <= "00";
  	    	obj1_grn <= "00";
  	    	obj1_blu <= "11";

				when RED_WIN_STATE =>
					-- place holder
					obj1_red <= "11";
  	    	obj1_grn <= "00";
  	    	obj1_blu <= "00";

				when TIE_STATE =>
				-- place holder
					obj1_red <= "11";
  	    	obj1_grn <= "11";
  	    	obj1_blu <= "11";
				
				when others =>
					null;
				end case;
				
  	end if;
	end if;
end process;
end arch;

pipelinig is like shifting in time by that any stages of clock ticks
- so if 3 stage pipeline, everything is just x(t-3)
- initiially, the later stages dont have anything
- but when they do its almost like we were just off by a bit!
- so its not actually a huge delay, just an initial 3 clk cycle delay

you can either change what you think is wrong to something else and see what happens
or you can change what you think is right to see if that is actually right 
- basically associate a certain part of you code with a certain action

with pipelining, make sure you konw what stage of a pipe each piece of code is in

is it fine if i use a gpio that just outputs high for 3.3V. I am using it purely to drive something logical nothign that requires too much current
- so need to check max current rating ie what can something draw max at 3.3V

in the tools memory part, this just means the flash storage chip
also, the mx25l
the l is NOT a "one" its an l

spix4 means quad spi so 4 data lines

file name is the .mcs aka the actual file that is being flashed to flash
- so this file is created basically just like the bitsream
- you will need to create it in the write memory configuration file part
- name it the same thing as the bit stream

----------------------------------------------------
you can sample the data line to make sure the data has stabilized!
- like you sent out the data 

NOTE: you can have a counter like this

if counter < threshold
	counter++
else
	state machine stuff

ALSO ALWAYS use metastability
