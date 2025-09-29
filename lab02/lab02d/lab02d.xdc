# Clock
set_property PACKAGE_PIN L17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports clk]

# LEDs
set_property PACKAGE_PIN A17 [get_ports led[0]]
set_property IOSTANDARD LVCMOS33 [get_ports led[0]]

set_property PACKAGE_PIN C16 [get_ports led[1]]
set_property IOSTANDARD LVCMOS33 [get_ports led[1]]

# buttons
set_property PACKAGE_PIN A18 [get_ports btn[0]]
set_property IOSTANDARD LVCMOS33 [get_ports btn[0]]

set_property PACKAGE_PIN B18 [get_ports btn[1]]
set_property IOSTANDARD LVCMOS33 [get_ports btn[1]]