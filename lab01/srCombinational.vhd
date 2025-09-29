library IEEE;
use IEEE.std_logic_1164.all;

entity SRLATCH1 is
	port(
		nS: in  std_logic;
		nR: in  std_logic;
		Q:  out std_logic
	);
end SRLATCH1;

architecture arch of SRLATCH1 is
	signal q_i:  std_logic;
	signal nq_i: std_logic;
begin
	Q<=q_i;

	q_i<=(not nq_i) or (not nS) after 0.1us;
	nq_i<=(not q_i) or (not nR) after 0.1us;
end arch;