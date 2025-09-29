library IEEE;
use IEEE.std_logic_1164.all;

entity hadd is
  port (
    X: in  std_logic; -- Data in
		Y: in  std_logic; -- Data in
		C: out std_logic; -- Carry out
		S: out std_logic  -- Sum out
  );
end hadd;

architecture arch of hadd is
begin
  C<=X and Y;
	S<=X xor Y;
end arch;