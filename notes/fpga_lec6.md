The objective is to learn to use the primitive items
- ADC, RAM and CMT
- CMT is clock maangement tile

look at the vivado 7-series FPGA libraries guide
- then look at each primitive's stuff

## 1. ADC
- the adc block is called XADC in the documentation

it can digtize signals from different sources also called channels
18 inputs
- it can be from external inputs or internal ones
- ADC has configuration options
- need to read the SCR register in chapter 3
- aka the status and control regiter
- probability quite similar to the st microcontrollers

### Documentation reading

## 2. RAM block
- can be configured in different word sizes
- documentation is in 7 series FPGAS memory resources user guide
- the ram blocks can store 9 x 4096 bits of data
- there are 50 of these according to the documentation
- dual ported so can read and write at the same time
- there are 2 sets of address signals, input data signalds and output data signals for this reason
- these ports can be of various widths

std_logic_vector uses these RAM blocks
- however, they dont actually say we are usign a certain data witdth
- it instead instantitates the largest size possible and ignores the unused bits
- the data port width is the data bit size
- address port width is the address bit size
- dept is the total amount- notice how if address port width is 9, then the depth is 512 which is 2**9
- addr port is the bits we use when inputing the the adress
- DI/DO port is the data in data out port
- DIP/DOP data in data out port ??
- every byte has a parity bit which is why the data port widt his 9 * size

cascade mode is allowing 2 ram blocks to form a signle 1 x 665536 memor yblock
- this uses address bit 15

FIFO is literally just when you write into memory, the address increments for the write
when you read, then address also increments
so its like a queue for both tx and rx

so say i write, it gets stored to0x0
write again 0x1
again 0x2

for read, i read 0x0
then the pointer goes to 0x1
then 0x2

### documentation reading
- of both the configuration and such

## 3 CMT
- mixed clock manager
- phase-locked loop
- CMTs are used to derive a new clock from a signle external lock when a non simple divide by integer solution or an accumulator will work. 
- for example, you cant just multiply a 12mhz clock to make it faster
- so you would use CMT for this
- the PLL is to make sure they are synced
- since small frequency changes manifest as small shifts in phase overtime
- we cannot use PLL with the input clock on cmod A&
- use MMCM only

- chapter 3 of the user guide for MMCM
- contains VCO where the voltage is the desired frequency
- the VCo thing is in sync with a PLL
- VCO used to resync to the desired ratio -> this is like mixed mode because you configure in digital to control the analog part

understanding the frequency thing

$\frac{F_{CLKin1}}{D} = F_{CLKFB} = \frac{F_{VCO}}{M}$ where clkin1 is the main clock input
- d is the dividing factor
- essentially, the circuit drivers the VCo such that the two inputs, CLKIN/D and CLKFBIN hae the same frequencies 
- CLKFBOUT is just VCO/M sinc ethe VCO output is then divided by a factor M
- $F_{VCO}\frac{F_{CLKIN1 * M}}{D}$
- From each output, the VCO is further divided, into $\frac{F_{CLKIN1 * M}}{D * O}$ where O is the dividing factor
- so as long as O < M/D we are multiplying by a factor
- divide F works for fractical ones
- anything that ends in F is fractional
- this feedback stuff is like circuits like anything in is anything out dicitaed by component equations