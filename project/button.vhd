library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity button is
	port(
		clk:   in  std_logic;
		btn_i: in std_logic;
    btn_o: out std_logic;
    level_o: out std_logic
	);
end button;

architecture arch of button is
	signal cntr: unsigned(6 downto 0);
  signal r_meta : std_logic_vector(2 downto 0):=b"000";
  signal r_saturation : unsigned(18 downto 0):=b"0000000000000000000";
  signal r_saturated : std_logic := '0';
  signal r_prev_saturated : std_logic := '0';

  constant SAT_MAX : unsigned(18 downto 0) := b"1111111111111111111";
  constant SAT_MIN : unsigned(18 downto 0) := b"0000000000000000000";
  
  -- Red button debouncing
begin
red_button: process(clk) 
  begin 
    if rising_edge(clk) then
      r_meta(0) <= btn_i;
      r_meta(1) <= r_meta(0);
      r_meta(2) <= r_meta(1);

      if (r_meta(2) = '0') then --pull up resistor thus button not pressed
        if (r_saturation > SAT_MIN) then --1. switch from /= SAT_MIn to > SAT_Min
          r_saturation <= r_saturation - 1;
        --else
        --  r_saturated <= '0';
        end if;
      elsif (r_meta(2) = '1') then
        if (r_saturation < SAT_MAX) then
          r_saturation <= r_saturation + 1;
        --else
        --  r_saturated <= '1';
        end if;
      end if;

      -- need to separate the two conditions since need to check for both
      if r_saturation = SAT_MAX then
        r_saturated <= '1';
        level_o <= '1';
      elsif r_saturation = SAT_MIN then
        r_saturated <= '0';
        level_o <= '0';
      else
        level_o <= '0';
      end if;

      if r_saturated = '1' and r_prev_saturated = '0' then
        btn_o <= '1';
      else
        btn_o <= '0';
      end if;

      -- update every clk cycle so that if rising edge met, it is only met once rather than forever
      r_prev_saturated <= r_saturated;
    end if;
  end process;
end arch;