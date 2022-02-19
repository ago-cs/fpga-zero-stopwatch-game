vlib work
vlog -sv ./../../rtl/posedge_detector.sv
vlog -sv posedge_detector_tb.sv

vsim -novopt posedge_detector_tb
add log -r /*
#add wave -r *

add wave -expand -group ENV                 /posedge_detector_tb/cb/cb_event

add wave -expand -group ENV -color #00FFFF  /posedge_detector_tb/clk
add wave -expand -group ENV -color #FF0000  /posedge_detector_tb/data_in
add wave -expand -group ENV -color #7CFC00  /posedge_detector_tb/data_out

add wave -expand -group DUT -color #00FFFF  /posedge_detector_tb/DUT/clk_i
add wave -expand -group DUT -color #FF0000  /posedge_detector_tb/DUT/d_i
add wave -expand -group DUT -color #FFFF00  /posedge_detector_tb/DUT/d_delay

add wave -expand -group DUT -divider Output

add wave -expand -group DUT -color #7CFC00  /posedge_detector_tb/DUT/posedge_stb_o

configure wave -namecolwidth 300
configure wave -valuecolwidth 40

run -all

WaveRestoreCursors {{Cursor 1} {15 ns} 0}
WaveRestoreZoom    {0 ns} {58 ns}