LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE custom_types_pkg IS
  CONSTANT ROWS : INTEGER := 15; --15 * 32 = 480
  CONSTANT COLS : INTEGER := 20; -- 20 * 32 = 640

  TYPE piece IS (EMPTY_PIECE, RED_PIECE, BLUE_PIECE, TIE_PIECE);
  TYPE game_state IS (BLUE_TURN_STATE, RED_TURN_STATE, BLUE_WIN_STATE, RED_WIN_STATE, TIE_STATE);
  TYPE board_type IS ARRAY (0 TO ROWS - 1, 0 TO COLS - 1) OF piece; --2d array of board
  TYPE circle_center IS ARRAY(1 DOWNTO 0) OF INTEGER;
  TYPE circle_center_array IS ARRAY (0 TO ROWS - 1, 0 TO COLS - 1) OF circle_center;

  TYPE unsigned_pipeline_array IS ARRAY(0 DOWNTO 0) OF unsigned(9 DOWNTO 0);
  TYPE integer_pipeline_array IS ARRAY(4 DOWNTO 0) OF INTEGER;
  TYPE board_pipe_t IS ARRAY(4 DOWNTO 0) OF board_type;
  TYPE current_game_state_pipe_t IS ARRAY(4 DOWNTO 0) OF game_state;
  TYPE piece_pipe_t IS ARRAY(4 DOWNTO 0) OF piece;
END PACKAGE custom_types_pkg;