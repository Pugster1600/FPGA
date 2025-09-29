library IEEE;
use IEEE.std_logic_1164.all;

entity lab02b is
  port (
    clk : in std_logic;
    led : out std_logic_vector(1 downto 0) --just 2 LEDS so 2 bit counter
  );
end lab02b;
  
architecture arch of lab02b is
  component bcounter is
    -- 1. THIS IS AN EXTRA THING WE NEED TO DO IN THE DECLARATION
    generic (
      NBITS : natural --natural means "NBITS is a non-negative integer"
      );
    port(
      clk: in std_logic;-- Clock input
      rst: in std_logic;-- Asynchronouse reset
      cin: in std_logic;-- Carry-in and run control
      cout: out std_logic;-- Carry-out for cascading
      bits: out std_logic_vector(NBITS-1 downto 0) --declare generic output (relative to the generic!)
    );
 end component;
 signal bits : STD_LOGIC_VECTOR(23 downto 0);

begin
  counter : bcounter
   -- 2. ONLY THING EXTRA HERE IS THE addition of 'generic map (genericVariable => number)'
    generic map(
      -- INSTANTIATION IS WHEN WE ACTUALLY DEFINE NBITS
      NBITS => bits'high - bits'low + 1 --23 - 0 + 1 = 24 bits
    )
    port map(
      clk => clk,
      rst => '0',
      cin => '1',
      cout => open,
      bits => bits
    );
    
    -- output only the 2MSB
    -- SO WHILE ALL 23 bits are actually running
    -- led is defined in the top level -> top level ports are actually connected to GPIO
    led <= bits(bits'high downto bits'high - 1);
end arch;
