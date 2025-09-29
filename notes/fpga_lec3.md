1. sequential stuff should be described by process NOT gates since we want them to be inferred
- process are behavioral description
- BUT we used structual description aka gates

outputs should not be on the right hand of an assignment

write vhdl such that it gets inferred to be the primitives on board
dont use structural descriptions
> use processes or instantiate primitives

toggle flip flops are bad for both delays and effiecient use of limited clock resources
- dont use structural descriotions

## handling reptitive structures
- 1. expression of array of std logic bits

std_logic_vector is a bus or group of wires

3 down 0 -> 3210
4 down 2 -> 432
0 up 4 -> 01234

C <= A(3)
- bit 3 of the bus A goes to C

signal attributes

stdlogic vector generics 
> we dont usually use auto instantiation since we create a generic instead 

Generics just make life way easier

tsetup
- time you need to wait before you can actually send form clock send

thold
- time to hold the data you want to be samp;ed

higher t hold, lower pd
- since pd 

clock domain is anything connected to the same clock

if you do have a data signal going AND different clock feeding, you need meta stabiliity sync
- so differnt clock domains require meta stability sync
--------------------------------------------------------------------
METASTABILITY
- when a signal is transffered between circuitry in unrelated or async clock domains -> mean time between failures
- this is basically when the dff tries to change states
- it can either be in a 1 or 0 state
- when it changes states, the voltage isnt really 0 or 3.3/5
- its instead something in between just because it cant instantenous change its voltage
- so the dff is not really in a good state yet
- meaning that the output is not 0 or 1 yet since the voltage is in the forbidden zone
- its basically in a hill top with 0 and 1 in between (like diff eq where its an unstable equilibirum)
- to resolve this, we can chain dff since each dff 

So the thought is that rather than having the next stage sample it immedately (where the output is stuck between 0 and 1),
we have it wait for the dff to settle by chaining dff

so the way to think about it is: there is no 0 or 1
- its about signals settling down
- the signals propogate down one ff at a time
- so the voltage needs to propagate down the line

ff1 -> ff2 -> ff3
so ff1 is not in a defined state
- its components may be say 1.8V
- the crucial part is that the ff do NOT sample ie there is no change in voltage until the next clock edge 
- So when the next clock edge hits, ff1 may still not be stable meaning the voltage through it is still not 0v or 5v
- But ff2 still samples and whatever the voltage is of ff1 is used to drive ff2.
- ff1 and ff2 are still settling -> ff2 picks up a stronger signal than ff1 had originally 
- but they have spent a good amont of time settling
- so that by ff3, ff1 signal has settled to say 5v and ff2 is also at 5v
- each ff acts as a probabilistic filter 

1. tsetup
- data input must be high for a certain time before rising edge
- enough time for the data transistor to switch and hold state
- dont think of it as logic but rather as an analog circuit
- the data MUST BE STABLE FIRST 
- if we sampled at the clock edge, the data voltage might not have time to settle
- Setup time ensures the data is stable long enough before the clock triggers the FF (the data itself is stable so that we can prepare to latch since we dont want the data to not be stable when we try to latch)

2. thold
- data input must be high for a certain time after rising edge
- so that the transistors after the data transistor have enough time to propagate through
- the INPUT SIGNAL IS THE THING DRIVING ALL THE SWITCHING 
- the longer you have the input signal driving, the more time it has to force the other transistors to swtich
- if we didnt hold data, the latching might not happen
- Hold time ensures the data stays stable long enough after the clock triggers the FF (for the ff to latch)

3. tout
- reigster output is available after a specific clock to output delay
- the meta stable state is the time between the rising clock edge and tout
- so it has enough time to settle
- in sync system, everything is designed around the tout time ie the clock edge is slow enough that tout is less than a clock cycle

4. async systems
- in async systems, the driver's clock might tick before the thold period meaning we dont have the signal strength to keep driving the output
- thus our thing enters meta stability where its been driven but not completely which means it may not settle to a state in the given tout time

transferring data between clock domains requires circuitry to synchronize the data
- meaning that we need to make sure there is no metastability

so ff1 has time to settle its voltage
ff2 samples ff1 when ff1 has settled a bit
then ff3 samples ff2 when ff2 has even more time to settle

putting combinationa logic between is bad since there is more stuff to propagate thorugh meaning its takes longer to stabilize

each one is a more settled down version of the next

------------------
implemented design is like actual luts (luts is basically just ram) and primitives

##need to specify the GPIOs associated with the ports of the top level module

## 12 MHz Clock Signal  
## physical top level pin is l17 which is the clock port
## it has an external oscillator
## so you are just telling the fpga 
## hey we want to use the external oscillator at this frequency as the main clock of the system
set_property-dict { PACKAGE_PIN L17 IOSTANDARD LVCMOS33 }
[get_ports { clk }];
create_clock-add-name sys_clk_pin-period 83.33-waveform
{0 41.66} [get_ports {clk}];

## LEDs
## LED1
set_property-dict { PACKAGE_PIN A17 IOSTANDARD LVCMOS33 }
[get_ports { led[0] }];
## LED 2
set_property-dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS33 }
[get_ports { led[1] }];

## set-property is used to inform syntheszier of the association between GPIO and top level port
## create_clock tells the synthesizer the frequency at which it should expect the circuit to run at
## so that the syntheszier can ensure the circuit will run at the desired speed

# Assign a physical pin and I/O standard
set_property PACKAGE_PIN <pin_name> [get_ports <port_name>]
set_property IOSTANDARD <io_standard> [get_ports <port_name>]


about the HADD
- the way the half adder works is it takes the input bits stored from the dff
- then, it adds one to it by having the carry in bit of the LSB HADD be 1
- the HADD's output bits are the data bits for the dff
- the dff's output bits are the input bits to the HADD
- we add 1 by having the carry in bit = 1 for the LSB HADD 

notice how that for digital design, we want something to serve as multiple things
- like logically speaking if the carry in bit = 0, then we dont count!
- so it serves as both an enable bit and an actual counting bit
- this way we dont need to gate the clock which is rlly bad since its not really part of the clock domain anymore
- this could lead to metastability problems

note: for programming, variables are just an abstraction over a range of address for a specific thing
- like a variable name for a struct is abtraction over that range of addresses

NOTE: projects have the .xpr extension

so it uses OFDM and in each frequency bin they use qpsk or qam such that the bandwidth in each bin is not larger than 1/t

For anyone wondering if marking the variables as volatile to prevent compiler optimizations would fix the issue... yes, in an older CPU, that would work. But the moment the CPU has instruction pipelining, the instructions executed by the hardware are changed not just by the compiler, but also by the CPU, so volatile does not fix the issue. Software only solutions would work if it weren't for CPU instruction pipelining and optimizations applied to microcode, so the solution, as the video states, is to use hardware atomics, which is what mutex implementations use under the hood on modern platforms.

EDIT : I'm tired of explaining this to people and having my replies be deleted by YT over and over again, so I'll write it once and hope people with a minimum of intelligence can understand this: I'm talking about out of order execution and instruction reordering. Just because you didn't know that CPUs can reorder instructions, it doesn't mean that they can't. Look it up. The video literally talks about microcode, one would expect that people would watch the whole thing BEFORE going to the comments, but it seems not to be the case.
- so hardware optimization is re arranging the orer of exceution and guessing the order

snapdragon - qualcomm
complex tasks into simple instructions