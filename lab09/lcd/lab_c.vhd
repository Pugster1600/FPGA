library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_c is
	port(
		clk:   in  std_logic;
		rx:    in  std_logic;
		tx:    out std_logic;
		com:   out std_logic;
		seg_a: out std_logic;
		seg_b: out std_logic;
		seg_c: out std_logic;
		seg_d: out std_logic;
		seg_e: out std_logic;
		seg_f: out std_logic;
		seg_g: out std_logic
	);
end lab_c;

architecture arch of lab_c is
	component lab_c_gui
		port(
			clk:    in  std_logic;
			rx:     in  std_logic;
			tx:     out std_logic;
			data_o: out unsigned(3 downto 0)
		);
	end component;
	signal data: unsigned(3 downto 0);
  signal segment_lines : std_logic_vector(6 downto 0);

  type segment_table is array(0 to 15) of std_logic_vector(6 downto 0);
  constant seg_table : segment_table := (
    "1111110", -- 0
    "0110000", -- 1
    "1101101", -- 2
    "1111001", -- 3
    "0110011", -- 4
    "1011011", -- 5
    "1011111", -- 6
    "1110000", -- 7
    "1111111", -- 8
    "1111011", -- 9
    "1110111", -- A
    "0011111", -- b
    "1001110", -- c
    "0111101", -- d
    "1001111", -- e
    "1000111"  -- f
  );

  constant half_period : integer := 49999; --120 hz signal is 99999 full period
  signal counter : integer := 0;
  signal clk_div : std_logic := '0';


begin
	gui: lab_c_gui port map(clk=>clk,rx=>rx,tx=>tx,data_o=>data);
  seg_a <= segment_lines(6);
  seg_b <= segment_lines(5);
  seg_c <= segment_lines(4);
  seg_d <= segment_lines(3);
  seg_e <= segment_lines(2);
  seg_f <= segment_lines(1);
  seg_g <= segment_lines(0);

  com <= clk_div;
process (clk)
begin
  if rising_edge(clk) then
    -- clk
    if counter < half_period then
      counter <= counter + 1;
    else
      clk_div <= not clk_div;
      counter <= 0;
    end if;

    -- segment_lines
    if clk_div = '0' then
      segment_lines <= seg_table(to_integer(data));
    else
      segment_lines <= not seg_table(to_integer(data));
    end if;
  end if;


end process;

end arch;