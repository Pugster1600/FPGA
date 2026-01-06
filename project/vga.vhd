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
		col_selected : in integer;
		tx:    out   std_logic;
		red:   out   std_logic_vector(1 downto 0);
		green: out   std_logic_vector(1 downto 0);
		blue:  out   std_logic_vector(1 downto 0);
		hsync: out   std_logic;
		vsync: out   std_logic
	);
end vga;

architecture arch of vga is
	-- Default signals from VGA Lab
	signal hcount:   unsigned(9 downto 0);
	signal vcount:   unsigned(9 downto 0);
	signal blank:    std_logic;
	signal frame:    std_logic;
	signal obj1_red: std_logic_vector(1 downto 0);
	signal obj1_grn: std_logic_vector(1 downto 0);
	signal obj1_blu: std_logic_vector(1 downto 0);

	-- circle calculations
	signal dx : integer := 0;
	signal dy : integer := 0;
	signal dx_squared : integer := 0;
	signal dy_squared : integer := 0;
	constant ROWS : integer := 15; --15 * 32 = 480
  constant COLS : integer := 20; -- 20 * 32 = 640
	constant RADIUS : integer := 12; -- integers are unsigned by default
	constant SLOT_SIZE : integer := 32;
	constant SLOT_CENTER : integer := 16; -- 32/2 = 16
	constant RADIUS_SQUARED : integer := RADIUS * RADIUS;
	constant COORDINATE_ROW_INDEX : integer := 1;
	constant COORDINATE_COL_INDEX : integer := 0;

	-- vga: sync pipelines
	signal hsync_pipe: std_logic_vector(5 downto 0);
	signal vsync_pipe: std_logic_vector(5 downto 0);
	signal hsync_sig : std_logic;
	signal vsync_sig : std_logic;

	-- vga: blank pipeline
	signal blank_pipe : std_logic_vector(5 downto 0);

	-- user current_column pipeline
	signal col_selected_pipe : integer_pipeline_array;

	-- board state pipeline
	signal board_pipe : board_pipe_t;

	-- row,col of pipelined pixel
	signal current_row_pipe : integer_pipeline_array;
	signal current_col_pipe : integer_pipeline_array;

	-- current pixel pipelines
	signal hcount_pipe : unsigned_pipeline_array;  
	signal vcount_pipe : unsigned_pipeline_array;

	-- frame pipe
	signal frame_pipe : std_logic_vector(3 downto 0) := (others => '0');

	-- game state pipe
	signal current_game_state_pipe : current_game_state_pipe_t;

	-- current piece pipeline
	signal current_piece_pipe : piece_pipe_t;

	function init_circle_center return circle_center_array is
    variable center_array : circle_center_array;
		begin
		    for i in 0 to ROWS - 1 loop
		        for j in 0 to COLS - 1 loop
								center_array(i, j)(COORDINATE_ROW_INDEX) := i * SLOT_SIZE + SLOT_CENTER;  -- row: row, col 
		            center_array(i, j)(COORDINATE_COL_INDEX) := j * SLOT_SIZE + SLOT_CENTER;  -- col: row, col
		        end loop;
		    end loop;
		    return center_array;
		end function;

	signal clkfx : std_logic;
	signal center_array : circle_center_array := init_circle_center;
	signal center : integer := 0;
	signal is_in_range : std_logic := '0';

function init_board_win return board_type is
    variable t : board_type;
begin
    -- initialize all cells to EMPTY
    for i in 0 to ROWS - 1 loop
        for j in 0 to COLS - 1 loop
            t(i,j) := EMPTY_PIECE;
        end loop;
    end loop;

    ----------------------------------------------------------------
    -- Clear "WIN" display on 15x20 grid (rows 0-14, cols 0-19)
    -- Letter height: rows 3-11 (9 rows tall)
    ----------------------------------------------------------------

    -- ===== W (columns 2-6) =====
    -- Left vertical stroke
    for r in 3 to 11 loop
        t(r,2) := BLUE_PIECE;
    end loop;
    
    -- Left diagonal (going down-right)
    t(9,3) := BLUE_PIECE;
    t(10,3) := BLUE_PIECE;
    t(11,4) := BLUE_PIECE;
    
    -- Right diagonal (going up-right)
    t(11,4) := BLUE_PIECE;
    t(10,5) := BLUE_PIECE;
    t(9,5) := BLUE_PIECE;
    
    -- Right vertical stroke
    for r in 3 to 11 loop
        t(r,6) := BLUE_PIECE;
    end loop;

    -- ===== I (columns 8-10) =====
    -- Top horizontal bar
    for c in 8 to 10 loop
        t(3,c) := BLUE_PIECE;
    end loop;
    
    -- Vertical center line
    for r in 4 to 10 loop
        t(r,9) := BLUE_PIECE;
    end loop;
    
    -- Bottom horizontal bar
    for c in 8 to 10 loop
        t(11,c) := BLUE_PIECE;
    end loop;

    -- ===== N (columns 12-16) =====
    -- Left vertical stroke
    for r in 3 to 11 loop
        t(r,12) := BLUE_PIECE;
    end loop;
    
    -- Diagonal connecting stroke
    t(4,13) := BLUE_PIECE;
    t(5,13) := BLUE_PIECE;
    t(6,14) := BLUE_PIECE;
    t(7,14) := BLUE_PIECE;
    t(8,15) := BLUE_PIECE;
    t(9,15) := BLUE_PIECE;
    
    -- Right vertical stroke
    for r in 3 to 11 loop
        t(r,16) := BLUE_PIECE;
    end loop;

    return t;
end function;

function init_board_tie return board_type is
    variable t : board_type;
begin
    -- initialize all cells to EMPTY
    for i in 0 to ROWS - 1 loop
        for j in 0 to COLS - 1 loop
            t(i,j) := EMPTY_PIECE;
        end loop;
    end loop;

    ----------------------------------------------------------------
    -- Larger, more centered "TIE" on 15x20 grid
    ----------------------------------------------------------------

    -- ===== T (columns 3-7) =====
    -- Top horizontal bar
    for c in 3 to 7 loop
        t(3,c) := BLUE_PIECE;
    end loop;
    -- Vertical line down the middle
    for r in 4 to 11 loop
        t(r,5) := BLUE_PIECE;
    end loop;

    -- ===== I (columns 9-10) =====
    -- Vertical line
    for r in 3 to 11 loop
        t(r,9) := BLUE_PIECE;
        t(r,10) := BLUE_PIECE;
    end loop;
    -- Top and bottom horizontal bars
    for c in 9 to 10 loop
        t(3,c) := BLUE_PIECE;  -- top
        t(11,c) := BLUE_PIECE; -- bottom
    end loop;

    -- ===== E (columns 12-16) =====
    -- Left vertical
    for r in 3 to 11 loop
        t(r,12) := BLUE_PIECE;
    end loop;
    -- Top horizontal
    for c in 12 to 16 loop
        t(3,c) := BLUE_PIECE;
    end loop;
    -- Middle horizontal
    for c in 12 to 15 loop
        t(7,c) := BLUE_PIECE;
    end loop;
    -- Bottom horizontal
    for c in 12 to 16 loop
        t(11,c) := BLUE_PIECE;
    end loop;

    return t;
end function;


	constant win_board : board_type := init_board_win;
	constant tie_board : board_type := init_board_tie;


begin
	-- place this on the outside or else you are missing one stage of the pipeline! -> draw it out and you will see
	--hsync <= hsync_pipe(5);
	--vsync <= vsync_pipe(5);
	tx<='1';
	clkfx <= clk;

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
				hsync_pipe(0)<='0';
			else
				hsync_pipe(0)<='1';
			end if;
			if (vcount>=to_unsigned(490,10)) and
				(vcount<=to_unsigned(491,10)) then
				vsync_pipe(0)<='0';
			else
				vsync_pipe(0)<='1';
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
	red<=b"00" when blank_pipe(3) ='1' else obj1_red; --blank = 0 means output pixels, 1 means dont output pixel ie during the dead time
	green<=b"00" when blank_pipe(3) ='1' else obj1_grn;
	blue<=b"00" when blank_pipe(3) ='1' else obj1_blu;

-- this also is for the final stage pipeline!
grid_update : process(clkfx)
begin
  -- saying that when this is the current pixel, make obj1_red, obj1_grn etc
  if rising_edge(clkfx) then 
    --1. only change current_game state in the frame section to not get cut up mid way!
		-- only latch the board when frame = '1'?
    if frame = '1' then
			board_pipe(0) <= board;
		end if;
  end if;
end process;

-- stage 1 pipeline
pipeline_1 : process(clkfx)
begin
	if rising_edge(clkfx) then
		current_row_pipe(0) <= to_integer(vcount) / SLOT_SIZE; -- to_integer(shift_right(vcount, 5)); optimized to shift right by 5 
		current_col_pipe(0) <= to_integer(hcount) / SLOT_SIZE;
		hcount_pipe(0) <= hcount;
		vcount_pipe(0) <= vcount;

		-- hsync and vsync stage 1 done by the vga process 
		-- board only gets locked in the pipeline process when frame = '1'
		frame_pipe(0) <= frame;
		col_selected_pipe(0) <= col_selected;
		blank_pipe(0) <= blank;
		current_game_state_pipe(0) <= current_game_state;
	end if;
end process;

-- stage 2 pipeline
pipeline_2 : process(clkfx)
begin
	if rising_edge(clkfx) then
		dx <= center_array(current_row_pipe(0), current_col_pipe(0))(COORDINATE_COL_INDEX) - to_integer(hcount_pipe(0));-- col aka hcount
		dy <= center_array(current_row_pipe(0), current_col_pipe(0))(COORDINATE_ROW_INDEX) - to_integer(vcount_pipe(0));-- row aka vcount
		current_row_pipe(1) <= current_row_pipe(0);
		current_col_pipe(1) <= current_col_pipe(0);
		current_piece_pipe(1) <= board_pipe(0)(current_row_pipe(0), current_col_pipe(0));

		frame_pipe(1) <= frame_pipe(0);
		hsync_pipe(1) <= hsync_pipe(0);
		vsync_pipe(1) <= vsync_pipe(0);
		col_selected_pipe(1) <= col_selected_pipe(0);
		blank_pipe(1) <= blank_pipe(0);
		current_game_state_pipe(1) <= current_game_state_pipe(0);
	end if;
end process;

-- stage 3 pipeline
pipeline_3 : process(clkfx)
begin
	if rising_edge(clkfx) then
		current_row_pipe(2) <= current_row_pipe(1);
		current_col_pipe(2) <= current_col_pipe(1);
		frame_pipe(2) <= frame_pipe(1);

		dx_squared <= dx * dx;
		dy_squared <= dy * dy;
		hsync_pipe(2) <= hsync_pipe(1);
		vsync_pipe(2) <= vsync_pipe(1);
		col_selected_pipe(2) <= col_selected_pipe(1);
		current_piece_pipe(2) <= current_piece_pipe(1);
		blank_pipe(2) <= blank_pipe(1);
		current_game_state_pipe(2) <= current_game_state_pipe(1);
	end if;
end process;

-- stage 4 pipeline
pipeline_4 : process(clkfx)
begin
	if rising_edge(clkfx) then
		current_row_pipe(3) <= current_row_pipe(2);
		current_col_pipe(3) <= current_col_pipe(2);
		frame_pipe(3) <= frame_pipe(2);
		hsync_pipe(3) <= hsync_pipe(2);
		vsync_pipe(3) <= vsync_pipe(2);
		col_selected_pipe(3) <= col_selected_pipe(2);
		current_piece_pipe(3) <= current_piece_pipe(2);
		blank_pipe(3) <= blank_pipe(2);
		current_game_state_pipe(3) <= current_game_state_pipe(2);

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
		hsync <= hsync_pipe(3);
		vsync <= vsync_pipe(3);
		if frame_pipe(3) = '0' then
			-- default behavior
			obj1_red <= "00";
  	  obj1_grn <= "00";
  	  obj1_blu <= "00";
			case current_game_state_pipe(3) is
				when BLUE_TURN_STATE | RED_TURN_STATE =>
					if current_col_pipe(3) = col_selected_pipe(3) and is_in_range = '0' then
						-- background color for the current column selected
						if current_game_state_pipe(3) = BLUE_TURN_STATE then
							obj1_red <= "00";
  	    			obj1_grn <= "00";
  	    			obj1_blu <= "10";
						else 
							obj1_red <= "00";
  	    			obj1_grn <= "10";
  	    			obj1_blu <= "00";
						end if;
					end if;

					case current_piece_pipe(3) is
						when RED_PIECE =>
							-- if within range ie r**2 - (dx**2 + dy**2) > 0
							if is_in_range = '1' then
								obj1_red <= "00";
  	    				obj1_grn <= "11";
  	    				obj1_blu <= "00";
							end if;

						when BLUE_PIECE =>
							if is_in_range = '1' then
								obj1_red <= "00";
  	    				obj1_grn <= "00";
  	    				obj1_blu <= "11";
							end if;

						when EMPTY_PIECE =>
							if is_in_range = '1' then
								obj1_red <= "00";
  	    				obj1_grn <= "01";
  	    				obj1_blu <= "01";
							end if;

						when others =>
							null;

					end case;
					
				when BLUE_WIN_STATE | RED_WIN_STATE =>
					-- actual game pieces
					if is_in_range = '1' then
						case current_piece_pipe(3) is
							when RED_PIECE =>
									obj1_red <= "00";
  	    					obj1_grn <= "11";
  	    					obj1_blu <= "00";
					
							when BLUE_PIECE =>
									obj1_red <= "00";
  	    					obj1_grn <= "00";
  	    					obj1_blu <= "11";
					
							when EMPTY_PIECE =>
									obj1_red <= "00";
  	    					obj1_grn <= "01";
  	    					obj1_blu <= "01";
							when others =>
								null;
						end case;
					
					-- background
					else 
						case win_board(current_row_pipe(3), current_col_pipe(3)) is
							when BLUE_PIECE =>
								if current_game_state_pipe(3) = BLUE_WIN_STATE then
									obj1_red <= "00";
  	    					obj1_grn <= "00";
  	    					obj1_blu <= "10";
								else
									obj1_red <= "00";
  	    					obj1_grn <= "10";
  	    					obj1_blu <= "00";
								end if;
							when others =>
								null;
						end case;
					end if;

				when TIE_STATE =>
					-- actual game pieces
					if is_in_range = '1' then
						case current_piece_pipe(3) is
							when RED_PIECE =>
								obj1_red <= "00";
  	    				obj1_grn <= "11";
  	    				obj1_blu <= "00";
					
							when BLUE_PIECE =>
								obj1_red <= "00";
  	    				obj1_grn <= "00";
  	    				obj1_blu <= "11";
					
							when EMPTY_PIECE =>
								obj1_red <= "00";
  	    				obj1_grn <= "01";
  	    				obj1_blu <= "01";
							when others =>
								null;
						end case;
					
					-- background
					else 
						case tie_board(current_row_pipe(3), current_col_pipe(3)) is
							when BLUE_PIECE =>
								obj1_red <= "00";
  	    				obj1_grn <= "10";
  	    				obj1_blu <= "10";
							when others =>
								null;
						end case;
					end if;
				
				when others =>
					null;
				end case;
  	end if;
	end if;
end process;
end arch;
