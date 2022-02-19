vlib work
vlog -sv ./../../rtl/led_strip.sv
vlog -sv led_strip_tb.sv

vsim -novopt led_strip_tb
add log -r /*
#add wave -r *

add wave -expand -group ENV   -color #7CFC00                  /led_strip_tb/sw
add wave -expand -group ENV   -color #1E90FF -radix unsigned  /led_strip_tb/cnt
add wave -expand -group ENV   -color #FF2020 -radix unsigned  /led_strip_tb/led

add wave -expand -group DUT   -color #7CFC00                  /led_strip_tb/DUT/sw_i
add wave -expand -group DUT   -color #1E90FF -radix unsigned  /led_strip_tb/DUT/cnt_i
add wave -expand -group DUT   -color #FF2020 -radix unsigned  /led_strip_tb/DUT/led_o

configure wave -namecolwidth  200
configure wave -valuecolwidth 100

run -all