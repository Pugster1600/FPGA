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



WRITE A PIECE OF CODE FOR THIS

NOTE: think of it in terms of base 10 so we can kinda see it at play with something we are more familiar with

how does integer division work in terms of logic gates like if i am trying to implement it in say vhdl. Just give the high level overview dont actually provide an implementation

learn but also come up with original thoughts
- like anyalyze why this works using your own thoughts first!