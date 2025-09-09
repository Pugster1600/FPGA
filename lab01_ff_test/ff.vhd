library IEEE;
use IEEE.std_logic_1164.all;

entity ff is 
    port (
        d : in std_logic;
        clk : in std_logic;
        reset : in std_logic;
        q : out std_logic        
    );    
end ff;

-- ============anything that is a sequence of descriptions needs begin
-- like start of process or something
-- BUT need to say end if the thing has a name like process, architecture, entity etc
architecture behavior of ff is
    -- ====== 1. signals
    -- ====== 2. components
begin --===== do not need to have a matching end statement here
    process (clk, reset)
        begin
            if reset = '1' then
                q <= '0';
            elsif rising_edge(clk)then
                q <= d;
            end if;
    end process;
end behavior;

-- == must check for async reset first or else error
-- the reason is that reset should be the first thing to be checked
-- meaning reset should override the clock if both trigger the process
-- but more importantly
-- so the if statement order controls the priority!
-- RESET MUST BE FIRST IS THE MOST IMPORTANT TAKEAWAY