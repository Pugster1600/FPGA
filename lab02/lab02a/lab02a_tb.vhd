library IEEE;
use IEEE.std_logic_1164.all;

entity lab02a_tb is
end lab02a_tb;

architecture arch of lab02a_tb is
  -- component declaration
  component lab02a is
    port (
      clk : in std_logic;
      bits : out STD_LOGIC_VECTOR(3 downto 0)
    );
  end component;

  --signals
  signal clk : std_logic;
  signal bits : STD_LOGIC_VECTOR(3 downto 0);
begin
  -- component instantiation
  test : lab02a 
    port map(
      clk => clk,
      bits => bits
    );

process 
  begin
    clk<='0';
    wait for 40 ns;
    clk<='1';
    wait for 40 ns;
  end process;
end arch;