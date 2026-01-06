library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_a is
	port(
		clk:   in  std_logic;
		rx:    in  std_logic;
		tx:    out std_logic;
		btn_r: in  std_logic;
		btn_b: in  std_logic;
		btn_y: in  std_logic;
		btn_g: in  std_logic
	);
end lab_a;

architecture arch of lab_a is
	component lab_a_gui
		port(
			clk:    in  std_logic;
			rx:     in  std_logic;
			tx:     out std_logic;
			cntr_i: in  unsigned(6 downto 0);
			cntb_i: in  unsigned(6 downto 0);
			cnty_i: in  unsigned(6 downto 0);
			cntg_i: in  unsigned(6 downto 0)
		);
	end component;
	signal cntr: unsigned(6 downto 0);
	signal cntb: unsigned(6 downto 0);
	signal cntg: unsigned(6 downto 0);
  signal cnty: unsigned(6 downto 0);


  signal r_meta : std_logic_vector(2 downto 0):=b"000";
  signal g_meta : std_logic_vector(2 downto 0):=b"000";
  signal b_meta : std_logic_vector(2 downto 0):=b"000";
  signal y_meta : std_logic_vector(2 downto 0):=b"000";

  signal r_saturation : unsigned(18 downto 0):=b"0000000000000000000";
  signal r_saturated : std_logic := '0';
  signal r_prev_saturated : std_logic := '0';
  signal g_saturation : unsigned(18 downto 0):=b"0000000000000000000";
  signal g_saturated : std_logic := '0';
  signal g_prev_saturated : std_logic := '0';
  constant SAT_MAX : unsigned(18 downto 0) := b"1111111111111111111";
  constant SAT_MIN : unsigned(18 downto 0) := b"0000000000000000000";

  constant GUI_MAX : unsigned(6 downto 0) := b"1111111";
  constant GUI_MIN : unsigned(6 downto 0) := b"0000000";
begin
	gui: lab_a_gui port map(clk=>clk,rx=>rx,tx=>tx,
		cntr_i=>cntr,cntb_i=>cntb,cnty_i=>cnty,cntg_i=>cntg);
  
  -- Red button debouncing
red_button: process(clk) 
  begin 
    if rising_edge(clk) then
      r_meta(0) <= btn_r;
      r_meta(1) <= r_meta(0);
      r_meta(2) <= r_meta(1);

      if (r_meta(2) = '1') then --pull up resistor thus button not pressed
        if (r_saturation /= SAT_MIN) then
          r_saturation <= r_saturation - 1;
        else
          --r_saturation <= to_unsigned(0, r_saturation'high + 1);
          r_saturated <= '0';
          --r_prev_saturated <= r_saturated;
        end if;
      elsif (r_meta(2) = '0') then
        if (r_saturation /= SAT_MAX) then
          r_saturation <= r_saturation + 1;
        else
          --r_saturation <= to_unsigned(127, r_saturation'high + 1);
          r_saturated <= '1';
          --r_prev_saturated <= r_saturated;
        end if;
      end if;

      if r_saturated = '1' and r_prev_saturated = '0' then
        --r_prev_saturated <= r_saturated;
        if cntr /= GUI_MAX then
          cntr <= cntr + 1;
        else
          cntr <= GUI_MIN;
        end if;
      end if;

      -- update every clk cycle so that if rising edge met, it is only met once rather than forever
      r_prev_saturated <= r_saturated;
    end if;
  end process;

green_button: process(clk) 
  begin 
    if rising_edge(clk) then
      g_meta(0) <= btn_g;
      g_meta(1) <= g_meta(0);
      g_meta(2) <= g_meta(1);

      if (g_meta(2) = '1') then --pull up resistor thus button not pressed
        if (g_saturation /= SAT_MIN) then
          g_saturation <= g_saturation - 1;
        else
          g_saturated <= '0';
        end if;
      elsif (g_meta(2) = '0') then
        if (g_saturation /= SAT_MAX) then
          g_saturation <= g_saturation + 1;
        else
          g_saturated <= '1';
        end if;
      end if;

      
      if g_saturated = '1' and g_prev_saturated = '0' then
        if cntg /= GUI_MAX then
          cntg <= cntg + 1;
        else
          cntg <= GUI_MIN;
        end if;
      end if;

      -- update every clk cycle so that if rising edge met, it is only met once rather than forever
      g_prev_saturated <= g_saturated;
    end if;
  end process;

blue_button: process(clk)
  begin 
    if rising_edge(clk) then
      b_meta(0) <= btn_b;
      b_meta(1) <= b_meta(0);
      b_meta(2) <= b_meta(1);

      if (b_meta(2) = '1') and (b_meta(1) = '0') then
        if cntb /= GUI_MAX then
          cntb <= cntb + 1;
        else
          cntb <= GUI_MIN;
        end if;
      end if;
    end if;
  end process;

yellow_button: process(clk)
  begin 
    if rising_edge(clk) then
      y_meta(0) <= btn_y;
      y_meta(1) <= y_meta(0);
      y_meta(2) <= y_meta(1);

      if (y_meta(2) = '1') and (y_meta(1) = '0') then
        if cnty /= GUI_MAX then
          cnty <= cnty + 1;
        else
          cnty <= GUI_MIN;
        end if;
      end if;
    end if;
  end process;
end arch;