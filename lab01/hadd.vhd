library IEEE;
use IEEE.std_logic_1164.all;


entity hadd is
  port (
    X: in std_logic;--Datain
    Y: in std_logic;--Datain
    C: out std_logic;--Carryout
    S: out std_logic--Sumout
  );
end hadd;

architecture behavior of hadd is
begin
  C<=X and Y;
  S<=X xor Y;
end behavior;