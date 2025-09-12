library IEEE;
use IEEE.std_logic_1164.all; 

-- single entity
entity srPriority is 
    port (
        nS: in std_logic;
        nR: in std_logic;
        Q: out std_logic
    );
end srPriority;

-- double architecture
architecture priority of srPriority is
begin
    -- way easier to describe BUT both technically synthesize to the same thing -> a latch primitive
    process(nS, nR)
        begin 
            if (nR = '0') and (nS = '1') then -- reset
                Q <= '0'; --with delays on both, it fails
            elsif (nR = '1' and nS = '0') then -- set
                Q <= '1';
            end if;
    end process;
    -- q_i<= (not nq_i) or (not nS); output
    -- nq_i<= (not q_i) or (not nR); not output
end priority;

--