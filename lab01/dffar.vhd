library IEEE;
use IEEE.std_logic_1164.all;

entity dffar is
    port(
        D: in std_logic; --data input
        C: in std_logic; --clock input
        R: in std_logic;
        Q: out std_logic
    );
end dffar;

architecture behavior of dffar is
    -- signal
    begin
        process (r, c)
            begin
            -- r is prioritize
                if r = '1' then
                    q <= '0' after 0.1us; -- propogation delay
                elsif rising_edge(c) then
                    q <= d after 0.1us; --propogation delay
                end if;                                   
        end process;
    
end behavior;