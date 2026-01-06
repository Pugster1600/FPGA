library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_b_gui is
	port(
		clk:    in  std_logic;
		rx:     in  std_logic;
		tx:     out std_logic:='1';
		data_o: out std_logic_vector(14 downto 0)
	);
end lab_b_gui;

architecture arch of lab_b_gui is
	signal rx_d1:  std_logic:='1';
	signal rx_d2:  std_logic:='1';
	signal rx_d3:  std_logic:='1';
	signal count:  unsigned(6 downto 0):=b"000_0000";
	signal state:  std_logic_vector(2 downto 0):=b"000";
	signal rx_buf: std_logic_vector(7 downto 0):=b"0000_0000";
	signal temp_o: std_logic_vector(9 downto 0):=b"00_0000_0000";
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
					if (rx_buf(7)='1') then
						state<=b"001";
						temp_o(4 downto 0)<=rx_buf(5 downto 1);
					elsif (state=b"000") then
						state<=b"001";
						temp_o(4 downto 0)<=rx_buf(5 downto 1);
					elsif (state=b"001") then
						state<=b"010";
						temp_o(9 downto 5)<=rx_buf(5 downto 1);
					elsif (state=b"010") then
						state<=b"011";
						data_o(9 downto 0)<=temp_o;
						data_o(14 downto 10)<=rx_buf(5 downto 1);
					elsif (state=b"011") then
						state<=b"100";
						temp_o(4 downto 0)<=rx_buf(5 downto 1);
					end if;
				end if;
			else
				-- Increment counter
				count<=count+1;
			end if;
			-- Receive data
			if (count=b"001_0100") then
				rx_buf(0)<=rx_d3;
			end if;
			if (count=b"010_0001") then
				rx_buf(1)<=rx_d3;
			end if;
			if (count=b"010_1110") then
				rx_buf(2)<=rx_d3;
			end if;
			if (count=b"011_1011") then
				rx_buf(3)<=rx_d3;
			end if;
			if (count=b"100_1000") then
				rx_buf(4)<=rx_d3;
			end if;
			if (count=b"101_0101") then
				rx_buf(5)<=rx_d3;
			end if;
			if (count=b"110_0010") then
				rx_buf(6)<=rx_d3;
			end if;
			if (count=b"110_1111") then
				rx_buf(7)<=rx_d3;
			end if;
		end if;
	end process;
end arch;