library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab07 is
	port(
		clk: in    std_logic;
		rx:  in    std_logic;
		tx:  out   std_logic;
		srx: out   std_logic;-- PIC pin 9 RS-232
		stx: in    std_logic;-- PIC pin 10 RS-232
		nss: out   std_logic;-- PIC pin 11 SPI
		sck: out   std_logic;-- PIC pin 12 SPI
		sdi: out   std_logic;-- PIC pin 4 SPI
		sdo: in    std_logic;-- PIC pin 3 SPI
		scl: inout std_logic;-- PIC pin 6 I2C
		sda: inout std_logic -- PIC pin 5 I2C
	);
end lab07;

architecture arch of lab07 is
	--perspective of GUI so trig_o is out of gui
	component lab07_gui
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_o: out std_logic_vector(7 downto 0);
			data_i: in  std_logic_vector(7 downto 0);
			trig_o: out std_logic
		);
	end component;
	signal data_o:    std_logic_vector(7 downto 0);
	signal data_i:    std_logic_vector(7 downto 0);
	signal trig:      std_logic;

	type SPI_STATE is (IDLE_STATE, SELECT_STATE, SETUP_STATE, RISING_EDGE_STATE, SAMPLE_STATE, DATA_STATE, FALLING_EDGE_STATE, DESELECT_STATE);
	signal current_state : SPI_STATE := IDLE_STATE;
	signal trig_meta : std_logic_vector(2 downto 0) := "000";
	signal clk_counter : unsigned(7 downto 0) := to_unsigned(0, 8);
	signal current_tx_bit : unsigned(3 downto 0) := to_unsigned(7,4); --MSB first
	signal current_rx_bit : unsigned(3 downto 0) := to_unsigned(7,4); --MSB first

	constant clk_size : integer := 8;
	constant full_period : integer := 120;
	constant half_period : integer := 60;
	constant sample_point : integer := 45; -- Sample 3/4 through half period
begin
	gui: lab07_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i,trig_o=>trig);

	-- not used output pins
	scl<='Z';
	sda<='Z';
	srx<='0';

process (clk)
begin
	if rising_edge(clk) then
		-- trig meta
		trig_meta(0) <= trig;
		trig_meta(1) <= trig_meta(0);
		trig_meta(2) <= trig_meta(1);
		
		-- global counter
		if current_state /= IDLE_STATE then
			clk_counter <= clk_counter + 1;
		end if;

		case current_state is
			-- start state
			when IDLE_STATE =>
				sdi <= '0';
				nss <= '1';
				sck <= '0';

				if (trig_meta(2) = '1') then
					current_state <= SELECT_STATE;
					clk_counter <= to_unsigned(0, clk_size);
					current_tx_bit <= to_unsigned(7,4);
					current_rx_bit <= to_unsigned(7,4);
				end if;
			
			-- select slave
			when SELECT_STATE =>
				nss <= '0';
				sck <= '0';
				sdi <= data_o(to_integer(current_tx_bit));
				clk_counter <= to_unsigned(0,clk_size);
				current_state <= SETUP_STATE;
			
			-- time before first rising edge
			when SETUP_STATE =>
				nss <= '0';
				sck <= '0';
				if to_integer(clk_counter) >= half_period then
					current_state <= RISING_EDGE_STATE;
					clk_counter <= to_unsigned(0,clk_size);
				end if;

			-- create rising edge
			when RISING_EDGE_STATE =>
				nss <= '0';
				sck <= '1';
				if to_integer(clk_counter) >= sample_point then
					current_state <= SAMPLE_STATE;
				end if;

			-- sample after a certain period of time
			when SAMPLE_STATE =>
				nss <= '0';
				sck <= '1';
				data_i(to_integer(current_rx_bit)) <= sdo;
				
				if to_integer(clk_counter) >= half_period then
					current_state <= DATA_STATE;
					clk_counter <= to_unsigned(0,clk_size);
				end if;
			
			-- output data
			when DATA_STATE => 
				nss <= '0';
				sck <= '1';
				-- check if sent out al lbits
				if ((to_integer(current_tx_bit) = 0) and (to_integer(current_rx_bit) = 0)) then
					current_state <= DESELECT_STATE;
					clk_counter <= to_unsigned(0,clk_size);
				else
					current_tx_bit <= current_tx_bit - 1;
					current_rx_bit <= current_rx_bit - 1;
					current_state <= FALLING_EDGE_STATE;
				end if;

			-- falling edge
			when FALLING_EDGE_STATE =>
				nss <= '0';
				if to_integer(clk_counter) >= half_period then
					sck <= '0';
					sdi <= data_o(to_integer(current_tx_bit));
					current_state <= RISING_EDGE_STATE;
					clk_counter <= to_unsigned(0,clk_size);
				else
					sck <= '1';
				end if;
			
			-- end of transmission
			when DESELECT_STATE =>
				sck <= '0';
				sdi <= '0';
				if to_integer(clk_counter) >= half_period then
					current_rx_bit <= to_unsigned(7,4);
					current_tx_bit <= to_unsigned(7,4);
					clk_counter <= to_unsigned(0,clk_size);
					nss <= '1';
					current_state <= IDLE_STATE;
				else
					nss <= '0';
				end if;
			
			-- should not happen
			when others =>
				null;
		end case;
	end if;
end process;
end arch;