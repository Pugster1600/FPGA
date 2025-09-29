# This file defines the interaction with the board
## Push Button
# PACKAGE_PIN A18 means pin A18 on the board (dependent on the board itself)
# IOSTANDARD just staying its IO
# LVCMOS33 means low voltage, CMOS, 3.3V (rather than say 5 V)
# the port names NEED TO MATCH THE DESIGN SOURCE NAME
# so to distinguish between 2 entities with the same port names

# the port names here ie button/led must match that of the top level one
#set_property-dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports { buttonTopLevel }];

## LED
#set_property-dict { PACKAGE_PIN A17 IOSTANDARD LVCMOS33 } [get_ports { ledTopLevel }];

## Push Button
set_property PACKAGE_PIN A18 [get_ports { buttonTopLevel }]
set_property IOSTANDARD LVCMOS33 [get_ports { buttonTopLevel }]

## LED
set_property PACKAGE_PIN A17 [get_ports { ledTopLevel }]
set_property IOSTANDARD LVCMOS33 [get_ports { ledTopLevel }]

## Push Button
#set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { buttonTopLevel }];

## LED
#set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { ledTopLevel }];
