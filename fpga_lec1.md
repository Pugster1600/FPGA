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