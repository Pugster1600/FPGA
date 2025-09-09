library IEEE;
use IEEE.std_logic_1164.all;

entity bcounter is
  port(
    C: in std_logic;--Clockinput
    R: in std_logic;--Asynchronousereset
    B4: out std_logic;--Outputbits
    B3: out std_logic;
    B2: out std_logic;
    B1: out std_logic;
    B0: out std_logic
  );
end bcounter;

architecture behavior of bcounter is
  -- signals -> any wire that you see not ocnnected to the outside world??
  signal c0 : std_logic;
  signal c1 : std_logic;
  signal c2 : std_logic;
  signal c3 : std_logic;
  -- c4 is open

  signal q0 : std_logic;
  signal q1 : std_logic;
  signal q2 : std_logic;
  signal q3 : std_logic;
  signal q4 : std_logic;

  signal d0 : std_logic;
  signal d1 : std_logic;
  signal d2 : std_logic;
  signal d3 : std_logic;
  signal d4 : std_logic;

  -- component declaration
  component hadd is
    port (
      X: in std_logic;--Datain
      Y: in std_logic;--Datain
      C: out std_logic;--Carryout
      S: out std_logic--Sumout
    );
  end component;

  component dffar is
    port(
          D: in std_logic; --data input
          C: in std_logic; --clock input
          R: in std_logic;
          Q: out std_logic
      );
    end component;

begin
  -- component instantiation
  -- hadd init
  -- basically any of the internal components here must either be connected
  -- to the input/output of the top level 
  -- OR to the signals inside the top level

  -- this is NOT port mapping but rather assignment!
  b0 <= q0;
  b1 <= q1;
  b2 <= q2;
  b3 <= q3;
  b4 <= q4;

  hadd0 : hadd 
    port map (
      X => q0,
      Y => '1', --assign to one
      C => c0,
      S => d0
  );

  hadd1 : hadd 
    port map (
      X => q1,
      Y => c0,
      C => c1,
      S => d1
  );

  hadd2 : hadd 
    port map (
      X => q2,
      Y => c1,
      C => c2,
      S => d2
  );

  hadd3 : hadd 
    port map (
      X => q3,
      Y => c2,
      C => c3,
      S => d3
  );

  hadd4 : hadd 
    port map (
      X => q4,
      Y => c3,
      C => open,
      S => d4
  );
  
  -- dffar init
  dffar0 : dffar
   port map(
      D => d0,
      C => C,
      R => R,
      Q => q0
  );

  dffar1 : dffar
   port map(
      D => d1,
      C => C,
      R => R,
      Q => q1
  );

  dffar2 : dffar
   port map(
      D => d2,
      C => C,
      R => R,
      Q => q2
  );

  dffar3 : dffar
   port map(
      D => d3,
      C => C,
      R => R,
      Q => q3
  );

  dffar4 : dffar
   port map(
      D => d4,
      C => C,
      R => R,
      Q => q4
  );
end behavior;