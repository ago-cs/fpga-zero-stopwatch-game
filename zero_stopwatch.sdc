set_time_format -unit ns -decimal_places 3

create_clock -name {clk_50}      -period 20.000 -waveform { 0.000 10.000 } [get_ports {MAX10_CLK1_50}]
create_clock -name {clk_50_io} -period 20.000 -waveform { 0.000 10.000 }

derive_pll_clocks

derive_clock_uncertainty

#**************************************************************
# Create Clock
#**************************************************************
# suppose +- 100 ps skew
# Board Delay (Data) + Propagation Delay - Board Delay (Clock)
set_input_delay -max -clock clk_50_io 0.0 [get_ports {SW* KEY*}]
set_input_delay -min -clock clk_50_io 0.0 [get_ports {SW* KEY*}]

#**************************************************************
# Set Output Delay
#**************************************************************
# suppose +- 100 ps skew
# max : Board Delay (Data) - Board Delay (Clock) + tsu (External Device)
set_output_delay -max -clock clk_50_io 0.0 [get_ports {LEDR* HEX*}]
set_output_delay -min -clock clk_50_io 0.0 [get_ports {LEDR* HEX*}]

