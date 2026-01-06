## 12 MHz Clock Signal
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_14 Sch=gclk
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports {clk}];

## Buttons
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { btn }]; #IO_L19N_T3_VREF_16 Sch=btn[0]

## Analog XADC Pins
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { vaux12_n }]; #IO_L2N_T0_AD12N_35 Sch=ain_n[16]
set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS33 } [get_ports { vaux12_p }]; #IO_L2P_T0_AD12P_35 Sch=ain_p[16]

## GPIO Pins
set_property -dict { PACKAGE_PIN M1    IOSTANDARD LVCMOS33 } [get_ports { square }]; #IO_L9N_T1_DQS_AD7N_35 Sch=pio[17]

## UART
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { tx }]; #IO_L7N_T1_D10_14 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { rx  }]; #IO_L7P_T1_D09_14 Sch=uart_txd_in