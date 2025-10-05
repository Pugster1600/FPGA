library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab04_tb is
end lab04_tb;

architecture arch of lab04_tb is
  component lab04a is 
    port (
      clk: in  std_logic;
  		rx:  in  std_logic;
  		tx:  out std_logic;
  		btn: in  std_logic;
  		led: out std_logic_vector(1 downto 0);

      data_o_tb:    in std_logic_vector(41 downto 0); --data from matlab
	    data_i_tb:    out std_logic_vector(41 downto 0); --data to matlab
	    start_tb:     out std_logic;
	    remainder_tb: out unsigned(62 downto 0); --unsigned meant only for internal use not ports
	    divisor_tb:   out unsigned(62 downto 0);
	    factor_tb:    out unsigned(21 downto 0); --check all the way up to 2^21 (half way mark)
      count_tb: out unsigned (7 downto 0);
      dividend_tb : out unsigned(41 downto 0) := TO_UNSIGNED(0, 42)
    );
  end component;

  signal clk : std_logic;
  signal btn : std_logic;
  signal led : std_logic_vector(1 downto 0);
  signal tx : std_logic;
  signal rx: std_logic;

  signal data_o:    std_logic_vector(41 downto 0); --data from matlab
	signal data_i:    std_logic_vector(41 downto 0):=std_logic_vector(to_unsigned(1, 42)); --data to matlab
	signal start:     std_logic:='0';
	signal remainder: unsigned(62 downto 0); --unsigned meant only for internal use not ports
	signal divisor:   unsigned(62 downto 0);
	signal factor:    unsigned(21 downto 0):=b"100000_00000000_00000000"; --check all the way up to 2^21 (half way mark)
  signal btn_sync : std_logic_vector(3 downto 0); -- rising edge detector
  signal count : unsigned (7 downto 0) := to_unsigned(0, 8);
  signal dividend : unsigned(41 downto 0);
-- DATA_OUT IS THE ISSUE AKA DIVIDEND
begin
  --generic map
  lab : lab04a port map (
    clk => clk,
    rx => rx,
    tx => tx,
    btn => btn,
    led => led,

    data_o_tb => data_o,
    data_i_tb => data_i,
    start_tb => start,
    remainder_tb => remainder,
    divisor_tb => divisor,
    factor_tb => factor,
    count_tb => count,
    dividend_tb => dividend
  );
-- REMAINDER AND DIVIDEND
process

  begin
    -- init button
    data_o <= std_logic_vector(to_unsigned(100000 , 42));
    wait for 1 us;
    btn <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    btn <= '1';
    wait for 1 us;

    -- start press
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;

    -- start count
    btn <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    clk <= '0';
    wait for 1 us;

    while true loop
      clk <= '1';
      wait for 1 us;
      clk <= '0';
      wait for 1 us;
      clk <= '1';
      wait for 1 us;
      clk <= '0';
      wait for 1 us;
    end loop;

    
  end process;
end arch;