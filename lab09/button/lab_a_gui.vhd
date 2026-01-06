library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_a_gui is
	port(
		clk:    in  std_logic;
		rx:     in  std_logic;
		tx:     out std_logic:='1';
		cntr_i: in  unsigned(6 downto 0);
		cntb_i: in  unsigned(6 downto 0);
		cnty_i: in  unsigned(6 downto 0);
		cntg_i: in  unsigned(6 downto 0)
);
end lab_a_gui;

architecture arch of lab_a_gui is
	signal rx_d1: std_logic:='1';
	signal rx_d2: std_logic:='1';
	signal rx_d3: std_logic:='1';
	signal count: unsigned(7 downto 0):=b"0000_0000";
	signal state: std_logic_vector(1 downto 0):=b"00";
	signal temp:  std_logic_vector(7 downto 0):=b"0000_0000";
begin
	process(clk)
	begin
		if rising_edge(clk) then
			-- Metastability shift register
			rx_d1<=rx;
			rx_d2<=rx_d1;
			rx_d3<=rx_d2;
			-- Clock counter
			if (count=b"0000_0000") then
				-- Check for start bit
				if (rx_d3='0') or (state/=b"11") then
					count<=b"0000_0001";
				end if;
			elsif (count=b"1000_0001") then
				-- Reset counter
				count<=b"0000_0000";
			else
				-- Increment counter
				count<=count+1;
			end if;
			-- Transmit data
			if (count=b"0000_0000") then
				if (rx_d3='0') then
					state<=b"00";
					temp<='1'&std_logic_vector(cntr_i);
					tx<='0';
				elsif (state=b"00") then
					state<=b"01";
					temp<='0'&std_logic_vector(cntb_i);
					tx<='0';
				elsif (state=b"01") then
					state<=b"10";
					temp<='0'&std_logic_vector(cnty_i);
					tx<='0';
				elsif (state=b"10") then
					state<=b"11";
					temp<='0'&std_logic_vector(cntg_i);
					tx<='0';
				end if;
			elsif (count=b"0000_1101") then
				tx<=temp(0);
			elsif (count=b"0001_1010") then
				tx<=temp(1);
			elsif (count=b"0010_0111") then
				tx<=temp(2);
			elsif (count=b"0011_0100") then
				tx<=temp(3);
			elsif (count=b"0100_0001") then
				tx<=temp(4);
			elsif (count=b"0100_1110") then
				tx<=temp(5);
			elsif (count=b"0101_1011") then
				tx<=temp(6);
			elsif (count=b"0110_1000") then
				tx<=temp(7);
			elsif (count=b"0111_0101") then
				tx<='1';
			end if;
		end if;
	end process;
end arch;