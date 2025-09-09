library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--====== 1. IO of test bench
entity buffer_tb is
end buffer_tb;

--======= 2. internals of test bench
architecture behavior of buffer_tb is
    --===== 2.1 signals
    --variable instantiation
    --signals are wires in vhdl
    signal sig1 : std_logic := '1'; 
    signal sig2 : std_logic;
    
    --===== 2.2 components
    -- component declaration(defining what the inputs are called)
    --COMPONENT NAMES MUST MATCH original
    --ie bufferGate and the ports of bufferGate
    -- bufferGateComp WONT WORK!!
    component bufferGate
        port(
            button : in std_logic;
            led : out std_logic
        );
    end component;
        
begin
    --====== 2.3 object instantiation
    -- => is a mapping operator port -> 
    -- port_name_in_component => signal_in_architecture
    
    --the Component name must be correct!!!
    bufferObject : bufferGate
        port map(button => sig1, led => sig2);
    
    --====== 2.4 actual dynamic part
    processName : process
    begin
        --assign ONLY to wires/signals not the component itself 
        --though the signal can be connected to the signal
        sig1 <= '0'; -- <= is the assignment operator equal to := for variables/initialized values
        wait for 10 ns;  -- => is the mapping operator
        sig1 <= '1'; 
        wait for 10 ns;
        wait;
    end process;
end behavior;
