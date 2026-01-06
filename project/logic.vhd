LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.custom_types_pkg.ALL;

ENTITY logic IS
  PORT (
    clk : IN STD_LOGIC;
    left_btn : IN STD_LOGIC;
    right_btn : IN STD_LOGIC;
    place_btn : IN STD_LOGIC;
    board : OUT board_type;
    col_selected : OUT INTEGER;
    current_game_state : OUT game_state
  );
END logic;

ARCHITECTURE logic OF logic IS
  CONSTANT ROWS : INTEGER := 15;
  CONSTANT COLS : INTEGER := 20;

  -- Piece State
  SIGNAL piece_to_place : piece := RED_PIECE;
  SIGNAL col_selected_sig : INTEGER := 0;

  -- Metastability Shift Registers
  --SIGNAL move_btn_meta : STD_LOGIC_VECTOR(2 DOWNTO 0);
  --SIGNAL place_btn_meta : STD_LOGIC_VECTOR(2 DOWNTO 0);

  -- Board State
  SIGNAL board_sig : board_type := (OTHERS => (OTHERS => EMPTY_PIECE));
  SIGNAL current_state : game_state := BLUE_TURN_STATE;
  
  -- Current winning pipeline stage
  SIGNAL pipeline_stage : std_logic_vector(2 downto 0) := "000";
  SIGNAL winning_side : piece := EMPTY_PIECE;
   
  FUNCTION get_place_row(
    board : board_type;
    col : INTEGER
  ) RETURN INTEGER IS
    VARIABLE r : INTEGER;
  BEGIN
    FOR r IN ROWS - 1 DOWNTO 0 LOOP
      IF board(r, col) = EMPTY_PIECE THEN
        RETURN r; -- Found an empty slot
      END IF;
    END LOOP;

    RETURN -1;
  END FUNCTION;

  -- Check horizontal  wins
  FUNCTION check_horizontal(board : board_type) RETURN piece IS
    VARIABLE p : piece;
  BEGIN
    -- Horizontal Check
    FOR r IN 0 TO ROWS - 1 LOOP
      FOR c IN 0 TO COLS - 4 LOOP
        p := board(r, c);
        IF p /= EMPTY_PIECE THEN
          IF board(r, c + 1) = p AND
            board(r, c + 2) = p AND
            board(r, c + 3) = p THEN
            RETURN p;
          END IF;
        END IF;
      END LOOP;
    END LOOP;

    RETURN EMPTY_PIECE; -- No horizontal winner
  END FUNCTION;

  -- Check vertical wins
  FUNCTION check_vertical(board : board_type) RETURN piece IS
    VARIABLE p : piece;
  BEGIN
    -- Vertical Check
    FOR c IN 0 TO COLS - 1 LOOP
      FOR r IN 0 TO ROWS - 4 LOOP
        p := board(r, c);
        IF p /= EMPTY_PIECE THEN
          IF board(r + 1, c) = p AND
            board(r + 2, c) = p AND
            board(r + 3, c) = p THEN
            RETURN p;
          END IF;
        END IF;
      END LOOP;
    END LOOP;

    RETURN EMPTY_PIECE; -- No vertical winner
  END FUNCTION;
  
  -- Check down right diagonals
  FUNCTION down_right_diagonal(board : board_type) RETURN piece IS
    VARIABLE p : piece;
  BEGIN
    -- Diagonal Down-Right
    FOR r IN 0 TO ROWS - 4 LOOP
      FOR c IN 0 TO COLS - 4 LOOP
        p := board(r, c);
        IF p /= EMPTY_PIECE THEN
          IF board(r + 1, c + 1) = p AND
            board(r + 2, c + 2) = p AND
            board(r + 3, c + 3) = p THEN
            RETURN p;
          END IF;
        END IF;
      END LOOP;
    END LOOP;

    RETURN EMPTY_PIECE; -- No diagonal winner
  END FUNCTION;

  -- Check down right diagonals
  FUNCTION up_right_diagonal(board : board_type) RETURN piece IS
    VARIABLE p : piece;
  BEGIN
    -- Diagonal Up-Right
    FOR r IN 3 TO ROWS - 1 LOOP
      FOR c IN 0 TO COLS - 4 LOOP
        p := board(r, c);
        IF p /= EMPTY_PIECE THEN
          IF board(r - 1, c + 1) = p AND
            board(r - 2, c + 2) = p AND
            board(r - 3, c + 3) = p THEN
            RETURN p;
          END IF;
        END IF;
      END LOOP;
    END LOOP;

    RETURN EMPTY_PIECE; -- No diagonal winner
  END FUNCTION;

  -- Check for tie or ongoing game
  FUNCTION check_tie(board : board_type) RETURN piece IS
  BEGIN
    FOR r IN 0 TO ROWS - 1 LOOP
      FOR c IN 0 TO COLS - 1 LOOP
        IF board(r, c) = EMPTY_PIECE THEN
          RETURN EMPTY_PIECE; -- Game is ongoing
        END IF;
      END LOOP;
    END LOOP;

    RETURN TIE_PIECE; -- No empty slots → tie
  END FUNCTION;
BEGIN
  board <= board_sig;
  current_game_state <= current_state;
  col_selected <= col_selected_sig;

  PROCESS (clk)
  BEGIN
    -- Metastability Shift Registers
    IF RISING_EDGE(clk) THEN
    END IF;
  END PROCESS;

  PROCESS (clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      CASE current_state IS
        WHEN BLUE_TURN_STATE =>
          -- Toggle column to place
          -- Put piece down if possible -> if both are pressed low, only when the second is also pressed do we place the piece down (to prevent pieces getting indefintely placed down)
          IF place_btn = '1' THEN
            IF get_place_row(board_sig, col_selected_sig) /= - 1 THEN
              board_sig(get_place_row(board_sig, col_selected_sig), col_selected_sig) <= BLUE_PIECE;
              current_state <= RED_TURN_STATE;
            END IF;
          -- move right
          ELSIF left_btn = '0' AND right_btn = '1' THEN
            IF col_selected_sig + 1 > COLS - 1 THEN
              col_selected_sig <= 0;
            ELSE
              col_selected_sig <= col_selected_sig + 1;
            END IF;
          -- move left
          ELSIF left_btn = '1' AND right_btn = '0' THEN
            IF col_selected_sig - 1 < 0 THEN
              col_selected_sig <= COLS - 1;
            ELSE
              col_selected_sig <= col_selected_sig - 1;
            END IF; 
          END IF;
          
          case winning_side is
          when BLUE_PIECE=>
            current_state <= BLUE_WIN_STATE;
          when RED_PIECE=>
            current_state <= RED_WIN_STATE;            
          when TIE_PIECE=>
            current_state <= TIE_STATE;
          when others=>
            null;
          end case;
          
        WHEN RED_TURN_STATE =>
          -- Put piece down if possible
          IF place_btn = '1' THEN
            IF get_place_row(board_sig, col_selected_sig) /= - 1 THEN
              board_sig(get_place_row(board_sig, col_selected_sig), col_selected_sig) <= RED_PIECE;
              current_state <= BLUE_TURN_STATE;
            END IF;
          -- move right
          ELSIF left_btn = '0' AND right_btn = '1' THEN
            IF col_selected_sig + 1 > COLS - 1 THEN
              col_selected_sig <= 0;
            ELSE
              col_selected_sig <= col_selected_sig + 1;
            END IF;
          -- move left
          ELSIF left_btn = '1' AND right_btn = '0' THEN
            IF col_selected_sig - 1 < 0 THEN
              col_selected_sig <= COLS - 1;
            ELSE
              col_selected_sig <= col_selected_sig - 1;
            END IF; 
          END IF;
          
          case winning_side is
            when BLUE_PIECE=>
              current_state <= BLUE_WIN_STATE;
            when RED_PIECE=>
              current_state <= RED_WIN_STATE;            
            when TIE_PIECE=>
              current_state <= TIE_STATE;
            when others=>
              null;
          end case;

        WHEN BLUE_WIN_STATE =>
          -- If either button is pressed, restart game
          IF left_btn = '1' or right_btn = '1' or place_btn = '1' THEN
            current_state <= BLUE_TURN_STATE;
            board_sig <= (OTHERS => (OTHERS => EMPTY_PIECE));
            col_selected_sig <= 0;
          END IF; 

        WHEN RED_WIN_STATE =>
          -- If either button is pressed, restart game
          IF left_btn = '1' or right_btn = '1' or place_btn = '1' THEN
            current_state <= BLUE_TURN_STATE;
            board_sig <= (OTHERS => (OTHERS => EMPTY_PIECE));
            col_selected_sig <= 0;
          END IF;

        WHEN TIE_STATE =>
          -- If either button is pressed, restart game
          IF left_btn = '1' or right_btn = '1' or place_btn = '1' THEN
            current_state <= BLUE_TURN_STATE;
            board_sig <= (OTHERS => (OTHERS => EMPTY_PIECE));
            col_selected_sig <= 0;
          END IF;

        WHEN OTHERS =>
          NULL;
      END CASE;
    END IF;
  END PROCESS;
  
  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) then
      case pipeline_stage is
      when "000"=>
        if (winning_side = EMPTY_PIECE) then
          winning_side <= check_horizontal(board_sig);
        else
          winning_side <= EMPTY_PIECE;
        end if;
        pipeline_stage <= "001";
      when "001"=>
        if (winning_side = EMPTY_PIECE) then
          winning_side <= check_vertical(board_sig);
        else
          winning_side <= EMPTY_PIECE;
        end if;
        pipeline_stage <= "010";
      when "010"=>
        if (winning_side = EMPTY_PIECE) then
          winning_side <= down_right_diagonal(board_sig);
        else
          winning_side <= EMPTY_PIECE;
        end if;
        pipeline_stage <= "011";
      when "011"=>
        if (winning_side = EMPTY_PIECE) then
          winning_side <= up_right_diagonal(board_sig);
        else
          winning_side <= EMPTY_PIECE;
        end if;
        pipeline_stage <= "100";
      when "100"=>
        if (winning_side = EMPTY_PIECE) then
          winning_side <= check_tie(board_sig);
        else
          winning_side <= EMPTY_PIECE;
        end if;
        pipeline_stage <= "000";
      when others=>
        null;
      end case;
    END IF;
  END PROCESS;
END ARCHITECTURE;