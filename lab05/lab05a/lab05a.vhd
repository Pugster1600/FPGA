
library IEEE;
use IEEE.std_logic_1164.all;

entity lab05a is
	port(
		clk:      in  std_logic;
		rx:       in  std_logic;
		tx:       out std_logic;
		vaux12_n: in  std_logic;
		vaux12_p: in  std_logic
	);
end lab05a;

architecture arch of lab05a is
	component lab05a_gui is
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_i: in  std_logic_vector(11 downto 0)
		);
	end component;
	component lab05_adc is
		port(
			clk_i:     in  std_logic;
			vaux12n_i: in  std_logic;
			vaux12p_i: in  std_logic;
			rdy_o:     out std_logic;
			data_o:    out std_logic_vector(11 downto 0)
		);
	end component;
	signal data: std_logic_vector(11 downto 0);
begin
	gui: lab05a_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_i=>data);
	adc: lab05_adc port map(clk_i=>clk,vaux12n_i=>vaux12_n,
		vaux12p_i=>vaux12_p,rdy_o=>open,data_o=>data);
end arch;

