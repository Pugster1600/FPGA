----------------------------------------------------------------------------
-- Company: Johns Hopkins University 520.424 FPGA Synthesis Lab
-- Engineer: Johnny Shi
--
-- Create Date: 11/20/2025
-- Design Name: Programmable Counter
-- Module Name: counter - Behavioral
-- Project Name: FPGA Synthesis Lab Professional Counter
-- Target Devices: Digilent Cmod A7-35T
-- Tool Versions: Vivado 2025.1
--
-- Description:
-- This module implements a programmable counter with asynchronous reset
-- Features:
--   - Generalizable bit length (NBITS)
--   - Generalizable initial count value (INITC)
--   - Asynchronous reset input
--   - Synchronous load input
--   - Programmable start, increment, and end values
-- Operation:
--   - On reset, the counter initializes to INITC
--   - On load, the counter loads to count_i
--   - On each clock cycle, the counter increments by inc_i and carry_i
--     If count is greater than end_i, it wraps around and sets carry_o
--     If not, it updates the count without setting carry_o
--
-- Dependencies:
--  Requires ieee.numeric_std for arithmetic on unsigned types.
--
-- Revision History:
--  0.01 - 11/20/2025 - Professional Counter created and finished
--
-- Additional Comments:
--  This counter is designed with two segment coding
--  carry_o is combinational while count_o is registered
----------------------------------------------------------------------------

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
        inc_i : in std_logic_vector(NBITS - 1 downto 0); -- increment
        end_i : in std_logic_vector(NBITS - 1 downto 0); -- end count
        count_i : in std_logic_vector(NBITS - 1 downto 0); --count in
        carry_i : in std_logic; --carry into the counter
        count_o : out std_logic_vector(NBITS - 1 downto 0); --count out
        carry_o : out std_logic --carry out of the counter
    );
end counter;

architecture arch of counter is
    signal carry_i_u : unsigned(0 downto 0); -- 1-bit unsigned input
    signal count_i_u : unsigned(NBITS - 1 downto 0); -- unsigned count_i
    signal count_o_u : unsigned(NBITS - 1 downto 0) 
                     := to_unsigned(INITC, NBITS); --unsigned count_o
    signal inc_i_u : unsigned(NBITS - 1 downto 0); -- unsigned inc_i
    signal beg_i_u : unsigned(NBITS - 1 downto 0); -- unsigned beg_i
    signal end_i_u : unsigned(NBITS - 1 downto 0); -- unsigned end_i
    signal combinational_count_u : unsigned (NBITS - 1 downto 0);

begin
    -- initialize unsigned signals from ports
    carry_i_u(0) <= carry_i;
    count_i_u <= unsigned(count_i);
    count_o <= std_logic_vector(count_o_u);
    inc_i_u <= unsigned(inc_i);
    beg_i_u <= unsigned(beg_i);
    end_i_u <= unsigned(end_i);

    -- Combinational process: next counter value and carry_o
process(load_i, reset_i, count_o_u, carry_i_u, inc_i_u, end_i_u, beg_i_u)
begin
    -- asynchronous reset and load
    if load_i = '1' or reset_i = '1' then
        carry_o <= '0';
    -- overflow condition - counter wraps
    elsif ((b"0" & carry_i_u) + (b"0" & inc_i_u) + 
            (b"0" & count_o_u) > (b"0" & end_i_u)) then
        combinational_count_u <= count_o_u + inc_i_u + carry_i_u - 
                                (end_i_u - beg_i_u + 1);
        carry_o <= '1';
    -- normal counting condition
    else
        combinational_count_u <= count_o_u + inc_i_u + carry_i_u;
        carry_o <= '0'; 
    end if;
end process;

-- Sequential: register the counter value with async reset and sync load
process (clock_i, reset_i)
begin
    -- async reset to INITC
    if reset_i = '1' then 
        count_o_u <= to_unsigned(INITC, NBITS);
    elsif rising_edge(clock_i) then
        -- synchronous load of count_i to count_o
        if load_i = '1' then
          count_o_u <= count_i_u;
        -- register the combinational count to count_o
        else
            count_o_u <= combinational_count_u;
        end if;
    end if;
end process;
end arch;