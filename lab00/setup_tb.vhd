--this file defines the testbench!!
--this is for simulation only
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- testbench entity has no ports since it is not going to interact with outerworld
entity and_gate_tb is
end and_gate_tb;

-- here, we are defining the signals and pins associated with the testbench
-- we are creating a new architecture called and_gate_tb 
-- EVERYTHING IS NESTED UNDER ARCHITECTURE
-- we define signals associated with the testbench entity
architecture archName of and_gate_tb is
    -- 1. define the signals of tb for simulation
    -- these are signals inside the bench itself
    -- we then connect these signals to the component that we instantiated inside the testbench
    signal A : STD_LOGIC := '0'; -- := initializes the values (<= is the assignment operator later!)
    signal B : STD_LOGIC := '0'; -- := is the variable's starting value
    signal Y : STD_LOGIC; --IMPORTANT: these are signals ie wires now NOT inputs
    
    -- 2. define the component aka the class
    -- component declaration -> saying that the black bnox is defined by andGateArbName
    -- this is legit copy and pasted 
    -- but it says component rather than entity since its not interacting with outside world
    component andGateArbName --saying the component matches the interface andgateArbName ie input and output
        port (
            A : in STD_LOGIC; --vhdl is case insensitive
            B : in STD_LOGIC;
            Y : out STD_LOGIC
        );
    end component;
    
    -- 3. define the actual internals now
    --creating an actual process ie the systems level thing
begin
    -- here we are instanatiating the component/entity andGateArbName
    -- uutArb is just a label like a function name in asm
    --so uutArb is an object almost
    uutArb : andGateArbName 
        port map(A => A, B => B, Y => Y);
        --assigning the signals ie wires to the ports 
        --port map connects the signals to the pins
        --statement terminator with ;
        --using "port" rather than "generic" means A => signal rather than A => constant
    
    --simulation of the process
    sim_process : process --process is a key word
    -- "variables" between process and begin
    -- these get updated instantly
    -- "gen" to create a bunch of and gates
    -- "switch statements"
    -- process is sequentially block of code
    begin
        --testing all combinations of A and B
        --IMPORTANT: values do not get updated until the end of a process
        --so if A := '0', then A <= '1', Y <= A, Y will be '0' since A doesnt change until the end of process
        A <= '0'; B <= '0'; 
        wait for 10 ns;
        A <= '0'; B <= '1'; 
        wait for 10 ns;
        
        A <= '1'; B <= '0'; wait for 10 ns;
        A <= '1'; B <= '1'; wait for 10 ns;
        wait; --wait forever
        
    end process;
end archName;