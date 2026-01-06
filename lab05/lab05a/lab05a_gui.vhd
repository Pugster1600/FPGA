library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab05a_gui is
	port(
		clk_i:  in  std_logic;
		rx_i:   in  std_logic;
		tx_o:   out std_logic:='1';
		data_i: in  std_logic_vector(11 downto 0)
	);
end lab05a_gui;

architecture arch of lab05a_gui is
	signal rx_d1:  std_logic:='1';
	signal rx_d2:  std_logic:='1';
	signal rx_d3:  std_logic:='1';
	signal count:  unsigned(7 downto 0):=b"0000_0000";
	signal state:  std_logic:='0';
	signal tx_buf: std_logic_vector(7 downto 0):=b"0000_0000";
	signal temp:   std_logic_vector(13 downto 7):=b"000_0000";
begin
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			-- Metastability shift register
			rx_d1<=rx_i;
			rx_d2<=rx_d1;
			rx_d3<=rx_d2;
			-- Clock counter
			if (count=b"0000_0000") then
				-- Check for start bit
				if (rx_d3='0') or (state='1') then
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
					state<='1';
					tx_buf<='1'&data_i(6 downto 0);
					temp(11 downto 7)<=data_i(11 downto 7);
					tx_o<='0';
				elsif (state='1') then
					state<='0';
					tx_buf<=b"000"&temp(11 downto 7);
					tx_o<='0';
				end if;
			elsif (count=b"0000_1101") then
				tx_o<=tx_buf(0);
			elsif (count=b"0001_1010") then
				tx_o<=tx_buf(1);
			elsif (count=b"0010_0111") then
				tx_o<=tx_buf(2);
			elsif (count=b"0011_0100") then
				tx_o<=tx_buf(3);
			elsif (count=b"0100_0001") then
				tx_o<=tx_buf(4);
			elsif (count=b"0100_1110") then
				tx_o<=tx_buf(5);
			elsif (count=b"0101_1011") then
				tx_o<=tx_buf(6);
			elsif (count=b"0110_1000") then
				tx_o<=tx_buf(7);
			elsif (count=b"0111_0101") then
				tx_o<='1';
			end if;
		end if;
	end process;
end arch;