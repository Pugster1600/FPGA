## 12 MHz Clock Signal
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports clk];

# X0Y0
#create_clock -period 2.0 [get_ports clk];# -- fail
#create_clock -period 2.1 [get_ports clk];# -- fail
#create_clock -period 2.2 [get_ports clk];# -- pass
#create_clock -period 2.5 [get_ports clk];# -- pass
#create_clock -period 3.0 [get_ports clk];# -- pass
#create_clock -period 3.5 [get_ports clk];# -- pass
#create_clock -period 4.0 [get_ports clk];# -- pass

#X65Y0
#create_clock -period 2.0 [get_ports clk];# -- fail
#create_clock -period 2.1 [get_ports clk];# -- fail
#create_clock -period 2.2 [get_ports clk];# -- fail
#create_clock -period 2.3 [get_ports clk];# -- fail
#create_clock -period 2.4 [get_ports clk];# -- fail
#create_clock -period 2.5 [get_ports clk];# -- pass
#create_clock -period 3.0 [get_ports clk];# -- pass
#create_clock -period 3.5 [get_ports clk];# -- pass
#create_clock -period 4.0 [get_ports clk];# -- pass

#X0Y149
#create_clock -period 4.0 [get_ports clk];# -- fail
#create_clock -period 4.1 [get_ports clk];# -- fail
#create_clock -period 4.2 [get_ports clk];# -- fail
#create_clock -period 4.3 [get_ports clk];# -- fail
create_clock -period 4.4 [get_ports clk];# -- pass
#create_clock -period 4.5 [get_ports clk];# -- pass
#create_clock -period 5.0 [get_ports clk];# -- pass
#create_clock -period 6.5 [get_ports clk];# -- pass
#create_clock -period 6.0 [get_ports clk];# -- pass
#create_clock -period 7.5 [get_ports clk];# -- pass
#create_clock -period 8.0 [get_ports clk];# -- pass

## Push Button
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports btn];

## LED
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports led];

## Flip-flop placement constraints
set_property LOC SLICE_X0Y0 [get_cells tmp_reg];# Do not comment out this line!
#set_property LOC SLICE_X0Y0 [get_cells led_reg];
#set_property LOC SLICE_X65Y0 [get_cells led_reg];
set_property LOC SLICE_X0Y149 [get_cells led_reg];