library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab06 is
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
end lab06;

architecture arch of lab06 is
  type uart_state is (IDLE, START, DATA, STOP);
	component lab06_gui
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

  signal tx_current_bit : unsigned(3 downto 0) := to_unsigned(0,4); --only 8 data states
  signal tx_current_state : uart_state := IDLE;
  signal tx_counter : unsigned(7 downto 0) := to_unsigned(0,8);

  signal rx_current_bit : unsigned(3 downto 0) := to_unsigned(0,4); --only 8 data states
  signal rx_current_state : uart_state := IDLE;
  signal rx_counter : unsigned(7 downto 0) := to_unsigned(0, 8);

  signal stx_sig : std_logic_vector(2 downto 0) := "000";

  constant baud_period : integer := 104; --12mhz * 1/115200
begin
	gui: lab06_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i,trig_o=>trig);

	-- Example default state of FPGA outputs
	-- srx<='1';
  -- non UART pins driven to idle state bc the constraint file has all of these in use
	 nss<='1';
	 sck<='0';
	 sdi<='0';
	 scl<='Z';
	 sda<='Z';
-- tx fsm

-- actually trig might be for the rx fsm
process (clk)
begin
  if rising_edge(clk) then
    --metastability -> 1. FIRST SUGGESTION 1.1 make sure everything is clocked or use a pipeline in order to ensure timing
    case tx_current_state is
      when IDLE =>
        srx <= '1'; --THINGS THAT WE WANT TO ONLY CHANGE DURING A RISING EDGE WE SHOULD PUT IN A CLOCKED PROCESS
        if trig = '1' then --basically the ready flag for sending data -> also only doing it once per trigger so we dont put it in sensitivty list!
          -- also we should ignore it for all other states which is why only in IDLE state!
          tx_counter <= to_unsigned(0, 8); --idk the syntax
          tx_current_bit <= to_unsigned(0, 4);
          tx_current_state <= START;
        end if;

      when START =>
        -- bit is high throughout enetire state
        srx <= '0'; --pull low to indicate start condition
        if tx_counter > baud_period then --need to change the type
          tx_current_state <= DATA;
          tx_counter <= to_unsigned(0, 8); --same here change the type
          tx_current_bit <= to_unsigned(0,4);
        else
          tx_counter <= tx_counter + 1;
        end if;

      when DATA =>
        srx <= data_o(to_integer(tx_current_bit)); 
        if tx_counter > baud_period then
          if tx_current_bit + 1 >= 8 then --finished all data, reset all counters
            tx_current_state <= STOP;
            tx_current_bit <= to_unsigned(0,4);
            tx_counter <= to_unsigned(0,8);
          else 
            tx_current_bit <= tx_current_bit + 1;
            tx_counter <= to_unsigned(0,8);
          end if;
        else
          tx_counter <= tx_counter + 1;
        end if;

      when STOP => --current state
        srx <= '1'; --output
        if tx_counter > baud_period then --transition logic
          tx_current_state <= IDLE;
          tx_counter <= to_unsigned(0,8);
          tx_current_bit <= to_unsigned(0,4);
        else
          tx_counter <= tx_counter + 1;
        end if;

      when others =>
        null;
      end case;
  end if;
end process;

--rx fsm
process(clk)
begin
  if rising_edge(clk) then
    stx_sig(0) <= stx;
    stx_sig(1) <= stx_sig(0);
    stx_sig(2) <= stx_sig(1);
    -- ONLY LATCH AT ONE INSTANCE so say when count = 50 or something. Try to latch at the middle
    case rx_current_state is
      when IDLE =>
        -- using sig because cannot read directly from input i guess
        if stx_sig(2) = '0' then -- ACTUALLY IT IS THE READING OF THE RX LINE BEING PULLED LOW!!
          rx_current_state <= START;
          rx_counter <= to_unsigned(0,8);
          rx_current_bit <= to_unsigned(0,4);
        end if;
      when START =>
        if rx_counter > baud_period then
          rx_current_state <= DATA;
          rx_counter <= to_unsigned(0,8);
          rx_current_bit <= to_unsigned(0,4);
        else
          rx_counter <= rx_counter + 1;
        end if;

      when DATA =>
        if rx_counter > baud_period then
          if rx_current_bit + 1 >= 8 then -- maybe the stop condition here should be seeing that the line is pulled low again or something?
            rx_current_bit <= to_unsigned(0, 4);
            rx_current_state <= STOP;
            rx_counter <= to_unsigned(0,8);
          else 
            rx_current_bit <= rx_current_bit + 1;
            rx_counter <= to_unsigned(0,8);
          end if;
          
        elsif rx_counter = 52 then --104 / 2 = 52
          data_i(to_integer(rx_current_bit)) <= stx_sig(2);
          rx_counter <= rx_counter + 1;
        
        else
          rx_counter <= rx_counter + 1;
        end if;

      when STOP =>
        if rx_counter > baud_period then
          rx_current_state <= IDLE;
          rx_counter <= to_unsigned(0,8);
          rx_current_bit <= to_unsigned(0,4);
        else 
          rx_counter <= rx_counter + 1;
        end if;

      when others =>
        null;
    end case;
  end if;
end process;
--IMPORTNAT: rx does not know when tx ends just the configuratoin
-- this makes sense since tx signals an end with the line being pulled low BUT that could be confused for a data bit
-- unlike tx which we konw idle = 1 then it pulls the line low
end arch;