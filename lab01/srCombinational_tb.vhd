library IEEE;
use IEEE.std_logic_1164.all;

entity SRLATCH1_TB is
end SRLATCH1_TB;

architecture arch of SRLATCH1_TB is
	component SRLATCH1
		port(
			nS: in  std_logic;
			nR: in  std_logic;
			Q:  out std_logic
		);
	end component;
	signal nS: std_logic:='1';
	signal nR: std_logic:='1';
	signal Q:  std_logic;
begin
	test: SRLATCH1 port map (nS=>nS,nR=>nR,Q=>Q);

	process
	begin
		-- You must expand the test cases here
		-- so that all 12 transistions are tested.
		nS<='1';nR<='1';
		wait for 1 us;
		nS<='0';nR<='0';
		wait for 1 us;
		nS<='1';nR<='1';
		wait for 1 us;
		nS<='0';nR<='0';
		wait for 1 us;
		nS<='1';nR<='1';
		wait for 1 us;
		nS<='0';nR<='0';
		wait for 1 us;
		
		wait;
	end process;
end arch;