library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab04c is 
  port (
    clk: in  std_logic;
		rx:  in  std_logic;
		tx:  out std_logic;
		btn: in  std_logic;
		led: out std_logic_vector(1 downto 0)

    -- COMMENT OUT
    --data_o_tb:    in std_logic_vector(41 downto 0); --data from matlab
	  --data_i_tb:    out std_logic_vector(41 downto 0); --data to matlab
	  --start_tb:     out std_logic;
	  --remainder_tb: out unsigned(62 downto 0); --unsigned meant only for internal use not ports
	  --divisor_tb:   out unsigned(62 downto 0);
	  --factor_tb:    out unsigned(21 downto 0); --check all the way up to 2^21 (half way mark)
    --count_tb: out unsigned (7 downto 0);
    --dividend_tb : out unsigned(41 downto 0)

  );
end lab04c;

architecture arch of lab04c is
  -- 1. signals

  -- 2. component declaration
  component lab04_gui is
	  port(
	  	clk_i:  in  std_logic;
	  	rx_i:   in  std_logic;
	  	tx_o:   out std_logic:='1';
	  	data_o: out std_logic_vector(41 downto 0);
	  	data_i: in  std_logic_vector(41 downto 0)
	  );
  end component;

  signal data_o:    std_logic_vector(41 downto 0); --data from matlab
	signal data_i:    std_logic_vector(41 downto 0) :=std_logic_vector(to_unsigned(1, 42)); --data to matlab
	
  signal start:     std_logic:='0';
	signal remainder: unsigned(62 downto 0):= to_unsigned(0, 63); --unsigned meant only for internal use not ports
	signal divisor:   unsigned(62 downto 0);
	signal factor:    unsigned(21 downto 0):=b"100000_00000000_00000001"; --check all the way up to 2^21 (half way mark)
  signal btn_sync : std_logic_vector(3 downto 0) := b"0000"; -- rising edge detector
  signal count : unsigned (7 downto 0) := to_unsigned(23, 8);
	-- signal count:     unsigned(5 downto 0):=b"...";
  signal dividend : unsigned(41 downto 0) := TO_UNSIGNED(0, 42);
  signal largest_factor : std_logic_vector(41 downto 0) := std_logic_vector(to_unsigned(1, 42));
  signal is_prime : std_logic := '1';
  signal square : unsigned(43 downto 0) := to_unsigned(4, 44);

begin
  gui: lab04_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		                      data_o=>data_o,data_i=>data_i);
  
  -- COMMENT OUT
  --data_o <= data_o_tb;
  --data_i_tb <= data_i;
  --start_tb <= start;
  --remainder_tb <= remainder;
  --divisor_tb <= divisor;
  --factor_tb <= factor;
  --count_tb <= count;
  --dividend_tb <= dividend;

  -- when at 50k, the only difference is we are off by a factor of 2, this means we might be shifting too early, that is the difference (compare and contrast)
process(clk)
begin
  if rising_edge(clk) then
    -- metastability to connect async data aka on a different clk network for t_setup and t_hold
    btn_sync(0) <= btn;
    btn_sync(1) <= btn_sync(0);
    btn_sync(2) <= btn_sync(1);
    btn_sync(3) <= btn_sync(2);
    
    -- rising edge 
    if btn_sync(3) = '0' and btn_sync(2) = '1' and start = '0' then 
    --   led <= b"11";
      start <= '1';
      is_prime <= '1';
      -- NOTE: data_tb
      dividend <= unsigned(data_o); --how come changing this from data_o to data_tb makes such a big difference? -> simulation delta stuff ie timing requiremnt issue
      -- it cant be a coincidene there has to be a reason since it is reproducable
    end if;
     
    -- count counts the divisor shifts
    case count is
      -- 1. zero shift aka idle state in the current factor
      when b"00101010" => -- NOTE: UPDATE COUNT (need to shift 40 times, 41 is the idle state) 41, 42? -> actually its 42, 43 probably cause we start at 0 shift (so need to account for 1 extra)
        -- 1.1 start count at 0 or 2^21 -> either finished going through all factors up to 2^21 or have not started yet (start or end of going through all factors)
        if (factor = b"100000_00000000_00000001") then
          -- 1.1.1 idle state, starting to go through all factors
          if (start = '1') then -- NOTE: we also need to check if we have finished
            led <= b"11";
            factor <= b"000000_00000000_00000010"; -- start at factor = 2
            count <= b"00000000"; --start the count at shift = 0 (ekse stuck in infinite case loop)
            square <= to_unsigned(4, 44);

            data_i <= std_logic_vector(to_unsigned(1,42));
            --dividend <= unsigned(data_o);
            --remainder <= to_unsigned(1, 63);
            --remainder <= to_unsigned(dividend, 63);
            
            remainder <= unsigned((62 downto 42 => '0') & dividend); --extend the dividend [00]DIVIDEND
            divisor <= shift_left(to_unsigned(2, 63), 41); --extend the divisor FACTOR[00] -> MAKE SURE TO NOT USED REGISTERED SIGNALS HERE SINCE ONE CLOCK DELAY
          else
            led <= b"00";
          end if;
        
        -- 1.2 start new factor/count BUT we are not at factors 0 or 2^21, so we are in the middle of going through all factors and starting at new factor
        -- NOTE: there are a bunch of places to put this stuff, but a state machine makes it so that we have no collision!
        else
          if (factor = to_unsigned(2, 22)) then
            factor <= to_unsigned(3, 22);
            square <= to_unsigned(9, 44);
            divisor <= shift_left(unsigned((62 downto 22 => '0')&(factor + 1)), 41); 
          else 
            factor <= factor + 2;
            square <= (factor * factor) + 4 + shift_left(factor, 2); -- need to update the square rule
            divisor <= shift_left(unsigned((62 downto 22 => '0')&(factor + 2)), 41); 
          end if;
        
          remainder <= unsigned((62 downto 42 => '0') & dividend);
          -- remainder <= shift_right(unsigned((62 downto 42 => '0') & dividend), 21); --iniitalize dividend
          --divisor <= shift_left(unsigned((62 downto 22 => '0')&(factor + 1)), 41); --iniitalize divisor -> factor + 1 shifted (make sure not registered)
          count <= b"00000000"; --start the count at shift = 0
        end if;


      -- 2. final shift aka shift 41 times
      when b"00101001" => -- NOTE: UPDATE COUNT (40 is final, 41 is idle state)
        if (remainder = to_unsigned(0, 63)) or ((remainder = divisor)) then --remainder >= divsor and remainder - divisor = 0          
          if (unsigned((41 downto 22 => '0') & factor) /= dividend) and is_prime = '1' then --21, 42
            is_prime <= '0';
            data_i <= std_logic_vector(unsigned((41 downto 22 => '0') & factor));

            -- if it is not divisible by 2, then it is not divisible by any other even numebr
            -- thus we can start counting by adding 2 instead
            -- but this also means that we are never going to land at 2^21 since we are only going by odd numbers
            -- so we need to change our idle state to be say 2^21 + 1
            count <= b"00000000";
            factor <= b"100000_00000000_00000001"; --terminate when we figure out that it is not prime 
            start <= '0';
            is_prime <= '1';
          elsif (unsigned((41 downto 22 => '0') & factor) = dividend) and is_prime = '1' then
            data_i <= std_logic_vector(unsigned((41 downto 22 => '0') & factor));

            factor <= b"100000_00000000_00000001";
            count <= b"00000000";
            start <= '0';
            is_prime <= '1';
          elsif square > unsigned(b"00" & dividend) then

            factor <= b"100000_00000000_00000001";
            count <= b"00000000";
            start <= '0';
            is_prime <= '1';
          end if;

            
      end if;

      if (factor = b"100000_00000000_00000001") then
        if (is_prime = '1') then
          data_i <= std_logic_vector(dividend);
        end if;

        start <= '0';
        is_prime <= '1';
        square <= to_unsigned(4, 44);

      end if;

        -- finished shifting, change to new factor + reset shift count
        --factor <= factor + 1;
        count <= count + 1; --NOTE: UPDATE COUNT: reset count => '00010111'
        -- remainder <= shift_right(unsigned((62 downto 42 => '0') & dividend), 21);
      -- 3. every other shift
      when others => 
      -- move the signals around since there is going to be some timing issues unless purely combinational
        if (remainder >= divisor) then -- subtract just like in long division we are moving to check tens place if hundreds too small (dont keep track of quotient since only care about final value = 0 or not)
          remainder <= remainder - divisor;
        end if;
        -- i tihnk the timing here is wrong? there are some dependecies
        divisor <= shift_right(divisor, 1); --shift divisor right
        count <= count + 1; --
    end case;
  end if;
end process;

end arch;