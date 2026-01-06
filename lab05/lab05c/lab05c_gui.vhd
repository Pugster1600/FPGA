library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab05c_gui is
	generic(
		SAMPLES: natural
	);
	port(
		clk_i:   in  std_logic;
		rx_i:    in  std_logic;
		tx_o:    out std_logic:='1';
		thrsh_o: out std_logic_vector(11 downto 0);
		addr_o:  out std_logic_vector(9 downto 0);
		data_i:  in  std_logic_vector(11 downto 0)
	);
end lab05c_gui;

architecture arch of lab05c_gui is
	signal rx_d1:    std_logic:='1';
	signal rx_d2:    std_logic:='1';
	signal rx_d3:    std_logic:='1';
	signal rx_count: unsigned(6 downto 0):=b"000_0000";
	signal rx_buf:   std_logic_vector(7 downto 0):=b"0000_0000";
	signal tx_count: unsigned(8 downto 0):=b"0_0000_0000";
	signal addr_u:   unsigned(9 downto 0):=b"00_0000_0000";
	signal temp_o:   std_logic_vector(6 downto 0):=b"000_0000";
	signal trig:     std_logic;
begin
	addr_o<=std_logic_vector(addr_u);

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			-- Metastability shift register
			rx_d1<=rx_i;
			rx_d2<=rx_d1;
			rx_d3<=rx_d2;
			-- Receive clock counter
			if (rx_count=b"000_0000") then
				-- Check for start bit
				if (rx_d3='0') then
					rx_count<=b"000_0001";
				end if;
				trig<='0';
			elsif (rx_count=b"111_1100") then
				-- Check for stop bit
				if (rx_d3='1') then
					rx_count<=b"000_0000";
					if (rx_buf(7)='1') then
						temp_o(6 downto 0)<=rx_buf(6 downto 0);
						trig<='0';
					else
						thrsh_o(11 downto 7)<=rx_buf(4 downto 0);
						thrsh_o(6 downto 0)<=temp_o(6 downto 0);
						trig<='1';
					end if;
				else
					trig<='0';
				end if;
			else
				-- Increment counter
				rx_count<=rx_count+1;
				trig<='0';
			end if;
			-- Receive data
			if (rx_count=b"001_0100") then
				rx_buf(0)<=rx_d3;
			end if;
			if (rx_count=b"010_0001") then
				rx_buf(1)<=rx_d3;
			end if;
			if (rx_count=b"010_1110") then
				rx_buf(2)<=rx_d3;
			end if;
			if (rx_count=b"011_1011") then
				rx_buf(3)<=rx_d3;
			end if;
			if (rx_count=b"100_1000") then
				rx_buf(4)<=rx_d3;
			end if;
			if (rx_count=b"101_0101") then
				rx_buf(5)<=rx_d3;
			end if;
			if (rx_count=b"110_0010") then
				rx_buf(6)<=rx_d3;
			end if;
			if (rx_count=b"110_1111") then
				rx_buf(7)<=rx_d3;
			end if;
			-- Transmit clock counter
			if (tx_count=b"0_0000_0000") then
				-- Check if threshold has been received
				if (trig='1') or (addr_u/=b"00_0000_0000") then
					tx_count<=b"0_0000_0001";
				end if;
			elsif (tx_count=b"1_0001_1101") then
				-- Reset counter
				tx_count<=b"0_0000_0000";
				-- Increment address
				if (addr_u=to_unsigned(SAMPLES-1,10)) then
					addr_u<=b"00_0000_0000";
				else
					addr_u<=addr_u+1;
				end if;
			else
				-- Increment counter
				tx_count<=tx_count+1;
			end if;
			-- Transmit data
			if (tx_count=b"0_0000_0000") then
				if (trig='1') or (addr_u/=b"00_0000_0000") then
					tx_o<='0';-- Start bit
				end if;
			elsif (tx_count=b"0_0000_1101") then
				tx_o<=data_i(0);-- bit 0
			elsif (tx_count=b"0_0001_1010") then
				tx_o<=data_i(1);-- bit 1
			elsif (tx_count=b"0_0010_0111") then
				tx_o<=data_i(2);-- bit 2
			elsif (tx_count=b"0_0011_0100") then
				tx_o<=data_i(3);-- bit 3
			elsif (tx_count=b"0_0100_0001") then
				tx_o<=data_i(4);-- bit 4
			elsif (tx_count=b"0_0100_1110") then
				tx_o<=data_i(5);-- bit 5
			elsif (tx_count=b"0_0101_1011") then
				tx_o<=data_i(6);-- bit 6
			elsif (tx_count=b"0_0110_1000") then
				tx_o<='1';-- bit 7
			elsif (tx_count=b"0_0111_0101") then
				tx_o<='1';-- Stop bit
			elsif (tx_count=b"0_1000_0010") then
				tx_o<='0';-- Start bit
			elsif (tx_count=b"0_1000_1111") then
				tx_o<=data_i(7);-- bit 0
			elsif (tx_count=b"0_1001_1100") then
				tx_o<=data_i(8);-- bit 1
			elsif (tx_count=b"0_1010_1001") then
				tx_o<=data_i(9);-- bit 2
			elsif (tx_count=b"0_1011_0110") then
				tx_o<=data_i(10);-- bit 3
			elsif (tx_count=b"0_1100_0011") then
				tx_o<=data_i(11);-- bit 4
			elsif (tx_count=b"0_1101_0000") then
				tx_o<='0';-- bit 5
			elsif (tx_count=b"0_1101_1101") then
				tx_o<='0';-- bit 6
			elsif (tx_count=b"0_1110_1010") then
				tx_o<='0';-- bit 7
			elsif (tx_count=b"0_1111_0111") then
				tx_o<='1';-- Stop bit
			end if;
		end if;
	end process;
end arch;