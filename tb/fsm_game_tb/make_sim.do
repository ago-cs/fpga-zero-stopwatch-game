vlib work
vlog -sv ./../../rtl/datatype_package.sv
vlog -sv ./../../rtl/fsm_game.sv
vlog -sv fsm_game_tb.sv

vsim -novopt fsm_game_tb
add log -r /*
#add wave -r *

add wave -expand -group ENV                                 /fsm_game_tb/cb/cb_event
add wave -expand -group ENV -color #00FFFF                  /fsm_game_tb/clk
add wave -expand -group ENV -color #FF2020                  /fsm_game_tb/res
add wave -expand -group ENV -color #00CC00                  /fsm_game_tb/btn_stb
add wave -expand -group ENV -color #7CFC00                  /fsm_game_tb/win
add wave -expand -group ENV -color #FF7070                  /fsm_game_tb/game_res

add wave -expand -group DUT -color #1E90FF -radix unsigned  /fsm_game_tb/DUT/pause_cnt
add wave -expand -group DUT -color #1D627C                  /fsm_game_tb/DUT/pause_done
add wave -expand -group DUT -color #FFFF00                  /fsm_game_tb/DUT/state

configure wave -namecolwidth 225
configure wave -valuecolwidth 80

run -all
