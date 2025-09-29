## General Vivado workflow
1. write the vhdl code
2. create a separate folder for the vhdl and constraint files
- only push the vhdl files 
- since setting up the project folder is quite fast -> just add source, constraint and simulation files
- vivado has the flow navigator in order of how we should do it already which is great

if you are not using vivado, we can do something similar to using other toolchains and combining it with our own cmake and linkerscript and startup code

1. text editor like VScode
2. simulation
- like GHDL or something
3. synthesis which converts VHDL to netlist
- specific to the FPGA
4. place and route/bit stream
- show implementation to see the connections like LUTs to gates and what not

update the top module name to make sure it is correct

things update in a process if there is a wait statement OR when the process ends 

what if you do somehting like
clk <= 1
clk <= 0
inside a process?

remember that everything is something digital
- so it must follow physics laws 
- vhdl is not magic its just configuring gates 
- this means we are just building a digital circuit
- so a signal wire can only have one thing driving it
- BUT a signal wire can drive as many gates as it wants to

## syntax in vhdl
- can be in, out, inout
- inout usually happens at the top level 
- all internal signals ie those not connected to fpga IO pins should be in or out
- must either be declared as a signal or port

architecture
  -- signal
  -- component declaration
  -- packages are like header files
  -- but we are not going to use packages right now so we need to have the component declaration
begin
  -- component instantiation (including the name)
  -- port => another port or a signal
  -- then the actual stuff you want to do in between

signals are the names that you assign to wires
- can alias ie have another name
- signals declared as out cannot appear on the right side of an assignment
- assignment is just connecting

signal name mapping
- connecting ports to signals

- X is signal being driven by 2 sources
- U is undetermined

## structural description

1. combinatorial
- basically connecting gates

2. pritorizted
- signal name <= signal name when boolean else
  something

3. non prioritized 
- with signal name select
        signal anme <= signal name when choice 1

operator precedence
- not
- mul, div, mod and rem (mod and rem are different for signed vs unsigned)
- +/-
- rotate and shift (1 << 3)
- relative comparison, equality comparisions
- logical operations
- USE PARENTHESIS TO MAKE THINGS WAY EASIER!!!

with statement
- can only assign to one signal at a time

case
- can assign to multiple signal at a time

## Processes
- alternate form of combinatorial, prioritzed and non-prioritized statements
- ONLY WAY to describe edge triggered circuit
- sensitivity list

prioritized
- if, else if

unprior
- with, select

BOTH ARE parallel just you are trying to describe a circuit in the best way (describing the same circuit just in a different way!)
- you have to remember that you are describing a circuit

case?
- used for dont care

testbench
- identified by the empty entity
- ie no ports

in a process, the first statements will get ignored

non prioritzied is like a mux/combinational logic
piroritize is like a cascade of mux
- can still get the same behavior with non prioritized!!

transparent high/low for latched
- just like active high or low for

inferred a latch
- if the prior or non-prior description is incomplete

reset needs to have higher priority than the clk!!
- because it needs to be async

need async reset on power up to define a started state
- xlinix is special though cause it has a flash on board or something to configure itself
- by default, all ff will start at 0

net list is gates in the circuit and connections between them
- fpga primitive aka the most basic/smallest components in an fpga like a LUT

we use the primitive latch or flip flop in the fpga
- SO DO NOT BUILD YOU OWN becuase you do not know the propogation delay etc

MAKE SURE THE EPXRESSIONS YOU CAN BE INFERRED TO BE A FF by the syntehsizer so that we use the primitives

only a few clock networks that help with clock sync so that each ff gets the clock at the same time!
- clocks are really hard to manage so we only have a few clock neworks

we can specify propagation delay 
- use after 0.1us 
- this is for the simulation

-----------------------------------------
## Lab 1

In xilinx fpga, d latches and d flip flops are implemented by a register element primitive. A register element is a 1 bit memory device. Most registers are made up of N register elements. 
This is called a primitive becuase its not synthesized by combining other logic circuits in the fpga but rather is a component in of itself and cannot be broken further on the board. 
Most xilinx primiitves can be configured to act like different logic gates
- ie d latches canbe active high or low
- d flip flops either rising edge or falling edge
- async reset or not
- these are all implemented by the EXACT SAME primitive
- so the primitive can transfer its configuration but the function remains the same
We can technically combine things like logic gates (in the form of a mux/lut) to create these primitives
- BUT this lab will show why its not wise

FPGAs also contain a few low skew signal networks for carrying clock signals to flip flops and latches (ie the transition time between high and low is minimal). We only have a few of these so we need to share these wisely.

CANNOT USE THE SAME ARCH name for the same entity!
--------------------------------------
so you need to make sure that its written such that its concurrent which basically makes it so that its interpreted as a not gate

In VHDL, there are two main contexts:
1. Concurrent code (outside of processes)

Runs all the time, automatically.

Signal assignments like d4 <= not q4; are reactive — they update whenever q4 changes.

This is how VHDL models combinational logic, like gates.

✅ When you write d4 <= not q4; as a concurrent assignment, you're saying:

“Create a NOT gate between q4 and d4.”

2. Sequential code (inside a process, if, or case)

Runs step-by-step in order.

You can use := for variables or <= for signals, but only update them when certain events happen (like clock edges).

This models flip-flops, registers, or state machines — not simple gates.

✅ To infer a NOT gate:

Write it as a concurrent assignment, like this:

architecture Behavioral of my_design is
    signal d4, q4 : std_logic;
begin
    d4 <= not q4; -- <-- concurrent, inferred as NOT gate
end Behavioral;


No process, no clock, no control structure — just a clean, continuous logic assignment.

⚠️ What happens if you do it in a process?
process(q4)
begin
    d4 <= not q4;
end process;


✅ This still behaves like a NOT gate in simulation and synthesis — but:

It's a sequential description of combinational logic.

You must include all inputs in the sensitivity list (here, just q4) to avoid unintended latches.

Synthesis tools may warn you if it's not clearly combinational.

So for simple gates, concurrent code is cleaner and safer.

✅ TL;DR
Expression	Context	Effect	Inferred Hardware
d4 <= not q4;	Concurrent	Always evaluates	NOT gate ✅
d4 <= not q4; inside process(q4)	Sequential	Updates when q4 changes	Also a NOT gate (but more work, more risk) ⚠️

Let me know if you want to see the difference with simulation waveforms or more examples (like NAND, AND, flip-flops, etc.)!

## SO WE CAN TECHNICALLY USE A NOT GATE
but this is much cleaner

concurrent code is pretty much just logical gates ie everything changes at the same time cause its hardware (single mux)
"seqential code" is almost like multi layer mux
- if not the first IF, then we hop on the next mux, if not this mux, then the next 

| Concept               | Synthesized As       | Example                    |
| --------------------- | -------------------- | -------------------------- |
| `if` / `elsif`        | MUX or decision tree | Multiple paths → MUX       |
| `case`                | MUX (often cleaner)  | Select between signals     |
| `if rising_edge(clk)` | Flip-flops           | Registers / state machines |
| Concurrent assign     | Logic gate           | `a <= b and c;` → AND gate |

purely if, elif is technically just combinational DESCRIBED DIFFERENTLY
- so if elif is just truth table which is combinational1
- seqeuential way of describing something combinatally
- CASE statements also used for combinational!

rising_edge clk now is something that is hard to describe combinationally (possibly just describe circuit!)
- but its better for if/elsif
- cause its flip flop!

| Area                                                | Importance | Notes                                            |
| --------------------------------------------------- | ---------- | ------------------------------------------------ |
| **Entity & Architecture**                           | ★★★★★      | Defines interface and behavior. Core structure.  |
| **Signals, Variables, Constants**                   | ★★★★☆      | Essential for internal data flow and timing.     |
| **Processes**                                       | ★★★★★      | Key for describing sequential logic.             |
| **Concurrent vs Sequential Statements**             | ★★★★★      | Fundamental to hardware modeling.                |
| **If / Case / Loops**                               | ★★★☆☆      | Like regular programming, with timing semantics. |
| **Data Types (std\_logic, arrays, records)**        | ★★★★☆      | Rich type system but used consistently.          |
| **Generics and Ports**                              | ★★★★☆      | For parameterized designs and interconnects.     |
| **Libraries (ieee.std\_logic\_1164, numeric\_std)** | ★★★★☆      | Must-know for most designs.                      |

| Area                                    | Description                                                                         |
| --------------------------------------- | ----------------------------------------------------------------------------------- |
| **Designing State Machines**            | Clean state transitions, encoding, and reliability.                                 |
| **Clock Domains / Timing**              | Managing clocks, metastability, setup/hold, etc.                                    |
| **Hierarchy & Modularity**              | Creating reusable components.                                                       |
| **Synthesis Awareness**                 | Writing VHDL that synthesizes efficiently to hardware.                              |
| **Simulation & Testbenches**            | Creating realistic, useful simulations.                                             |
| **Toolchain & Constraints**             | Knowing your FPGA tools (Xilinx, Intel, etc), timing constraints, pin mapping, etc. |
| **Interfacing with IPs or Peripherals** | Integrating with memory, UARTs, AXI, etc.                                           |
| **Debugging**                           | Simulation vs hardware debugging is a deep topic.                                   |

so the learning curve is from actual integration rather than syntax vs programming languages where you need to learn the tools the language provides
since the logic is the same across all 

Yes, RISC-V is an architecture that follows the RISC (Reduced Instruction Set Computer) design philosophy.

Breakdown:

RISC (Reduced Instruction Set Computer):

A design approach that uses a small, highly optimized set of instructions.

Focuses on simplicity, speed, and efficiency.

Each instruction typically executes in a single clock cycle.

RISC-V:

Pronounced "RISC-five"

An open standard Instruction Set Architecture (ISA) based on RISC principles.

Developed at UC Berkeley in 2010.

Designed to be:

Modular (base ISA + optional extensions)

Open-source (no licensing fees)

Simple and clean, making it suitable for research, education, and industry use.

So in short:

✅ RISC-V is a modern implementation of the RISC ISA philosophy.
It follows RISC principles and builds an open, extensible architecture around them.

Let me know if you want a comparison with other RISC architectures like ARM or MIPS.
