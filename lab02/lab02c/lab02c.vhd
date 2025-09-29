library IEEE;
use IEEE.std_logic_1164.all;

entity lab02c is
  port (
    clk : in std_logic;
    btn : in std_logic_vector(1 downto 0);
    led : out std_logic_vector(1 downto 0)
  );
end lab02c;

architecture arch of lab02c is
  -- 1. component declaration
  component bcounter is
    generic (
      NBITS : natural
    );
    port (
      clk: in std_logic;-- Clock input
      rst: in std_logic;-- Asynchronouse reset
      cin: in std_logic;-- Carry-in and run control
      cout: out std_logic;-- Carry-out for cascading
      bits: out std_logic_vector(NBITS-1 downto 0)
    );
  end component;

  -- 2. signal declaration
  signal bits : std_logic_vector(23 downto 0);

begin
  -- 3. component instantiation
  counter : bcounter 
    generic map (
      NBITS => bits'high - bits'low + 1
    )
    port map (
      clk => clk,
      rst => btn(1), --reset counter is button 1
      cin => btn(0), --basically if button is high, then we add 1 since carry in is what is actually being added
      cout => open,
      bits => bits
    );

    led <= bits(bits'high downto bits'high - 1);
end arch;