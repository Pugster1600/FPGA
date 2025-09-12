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