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
  -- 1. signal : use std_logic-vector for better IO definition aka ports BUT the actual math is done by unsigned
  -- in hardware they are the same wire so this is a synthesis thing for VHDL purposes aka hardware abstraction
  signal carry_i_uint : unsigned(0 downto 0);
  signal count_i_uint : unsigned(NBITS - 1 downto 0);
  signal count_o_uint : unsigned(NBITS - 1 downto 0) := to_unsigned(INITC, NBITS);
  signal inc_i_uint : unsigned(NBITS - 1 downto 0);
  signal beg_i_uint : unsigned(NBITS - 1 downto 0);
  signal end_i_uint : unsigned(NBITS - 1 downto 0);
  signal combinational_count_uint : unsigned (NBITS - 1 downto 0);

begin
  -- order does not matter as long as long as port output is not on the right side of declaration
  -- since this is just wires
  carry_i_uint(0) <= carry_i;
  count_i_uint <= unsigned(count_i);
  count_o <= std_logic_vector(count_o_uint);
  inc_i_uint <= unsigned(inc_i);
  beg_i_uint <= unsigned(beg_i);
  end_i_uint <= unsigned(end_i);

  -- combinational process -> anything involved in this process SHOULD CAUSE IT unless its meant to be a constant!
  process(load_i, reset_i, count_o_uint, carry_i_uint, inc_i_uint, end_i_uint, beg_i_uint) --load_i, reset_i
    begin
      -- stuff is not registered so it updated immedately!!
        --cast to signed and unsigned first -> just need to sign extend by 1 since max INC is NBITS long (the carryin = 1 is still within range too)
        if load_i = '1' or reset_i = '1' then
          carry_o <= '0';
        elsif ((b"0" & carry_i_uint) + (b"0" & inc_i_uint) + (b"0" & count_o_uint) > (b"0" & end_i_uint)) then
        -- 1. using an intermediate combinational_count_uint is BETTER rather than adding to self cause 1. infinite loop
        -- 2. we have on registered value only aka count_o
        -- so any updated values are calculated from count_o + EXTRA, value outputed to count, registered in count_o
        -- THE THINGS BEING ADDED NEED TO BE REGISTERED!!! if it can cause infinite loop
        combinational_count_uint <= count_o_uint + inc_i_uint + carry_i_uint - (end_i_uint - beg_i_uint + 1);
        --carry_o <= '1';
        carry_o <= '1';--(not load_i) and (not reset_i); --aka just (not reset_i) but easier to see this way
      else
        combinational_count_uint <= count_o_uint + inc_i_uint + carry_i_uint;
        carry_o <= '0';
      end if;
  end process;

  -- registered process -> how does load_i play a factor in this?
  -- should reset be in the combinational side of things??
  process (clock_i, reset_i)
    begin
      -- If reset, force everything to INITC
      if reset_i = '1' then 
        count_o_uint <= to_unsigned(INITC, NBITS);
      --if rising edge, either load new value OR add
      elsif rising_edge(clock_i) then
        if load_i = '1' then
          count_o_uint <= count_i_uint;
          -- carry_o <= '0'; --contention cause 2 different things driving it, one combinational and one seq
        else
          count_o_uint <= combinational_count_uint;
      end if;
    end if;
  end process;
end arch;
