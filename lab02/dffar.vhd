library IEEE;
use IEEE.std_logic_1164.all;

entity dffar is
  port (
    D: in  std_logic; -- Data input
		C: in  std_logic; -- Clock input
		R: in  std_logic; -- Asynchronouse reset
		Q: out std_logic:='0' -- Data output (give it a power on value since reset is not initially high)
  );
end dffar;

architecture arch of dffar is
begin
  process (R, C)
  begin
    if R = '1' then
      Q <= '0';
    elsif rising_edge(C) then 
      Q <= D;
    end if;
  end process;
end arch;