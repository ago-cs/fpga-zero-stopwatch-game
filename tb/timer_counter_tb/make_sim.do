vlib work
vlog -sv ./../../rtl/timer_counter.sv
vlog -sv timer_counter_tb.sv

vsim -novopt timer_counter_tb
add log -r /*
#add wave -r *

add wave -expand -group TIM_CNT_1 -color #00FFFF                  /timer_counter_tb/DUT1/clk_i
add wave -expand -group TIM_CNT_1 -color #FF1010                  /timer_counter_tb/DUT1/res_i
add wave -expand -group TIM_CNT_1 -color #7CFC00                  /timer_counter_tb/DUT1/en_i
add wave -expand -group TIM_CNT_1 -color #1E90FF -radix unsigned  /timer_counter_tb/DUT1/cnt_o
add wave -expand -group TIM_CNT_1 -color #1D627C -radix unsigned  /timer_counter_tb/DUT1/delay
add wave -expand -group TIM_CNT_1 -color #FFFF00                  /timer_counter_tb/DUT1/c_stb_o

add wave -expand -group TIM_CNT_2 -color #00FFFF                  /timer_counter_tb/DUT2/clk_i
add wave -expand -group TIM_CNT_2 -color #FF1010                  /timer_counter_tb/DUT2/res_i
add wave -expand -group TIM_CNT_2 -color #7CFC00                  /timer_counter_tb/DUT2/en_i
add wave -expand -group TIM_CNT_2 -color #1E90FF -radix unsigned  /timer_counter_tb/DUT2/cnt_o
add wave -expand -group TIM_CNT_2 -color #1D627C -radix unsigned  /timer_counter_tb/DUT2/delay
add wave -expand -group TIM_CNT_2 -color #FFFF00                  /timer_counter_tb/DUT2/c_stb_o

add wave -expand -group TIM_CNT_3 -color #00FFFF                  /timer_counter_tb/DUT3/clk_i
add wave -expand -group TIM_CNT_3 -color #FF1010                  /timer_counter_tb/DUT3/res_i
add wave -expand -group TIM_CNT_3 -color #7CFC00                  /timer_counter_tb/DUT3/en_i
add wave -expand -group TIM_CNT_3 -color #1E90FF -radix unsigned  /timer_counter_tb/DUT3/cnt_o
add wave -expand -group TIM_CNT_3 -color #1D627C -radix unsigned  /timer_counter_tb/DUT3/delay
add wave -expand -group TIM_CNT_3 -color #FFFF00                  /timer_counter_tb/DUT3/c_stb_o

configure wave -namecolwidth 225
configure wave -valuecolwidth 40

run -all