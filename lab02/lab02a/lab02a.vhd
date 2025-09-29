library IEEE;
use IEEE.std_logic_1164.all;

--this file is basically the direct instantiation of a generic
--so this is almost just a wrapper around the original arch since we need to specify the vector size

entity lab02a is
  port (
    clk : in std_logic;
    bits : out STD_LOGIC_VECTOR(3 downto 0)
  );
end lab02a;

architecture arch of lab02a is
  component bcounter is
    generic(
      NBITS : natural --default aka natural is 4
    );

    port (
      clk : in std_logic; -- clk
      rst : in std_logic; -- async reset
      cin : in std_logic; -- carry in and run control
      cout : out std_logic; -- carry out for cascading
      bits : out std_logic_vector(NBITS - 1 downto 0) --output bits
    );
  end component;

  --signal
begin
  -- generic is a paramter you can set at instantiation time rather than component creation time -> nothing is runtime since everything is hardware (though we probably can but itll be quite difficult)
  -- this just taxes the vivado software more but the end hardware product is the same!
  counter : bcounter 
    generic map(NBITS => bits'high-bits'low+1) --overrides the default value of nbits to  -> view this as (bits'high) - (bits'low) + 1 aka 3 - 0 + 1
    port map(clk => clk, rst => '0', cin => '1', cout => open, bits => bits); --think of the ' notation as the attribute operator in C or python (class.attribute OR in our case bits.high) struct.field
end arch;