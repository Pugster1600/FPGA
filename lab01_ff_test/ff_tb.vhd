-- ===============defines the test bed aka the top level view but in simulation

library IEEE;
use IEEE.std_logic_1164.all;

-- =============no ports talking to the outside world cause top level in simulation
entity ff_tb is 
end ff_tb;

architecture behavior of ff_tb is
    signal tb_d : std_logic := '0';
    signal tb_clk : std_logic := '0';
    signal tb_reset : std_logic := '0'; 
    signal tb_q : std_logic; -- output so not default value or else undefined std_logic
    
    -- copy and paste of entity
    component ff
        port (
            d : in std_logic;
            clk : in std_logic;
            reset : in std_logic;
            q : out std_logic
        );
    end component;
begin
    -- object instantiation
    ffObject : ff 
        -- define connections
        port map (
            d => tb_d,
            clk => tb_clk,
            reset => tb_reset,
            q => tb_q
        ); 
    process
        begin
            -- 1. change d, nothing should happen
            tb_d <= '1'; -- can only change signals!
            wait for 10ns;
            
            -- 2. toggle clk
            tb_clk <= '1';
            wait for 10ns;
            
            tb_clk <= '0';
            wait for 10ns;
            
            tb_reset <= '1';
            wait;
            
        end process;
end behavior;

