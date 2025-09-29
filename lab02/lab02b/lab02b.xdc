## 12 MHz Clock Signal  
## physical top level pin is l17 which is the clock port
## it has an external oscillator
## so you are just telling the fpga 
## hey we want to use the external oscillator at this frequency as the main clock of the system
set_property PACKAGE_PIN L17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports clk]


## set-property is used to inform syntheszier of the association between GPIO and top level port
## create_clock tells the synthesizer the frequency at which it should expect the circuit to run at
## so that the syntheszier can ensure the circuit will run at the desired speed
# LEDs
set_property PACKAGE_PIN A17 [get_ports led[0]]
set_property IOSTANDARD LVCMOS33 [get_ports led[0]]

set_property PACKAGE_PIN C16 [get_ports led[1]]
set_property IOSTANDARD LVCMOS33 [get_ports led[1]]
