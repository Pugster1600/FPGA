field programmable with anti-fuses which are the opposite of fuses ie when a higher current runs through it it shorts rather than opens

floating gate
- just changes the threshold voltage 
- removing the floating gates electrons erases it

the flash of the fpga can hold the configuration but it could also be directly loaded from the machine

gate array are mapped to AND and OR plane
- PAL since we can create any Boolean function form it ie sum of products

CPLD
- multiple PAL

gate arrays
- array of logic gates with programmable interconnects

programmable logic blocks
special function block -> RAM block, clock dividers, 
programmable interconnect

basic CLB is using a mux 4-2 mux
- so the input to the mux is what changes ie the top changes but the side stays the same

IO blocks
- DDR dual data rate, one clock period, 2 bits per wire
- so one bit one clock high and one when clock low
- handles DDR, different threshold logic ie TTL vs CMOS
- programmable slew rate, driver current, delay etc

Routing
- length of wires
- long wire more stray capacitance thus you have to charge the capacitor up essentially causing a delay
- RC constant type thing

block RAM, DSP48, CMT, memory controller

so we have bits to configure CLB mux control, then we have routing switch and LUT content

usually have a pull up because TTL pull up is way harder than pull down

LVCMOS33- low voltage cmos 3.3V rather than 5V
pin description changes between different boards

---------------------
think of hdl as html or something
- we are describing the page and everything happens more or less at once
- the IO is like javascript 
- RTL means how data is transferred between parts rather than how that circuit is being used to do that transferring
- IP blocks are like functions that we use in programming and they are often created by other companies
- we only know the IO, not the actual workings of it

HDL coding -> simulation/testbench -> synthesis (hdl code into gate level representation -> net lists that says how the cells logic and registers are connected) -> place and route (like routing PCB)

## Entity
- the interface
- describes what the component does
- the name of the component
- the IO of the component
- and optional generic paramters like bit-widths, delays etc
- this is the black box description

## Architecture
- the implementation
- how the component works
- the actual logic
- can have multiple architecutres for the same entity
- ie same IO but different logic
- like we can implement an adder (the interface)
- but with different logic (the architecture)

.xpr is the project file that you want to open when opening a project

## constraints
- based on the SDC file format
- this is not specific to VHDL but also applies to verilog too

## main code
- this is sort of the systems level implementation

need to add design source aka the class
and the simulation source aka the instantiation

it has a built in led and button
our goal today is to get the button to control the led

-------------------------
--This file is the vhdl code NOT the test bench

library IEEE;
use IEEE.std_logic_1164.all;

-- 1. Entity: defines the interface
-- NOTE: Entity is everything facing the outside world
-- Think of this as the black box
-- defines input and output
-- like it defines what an adder is
entity andGateArbName is
    port( --port just says these are the pins
        A: in std_logic; -- input var A -> can set deafult with A : in std_logc := '0';
        B: in std_logic; -- input var B
        Y: out std_logic -- output var Y
    );
end andGateArbName;

-- Architecture: defines the logic
-- NOTE: this is everything internal NOT facing the outside world
-- it says how do we implement the adder
-- so ripple carry vs carry look ahead
architecture andGateArbNameArch of andGateArbName is
    --signal and component between architecture
    --signal definitions
    --components within the architecture
    --look at the setup_tb.vhd file
begin
    Y <= A and B; -- <= is signal assign, so we are saying Y = A * B
end andGateArbNameArch;

--/*
--we can defined constraints
--they basically say hey this signal is from/going elsewhere
--like the signal is from say IO
--*/
---------------------------------
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
    signal Y : std_logic; --IMPORTANT: these are signals ie wires now NOT inputs
    
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
    uutArb : andGateArbName port map(A => A, B => B, Y => Y);
        --assigning the signals ie wires to the ports 
        --port map connects the signals to the pins
        --statement terminator with ;
        --using "port" rather than "generic" means A => signal rather than A => constant
    
    --simulation of the process
    sim_process : process() --process is a key word
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


-------------
-- updated: gpt
-- This file contains the VHDL code for an AND gate
-- It is the DESIGN file (not the testbench)

library IEEE;
use IEEE.std_logic_1164.all;

--==================================================
-- 1. ENTITY: Interface definition (like a black box)
--==================================================
-- The entity defines the external inputs and outputs (ports)
entity andGateArbName is
    port(
        A : in std_logic;  -- Input signal A
        B : in std_logic;  -- Input signal B
        Y : out std_logic  -- Output signal Y
    );
end andGateArbName;

--==================================================
-- 2. ARCHITECTURE: Internal logic of the gate
--==================================================
-- This defines how the gate behaves using the inputs
architecture andGateArbNameArch of andGateArbName is
begin
    -- AND logic: output Y is A AND B
    Y <= A and B;
end andGateArbNameArch;

--==================================================
-- NOTES:
-- Constraints (not defined in this file) tell the FPGA
-- which physical pin each signal connects to (I/O)
-- For example: A might map to pin U16 on the board
-- This is done in a constraints file (.xdc or .ucf)
--==================================================


---------------------------------------------------------------
-- updated: gpt
-- This file defines the TESTBENCH
-- It is for SIMULATION ONLY (not for synthesis or hardware)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Testbench entity: has NO ports since it does not interact with the outside world
entity and_gate_tb is
end and_gate_tb;

-- Architecture of the testbench
architecture archName of and_gate_tb is

    -- 1. Internal testbench signals (used to drive the DUT)
    signal A : std_logic := '0';
    signal B : std_logic := '0';
    signal Y : std_logic;

    -- 2. Component declaration (copy of your design's entity interface)
    component andGateArbName
        port (
            A : in std_logic;
            B : in std_logic;
            Y : out std_logic
        );
    end component;

begin
    -- 3. Instantiate the DUT (Device Under Test)
    uutArb : andGateArbName
        port map (
            A => A,
            B => B,
            Y => Y
        );

    -- 4. Stimulus process: applies input test vectors
    sim_process : process
    begin
        -- Test all input combinations
        A <= '0'; B <= '0'; wait for 10 ns;
        A <= '0'; B <= '1'; wait for 10 ns;
        A <= '1'; B <= '0'; wait for 10 ns;
        A <= '1'; B <= '1'; wait for 10 ns;

        wait; -- Wait forever (ends simulation)
    end process;

end archName;

---------------------------------------
add the and gate into the design sourcs
add the tb into the simulation sources

teroshdl

## simulation
- upload vhdl design sources
- upload vhdl simulation sources
- then click simulate
- if syntax errors then you might see U or errors

## sythensis
- 1. after simulation, you can create the constraints file
- the goal is to have on entity that combines everything
- so if we have many entities, we are going to combine them all into one final entity
- this final entity will talk to the outside world which is why ports can have the same name across entities
- so we use signals to connect different entities
- to connect 
- port map(inputPort => signal1, outputPort => signal2)
- port map(inputPort => signal2, outputPort => signal3)
- 2. create the top level file
- 3. run linter to check the process
- 4. synthesize
- here you can open what you synthesized
- 5. run implementation to map synthesized design to FPGA
- 6. generate bit stream to upload
- 7. harware manager to choose the device
- 8. program device under the bitstream section
- need to connect to the targer

 [Designutils 20-1307] Command 'set_property-dict' is not supported in the xdc constraint file. [C:/Users/jshi4000/FPGA/lab00/lab00.srcs/constrs_1/new/firstConstraint.xdc:10]

 ## uploading the bit stream
- open hardware target, connect to local aka the host computer
- then select hardware target will show up the board that is connected to the machine
- then program device -> check the bitstream file that you want

 --------------------------------
 In the context of Hardware Description Languages (HDL), synthesis refers to the process of converting an HDL code (usually written in VHDL or Verilog) into a netlist, which is a representation of the hardware components and their connections, typically for the purpose of programming a Field-Programmable Gate Array (FPGA) or for ASIC (Application-Specific Integrated Circuit) design.

The steps in the synthesis process generally include:

Parsing: The HDL code is read and parsed to check for syntax and semantic correctness.

Optimization: The synthesis tool optimizes the design for speed, area, or power consumption. This might involve simplifying logic, merging equivalent logic gates, or other techniques.

Translation to Gate-Level Representation: The HDL constructs (like if-else statements, loops, and processes) are mapped to logical gates (AND, OR, XOR, etc.) and flip-flops. For example, a case statement might be translated into a multiplexer, or a simple if condition might be converted into combinatorial logic.

Netlist Generation: The output of the synthesis process is a netlist, which is a collection of interconnected gates and flip-flops, typically represented using a standard hardware description format like Verilog, VHDL, or a specialized format for a specific vendor's FPGA/ASIC toolchain.

Technology Mapping: If targeting a specific device (like an FPGA), the synthesis tool will map the logic to the device’s available resources (logic blocks, LUTs, flip-flops, etc.).

Constraints Handling: The synthesis tool also takes into account various design constraints (such as timing, clock constraints, and physical design limitations).

Why is Synthesis Important?

From HDL to Hardware: It’s the crucial step to take a high-level design described in HDL and turn it into something that can be physically implemented on hardware.

Resource Optimization: Synthesis helps in optimizing the design in terms of the usage of resources (such as logic blocks or gates) and performance (speed or latency).

Verification: After synthesis, engineers often perform verification to ensure that the synthesized design meets the required functional and timing specifications.

Example:

If you write a simple Verilog code like:

module simple_adder(input a, b, output sum);
  assign sum = a + b;
endmodule


When synthesized, this code might be translated into a netlist with a set of gates (like an XOR or AND gate, depending on the implementation) and flip-flops, ready to be mapped to physical hardware.

Let me know if you want more specific details about synthesis tools or if you're working on a particular FPGA or ASIC design!

----------------------------
LUT -> look up table
basically if 4 inputs, can output 2^4
> basically a truth table
> basically a small RAM
> input is address
> or done using mux

part of larger structure called CLB or logic elements
> contain LUTs, flip flops, muxes for slecting between logic paths and carry logic for math

physically, LUT is a tiny block of SRAMs surrounded by muxes and routing

1. routes
matrix of programmable switches
- like transistors or muxes that move the routes around
- its juts transistors and stuff rerouting lines between 
- transistor is a switch, remember that!
SRAM to SRAM
LUT to LUT
SRAM to LUT
LUT to SRAM SRAM

LUT (aka combinational logic)to flip flop (to remember)

memory cell contorls which routes are open

LUT is just a programmable device like SRAM so we have word and bit lines

LUT to LUT
LUT to flip flop
LUT to IO
input to LUT
memor y cell to routing switch

so we have memory cells 
> so SRAM aka LUT

then we have routes to connect LUTs
> aka transistors or MUX (the input of them determine how they are routed)

LUT and flip flop is all you need
> because thats combinational logic and sequential logic
> then you can route how they are connected with the routing switches aka transitors
> then you can route them to the outside world aka IO

## Netlist
- in nets folder, you can right click then click schematic
- or also in the schematic section under synthesis
## Process
1. concurrency
- in a process, everything happens concurrently

Ex:
if i have something like

architecture behave of andGate
    signal and2 : std_logic --signals internal to the arch

    and2 <= A and B;
    Y = and2;
end andGate

we can technically flip the 2 process lines because this is technically describing how wires are connected
So it does not matter
this is what we mean when we say concurrently like everything is just running with just some hardware delay

architecture behave of andGate
    signal and2 : std_logic --signals internal to the arch

    process (sensitivity): processName --can have inputs aka sensitivity
    begin
        and2 <= A and B;
        Y = and2;
    end process;
end andGate

sensitivity list is saying whenever one of the signal changes, run this process

if no sensitivity list, it will run process, then as soon as it reaches the end of the process, it reruns the process

process(all)
begin if s = '1' then
    y <= a;
    else
        y<=b;
    end if;
end process;
> anytime anything in the process changes, run the process
> so if s, a or b changes -> process(a,b,s)
> vhdl 2008

process(al)

inside process, its almost like code changes sequentially

so if we have something like
b <= a
y <= b

without a process, itll be like
new_b <= a
y <= old_b

process(a)
    variable temp : std_logic;
begin
    temp := not a;   -- immediate update
    b <= temp;       -- b gets scheduled to be updated
    y <= temp;       -- y also gets scheduled with the same value
end process;

### IMPORTANT: with process, things update at the end of a process
because of this, we can use a temp variable that is assigned immedately 
AND we can have sensitivity

use variabels for intermediate calculation when order matters
use signals to connect components or things in the outside world

without process, everything is just straight wires like normal gates becuase this is how things work IRL in hardware (everything changes so fast)

typically, processes describe sequential logic so we use clock edges and flip flops or something
- thus clk would be a sensitivity input

process(clk) --flipflop gets synthesized
begin
    if rising_edge(clk) then
        q <= d;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        a <= b;
        c <= a; --c gets old a NOT the new b value
    end if;
end process;

each signal<= maps to a reigster or flip flop
- all reigsters update at the same time on the clock edge

if else is good in process blocks
- much harder in concurrent code

## PROCESS VS NO PROCESS
1. process is good for flip flops and if, else
- because of sensitivity
- just cleaner code
- updated values still dont change until end of process aka one clk tick after usually (just based on sensitiivty)
2. great for complex combinational logic becuase of the easy if,else combination rather than needing to write boolean expressions
3. vhdl process is just a more convienent way of describing hardware!
process is good for on a clock edge, do this

each "signal <=" maps to a reigster or flip flop. Think about it, they are permanent connections between ports. 

No actual process, just gates (LUT), flip flops (reigsters), mux, decoder, logic paths (transistor switches), wires and clocks

<= does not take into immediately until after process suspends (process triggers at rising edge or something)
- think of things as blocks menaing they execute at the same time (like after an FSM clock tick, everything changes)
- so a process is like a block ()
- just that you can describe thing with if else even though it still synthesizes to the same harware
- it makes it easier to describe state machines, encoders, pipelined dataoaths etc

PROCESS IS NOT REAL HARDWARE, JUST DESCRIBES HARDWARE MORE EFFICENTLY

there is no d flipflop instantiation but rather we describe it with process
the synthesis tool will convert it accordingly to a d flip flop inside

IN combinaitonal logic like chaining a bunch of gates but without feedback, all points change at once!!!
> you need to remember this for hdl to succeed
> NOTHING IS done in order technically