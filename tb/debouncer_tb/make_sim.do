vlib work
vlog -sv ./../../rtl/debouncer.sv
vlog -sv debouncer_tb.sv

vsim -novopt debouncer_tb
add log -r /*
#add wave -r *

add wave -expand -group STATS   -color #FFFF00                  /debouncer_tb/clear_signal_stat
add wave -expand -group STATS   -color #FFFF00                  /debouncer_tb/noise_signal_stat

add wave -expand -group COMMON                                  /debouncer_tb/cb/cb_event
add wave -expand -group COMMON  -color #00FFFF                  /debouncer_tb/clk
add wave -expand -group COMMON  -color #FF1010                  /debouncer_tb/rst
add wave -expand -group COMMON  -color #FF1010                  /debouncer_tb/rst_done

add wave -expand -group MAIN    -color #7CFC00                  /debouncer_tb/pin
add wave -expand -group MAIN    -color #1E90FF                  /debouncer_tb/pin_state

add wave -expand -group DUT     -color #7CFC00                  /debouncer_tb/DUT/pin_i
add wave -expand -group DUT     -color #1E90FF                  /debouncer_tb/DUT/pin_state_o

add wave -expand -group DUT     -color #00FFFF                  /debouncer_tb/DUT/clk_i
add wave -expand -group DUT     -color #FF1010                  /debouncer_tb/DUT/s_rst_i
add wave -expand -group DUT     -color #1D627C                  /debouncer_tb/DUT/pin_d
add wave -expand -group DUT     -color #1D627C 					/debouncer_tb/DUT/pin_differ
add wave -expand -group DUT     -color #1E90FF -radix unsigned  /debouncer_tb/DUT/db_counter
add wave -expand -group DUT     -color #1E90FF					/debouncer_tb/DUT/db_counter_max

configure wave -namecolwidth 225
configure wave -valuecolwidth 80

run -all
