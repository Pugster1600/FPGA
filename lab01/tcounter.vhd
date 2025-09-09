library IEEE;
use IEEE.std_logic_1164.all;

-- these are outputs to talk to the outside world
entity tcounter is
    port (
        C: in std_logic;  -- Clock input
        R: in std_logic;  -- Asynchronouse reset
        B4: out std_logic;-- Output bits
        B3: out std_logic;
        B2: out std_logic;
        B1: out std_logic;
        B0: out std_logic
    );
end tcounter;

architecture behavior of tcounter is
    -- 1. signals -> just wires!
    signal reset : std_logic;
    signal q0 : std_logic;
    signal d0 : std_logic;

    signal q1 : std_logic;
    signal d1 : std_logic;

    signal q2 : std_logic;
    signal d2 : std_logic;

    signal q3 : std_logic;
    signal d3 : std_logic;

    signal q4 : std_logic;
    signal d4 : std_logic;

    -- 2. component declaration
    component dffar is
      port(
            D: in std_logic; --data input
            C: in std_logic; --clock input
            R: in std_logic;
            Q: out std_logic
        );
    end component;

  begin
    dffar0 : dffar
      port map (
          r => r, -- connecting a wire from r of tcounter to r of this chip!
          c => c, -- connecting a wire from c of tcounter to c of this chip
          q => q0, --connecting a wire to this port
          d => d0 -- connecting a wire to this port
      );

    dffar1 : dffar
      port map (
          r => r,
          c => d0, -- connecting a wire to this port, wire also connected to d0 of another chip!
          q => q1,
          d => d1
      );

    dffar2 : dffar
      port map (
          r => r,
          c => d1,
          q => q2,
          d => d2
      );

    dffar3 : dffar
      port map (
          r => r,
          c => d2,
          q => q3,
          d => d3
      );

    dffar4 : dffar
      port map (
          r => r,
          c => d3,
          q => q4,
          d => d4
      );

      -- port => signal -> port assignment operator
      -- signal <= value -> signal assignment operator

    -- REMEMBER: this runs infinetly because its wire connections!
    -- dont think of this as we are manually changing something BUT rather wiring a circuit up or describing logic!!
    -- does it matter if this is above or below the instantiation??? -> shouldnt cause its describing circuit NOT actually sequence!! -> so we are wiring the same way!
    -- this says connect another signal to this signal by notting it AKA just an inverter!
    d0 <= not q0;
    d1 <= not q1;
    d2 <= not q2;
    d3 <= not q3;
    d4 <= not q4;

    --connect pins to output
    b0 <= q0;
    b1 <= q1;
    b2 <= q2;
    b3 <= q3;
    b4 <= q4;

    --NOTE: we cannot do something like d0 => not b0 (instead do d0 <= not q0, btw q0 = b0)
    -- this is because b0 is an output, and we are not allowed to connect that to an input of something
    -- ie you cannot directly assign to b0 but rather must do so with an intermediate signal??
    -- ie you port map by connecting to a signal AKA A WIRE
    -- rather than connecting it to an expression!!!
    -- port map is describing wiring NOT logic!


end behavior;