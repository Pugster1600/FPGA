library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab03_gui is
	port(
		clk_i:  in  std_logic;
		rx_i:   in  std_logic;
		tx_o:   out std_logic:='1';
		data_o: out std_logic_vector(27 downto 0);
		data_i: in  std_logic_vector(27 downto 0)
	);
end lab03_gui;

architecture arch of lab03_gui is
	signal rx_d1:  std_logic:='1';
	signal rx_d2:  std_logic:='1';
	signal rx_d3:  std_logic:='1';
	signal count:  unsigned(6 downto 0):=b"000_0000";
	signal state:  std_logic_vector(2 downto 0):=b"000";
	signal rx_buf: std_logic_vector(7 downto 0):=b"0000_0000";
	signal tx_buf: std_logic_vector(7 downto 0):=b"0000_0000";
	signal temp_o: std_logic_vector(20 downto 0):=b"0_0000_0000_0000_0000_0000";
	signal temp_i: std_logic_vector(27 downto 7):=b"0000_0000_0000_0000_0000_0";
begin
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			-- Metastability shift register
			rx_d1<=rx_i;
			rx_d2<=rx_d1;
			rx_d3<=rx_d2;
			-- Clock counter
			if (count=b"000_0000") then
				-- Check for start bit
				if (rx_d3='0') then
					count<=b"000_0001";
					if (state=b"000") then
						tx_buf<='1'&data_i(6 downto 0);
						temp_i(27 downto 7)<=data_i(27 downto 7);
					elsif (state=b"001") then
						tx_buf<='0'&temp_i(13 downto 7);
					elsif (state=b"010") then
						tx_buf<='0'&temp_i(20 downto 14);
					elsif (state=b"011") then
						tx_buf<='0'&temp_i(27 downto 21);
					elsif (state=b"100") then
						tx_buf<='1'&data_i(6 downto 0);
						temp_i(27 downto 7)<=data_i(27 downto 7);
					else
						tx_buf<=b"0000_0000";
					end if;
				end if;
			elsif (count=b"111_1100") then
				-- Check for stop bit
				if (rx_d3='1') then
					count<=b"000_0000";
					if (rx_buf(7)='1') then
						state<=b"001";
						temp_o(6 downto 0)<=rx_buf(6 downto 0);
					elsif (state=b"000") then
						state<=b"001";
						temp_o(6 downto 0)<=rx_buf(6 downto 0);
					elsif (state=b"001") then
						state<=b"010";
						temp_o(13 downto 7)<=rx_buf(6 downto 0);
					elsif (state=b"010") then
						state<=b"011";
						temp_o(20 downto 14)<=rx_buf(6 downto 0);
					elsif (state=b"011") then
						state<=b"100";
						data_o(20 downto 0)<=temp_o;
						data_o(27 downto 21)<=rx_buf(6 downto 0);
					elsif (state=b"100") then
						state<=b"101";
						temp_o(6 downto 0)<=rx_buf(6 downto 0);
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
			-- Transmit data
			if (count=b"000_0000") then
				if (rx_d3='0') then
					tx_o<='0';
				end if;
			elsif (count=b"000_1101") then
				tx_o<=tx_buf(0);
			elsif (count=b"001_1010") then
				tx_o<=tx_buf(1);
			elsif (count=b"010_0111") then
				tx_o<=tx_buf(2);
			elsif (count=b"011_0100") then
				tx_o<=tx_buf(3);
			elsif (count=b"100_0001") then
				tx_o<=tx_buf(4);
			elsif (count=b"100_1110") then
				tx_o<=tx_buf(5);
			elsif (count=b"101_1011") then
				tx_o<=tx_buf(6);
			elsif (count=b"110_1000") then
				tx_o<=tx_buf(7);
			elsif (count=b"111_0101") then
				tx_o<='1';
			end if;
		end if;
	end process;
end arch;