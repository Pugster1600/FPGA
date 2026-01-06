library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab09a is
	port(
		clk: in  std_logic;
		led: out std_logic_vector(1 downto 0)
	);
end lab09a;

architecture arch of lab09a is
	--constant bits: integer:=6;-- Pass
	--constant bits: integer:=10;-- Pass
	--constant bits: integer:=12;-- Pass
	constant bits: integer:=13;-- Pass
	--constant bits: integer:=14;-- Fail
	--constant bits: integer:=21;-- Fail
	--constant bits: integer:=36;-- Fail
	signal count:  unsigned(bits-1 downto 0);
	signal ce:     std_logic;
begin
	led<=std_logic_vector(count(count'high downto count'high-1));

	process(clk)
	begin
		if rising_edge(clk) then
			ce<=not ce;
		end if;
	end process;

	process(clk,ce)
	begin
		if rising_edge(clk) and (ce='1') then
			count<=count+1;
		end if;
	end process;
end arch;