library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab03b_tb is
end lab03b_tb;

architecture arch of lab03b_tb is
	component counter
		generic(
			NBITS: natural;-- Counter size
			INITC: natural -- Power-on reset
		);
		port(
			clock_i: in  std_logic; -- Input clock
			reset_i: in  std_logic; -- Asynchronous reset
			load_i:  in  std_logic; -- Synchronous load
			beg_i:   in  std_logic_vector(NBITS-1 downto 0); -- Start count
			inc_i:   in  std_logic_vector(NBITS-1 downto 0); -- Increment
			end_i:   in  std_logic_vector(NBITS-1 downto 0); -- End count
			count_i: in  std_logic_vector(NBITS-1 downto 0); -- Count in
			carry_i: in  std_logic; -- Carry-in for cascading
			count_o: out std_logic_vector(NBITS-1 downto 0); -- Count out
			carry_o: out std_logic  -- Carry-out for cascading
		);
	end component;

  signal data_o : std_logic_vector(27 downto 0); -- the individual instances will get connected to this
  signal data_i : std_logic_vector(27 downto 0);
  signal carry_sig: std_logic_vector(7 downto 0);
  signal turbo_sig : std_logic;
  signal beg_h1_sig : std_logic_vector(3 downto 0);
  signal end_h1_sig : std_logic_vector(3 downto 0);
  
  signal set_time0 : std_logic_vector(27 downto 0) := std_logic_vector(to_unsigned(0, 28));

  signal clk : std_logic;
  signal led_sig : std_logic_vector(1 downto 0);
  signal btn_sync: std_logic_vector(1 downto 0);

begin
  prescalar : counter
    generic map (
      NBITS => 12, 
      INITC => 0
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => std_logic_vector(to_unsigned(0, 12)),
		  inc_i => std_logic_vector(to_unsigned(0, 12)),
		  end_i => std_logic_vector(to_unsigned(1199, 12)), --9 or 10
		  count_i => (others => '0'), --maps everything else to 0 
		  carry_i => '1', 
		  count_o => open, 
		  carry_o => carry_sig(0)
    );


  divider : counter 
    generic map (
      NBITS => 12, 
      INITC => 0
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => std_logic_vector(to_unsigned(0, 12)),
		  inc_i => std_logic_vector(to_unsigned(0, 12)),
		  end_i => std_logic_vector(to_unsigned(999, 12)), --9 or 10
		  count_i => (others => '0'), 
		  carry_i => turbo_sig, 
		  count_o => open, 
		  carry_o => carry_sig(1)
    );

  tens : counter 
    generic map (
      NBITS => 4, 
      INITC => 7
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => std_logic_vector(to_unsigned(0, 4)),
		  inc_i => std_logic_vector(to_unsigned(0, 4)),
		  end_i => std_logic_vector(to_unsigned(9, 4)), --9 or 10
		  count_i => data_o(3 downto 0), 
		  carry_i => carry_sig(1), 
		  count_o => data_i(3 downto 0), 
		  carry_o => carry_sig(2)
    );

  second_ones : counter 
    generic map (
      NBITS => 4, 
      INITC => 6
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => std_logic_vector(to_unsigned(0, 4)),
		  inc_i => std_logic_vector(to_unsigned(0, 4)),
		  end_i => std_logic_vector(to_unsigned(9, 4)), -- 9 or 10
		  count_i => data_o(7 downto 4), 
		  carry_i => carry_sig(2), 
		  count_o => data_i(7 downto 4), 
		  carry_o => carry_sig(3)
    );

  second_tens : counter 
    generic map (
      NBITS => 4, 
      INITC => 5
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => std_logic_vector(to_unsigned(0, 4)),
		  inc_i => std_logic_vector(to_unsigned(0, 4)),
		  end_i => std_logic_vector(to_unsigned(5, 4)), -- 5 or 6
		  count_i => data_o(11 downto 8), 
		  carry_i => carry_sig(3), 
		  count_o => data_i(11 downto 8), 
		  carry_o => carry_sig(4)
    );

  minute_ones : counter 
    generic map (
      NBITS => 4, 
      INITC => 4
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => std_logic_vector(to_unsigned(0, 4)),
		  inc_i => std_logic_vector(to_unsigned(0, 4)),
		  end_i => std_logic_vector(to_unsigned(9, 4)), -- 5 or 6
		  count_i => data_o(15 downto 12), 
		  carry_i => carry_sig(4), 
		  count_o => data_i(15 downto 12), 
		  carry_o => carry_sig(5)
    );

  minute_tens : counter 
    generic map (
      NBITS => 4, 
      INITC => 3
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => std_logic_vector(to_unsigned(0, 4)),
		  inc_i => std_logic_vector(to_unsigned(0, 4)),
		  end_i => std_logic_vector(to_unsigned(5, 4)), -- 5 or 6
		  count_i => data_o(19 downto 16), 
		  carry_i => carry_sig(5), 
		  count_o => data_i(19 downto 16), 
		  carry_o => carry_sig(6)
    );

  hours_ones : counter 
    generic map (
      NBITS => 4, 
      INITC => 2
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => beg_h1_sig,
		  inc_i => std_logic_vector(to_unsigned(0, 4)),
		  end_i => end_h1_sig, -- 5 or 6
		  count_i => data_o(23 downto 20), 
		  carry_i => carry_sig(6), 
		  count_o => data_i(23 downto 20), 
		  carry_o => carry_sig(7)
    );

  hours_tens : counter 
    generic map (
      NBITS => 4, 
      INITC => 1
    )
    port map (
      clock_i => clk,
		  reset_i => '0',
		  load_i => '0',
		  beg_i => std_logic_vector(to_unsigned(0, 4)),
		  inc_i => std_logic_vector(to_unsigned(0, 4)),
		  end_i => std_logic_vector(to_unsigned(2, 4)), -- hour values can be 0,1,2
		  count_i => data_o(27 downto 24), 
		  carry_i => carry_sig(7), 
		  count_o => data_i(27 downto 24), 
		  carry_o => open
    );
    
  turbo_sig <= carry_sig(0);
  
  beg_h1_sig<=std_logic_vector(to_unsigned(0,4));
  
  end_h1_sig<=std_logic_vector(to_unsigned(9,4)) when
    (data_i(27 downto 24)=std_logic_vector(to_unsigned(0,4)) or 
    data_i(27 downto 24)=std_logic_vector(to_unsigned(1,4)))
    else std_logic_vector(to_unsigned(3,4));

      --NEED TO REGISTER THIS OR ELSE RISK METASTABILITY
	-- led <= led_sig;
process(clk)
begin
  if rising_edge(clk) then
    -- two-stage synchronizer
    -- btn_sync <= btn;
    if data_o = set_time0 then
      led_sig <= b"11";
    end if;

		if btn_sync(1) = '1' then
			led_sig <= b"00";
		end if;

		if btn_sync(0) = '1' then
			set_time0 <= data_i;
		end if;
  end if;
end process;

process
begin
end process;
  
  --need to set a condition that if 23:59:59... then everything goes to 0
  
end arch;

-- IMPORTANT: metastability
-- only one thing driving a signal at a time
-- tb around the top level module