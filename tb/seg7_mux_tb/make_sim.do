vlib work
vlog -sv ./../../rtl/datatype_package.sv
vlog -sv ./../../rtl/seg7_mux.sv
vlog -sv seg7_mux_tb.sv

vsim -novopt seg7_mux_tb
add log -r /*
#add wave -r *
add wave -expand -group ENV	-color #00FFFF                 /seg7_mux_tb/clk
add wave -expand -group ENV -color #FF3399                 /seg7_mux_tb/msg
add wave -expand -group ENV -color #FFFF00 -radix unsigned /seg7_mux_tb/seg_result

add wave -expand -group DUT -color #FF3399                 /seg7_mux_tb/DUT/msg_i
add wave -expand -group DUT -color #FFFF00 -radix unsigned /seg7_mux_tb/DUT/seg_o

configure wave -namecolwidth  200
configure wave -valuecolwidth 100

run -all