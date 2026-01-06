
## HW STUFF
-- the 05_adc does the instantiation ie it actually configures the registers 
-- into the way we want it
-- we still need to 
-- need to specify which analog channel is connected ot the ADC input
-- we want AUX12 analog input which can be reouted to GPIO pin 16

confiugred so that the end of conversion signal triggers an a DRP dynamic reconfiguration port read
- so vaux12 is the channel we are reading from in the ADC
- but we must configure it so that the ADC is connected to vaux12

init40 is configuration register 0
- table 3-7 for ADC channel select
- we want 

we lok at the ADC channel 18-31 which is aligned with vaux12 
- virtual is just abstraction over hardware ie indirection
- aux12 is channel 28 

DRP address bus
- this is form the daddr bits
- daddr[6:5]  = 0 as per page 61
- so its 00_11100 for 28
- address bus for the drp -> xadc port descriptions
- daddr for drp
- so to configure the data address for the drp
- so we want to basically have the address point to the 

read conversion phase in pg 61

drp is like we are giving it inputs rather than going through jtag to give the inputs to configure or read data
- so here, instead of reading data from jtag, we intsead can output directly as via wires

so basically drp will route whatever reigster out straight out
- if we route say the configuration reigster then we can see the configuration register directly from the wires
- so what we care about is connecting the drp to the data port of vaux 12

1c as seen in page 28

## part B
the ram blocks being init as dual port means that we have enabled us to both read and write into the ram block at the exam same time

uart lines typically have like a fifo buffer if the rx end has not had the chance to read the data before it got another piec eof information
- so the read pointer may still be at 0x1 but the write pointer could be at 0x4

the RAM blocks are 1024 words of 36 bits
- this means it is 32 bits of actual information and 4 parity bits
- but we will only use the lower 12 bits to for the 12 bit ADC

input bits of the ram block are from the ADC
output blocks feed into the gui module so that it can send it to matlab
- the input address lines can also be driven by the gui so the gui can read from a certain data address

we need to write the vhdl code from addrb and web_i inputs inot the RAM module
- rdy is used to signal the completion of a conversion for the ADC blocks
- this means that when we are rdy, we will increment the address pointer, write to that address
- only write to the RAM block whent he button is pressed
- if the button is pressed, you write the 200 samples to the RAM block at addresses 0 to 199
- continue writing to the RAM block in blocks of 200 samples

when it is asking for data it reads from 0-199
- this is about 200 sample points

observations leads to you being able to eliminate certain reasons

so part of the ram block is to store the data
the other part of ram block is to share the data?
- so everything gets shuffled up

web = write enable b
so if rdy then write enable

write is b
read is a
- we can also see this bceuase adc out is connected to datab

------------------------------------------------------
## Review

the thing is already registered if it is in a clocked process

ff and latch
- ff will get inferred if inside a clocked process

whereas a latch will get inferred -> need to have a reset condition 
- if it is outside a clocked process
- so still in a process but not in a clocked one

variables
- to_integer and all that good stuff like bit padding too
- generate stateents, loops, case statements, while loops
- user defined data types

case = single mux with inputs corresponding to each state
if statements are staggered mux with the closest mux to the output being the highest priority statement

if 2 different things are driving the same input then it will show X
- IT SHOULD ONLY BE ASSIGNED IN A SINGAL PROCESS
- 
clb vs lut

------------------------------------------
we can write it to a register 
- that register then shifts it out to a shift reigster?
- but how would we know the current amount we have shifted
- should we hold a count or something

moore output only depends on state
- this means that the state encodes the input sort of 
- so the output is registered

mealy output depends on the state and input
- this means the output is not really registered and can change in between rising edges

rx looks for a start bit, meaning an input
output would be the bits
state is start, stop which bit we are currently sending

we can deviate by $\pm 5$ percent of the agreed baud rate
- reason is if both are off by 5 percent such that the difference is 10 percent, we are only sending 10 total bits including start and stop
- so this would be a total of 100% difference which is the threshold 

we need a counter 
- just adding by one no need for an accumlator
- the reason is to match the baud rates
- this could mean that some states only stay in that state for 10 clk cycles
- while another 11 clk cycles to make the overall baud rate correct

LUTs are tiny ROM
CLB are groups of LUTs and FF

--------------------
JUST BUILD SOMETHING ON A PCB
- you dont even need to do reserach ahead of time
- what you should do is basic plan then desifn like reading a data sheet
- then if you rae stuck while builidng it search up 
- once you are done, you can watch a tutoiral to polish up

1. bit extension
- unsigned, integer etc conversions
- accessing can only be done with integers

2. for loops syntax -> honestly syntax is fine to not remember just know how to do it

3. generate statements

4. LUTs

5. handshaking

------------------------
## VHDL type conversion
### The types
1. logic - std_logic_vector and std_logic
2. numeric - unsigned, signed
3. numeric types - integer, natural
4. real type
5. bit types

We are going to focus on std_logic_vector, std_logic, integer and unsigned

### Conversion
1. std_logic_vector to unsigned -> does not use to
- unsigned(std_logic_vector)
2. unsigned to std_logic_vector
- std_logic_vector(unsigned)

IMPORTANT: these are type casts NOT actual conversion
- just like how in C casting uint32_t to say uint8_t will just allow us to treat it as a different abstraction RATHER THAN changing the underlying bit

3. unsigned to integer -> uses to
- to_integer(unsigned)
4. integer to unsigned
- to_unsigned(int WIDTH)


you cannot ocnvert directly between integer and std_logic_vector
NOTICE HOW IF IT IS NOT ORIGNALLY A SEQUENCE OF bits (ie if it was an integer), you must specify the length!
- this means we can use '0'& for BOTH unsigned and std_logic_vector

YOU CAN ONLY DO MATH WITH INTEGERS AND UNSIGNED
- because they are actual math things so it tells the synthezier to use the adder blocks

SIGNALS ONLY UPDATE AT THE END OF A PROCESS aka after the rising edge/change
VARIABLES UPDATE immedately when you assign them

## custom types
type FSM_TYPE is (S0,S1,S2) -> you write this in the signal section of the architecture
signal FSM_sig : FSM_TYPE := S0



## Variables

process (clk)
  variable name_var : std_logic_vector := '1' --same syntax
begin 
  name_var := name_var + 1;

ONLY visible inside the process
changes immedately when assigned
retain value in between processes -> just like static varaibles in C
cannot be driver outside of processes
- signals are like wires

still just combinational if in combinational process
BUT in clocked process, the variable name_var gets registered, name_var := name_var
- THEN output of the reigster gets send to combinational do the + 1
- output of combinatla gets fed back to register and send to the process reigster

variables are just registers with combinatla logic outside
- so here, name_var is registered but it gets fed into combinational logic that does the + 1
- so it gives it the illusion of immediate

so the typicaly flow is 
register -> combinatal logic -> process register -> some other combinational
  ^             |                     ^             |
  |             |                     |             |
  ---------------                     ---------------
The output of combinatla logic then gets registered again in name_var
- but the output of combinational logic also gets fed to process register


## Latch inference
process (S,R)
begin
if S = '1' then
  Q <= '1'
else if R = '1' then
  Q <= '0'
end process;

process(a, b, sel)
begin
    if sel = '1' then --latch is inferred to hold state when sel = '0'
        y <= a;
    end if;
end process;

NOTICE how there is not else
- this is inferred as a latch because there is no clock
- BUT if you add an else, this will prevent a latch inference and make it a LUT combination
- basically for every possible input, the synthesizer must know the corresponding output
- this is why it infers a latch
- in order to not infer a latch, you need to manually cover all other possible inputs

To prevent latch inference
- 1. provide assignment at the start almost like a deafult
- since this is combinational, the synthesier will override the intiial assignmnet if need be
2. explicitly cover all cases

This is why for case statements, we use when others in order to prevent inference of latches
- case statements good for combinational description

AVOID COMBINATIONAL AND clocked being combined in the same process

process (x,y,z)
begin 
  if (x = '1') then
    w <= '0' --makes it so that it does not get inferred as latch for this section
      if (y = '0') then
        w <= '1'
    end if;
  else --does not get inferred as latch because of the else
    if z = 1 then --inferred as latch because no default state AND not cover all cases with an else
      w <= y
    end if
end process
## LUT and FF
6 inputs
- basiclaly a 2^6 register
- 6 address bits
- 1 output bit

5 input

## RAM

Distributed RAM
distributed RAM is a type of memory implemneted inside logic fabric using LUTs
- since LUTs are basically small 6-bit addressed memory cells
- 6 input 1 output LUT
- this means we have 64 addresses
- if we have 8 LUTs in paralle, this would make it 64 x 8
- the output can be 8 bits
- this is great for FIFO

distributed RAM looks like
if WE = 1
  ram(address) <= data

remember that when something is clocked, you q(t+1)= d(t)
- so its the previous clock cycle!

## for
process (x)
begin
  y(3) <= x(3);
  for i in 2 downto 0 loop
    y(i) <= y(i+1) or x(i)
  end loop;
end process;

general rule: anything on the right handside of an assignment in a process should be in the sensitivty list

asking if ff, latch, combinational or broken
1. is it clocked
- this means ff or broken
- 2. is reset the higher priority
- if it is, then not broken
- else broken

1. is it not clocked
- this means latch or combination
- 2. are all possible cases covered either with default assignment to output or an else
- if yes then combinational
- if no then latch

## clks and stuff and handshake and fsm

1hr mark

## handshaking
the 2 way handshake is just a request and an ack

a 4 way handshake is almost like a ack to the ack from the request end

--------------------------------------------
we are using vaux12
- the pin map maps this to pin 16
- so probably need to configure the gpio to map to the adc
- then configure the adc so that it enables vaux12

drp is basically i input a sequence of bits, that sequence it interpreted as the address we are reading from the memroy
- then it outputs the data from that area in memory

--------------------------------------
port b is the data into the ram since connected to adc
port a is the data out of the ram since connected to gui
- addra is driven by the gui so that the gui can get the data

we need to drive addrb to store the adc data into the ram
web_i to write enable basically
adc provides a trigger rdy, which is going to be used to increment addrb and enable the write into b

when button is pressed, write 200 samples in address 0 to 199 (ignorning presses in the middle of the 200 samples)
- when button is no longer pressed, pause 
- then wait again and overwrite address 0 to 199
-----------------------------------
1. 26 adcclk cycles per sample
2. max rate of transfer is 1 mhz
3. but the input clck is from dclk which is divided by a factor from 2-255
- thus we need to have an input signal of at least 52 mhz in order to get max transfer rate.

configure: 
MMCEME2-BASE
params:
DIVCLK_DIVIDE
CLKFBOUT_MULT_F
CLKOUT0-DIVIDEF

NEXT FEATURE
only start sampling when the threshold is gerater than the slider value in matlab
when prev sample <= theshold and current sample >= threshold

we need an extra sample, ie 3 data points because we need an extra clk cycle
- when checking the shift registers, we when we get the 3rd data point, we can finally check data 1 and data 2 since they are finally in the ff

It may appear that from the previous equations that for a given input frequency and desired
 output frequency, there are many possible values that 𝑀, 𝐷 and 𝑂 could be used. However, that
 is not necessarily the case. The primary constraint is that, because the phase detection circuit and
 VCO are analog circuits, they can only operate over one octave (frequency doubling). In the case
 of the XC7A35T FPGA, the VCO range is fixed to be between 600 MHz to 1200 MHz, so the 𝑀
 and 𝐷 factors need to be chosen judiciously. Furthermore, the fractional dividers are implemented
 via accumulators and will therefore cause additional jitter when used, so integer values should be
 chosen when practical.

 see behavior, then try to walk through the sequence/code to see which path could hvae caused that

 keep signals registered to prevent potential timing errors
 - this is what vivado was complaining about since we had combinaitonal logic feed into the ram block

process (fclk)
begin
	if rising_edge(fclk) then
		ready <= rdy and counting and threshold_met; --maybe all of these = '1'???
		btnSync(0) <= btn;
		btnSync(1) <= btnSync(0);
		btnSync(2) <= btnSync(1);

			-- counting used as flag to prevent multipole signals driving
		if btnSync(2) = '1' and counting = '0' then
			-- write the thing 200 times
			-- so a flagged process or something
			counting <= '1';
		end if;
		--just keep shifting the data down, checking the 2 oldest, then we send it out
	
		if counting = '1' then
			case to_integer(unsigned(addrb)) is --must be discrete types ie not an array of bits
				when 0 =>
					if rdy = '1' then --else hold, this does not infer latch cause inside a clocked process
						threshold_shift_reg(2) <= threshold_shift_reg(1);
						threshold_shift_reg(1) <= threshold_shift_reg(0);
						threshold_shift_reg(0) <= datab;
						-- need to be the previous ones because we will lose shift_reg 2 on the next clk cycle
						if (unsigned(threshold_shift_reg(1)) <= unsigned(thrsh)) and (unsigned(threshold_shift_reg(0)) >= unsigned(thrsh)) then
							addrb <= std_logic_vector(unsigned(addrb) + to_unsigned(1,addrb'length));
							threshold_met <= '1';
						end if;
						--addrb <= std_logic_vector(unsigned(addrb) + to_unsigned(1,addrb'length)); --registered so it gets stored next clk cycle, ram still uses current address
					end if;

				when 199 =>
					if rdy = '1' then
						threshold_shift_reg(2) <= threshold_shift_reg(1);
						threshold_shift_reg(1) <= threshold_shift_reg(0);
						threshold_shift_reg(0) <= datab;
						addrb <= std_logic_vector(to_unsigned(0, addrb'length));
						counting <= '0';
						threshold_met <= '0';
					end if;

				when others =>
					if rdy = '1' then
						threshold_shift_reg(2) <= threshold_shift_reg(1);
						threshold_shift_reg(1) <= threshold_shift_reg(0);
						threshold_shift_reg(0) <= datab;
						addrb <= std_logic_vector(unsigned(addrb) + to_unsigned(1,addrb'length));
					end if;
				end case;
		
			end if;
	end if;
end process;

IMPORTANT THING:
you can parallelize things
- by rewriting the same condition twice

somehting like

if A
  if B

  if C

instead do

if A
  if B

if A 
  if C

----------------------------
process(fclk)
begin
    if rising_edge(fclk) then
        -- -------------------------------
        -- 1) Button Synchronization
        -- -------------------------------
        btnSync(0) <= btn;
        btnSync(1) <= btnSync(0);
        btnSync(2) <= btnSync(1);

        -- start counting on rising edge of button
        if btnSync(2) = '1' and counting = '0' then
            counting <= '1';
        end if;

        -- -------------------------------
        -- 2) Shift Register Update
        -- -------------------------------
        if rdy = '1' and counting = '1' then
            threshold_shift_reg(2) <= threshold_shift_reg(1);
            threshold_shift_reg(1) <= threshold_shift_reg(0);
            threshold_shift_reg(0) <= datab;
        end if;

        -- -------------------------------
        -- 3) Threshold Detection
        -- -------------------------------
        -- Only compare the 12-bit ADC portion
        if rdy = '1' and counting = '1' then
            if (unsigned(threshold_shift_reg(1)(11 downto 0)) <= unsigned(thrsh)) and
               (unsigned(threshold_shift_reg(0)(11 downto 0)) >= unsigned(thrsh)) then
                threshold_met <= '1';
            else --NOTE: else not needed because ff already inferred
                threshold_met <= threshold_met;  -- hold previous value until increment
            end if;
        end if;

        -- -------------------------------
        -- 4) Ready Signal to RAM
        -- -------------------------------
        ready <= rdy and counting and threshold_met;

        -- -------------------------------
        -- 5) Address Increment & Counting Control
        -- -------------------------------
        if counting = '1' and ready = '1' then
            if addrb = std_logic_vector(to_unsigned(199, addrb'length)) then
                addrb <= (others => '0');
                counting <= '0';
                threshold_met <= '0';
            else
                addrb <= std_logic_vector(unsigned(addrb) + 1);
            end if;
        end if;
    end if;
end process;

this is pipelining

for timing violations, try to delay certain signals