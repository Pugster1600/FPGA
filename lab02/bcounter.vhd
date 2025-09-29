library IEEE;
use IEEE.std_logic_1164.all;

entity bcounter is
  generic(
    NBITS : natural := 4 --default is 4 (natural means integer >= 0)
  );

  port (
    clk : in std_logic; -- clk
    rst : in std_logic; -- async reset
    cin : in std_logic; -- carry in and run control
    cout : out std_logic; -- carry out for cascading
    bits : out std_logic_vector(NBITS - 1 downto 0) --output bits
  );
end bcounter;

architecture arch of bcounter is
  -- signal declaration -> anything that requires wiring/connections!!
  signal c : std_logic_vector(NBITS downto 0); --we have nbits + 1 carry lines
  signal d : std_logic_vector(NBITS-1 downto 0); --nbits data
  signal q : std_logic_vector(NBITS-1 downto 0); --nbits output


  -- component declaration
  component hadd is
    port (
      X: in  std_logic; -- Data in
  		Y: in  std_logic; -- Data in
  		C: out std_logic; -- Carry out
  		S: out std_logic  -- Sum out
    );
  end component;

  component dffar is
    port (
      D: in  std_logic; -- Data input
	  	C: in  std_logic; -- Clock input
	  	R: in  std_logic; -- Asynchronouse reset
	  	Q: out std_logic -- Data output
    );
  end component;

begin 
  c(0) <= cin; -- assign input carry to the carry of hadd0
  cout <= c(NBITS); --carry output
  bits <= q; --1 to 1 assignment of the std_vectors

  --only thing left to assign now is the reset of the carry bits and data bits

  -- for loop downcount from -> for loops do not skip the final index! unlike in python (C just does i < value)
  chain : for i in NBITS - 1 downto 0 generate --"chain" is an arbitrary name
    ha : HADD port map(x => q(i), y => c(i), c => c(i + 1), s => d(i)); --ha is arbitrary name -> port => signal
    ff : DFFAR port map(d => d(i), q => q(i), c => clk, r => rst);--ff is arbitrary name
    -- top level ports can be used to connect to the subcomponent ports -> like c => clk, in port map
    -- BUT the top level ports CANNOT be used on the right hand side of assignments
    -- use signals to connect internal to internal
    -- also use signals to intermediate logic
    -- like if you want to do something like (submodule_port <= top_level port), you need to instead do top_level <= intermediate
    -- then submodule_port <= intermediate (this DOES NOT MEAN ASSIGN rather it means connect them)
    -- BUT you can port map top module portsto submodule ports
  end generate;
end arch;