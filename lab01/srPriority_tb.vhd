library IEEE;
use IEEE.std_logic_1164.all;

-- no ports for tb
entity srPriority_tb is
end srPriority_tb;

architecture tb of srPriority_tb is
    -- 1. signals
    signal s : std_logic := '1'; -- default 1 since its a not version of SR latch
    signal r : std_logic := '1';
    signal q : std_logic;
    
    -- 2. component instantiation
    component srPriority is
        port(
            nS: in std_logic;
            nR: in std_logic;
            Q: out std_logic
        );
    end component;
begin
    test : srPriority 
        port map(nS => s, 
                 nR => R, 
                 q => q);
    
    process
        begin
            -- 0 -> no defined state yet so 1,1 means hold (but no pervious value)
        s <= '1'; r <= '1';
        wait for 10 ns;
        
        s <= '0'; r <= '1';
        wait for 10ns;
        
        s <= '1'; r <= '1';
        wait for 10ns;
        
        -- 1
        s <= '0'; r <= '1';
        wait for 10ns;
        
        -- 2
        s <= '1'; r <= '0';
        wait for 10ns;
        
        -- 3
        s <= '1'; r <= '1';
        wait for 10ns;
        
        -- 4
        s <= '1'; r <= '0';
        wait for 10ns;
        
        -- 5
        s <= '0'; r <= '1';
        wait for 10ns;
        
        -- 6
        s <= '1'; r <= '1';
        wait for 10ns;
        
        -- going to 00 or away from 00
        -- 7
        s <= '0'; r <= '0';
        wait for 10ns;
        
        -- 8
        s <= '1'; r <= '0';
        wait for 10ns;
        
        -- 9
        s <= '0'; r <= '0';
        wait for 10ns;
        
        -- 10
        s <= '0'; r <= '1';
        wait for 10ns;
        
        -- 11
        s <= '0'; r <= '0';
        wait for 10ns;
        
        -- 12
        s <= '1'; r <= '1';
        wait for 10ns;
        wait;
    end process;
end tb;
    