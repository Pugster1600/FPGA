## 12 MHz Clock Signal
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports clk ];

#create_clock -period 1.0 [get_ports clk ];# fail
#create_clock -period 2.1 [get_ports clk ];# fail
create_clock -period 2.2 [get_ports clk ];# pass
#create_clock -period 2.3 [get_ports clk ];# pass
#create_clock -period 2.5 [get_ports clk ];# pass
#create_clock -period 4.0 [get_ports clk ];# pass

set_multicycle_path -setup 2 -from [ get_pins count_reg[*]/C ] -to [ get_pins count_reg[*]/D ];
set_multicycle_path -hold  1 -from [ get_pins count_reg[*]/C ] -to [ get_pins count_reg[*]/D ];

## LEDs
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { led[1] }];