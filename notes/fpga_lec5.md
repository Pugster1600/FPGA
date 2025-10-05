assigning something in 2 different places is really bad
- ie do not put them in 2 different processes

since you hvae contention between two different drivers

variables can be used
- 

THIS IS BECAUSE WE ARE DESCRIBING HARDWARE

## functions
- meant to rpelace code to make it more readable
- just do math to assign to a signal rather than actual circuitry

## procedures
- generate circuitry

## variables
- USE IT FOR INTERMEDIATE CALCULATIONS
- like remmeber when you had to create a signal just to use it as an intermediate thing since you cannot use say an output port as the right side of the assignment operator
- use := not <=

## carry rupple
- fast carry chain in the xilinx fpga with a special wire that makes the carry super fast
- vs builidng our own where we have to use the general purpose ones
- THIS IS A LIMITED RESOURCE
- highly optimized carry ripple aka the standard one with reigstered carry


pipeline 

## fast mulitplicatoin
- 0011110 = factor * 2^5 - factor * 2^1
- rather than factor * 2^5 + 2^4 ....
- so only 2 adds
- but we have to precompute multiples 
- called booths
- the total adding can be done with a tree

## division
- SRT division
- digit recurrence algorithm
- quotient one digit at a time
- avoids long carry propagation

## 2's complimenet
- same adder circuit works for subtraction
- BUT the issue is that is not the case for multiplicationex

## exceed-N

## 
- xilinix fpga has hardware for multiplicatin
- both signed and unsigned

##
- but not really the case for division

nested counters
- structural descriptin is like saying generate 2 flip fop and wire them
- vs behavior where the structures are inferred
- nesterd counters
- no need for ocmbinatla carry generation
- one segment style coding owrks well 
- counters can be used as FSM
- to know which bit we are working on for division

same signal, different pattern use case
different signals then use if 

shift, compare subtract
- state machine based on what the value is after you compare and subtract

use metastability sync 
- these will just get inferred as ff
- use additional signals to simulate that

ps 2's compliment does not hold up for multiplication and division
booth's algorithm
----------------------------------------------------
how does integer division work in terms of logic gates like if i am trying to implement it in say vhdl. Just give the high level overview dont actually provide an implementation

multiplication doubles
- so say i have 9 * 9 = 81
- then 99 * 99 = 9801
- so it doubles the length

in our thing, we are trying to do 42 by 22 division

1. we extend the 42 bits to 63 bit (pad 0s to the left)
- so 111000 becaomes 000 111000
- so still the same number, just different number of bits
2. we pad zeros to the right such that the LSB of the divisor is lined up with the MSB of the divdend
- so this is just left shift by 2 continously
- 111000 becomes 111000 000
3. initialize the quotient to 0
- 

13 / 3
Dividend: 1101
Divisor:  0011
Remainder:0000
Quotient: 0000

1. R & dividend -> concat
- 0000 1101 << 1 = 0001 1010
- 0000 0000
- R = 0000, Q = 0000
- R - divisor = 0001 - 0011 < 0 
- thus Q[0] = 0, R = 0001 still
- if R > 0, then we keep shifting

2. 0001 1010 <<1 = 0011 0100
- R = 0011, Q = 0100
- R - D = 0000
- keep R, set Q[0] = 1
- 0011 0101

3.

Pseudocode

R = 0000
dividend = 1101
combined = R:dividend
for bits in dividend:
  combined = R:dividend
  combined = combined << 1
  if combined[R] - divisor >= 0:
    dividend[0] = 1 //dividend keeps getting shifted, but this keeps track of whether we are dividing into hundreds place or what not (relative position is the same after all 4 shifts!)
    R = combined[R] - divisor

typedef struct Result {
  uint32_t quotient;
  uint32_t remainder;
} Result;

Result division(uint32_t dividend, uint32_t divisor) {
  uint64_t combined = (uint64_t) dividend;
  uint32_t remainder = 0;
  Result result;
  //printf("%lu", &mask)
  //combined |= dividend; //remainder : dividend
  for (uint32_t i = 0; i < 32u; i++) {
    combined <<= 1;
    remainder = (uint32_t)(combined >> 32); //bottom 32 all 0s

    //remainder - divisor >= 0
    if (remainder >= divisor) {
      combined |= 0x1u; //set LSB = 1
      remainder = remainder - divisor;
      combined &= 0x00000000FFFFFFFFULL; // Clear top 32 bits
      combined |= ((uint64_t)remainder << 32); // Set new remainder

      //printf("Value: %" PRIu32 "\n", combined);
    }
  }

  result.quotient = (uint32_t)(combined & 0xFFFFFFFF);
  result.remainder = (uint32_t)(combined >> 32);
  return result;
}

//program first then try to create it in fpga

## The general concept here:
- We are starting off with the MSB of the dividend
- We are seeing if that MSB >= divisor
- if it is, then it means it can divide into it
- if it is not, then that means it cannot divide into it
- if we cannot divide into it, we need to bring now the next MSB (just like in normal long division)
- dividend[0] = 0, after 4 shifts this is the 3rd bit which makes sense cause thats how we do it in normal long division we start with MSB bits
- then we do it again (keeping the remainder, just shifting it to keep the previous values and bring in the new MSB)
- when it is greater, dividend[0] = 1, the remainder changes to remainder - divisor (exactly like normal long division!!)
- this is literally like normal long division that we do

## Anotheer view of the concept
- the current remainder is essentially the dividend
- we keep shifting hte divisor, just like moving from the hundreds to the 10s place when 5 cant go into 2
- since we are not keeping track of the quotient, no need to flip bits or anything
- so we just subtract, just like long division


WRITE A PIECE OF CODE FOR THIS

NOTE: think of it in terms of base 10 so we can kinda see it at play with something we are more familiar with

how does integer division work in terms of logic gates like if i am trying to implement it in say vhdl. Just give the high level overview dont actually provide an implementation

learn but also come up with original thoughts
- like anyalyze why this works using your own thoughts first!

describe cricuits based on behavior rather than structure
- the important thing to note is that anything registered will update based on the previous value


We are using nested counters since these are much easier to work with as a state machine
- figure out why is this
- in our case, we the counter to keep track of which divisor we are on
- that is the state
- this counter updates based on the previous state
- like if 2 fails, we are going to skip all even ones since we know they wont work
- so we need to flow on the state

The counters countinously run in the counter
- however, we want to figur eout if the factorization was finished or not
- here, we can use a button to start the counter
- so counter1 and counter2 hold idle states -> based on both counter1 and counter2 values
- we dont know if we just arrived there or if we started there
- we can use a flag to indicate that OR we can use an additional count slot for that
- so basically that additional slot acts as the flag

you have if else for prioritized things

## Part A
- user inputs a dividend
- then it presses the button

if something is assigned inside a process that is rising edge sensitive then it is inferred to be a flip flop

make sure you have a general idea of how the behavioral descriptoin gets implemented in terms of the fpga primitives

a balance between practical engineering classes and engineering theory classes
- enginereing theory being math heavy ones
- 

-------------------------
Excellent question. The short answer is: it depends on the kind of circuit being designed. Different fields of electrical engineering use different approaches — sometimes very mathematical (like signals and systems), and other times more practical or logic-based (like digital hardware design).

Let’s break it down by type of circuit and how they are typically built:

🧠 1. Analog Circuits

(e.g. amplifiers, filters, oscillators)

Approach: Signals and systems, circuit theory, and sometimes even control theory.

Engineers model the circuit using differential equations and Laplace transforms.

They use frequency-domain analysis (e.g., Bode plots) to design filters and amplifiers.

Example: Designing a low-pass filter involves choosing R and C values to shape the frequency response — this is directly a signals and systems problem.

Tools: MATLAB, SPICE simulators, circuit theory

🖧 2. Digital Circuits

(e.g. counters, CPUs, FPGAs)

Approach: Logic design, state machines, hardware description languages (HDLs) like VHDL or Verilog.

Designers don’t usually think in terms of signals and systems.

They think in terms of logic gates, Boolean algebra, state transitions, and timing.

A typical digital designer cares more about how to implement a finite state machine than solving a differential equation.

Example: You might build a traffic light controller using a state machine, described in VHDL, not as a continuous-time system.

Tools: VHDL/Verilog, simulation (ModelSim, Vivado), FPGAs

📡 3. Signal Processing Systems

(e.g. filters in communication systems, DSPs)

Approach: Signals and systems at a higher level, especially in algorithm design.

For implementation, DSP algorithms (like FIR filters or FFTs) are designed mathematically, then mapped to digital logic or software.

The design is based on signals and systems, but the hardware implementation uses digital circuit techniques.

Tools: MATLAB/Simulink for design, then VHDL/Verilog or C for implementation

⚙️ 4. Embedded Systems

(e.g. microcontrollers, SoCs)

Approach: Software-focused, with hardware-software co-design.

Use pre-built hardware (e.g., microcontrollers) and write firmware.

Circuits are often just supporting components (e.g., buttons, sensors, power supplies).

Tools: C/C++, Arduino, STM32, etc.

Summary Table
Circuit Type	Typical Approach	Involves Signals and Systems?
Analog	Circuit theory, Laplace, freq.	✅ Yes
Digital	Logic design, FSMs	❌ Rarely
Signal Processing	Math → logic implementation	✅ Design: Yes, Impl: No
Embedded Systems	Software + minimal hardware	❌ Mostly not
🧩 Real-world example:

Say you're designing an audio equalizer:

The filter design uses signals and systems: frequency response, transfer functions.

The implementation (on FPGA or microcontroller) uses logic or C code: registers, finite state machines, memory access.

If you're learning digital design (like VHDL), you mostly won't use a signals and systems approach. But for analog or DSP, you absolutely will.

Would you like a comparison between how you’d implement a filter in analog vs digital? Or how signals and systems math maps into VHDL/DSP blocks?

SNR and BER end Eb/no

descrbing circuits is just like code just a few extra things to consider like they are parallel etc
- this is cause the abstraction is made in such a way!
but maybe ai is better at a different set of abstractions
- we know thats the case cause we break them down into tokens!
like how fourier abstraction makes it easier for us to understand

not sythensizable means no hardware equivalent 

std_logic_vector to unsigned conversions -> appending bits, bit banging