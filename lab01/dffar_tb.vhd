library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dffar_tb is
end dffar_tb;

architecture Behavioral of dffar_tb is
    signal d : std_logic := '0';
    signal c : std_logic := '0'; 
    signal r : std_logic := '0';
    signal q : std_logic;
    
    --declaration
    component dffar is 
        port(
            D: in std_logic; --data input
            C: in std_logic; --clock input
            R: in std_logic;
            Q: out std_logic
        );
    end component;
begin
    -- instantiation -> port => signal
    dffarObj : dffar
        port map (
            d => d, 
            c => c, 
            r => r, 
            q => q
        );
        
    process
        begin
            r <= '0';
            
            c <= '0';
            wait for 10 us;
            
            -- 1. 0 to 1 on the d
            d <= '1';
            wait for 10 us; --make things in series rather than straight wires
            
            c <= '1';
            wait for 10 us;
            
            c <= '0';
            wait for 10 us;
            
            -- 2. 1 to 0 on the d
            d <= '0';
            wait for 10 us;
            
            c <= '1';
            wait for 10 us;
            
            c <= '0';
            wait for 10 us;
            
            -- 3. hold 0 on the d
            c <= '1';
            wait for 10 us;
            
            c <= '0';
            wait for 10 us;
            
            -- 4. hold 1 on the d
            d <= '1';
            
            c <= '1';
            wait for 10 us;
            
            c <= '0';
            wait for 10 us;
            
            c <= '1';
            wait for 10 us;
            
            c <= '0';
            wait for 10 us;
            
            -- 5. reset
            r <= '1';
            wait for 10 us;
            r <= '0';
            
            --6. reset takes precedence
            d <= '1';
            r <= '1';
            c <= '1';
            wait for 10 us;
            
            wait;
            
                
            
    end process;
end Behavioral;
