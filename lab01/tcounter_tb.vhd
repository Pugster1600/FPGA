library IEEE;
use IEEE.std_logic_1164.all;

entity tcounter_tb is
end tcounter_tb;

-- multiple processes are like 2 different circuits working AT THE SAME TIME!!
-- describe 2 different parts of the circuit that is happening at the same time!!!
-- remember you are describing a circuit -> a truth table almost 
architecture behavior of tcounter_tb is
  signal C : std_logic := '0';
  signal R : std_logic := '0';
  signal B0 : std_logic;
  signal B1 : std_logic;
  signal B2 : std_logic;
  signal B3 : std_logic;
  signal B4 : std_logic;

  component tcounter is
    port (
      C: in std_logic;  -- Clock input
      R: in std_logic;  -- Asynchronouse reset
      B4: out std_logic;-- Output bits
      B3: out std_logic;
      B2: out std_logic;
      B1: out std_logic;
      B0: out std_logic
    );
  end component;
  
begin

  tcounterObj : tcounter 
    port map(
      C => C,
      R => R,
      B4 => B4,
      B3 => B3,
      B2 => B2,
      B1 => B1,
      B0 => B0
    );

  process
    --make sure to enable the reset first in order to no have undefined behavior!!
    begin
    R <= '1';
    wait for 1 us;
    R <= '0';
    wait for 1 us;
    
    -- tick 1
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 2
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 3
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 4
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 5
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 6
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 7
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 8
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 9
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 10
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 11
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;

    -- tick 12
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 13
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 14
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 15
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;

    -- tick 16
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 17
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 18
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
    
    -- tick 19
    C <= '0';
    wait for 1 us;
    C <= '1';
    wait for 1 us;
  end process;

  --process
  --  begin
  --  R<='1';
  --  wait for 2.5 us;
  --  R<='0';
  --  wait;
  --end process;

end behavior; 

--NOTE: we can only change signal values (since signals connect ports to ports, we dont care about which component we are talking about JUST THE SIGNAL!!!)
--since the signal is connected to the component!