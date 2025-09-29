

time set and time hold are measured relative to the clock edge

Deassert sync
- we have the reset directly connected
- BUT we also have a shift register connectd
- this way so that when we deassert, the 0 will get shifted through
- so the set goes directly through
BUT the reset goes through gates

signed and unsigned types
- IEEE.numeric_std package
- signed and unsigned types are related to std_logic_vector since they are just the bit vectors
- VHDL does not have automatic type conversion so you cant direclty assigned signed, unsigned etc
- the BITS THEMSELVES ARE IDENTICAL when casting
- its just operations are different
- like MSB for a signed value would take the 2nd MSB since the 1st MSB is the sign technically
- and the interpretations will change, so the value itself will be different
- these are vectors!

integer, nautral and positive are just scalar types
- integer is implementation defined ie based on like the synthesizer kinda like "long" in C.
- we can technically change the integer values
- we use to_integer, to_signed and to_unsigned
- converting from scalar to bits, we can defined the array size

When you add to a bit vector, the hardware is an adder.
If that addition feeds back into the same register on each clock edge, the hardware is effectively a counter.

process if else done with double mux
pipelining just literally wires the the data out to another section rather than storing it 
- think of hardware to software switching

different circuits need to communicate combinatorially IN ORDER TO HAVE THEM BE IMMEDIATE SINCE it only takes the propagation delay time to go through
- if we say register the carry, the carry would delay by a cycle since the carry updates on the next clock cycle!

say we want to generate it after 4 cycles
- it will be delayed by one cycle so shifted in time by one cycle

what if we pregenerate the carry
- say generate it after 3 clock cycles
- we can technically do this but if we want to cascade a lot of counters, we have an issue of generating all
- ALSO it may wrap around if we cascade too much since we go ahead by 1 cycle. If we go ahead up to say 9 cycles but the final one only adds up to 8, we will wrap around!

we dont want a mix of clocked and unclocked signal
- make them all the same either combinational aka unclocked or seqeutnail ka clocked
- also dont want to duplicate conditions to check
- we want carry to be combinational 

separate clocked and combinatorial processes

acculmulator is made of full adders so we can add any number rather than being a power of 2 (HADD is only power of 2)

counter is good to divide a clock 
- bcounter is by powers of 2
- regular one will allow us to use integers

accumulator
- allows us to use netural

so we will have a counter
- every N times, it will have a cout
- this cout feeds into another counter 
- the second counter is the divided clock
- to avoid arithetic overflow and underflow, we can add extra bits
then we check if it flowed into those extra bits

number of bits = log(#of signals) 

when greater than 60, it will reset
- this just differs every 60 counts
- which is not that big of a deal


so if it goes to 64
- we can increment 5
- 5/64 of the original clock
- we may reset from say 67 to 0
- this is fine if we lose the 3 since it takes 5 entire cycles of 64 for one miss cin

-----------------------------------------
to have a count by 

process(clk)
begin 
  if rising_edge(clk) then
    if count = 3 then
      count <= 0;
    elsif count = 4 then
      count <= 1;
    else 
      count <= count + 2;

but there are a bunch of roll over scenarios
- so if count by 100, need to account for 100 rollsovers

instead we can do something like

process(clk)
begin 
  if rising_edge(clk) then
    if count + inc >= 5 then
      count <= count + inc - 5; -- handles overflow
    else 
      count <= count + inc;

--------------------
carry signal

we want the counters to be modular

-- adder0
process(clk)
begin 
  if rising_edge(clk) then
    if count + inc >= 5 then
      count <= count + inc - 5; -- handles overflow
      carry <= '1' --registered!
    else 
      count <= count + inc;
      carry <= '0'

--adder 1
process(clk)
begin 
  if (carry=’1’) then
 if (count1=4) then
 count1<=0;
 else
 count1<=count1+1;
 end if;
 end if;

but since it is registered, the sceond counter gets delayed by one cycle
- each subsequent counter gets delayed by another clock cycle
- this is called a pipeline delay

we can predict it by hvaing carry ='1' when its 1 less than the counter size
- BUT it will require the previous counter ot be 1 early
- then the previous one to be another 1 early
- say your counter is every5, if thats the case and you cascade 6, that means counter0 must be 6 early but that does not make sense!
plus each module will need to be delayed a different amount thus it is no modular

we need to generate it combinatally

NOTE: these are for the cascading counters
the ones above are for the accumulator
--this is for EACH CLOCK MODULE
process(clk,count0)
begin
  if rising_edge(clk) then
    if (count0=4) then --if overflow
      count0<=0;
    else
      count0<=count0+1; --count by 1
    end if;
  end if;
  
  if (count0=4) then
  carry<=’1’;
 else
  carry<=’0’;
 end if;
end process;

--2 if statements execute in parallel
--nested if is layered mux

--combinational section
process(clk)
begin
if rising_edge(clk) then
  if (carry=’1’) then
    if (count1=4) then
      count1<=0;
    else
      count1<=count1+1;
    end if;
  end if;
end if;
 end process;

issue:
- 2 assignments related to count0 
- mixes clocked and combinatorial assignments in the same process

2 idential tests for count0 means neededing to change code in 2 places

use the 2 segment stylce of coding (ie of describing hardware)
1. for combinational assignments
-- Combinatorial assignments
process(count0,count1)
begin-- Update rules for count0 and carry
--count0 is the first counter (can just keep adding 1)
--count1 is the second counter so it updates every time count0 resets
-- if count0 resets every 5, then its a divide by 5
  if (count0=4) then
    count0_next<=0;
    carry<=’1’;
  else
    count0_next<=count0+1;
    carry<=’0’;
  end if;-- Update rules for count1
  
  -- parallel process for the second one 
  if (carry=’1’) then
    if (count1=4) then
      count1_next<=0;
    else
      count1_next<=count1+1;
    end if;
  else
    count1_next<=count1;
end if;
end process;

 -- Registered signal updates
 process(clk)
 begin
 if rising_edge(clk) then
 count0<=count0_next;
 count1<=count1_next;
 end if;
 end process;

in essence, the adder updates immediately
- BUT the updated values are stored
- so the adder calculates the new value and carry in and carry out bits imedately
- the new values are stored in the register

making the counter generic
- for base 16, 0-15 is better since it takes 4 bits vs 5 bits for 1-16

accumualtor
- we want to increment by different values

process (count, inc, end, carry_in)
begin
  if (count + inc + carr_in > end) then
    count_next <= count + inc + carry_in - (end + 1)
    carry_out <= '1'
  else
     carry_next <= count + inc+ carry_in;
     carry_out <= '0'
 process(clk)
 begin
 if rising_edge(clk) then
 count<=count_next; --update the registered count
 end if;
 end process;

GENEREALIZE
1. end - 1
2. different inc values
3. we may want a different start value
- so we can generalize to end - beg + 1
- so count from 0 to end-beg
- so 1- 16 would be 0 to 15
- this is base 16
- 

 begin
 if (count+inc+carry_in>end) then
 count_next<=count+inc+carry_in-(end-beg+1);
 carry_out<=’1’;
 else
 count_next<=count+inc+carry_in;
 carry_out<=’0’;
 end if;
 end process;
 process(clk)
 begin
 if rising_edge(clk) then
 count<=count_next;
 end if;
 end process;

overflow
- in base 3, if inc=3 and base 5
we can do 
count+3 > 6
- but we would have to account for all others

so the best way is to extend the size of the array by log2(inc) bits
- dont declare more bits in signals
- instead declare concat since this uses less resources

RESET
- we can specify a power on value of a port or signal in xilinx FPGA's
- by deafult these are either pulled up, down or left floating
- NOTE: the input is not floating but the output is