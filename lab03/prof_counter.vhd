
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is 
  generic (
    NBITS : natural; --counter bit size
    INITC : natural  --power-on reset value
  );
  port (
    clock_i : in std_logic; --input clock
    reset_i : in std_logic; --async reset
    load_i : in std_logic; --sync load
    beg_i : in std_logic_vector(NBITS - 1 downto 0); -- start count
    inc_i : in std_logic_vector(NBITS - 1 downto 0); -- increment value
    end_i : in std_logic_vector(NBITS - 1 downto 0); -- end count
    count_i : in std_logic_vector(NBITS - 1 downto 0); --value to add from (data from reigster)
    carry_i : in std_logic; --carry into the counter
    count_o : out std_logic_vector(NBITS - 1 downto 0); --resulting value after add (data into register) 
    carry_o : out std_logic --carry out of the counter
  );
end counter;

architecture arch of counter is
  signal carry_i_u : unsigned(0 downto 0);
  signal count_i_u : unsigned(NBITS - 1 downto 0);
  signal count_o_u : unsigned(NBITS - 1 downto 0) := to_unsigned(INITC, NBITS);
  signal inc_i_u : unsigned(NBITS - 1 downto 0);
  signal beg_i_u : unsigned(NBITS - 1 downto 0);
  signal end_i_u : unsigned(NBITS - 1 downto 0);
  signal combinational_count_u : unsigned (NBITS - 1 downto 0);

begin
  carry_i_u(0) <= carry_i;
  count_i_u <= unsigned(count_i);
  count_o <= std_logic_vector(count_o_u);
  inc_i_u <= unsigned(inc_i);
  beg_i_u <= unsigned(beg_i);
  end_i_u <= unsigned(end_i);

  process(load_i, reset_i, count_o_u, carry_i_u, inc_i_u, end_i_u, beg_i_u)
    begin
        if load_i = '1' or reset_i = '1' then
          carry_o <= '0';
        elsif ((b"0" & carry_i_u) + (b"0" & inc_i_u) + (b"0" & count_o_u) > (b"0" & end_i_u)) then
        combinational_count_uint <= count_o_u + inc_i_u + carry_i_u - (end_i_u - beg_i_u + 1);
        carry_o <= '1';
      else
        combinational_count_u <= count_o_u + inc_i_u + carry_i_u;
        carry_o <= '0';
      end if;
  end process;

  process (clock_i, reset_i)
    begin
      if reset_i = '1' then 
        count_o_uint <= to_unsigned(INITC, NBITS);
      elsif rising_edge(clock_i) then
        if load_i = '1' then
          count_o_u <= count_i_u;
        else
          count_o_u <= combinational_count_u;
      end if;
    end if;
  end process;
end arch;
