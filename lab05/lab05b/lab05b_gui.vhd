library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab05b_gui is
	generic(
		SAMPLES: natural
	);
	port(
		clk_i:  in  std_logic;
		rx_i:   in  std_logic;
		tx_o:   out std_logic:='1';
		addr_o: out std_logic_vector(9 downto 0);
		data_i: in  std_logic_vector(11 downto 0)
	);
end lab05b_gui;

architecture arch of lab05b_gui is
	signal rx_d1:  std_logic:='1';
	signal rx_d2:  std_logic:='1';
	signal rx_d3:  std_logic:='1';
	signal count:  unsigned(8 downto 0):=b"0_0000_0000";
	signal addr_u: unsigned(9 downto 0):=b"00_0000_0000";
begin
	addr_o<=std_logic_vector(addr_u);

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			-- Metastability shift register
			rx_d1<=rx_i;
			rx_d2<=rx_d1;
			rx_d3<=rx_d2;
			-- Clock counter
			if (count=b"0_0000_0000") then
				-- Check for start bit
				if (rx_d3='0') or (addr_u/=b"00_0000_0000") then
					count<=b"0_0000_0001";
				end if;
			elsif (count=b"1_0001_1101") then
				-- Reset counter
				count<=b"0_0000_0000";
				-- Increment address
				if (addr_u=to_unsigned(SAMPLES-1,10)) then
					addr_u<=b"00_0000_0000";
				else
					addr_u<=addr_u+1;
				end if;
			else
				-- Increment counter
				count<=count+1;
			end if;
			-- Transmit data
			if (count=b"0_0000_0000") then
				if (rx_d3='0') or (addr_u/=b"00_0000_0000") then
					tx_o<='0';-- Start bit
				end if;
			elsif (count=b"0_0000_1101") then
				tx_o<=data_i(0);-- bit 0
			elsif (count=b"0_0001_1010") then
				tx_o<=data_i(1);-- bit 1
			elsif (count=b"0_0010_0111") then
				tx_o<=data_i(2);-- bit 2
			elsif (count=b"0_0011_0100") then
				tx_o<=data_i(3);-- bit 3
			elsif (count=b"0_0100_0001") then
				tx_o<=data_i(4);-- bit 4
			elsif (count=b"0_0100_1110") then
				tx_o<=data_i(5);-- bit 5
			elsif (count=b"0_0101_1011") then
				tx_o<=data_i(6);-- bit 6
			elsif (count=b"0_0110_1000") then
				tx_o<='1';-- bit 7
			elsif (count=b"0_0111_0101") then
				tx_o<='1';-- Stop bit
			elsif (count=b"0_1000_0010") then
				tx_o<='0';-- Start bit
			elsif (count=b"0_1000_1111") then
				tx_o<=data_i(7);-- bit 0
			elsif (count=b"0_1001_1100") then
				tx_o<=data_i(8);-- bit 1
			elsif (count=b"0_1010_1001") then
				tx_o<=data_i(9);-- bit 2
			elsif (count=b"0_1011_0110") then
				tx_o<=data_i(10);-- bit 3
			elsif (count=b"0_1100_0011") then
				tx_o<=data_i(11);-- bit 4
			elsif (count=b"0_1101_0000") then
				tx_o<='0';-- bit 5
			elsif (count=b"0_1101_1101") then
				tx_o<='0';-- bit 6
			elsif (count=b"0_1110_1010") then
				tx_o<='0';-- bit 7
			elsif (count=b"0_1111_0111") then
				tx_o<='1';-- Stop bit
			end if;
		end if;
	end process;
end arch;