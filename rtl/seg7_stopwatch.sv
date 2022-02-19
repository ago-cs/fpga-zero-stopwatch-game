module seg7_stopwatch #(
    parameter CLK_TICKS_PER_SEC = 50_000_000
) (
    input   logic       clk_i,              // clock
    input   logic       res_i,              // reset

    input   logic       en_i,               // run stopwatch

    output  logic[7:0]  s0_o,               // segment * 10ms
    output  logic[7:0]  s1_o,               // segment * 100ms
    output  logic[7:0]  s2_o,               // segment * 1s
    output  logic[7:0]  s3_o,               // segment * 10s
    output  logic[7:0]  s4_o,               // segment * 1m
    output  logic[7:0]  s5_o,               // segment * 10m

    output  logic[6:0]  val_x10ms_o         // 100ms,10ms values[00..99]
);

localparam TIM_CLK_CNT_MAX  = (CLK_TICKS_PER_SEC / 100);
localparam TIM_CLK_CNT_W    = $clog2(TIM_CLK_CNT_MAX);

localparam SEG_LIMIT_10_VAL = 10;
localparam SEG_LIMIT_10_W   = $clog2(SEG_LIMIT_10_VAL);
localparam SEG_LIMIT_6_VAL  = 6;
localparam SEG_LIMIT_6_W    = $clog2(SEG_LIMIT_6_VAL);

logic[TIM_CLK_CNT_W - 1:0]  tim_clk_cnt;

logic[SEG_LIMIT_10_W - 1:0] tim_10ms_cnt;
logic                       tim_10ms_en;

logic[SEG_LIMIT_10_W - 1:0] tim_100ms_cnt;
logic                       tim_100ms_en;

logic[SEG_LIMIT_10_W - 1:0] tim_1s_cnt;
logic                       tim_1s_en;

logic[SEG_LIMIT_6_W - 1:0]  tim_10s_cnt;
logic                       tim_10s_en;

logic[SEG_LIMIT_10_W - 1:0] tim_1m_cnt;
logic                       tim_1m_en;

logic[SEG_LIMIT_6_W - 1:0]  tim_10m_cnt;
logic                       tim_10m_en;

timer_counter #(.TICKS_COUNT_TO_RESET(TIM_CLK_CNT_MAX)) clk_counter (
    .clk_i      (clk_i),
    .en_i       (en_i),
    .res_i      (res_i),
    .cnt_o      (tim_clk_cnt),
    .c_stb_o    (tim_10ms_en)
);

timer_counter #(.TICKS_COUNT_TO_RESET(SEG_LIMIT_10_VAL)) tim_10ms_counter (
    .clk_i      (clk_i),
    .en_i       (tim_10ms_en),
    .res_i      (res_i),
    .cnt_o      (tim_10ms_cnt),
    .c_stb_o    (tim_100ms_en)
);

timer_counter #(.TICKS_COUNT_TO_RESET(SEG_LIMIT_10_VAL)) tim_100ms_counter (
    .clk_i      (clk_i),
    .en_i       (tim_100ms_en),
    .res_i      (res_i),
    .cnt_o      (tim_100ms_cnt),
    .c_stb_o    (tim_1s_en)
);

timer_counter #(.TICKS_COUNT_TO_RESET(SEG_LIMIT_10_VAL)) tim_1s_counter (
    .clk_i      (clk_i),
    .en_i       (tim_1s_en),
    .res_i      (res_i),
    .cnt_o      (tim_1s_cnt),
    .c_stb_o    (tim_10s_en)
);

timer_counter #(.TICKS_COUNT_TO_RESET(SEG_LIMIT_6_VAL)) tim_10s_counter (
    .clk_i      (clk_i),
    .en_i       (tim_10s_en),
    .res_i      (res_i),
    .cnt_o      (tim_10s_cnt),
    .c_stb_o    (tim_1m_en)
);

timer_counter #(.TICKS_COUNT_TO_RESET(SEG_LIMIT_10_VAL)) tim_1m_counter (
    .clk_i      (clk_i),
    .en_i       (tim_1m_en),
    .res_i      (res_i),
    .cnt_o      (tim_1m_cnt),
    .c_stb_o    (tim_10m_en)
);

timer_counter #(.TICKS_COUNT_TO_RESET(SEG_LIMIT_6_VAL)) tim_10m_counter (
    .clk_i      (clk_i          ),
    .en_i       (tim_10m_en),
    .res_i      (res_i),
    .cnt_o      (tim_10m_cnt),
    .c_stb_o    ()
);

seg7 seg7_s0 (
    .val_i(tim_10ms_cnt),
    .pnt_i(1'b0),
    .hzero_i(1'b0),
    .seg_o(s0_o)
);

seg7 seg7_s1 (
    .val_i(tim_100ms_cnt),
    .pnt_i(1'b0),
    .hzero_i(1'b0),
    .seg_o(s1_o)
);

seg7 seg7_s2 (
    .val_i(tim_1s_cnt),
    .pnt_i(1'b1),
    .hzero_i((tim_10s_cnt == 0) && (tim_1m_cnt == 0) && (tim_10m_cnt == 0)),
    .seg_o(s2_o)
);

seg7 seg7_s3 (
    .val_i(tim_10s_cnt),
    .pnt_i(1'b0),
    .hzero_i((tim_1m_cnt == 0) && (tim_10m_cnt == 0)),
    .seg_o(s3_o)
);

seg7 seg7_s4 (
    .val_i(tim_1m_cnt),
    .pnt_i(1'b1),
    .hzero_i(tim_10m_cnt == 0),
    .seg_o(s4_o)
);

seg7 seg7_s5 (
    .val_i(tim_10m_cnt),
    .pnt_i(1'b0),
    .hzero_i(1'b1),
    .seg_o(s5_o)
);

always_comb begin
    val_x10ms_o = 7'(tim_100ms_cnt * 10 + tim_10ms_cnt);
end

endmodule: seg7_stopwatch
