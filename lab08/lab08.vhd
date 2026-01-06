library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity lab08 is
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
end lab08;

architecture arch of lab08 is
    component lab08_gui
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
    signal data_i:     std_logic_vector(7 downto 0);
    signal trig:        std_logic;
    signal scl_in:          std_logic;
    signal scl_out:         std_logic := '1';
    signal sda_in:          std_logic;
    signal sda_out:         std_logic := '1';
    
    type i2c_state_type is (
        IDLE,
        START_SDA_LOW,
        START_SCL_LOW,
        SEND_ADDR_BIT,
        ADDR_SCL_HIGH,
        ADDR_SCL_LOW,
        RELEASE_SDA_FOR_ADDR_ACK,
        ADDR_ACK_SCL_HIGH,
        CHECK_ADDR_ACK,
        ADDR_ACK_SCL_LOW,
        SEND_DATA_BIT,
        DATA_SCL_HIGH,
        DATA_SCL_LOW,
        RELEASE_SDA_FOR_DATA_ACK,
        DATA_ACK_SCL_HIGH,
        CHECK_DATA_ACK,
        DATA_ACK_SCL_LOW,
        STOP_SDA_HIGH,
        STOP_SCL_HIGH,
        REPEATED_START_SDA_LOW,
        REPEATED_START_SCL_LOW,
        SEND_READ_ADDR_BIT,
        READ_ADDR_SCL_HIGH,
        READ_ADDR_SCL_LOW,
        RELEASE_SDA_FOR_READ_ACK,
        READ_ACK_SCL_HIGH,
        CHECK_READ_ACK,
        READ_ACK_SCL_LOW,
        READ_SCL_HIGH,
        CAPTURE_DATA_BIT,
        READ_SCL_LOW,
        SEND_MASTER_NACK,
        MASTER_NACK_SCL_HIGH,
        MASTER_NACK_SCL_LOW,
        FINAL_STOP_SCL_HIGH,
        FINAL_STOP_SDA_HIGH,
        ERROR
    );
    
    -- Timing constants
    constant HALF_PERIOD : unsigned(7 downto 0) := to_unsigned(60, 8);  -- 50 microseconds
    constant QUARTER_PERIOD : unsigned(7 downto 0) := to_unsigned(30, 8);  -- 25 microseconds
    
    -- I2C address constants
    constant I2C_WRITE_ADDRESS : std_logic_vector(7 downto 0) := "10100000"; 
    constant I2C_READ_ADDRESS  : std_logic_vector(7 downto 0) := "10100001"; 
    
    -- Bit position constants
    constant BIT_COUNT_MAX : integer := 7;
    constant BIT_COUNT_MIN : integer := 0;
    
    signal timer_counter:   unsigned(7 downto 0) := (others => '0');
    signal timer_target:    unsigned(7 downto 0) := (others => '0');
    signal current_state :  i2c_state_type := IDLE;
    signal current_bit :   unsigned(3 downto 0) := (others => '0');
    signal write_data:      std_logic_vector(7 downto 0) := (others => '0');
    signal read_data:       std_logic_vector(7 downto 0) := (others => '0');

    signal scl_in_meta:     std_logic_vector(2 downto 0) := (others => '0');
    signal sda_in_meta:     std_logic_vector(2 downto 0) := (others => '0');
begin
    gui: lab08_gui port map(
        clk_i => clk,
        rx_i => rx,
        tx_o => tx,
        data_o => data_o,  
        data_i => data_i,    
        trig_o => trig       
    );

    scl_pin: IOBUF port map(
        O => scl_in,
        IO => scl,
        I => '0',
        T => scl_out
    );
    
    sda_pin: IOBUF port map(
        O => sda_in,
        IO => sda,
        I => '0',
        T => sda_out
    );

    -- Example default state of FPGA outputs
	srx<='1';
	nss<='1';
	sck<='0';
	sdi<='0';
	--scl<='1';
	--sda<='1';

process(clk)
begin
    if rising_edge(clk) then
        scl_in_meta(0) <= scl_in;
        scl_in_meta(1) <= scl_in_meta(0);
        scl_in_meta(2) <= scl_in_meta(1);
        sda_in_meta(0) <= sda_in;
        sda_in_meta(1) <= sda_in_meta(0);
        sda_in_meta(2) <= sda_in_meta(1);
        
        -- chec if timer has reached
        if timer_counter >= timer_target then
            timer_counter <= (others => '0');
            
            case current_state is
                --idle state
                when IDLE =>
                    if trig= '1' then
                        timer_target <= HALF_PERIOD;
                        current_state <= START_SDA_LOW;
                        write_data <= data_o;
                    end if;
                    
                -- start transmission by pulling sda low
                when START_SDA_LOW =>  
                    sda_out <= '0'; 
                    if sda_in_meta(2) = '0' then
                        current_state <= START_SCL_LOW;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                -- pull scl low
                when START_SCL_LOW =>
                    scl_out <= '0';
                    current_bit <= to_unsigned(BIT_COUNT_MAX, 4);
                    if scl_in_meta(2) = '0' then
                        current_state <= SEND_ADDR_BIT;
                        timer_target <= QUARTER_PERIOD;
                    end if; 
                    
                --send slave address -> repeat 1
                when SEND_ADDR_BIT =>  
                    sda_out <= I2C_WRITE_ADDRESS(to_integer(current_bit));
                    if sda_in_meta(2) = I2C_WRITE_ADDRESS(to_integer(current_bit)) then
                        current_state <= ADDR_SCL_HIGH;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                
                -- toggle clk
                when ADDR_SCL_HIGH =>  
                    scl_out <= '1';
                    if scl_in_meta(2) = '1' then
                        current_state <= ADDR_SCL_LOW;
                        timer_target <= HALF_PERIOD;
                    end if;
                
                -- toggle clk
                when ADDR_SCL_LOW =>  
                    scl_out <= '0';
                    if scl_in_meta(2) = '0' then
                        if current_bit > BIT_COUNT_MIN then
                            current_bit <= current_bit - 1;
                            current_state <= SEND_ADDR_BIT;
                        else
                            current_state <= RELEASE_SDA_FOR_ADDR_ACK;
                        end if;
                        timer_target <= QUARTER_PERIOD;
                    end if; 
                    
                --release sda for slave ack
                when RELEASE_SDA_FOR_ADDR_ACK =>  
                    sda_out <= '1'; 
                    current_state <= ADDR_ACK_SCL_HIGH;     
                    timer_target <= QUARTER_PERIOD;
                
                -- release clk for slave ack
                when ADDR_ACK_SCL_HIGH => 
                    scl_out <= '1'; 
                    if scl_in_meta(2) = '1' then
                        current_state <= CHECK_ADDR_ACK;     
                        timer_target <= HALF_PERIOD;
                    end if;
                
                -- check address check from slave
                when CHECK_ADDR_ACK =>  
                    if sda_in_meta(2) = '0' then
                        current_state <= ADDR_ACK_SCL_LOW;     
                    else    
                        current_state <= ERROR;
                    end if;
                
                -- once low, restart transmission
                when ADDR_ACK_SCL_LOW =>  
                    scl_out <= '0';
                    if scl_in_meta(2) = '0' then
                        current_bit <= to_unsigned(BIT_COUNT_MAX, 4);
                        current_state <= SEND_DATA_BIT;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                    
                -- send data to slave
                when SEND_DATA_BIT =>  
                    sda_out <= write_data(to_integer(current_bit));
                    if sda_in_meta(2) = write_data(to_integer(current_bit)) then
                        current_state <= DATA_SCL_HIGH;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                
                -- toggle clk
                when DATA_SCL_HIGH =>  
                    scl_out <= '1';
                    if scl_in_meta(2) = '1' then
                        current_state <= DATA_SCL_LOW;
                        timer_target <= HALF_PERIOD;
                    end if;
                
                -- toggle clk
                when DATA_SCL_LOW =>  
                    scl_out <= '0';
                    if scl_in_meta(2) = '0' then
                        if current_bit > BIT_COUNT_MIN then
                            current_bit <= current_bit - 1;
                            current_state <= SEND_DATA_BIT;
                        else
                            current_state <= RELEASE_SDA_FOR_DATA_ACK;
                        end if;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                    
                --release sda for slave ack
                when RELEASE_SDA_FOR_DATA_ACK =>  
                    sda_out <= '1'; 
                    current_state <= DATA_ACK_SCL_HIGH;     
                    timer_target <= QUARTER_PERIOD;
                
                -- release clk for slave ack
                when DATA_ACK_SCL_HIGH => 
                    scl_out <= '1'; 
                    if scl_in_meta(2) = '1' then
                        current_state <= CHECK_DATA_ACK;     
                        timer_target <= HALF_PERIOD;
                    end if;
                
                -- wait for slave data ack
                when CHECK_DATA_ACK =>  
                    if sda_in_meta(2) = '0' then
                        current_state <= DATA_ACK_SCL_LOW;     
                    else    
                        current_state <= ERROR;
                    end if;
                
                -- pull clk line to restart transmission
                when DATA_ACK_SCL_LOW =>  
                    scl_out <= '0'; 
                    if scl_in_meta(2) = '0' then
                        current_state <= STOP_SDA_HIGH;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                    
                --stop condition to let slave talk
                when STOP_SDA_HIGH =>  
                    sda_out <= '1'; 
                    if sda_in_meta(2) = '1' then
                        current_state <= STOP_SCL_HIGH;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                    
                when STOP_SCL_HIGH =>  
                    scl_out <= '1'; 
                    if scl_in_meta(2) = '1' then
                        current_state <= REPEATED_START_SDA_LOW;
                        timer_target <= QUARTER_PERIOD;
                    end if;     
                    
                --restart transmission by sending sda low
                when REPEATED_START_SDA_LOW =>  
                    sda_out <= '0'; 
                    if sda_in_meta(2) = '0' then
                        current_state <= REPEATED_START_SCL_LOW;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                
                --pull scl low
                when REPEATED_START_SCL_LOW =>
                    scl_out <= '0';
                    current_bit <= to_unsigned(BIT_COUNT_MAX, 4);
                    if scl_in_meta(2) = '0' then
                        current_state <= SEND_READ_ADDR_BIT;
                        timer_target <= QUARTER_PERIOD;
                    end if; 
                    
                --send address to read from slave
                when SEND_READ_ADDR_BIT =>  
                    sda_out <= I2C_READ_ADDRESS(to_integer(current_bit));
                    if sda_in_meta(2) = I2C_READ_ADDRESS(to_integer(current_bit)) then
                        current_state <= READ_ADDR_SCL_HIGH;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                
                -- toggle clk
                when READ_ADDR_SCL_HIGH =>  
                    scl_out <= '1';
                    if scl_in_meta(2) = '1' then
                        current_state <= READ_ADDR_SCL_LOW;
                        timer_target <= HALF_PERIOD;
                    end if;
                
                -- toggle clk
                when READ_ADDR_SCL_LOW =>  
                    scl_out <= '0';
                    if scl_in_meta(2) = '0' then
                        if current_bit > BIT_COUNT_MIN then
                            current_bit <= current_bit - 1;
                            current_state <= SEND_READ_ADDR_BIT;
                        else
                            current_state <= RELEASE_SDA_FOR_READ_ACK;
                        end if;
                        timer_target <= QUARTER_PERIOD;
                    end if; 
                    
                --wait for slave ack by releasing line
                when RELEASE_SDA_FOR_READ_ACK =>  
                    sda_out <= '1'; 
                    current_state <= READ_ACK_SCL_HIGH;     
                    timer_target <= QUARTER_PERIOD;
 
                when READ_ACK_SCL_HIGH => 
                    scl_out <= '1'; 
                    if scl_in_meta(2) = '1' then
                        current_state <= CHECK_READ_ACK;     
                        timer_target <= HALF_PERIOD;
                    end if;
                
                -- ensure slave ack
                when CHECK_READ_ACK =>  
                    if sda_in_meta(2) = '0' then
                        current_state <= READ_ACK_SCL_LOW;     
                    else    
                        current_state <= ERROR;
                    end if;
                
                -- toggle clk
                when READ_ACK_SCL_LOW =>  
                    scl_out <= '0';
                    if scl_in_meta(2) = '0' then
                        current_bit <= to_unsigned(BIT_COUNT_MAX, 4);
                        current_state <= READ_SCL_HIGH;
                        timer_target <= HALF_PERIOD;
                    end if; 

                --toggle clk
                when READ_SCL_HIGH =>  
                    scl_out <= '1';
                    if scl_in_meta(2) = '1' then
                        current_state <= CAPTURE_DATA_BIT;
                        timer_target <= HALF_PERIOD;
                    end if;
                
                -- read the data
                when CAPTURE_DATA_BIT =>  
                    read_data(to_integer(current_bit)) <= sda_in_meta(2);
                    current_state <= READ_SCL_LOW;
                
                -- retake control of clk line
                when READ_SCL_LOW =>  
                    scl_out <= '0';
                    if scl_in_meta(2) = '0' then
                        if current_bit > BIT_COUNT_MIN then
                            current_bit <= current_bit - 1;
                            current_state <= READ_SCL_HIGH;
                            timer_target <= HALF_PERIOD;
                        else
                            current_state <= SEND_MASTER_NACK;
                            timer_target <= QUARTER_PERIOD;
                        end if;
                    end if;
                    
                -- nack to end convo
                when SEND_MASTER_NACK =>  
                    data_i <= read_data;  -- Send read data to GUI
                    sda_out <= '1'; 
                    if sda_in_meta(2) = '1' then
                        current_state <= MASTER_NACK_SCL_HIGH;     
                        timer_target <= QUARTER_PERIOD;
                    end if;
                
                -- end transmission by pulling line high
                when MASTER_NACK_SCL_HIGH => 
                    scl_out <= '1'; 
                    if scl_in_meta(2) = '1' then
                        current_state <= MASTER_NACK_SCL_LOW;     
                        timer_target <= HALF_PERIOD;
                    end if;
                    
                when MASTER_NACK_SCL_LOW =>  
                    scl_out <= '0';
                    if scl_in_meta(2) = '0' then
                        current_state <= FINAL_STOP_SCL_HIGH; 
                        timer_target <= QUARTER_PERIOD;    
                    end if;
                    
                -- wait for handshake
                when FINAL_STOP_SCL_HIGH =>  
                    scl_out <= '1'; 
                    if scl_in_meta(2) = '1' then
                        current_state <= FINAL_STOP_SDA_HIGH;
                        timer_target <= QUARTER_PERIOD;
                    end if;
                    
                when FINAL_STOP_SDA_HIGH =>  
                    sda_out <= '1'; 
                    if sda_in_meta(2) = '1' then
                        current_state <= IDLE;
                        timer_target <= (others => '0');  -- Stop timer in IDLE
                    end if;                                 
                                                       
                when ERROR =>  
                    scl_out <= '1';
                    sda_out <= '1';
                    timer_target <= (others => '0');  -- Stop timer in IDLE
                    current_state <= IDLE;
                    
                when others =>
                    current_state <= IDLE;
            end case;
        elsif current_state /= IDLE then
            -- Only increment timer when not in IDLE state
            timer_counter <= timer_counter + 1;
        else
            -- In IDLE state, keep timer at 0
            timer_counter <= (others => '0');
        end if;
    end if;
end process;        
end arch;