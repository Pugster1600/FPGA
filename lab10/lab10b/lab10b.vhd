library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab09b is
	port(
		clk: in  std_logic;
		rx:  in  std_logic;
		tx:  out std_logic:='1'
	);
end lab09b;

architecture arch of lab09b is
begin
	process(clk)
	begin
		if rising_edge(clk) then
			tx<=rx;
		end if;
	end process;
end arch;