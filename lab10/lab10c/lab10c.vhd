library IEEE;
use IEEE.std_logic_1164.all;

entity lab09c is
	port(
		clk: in  std_logic;
		btn: in  std_logic;
		led: out std_logic
	);
end lab09c;

architecture arch of lab09c is
	signal tmp: std_logic;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			tmp<=btn;
			led<=tmp;
		end if;
	end process;
end arch;