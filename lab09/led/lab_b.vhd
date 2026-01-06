library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_b is
	port(
		clk: in  std_logic;
		rx:  in  std_logic;
		tx:  out std_logic;
		row: out std_logic_vector(6 downto 2);
		col: out std_logic_vector(4 downto 2)
	);
end lab_b;

architecture arch of lab_b is
	component lab_b_gui
		port(
			clk:    in  std_logic;
			rx:     in  std_logic;
			tx:     out std_logic:='1';
			data_o: out std_logic_vector(14 downto 0)
		);
	end component;
	signal data: std_logic_vector(14 downto 0);

  signal col2 : std_logic_vector(4 downto 0);
  signal col3 : std_logic_vector(4 downto 0);
  signal col4 : std_logic_vector(4 downto 0);
  signal counter : integer := 0;

  constant COL_HIGH : integer := 2;
  constant COL_LOW : integer := 0;
  constant ROW_HIGH : integer := 4;
  constant ROW_LOW : integer := 0;
  constant LED_IN_COL : integer := 5;
  constant HALF_PERIOD : integer := 59999; -- 250 hz full period is 200000

  signal col_index : integer := 2;
  signal row_index : integer := 2;
  

begin
	gui: lab_b_gui port map(clk=>clk,rx=>rx,tx=>tx,data_o=>data);

process(clk)
begin
  if rising_edge(clk) then
    col2 <= data(4 downto 0);
    col3 <= data(9 downto 5);
    col4 <= data(14 downto 10);

    if counter < HALF_PERIOD then
      counter <= counter + 1;
    else
      case col_index is
      when 2 =>
        col_index <= 3;
        row <= data(4 downto 0);-- & "00";
        
        -- drive to 1 if not active since guaranteed it is off
        col <= "110";
        --col(2) <= '0';
        --col(3) <= '1';
        --col(4) <= '1';

      when 3 =>
        col_index <= 4;
        row <= data(9 downto 5);-- & "00";
        
        col <= "101";
        --col(2) <= '1';
        --col(3) <= '0';
        --col(4) <= '1';

      when others =>
        col_index <= 2;
        row <= data(14 downto 10);-- & "00";
        
        col <= "011";
        --col(2) <= '1';
        --col(3) <= '1';
        --col(4) <= '0';
    end case;

    --ALL OF THIS EXECUTES AT THE SAME TIME SO THIS IS NOT THE DESIRED BEHAVIOR
    --for i in COL_HIGH downto COL_LOW loop
    --  for j in ROW_HIGH downto ROW_LOW loop
    --    if data(i * LED_IN_COL + j) = '1' then
    --      row(j + 2) <= '1';
    --      col(i + 2) <= '1';
    --    else
    --      row(j + 2) <= '0';
    --      col(i + 2) <= '0';
    --    end if;
    --  end loop;
    --end loop;
      counter <= 0;
    end if;

    
  end if;
end process;


end arch;