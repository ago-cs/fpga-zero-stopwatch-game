`timescale  1ns/1ns

module timer_counter_tb;

localparam TIM1_TICKS_COUNT_TO_RESET = 3;   // values 0..1..2
localparam TIM2_TICKS_COUNT_TO_RESET = 4;
localparam TIM3_TICKS_COUNT_TO_RESET = 5;

localparam TIM1_CNT_W = $clog2(TIM1_TICKS_COUNT_TO_RESET);
localparam TIM2_CNT_W = $clog2(TIM2_TICKS_COUNT_TO_RESET);
localparam TIM3_CNT_W = $clog2(TIM3_TICKS_COUNT_TO_RESET);

bit                     clk;
logic                   res;

logic                   cnt1_en;
bit [TIM1_CNT_W - 1:0]  cnt1_cnt;       // TIM1 counter
logic                   cnt1_ovfl_stb;  // plays role of "cnt2_en"

bit [TIM2_CNT_W - 1:0]  cnt2_cnt;       // TIM2 counter
logic                   cnt2_ovfl_stb;  // plays role of "cnt3_en"

bit [TIM3_CNT_W - 1:0]  cnt3_cnt;       // TIM3 counter
logic                   cnt3_ovfl_stb;  // not used, but nice to see

initial begin
    forever
        #5 clk = !clk;
end

default clocking
    cb @ (posedge clk);
endclocking

timer_counter #(.TICKS_COUNT_TO_RESET(TIM1_TICKS_COUNT_TO_RESET)) DUT1 (
    .clk_i      (clk),
    .en_i       (cnt1_en),
    .res_i      (res),
    .cnt_o      (cnt1_cnt),
    .c_stb_o    (cnt1_ovfl_stb)
);

timer_counter #(.TICKS_COUNT_TO_RESET(TIM2_TICKS_COUNT_TO_RESET)) DUT2 (
    .clk_i      (clk),
    .en_i       (cnt1_ovfl_stb),
    .res_i      (res),
    .cnt_o      (cnt2_cnt),
    .c_stb_o    (cnt2_ovfl_stb)
);

timer_counter #(.TICKS_COUNT_TO_RESET(TIM3_TICKS_COUNT_TO_RESET)) DUT3 (
    .clk_i      (clk),
    .en_i       (cnt2_ovfl_stb),
    .res_i      (res),
    .cnt_o      (cnt3_cnt),
    .c_stb_o    (cnt3_ovfl_stb)
);

initial begin
    clk = 0;
    res = 1;

    cnt1_en = 1;
    ##1;
    res = 0;

    ##90;
    $stop();
end

endmodule: timer_counter_tb
