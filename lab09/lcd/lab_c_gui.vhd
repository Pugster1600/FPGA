library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_c_gui is
	port(
		clk:    in  std_logic;
		rx:     in  std_logic;
		tx:     out std_logic:='1';
		data_o: out unsigned(3 downto 0):=b"0000"
	);
end lab_c_gui;

architecture arch of lab_c_gui is
	signal rx_d1:  std_logic:='1';
	signal rx_d2:  std_logic:='1';
	signal rx_d3:  std_logic:='1';
	signal count:  unsigned(6 downto 0):=b"000_0000";
	signal temp_o: unsigned(2 downto 0):=b"000";
begin
	process(clk)
	begin
		if rising_edge(clk) then
			-- Metastability shift register
			rx_d1<=rx;
			rx_d2<=rx_d1;
			rx_d3<=rx_d2;
			-- Clock counter
			if (count=b"000_0000") then
				-- Check for start bit
				if (rx_d3='0') then
					count<=b"000_0001";
				end if;
			elsif (count=b"111_1100") then
				-- Check for stop bit
				if (rx_d3='1') then
					count<=b"000_0000";
				end if;
			else
				-- Increment counter
				count<=count+1;
			end if;
			-- Receive data_o
			if (count=b"001_0100") then
				temp_o(0)<=rx_d3;
			end if;
			if (count=b"010_0001") then
				temp_o(1)<=rx_d3;
			end if;
			if (count=b"010_1110") then
				temp_o(2)<=rx_d3;
			end if;
			if (count=b"011_1011") then
				data_o(3)<=rx_d3;
				data_o(2 downto 0)<=temp_o;
			end if;
		end if;
	end process;
end arch;