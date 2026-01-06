## 12 MHz Clock Signal
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports clk ];
create_clock -period 13.3 [ get_ports clk ];

#set_output_delay -clock clk -max 0.5 [ get_ports tx ];# pass WNS =  2.683, TNS =  0.000, WHS = NA, THS = NA
#set_output_delay -clock clk -max 1.0 [ get_ports tx ];# pass WNS = 2.183, TNS = 0.000, WHS = NA, THS = NA
#set_output_delay -clock clk -max 1.5 [ get_ports tx ];# pass WNS = 1.683, TNS = 0.000, WHS = NA, THS = NA
#set_output_delay -clock clk -max 2.0 [ get_ports tx ];# pass WNS = 1.183, TNS = 0.000, WHS = NA, THS = NA
#set_output_delay -clock clk -max 2.5 [ get_ports tx ];# pass WNS = 0.683, TNS = 0.000, WHS = NA, THS = NA
#set_output_delay -clock clk -max 3.0 [ get_ports tx ];# pass WNS =  0.326, TNS =  0.000, WHS = NA, THS = NA
set_output_delay -clock clk -max 3.3 [ get_ports tx ];# pass WNS =  0.026, TNS =  0.000, WHS =NA, THS  = NA
#set_output_delay -clock clk -max 3.4 [ get_ports tx ];# fail WNS = -0.074, TNS = -0.074, WHS = NA, THS = NA
#set_output_delay -clock clk -max 3.5 [ get_ports tx ];# fail WNS = -0.174, TNS = -0.174, WHS = NA, THS = NA

#set_output_delay -clock clk -min -1.0 [ get_ports tx ]; # pass WNS = 0.026, TNS = 0.000, WHS = 1.563, THS = 0.000
#set_output_delay -clock clk -min -2.0 [ get_ports tx ];# pass WNS = 0.026, TNS = 0.000, WHS = 1.085, THS = 0.000
#set_output_delay -clock clk -min -2.5 [ get_ports tx ];# pass WNS = 0.026, TNS = 0.000, WHS = 0.585, THS = 0.000
#set_output_delay -clock clk -min -2.8 [ get_ports tx ];# pass WNS = 0.026, TNS = 0.000, WHS = 0.285, THS = 0.000
set_output_delay -clock clk -min -2.9 [ get_ports tx ];# pass WNS = 0.026, TNS = 0.000, WHS =  0.185, THS = 0.000
#set_output_delay -clock clk -min -3.0 [ get_ports tx ];# fail WNS = -0.443, TNS = -0.443, WHS =  0.276, THS = 0.000

#set_input_delay -clock clk -max  3.0 [ get_ports rx ];# pass WNS = 0.026, TNS = 0.000, WHS =  1.085, THS = 0.000
#set_input_delay -clock clk -max  5.0 [ get_ports rx ];# pass WNS = 0.026, TNS = 0.000, WHS = 1.085, THS = 0.000
#set_input_delay -clock clk -max  10.0 [ get_ports rx ];# pass WNS = 0.026, TNS = 0.000, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -max 11.0 [ get_ports rx ];# pass WNS = 0.026, TNS = 0.000, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -max 12.0 [ get_ports rx ];# pass WNS = 0.026, TNS = 0.000, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -max 13.0 [ get_ports rx ];# pass WNS = 0.026, TNS = 0.000, WHS = 0.185, THS = 0.000
set_input_delay -clock clk -max 14.0 [ get_ports rx ];# pass WNS = 0.026, TNS = 0.000, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -max 14.1 [ get_ports rx ];# fail WNS = -0.051, TNS = -0.051, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -max  15.0 [ get_ports rx ];# fail WNS = -0.951, TNS = -0.961, WHS = 0.185, THS = 0.000

#set_input_delay -clock clk -min 1.0 [ get_ports rx ];# fail WNS = -2.411, TNS =  -2.061, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -min 2.0 [ get_ports rx ];# fail WNS = -1.538, TNS =  -1.538, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -min 3.0 [ get_ports rx ];# fail WNS = -0.937, TNS =  -0.937, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -min 3.5 [ get_ports rx ];# fail WNS = -0.791, TNS =  -0.791, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -min 3.8 [ get_ports rx ];# fail WNS = -0.702, TNS =  -0.702, WHS = 0.185, THS = 0.000
#set_input_delay -clock clk -min 3.9 [ get_ports rx ];# fail WNS = -0.318, TNS =  -0.318, WHS = 0.185, THS = 0.000
set_input_delay -clock clk -min 4.0 [ get_ports rx ];# pass WNS = 0.026, TNS = 0.000, WHS = 0.004, THS = 0.000