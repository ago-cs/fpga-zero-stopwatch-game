import datatype_package::*;

module zero_stopwatch_top (
    input MAX10_CLK1_50,
    input  [1:0] KEY,
    input  [9:0] SW,
    output [7:0] HEX0,
    output [7:0] HEX1,
    output [7:0] HEX2,
    output [7:0] HEX3,
    output [7:0] HEX4,
    output [7:0] HEX5,
    output [9:0] LEDR
);

logic       clk;

logic       key_0_inv;              // button "reset"
logic       key_1_inv;              // button "game"/"shoot"

logic[7:0]  s0;                     // variable for control seg0
logic[7:0]  s1;
logic[7:0]  s2;
logic[7:0]  s3;
logic[7:0]  s4;
logic[7:0]  s5;

logic[9:0]  led             = '0;   // for mapping to mapping to LEDR
logic[9:0]  sw              = '0;   // for mapping to mapping to SW

logic       s_res           = 0;    // synchronized signal of "reset" button
logic       s_game_shoot    = 0;    // synchronized signal of "game"/"shoot"

logic       res_stb         = 0;    // strobe on reset "reset" button signal
logic       game_shoot_stb  = 0;    // strobe on reset "game"/"shoot" button signal

logic[6:0]  frac_sec_val    = '0;   // fractional part of second 00..99

msg_t       msg;                    // type of info to display (out of fsm_game)
logic       pause_stopwatch = 0;    // run/stop stopwatch counter (out of fsm_game)
logic       in_game_reset   = 0;    // reset came from fsm_game;

// debouncer + synchronizer for buttons
debouncer #(.DB_CNT_HW_TICKS(1000)) res_synchronizer (
    .clk_i          (clk),
    .s_rst_i        (1'b0),
    .pin_i          (key_0_inv),
    .pin_state_o    (s_res)
);

debouncer #(.DB_CNT_HW_TICKS(1000)) game_shoot_synchronizer (
    .clk_i          (clk),
    .s_rst_i        (1'b0),
    .pin_i          (key_1_inv),
    .pin_state_o    (s_game_shoot)
);

// strobe builder on posedge for buttons
posedge_detector res_strobe_builder(
    .clk_i          (clk),
    .d_i            (s_res),
    .posedge_stb_o  (res_stb)
);

posedge_detector game_shoot_strobe_builder(
    .clk_i          (clk),
    .d_i            (s_game_shoot),
    .posedge_stb_o  (game_shoot_stb)
);

// 8-segment mux
seg7_mux seg_mux (
    .msg_i          (msg),
    .seg_empty_i    ('{
                        { 1'b1, SEG_OFF },
                        { 1'b1, SEG_OFF },
                        { 1'b1, SEG_OFF },
                        { 1'b1, SEG_OFF },
                        { 1'b1, SEG_OFF },
                        { 1'b1, SEG_OFF }
                    }),
    .seg_welcome_i  ('{
                        { 1'b1, SEG_OFF },
                        { 1'b1, SEG_T },
                        { 1'b1, SEG_R },
                        { 1'b1, SEG_A },
                        { 1'b1, SEG_T },
                        { 1'b1, SEG_5 }
                    }),
    .seg_ready_i    ('{
                        { 1'b1, SEG_OFF },
                        { 1'b1, SEG_0 },
                        { 1'b1, SEG_G },
                        { 1'b1, SEG_DASH },
                        { 1'b1, SEG_0 },
                        { 1'b1, SEG_G }
                    }),
    .seg_win_i      ('{
                        { 1'b1, SEG_OFF },
                        { 1'b1, SEG_R },
                        { 1'b1, SEG_E },
                        { 1'b1, SEG_P },
                        { 1'b1, SEG_U },
                        { 1'b1, SEG_5 }
                    }),
    .seg_stopwatch_i('
                        { s0, s1, s2, s3, s4, s5 }
                    ),
    .seg_o          ('
                        { HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 }
                    )
);

// 8-segment stopwatch
seg7_stopwatch #(.CLK_TICKS_PER_SEC(50_000_000)) stopwatch (
    .clk_i          (clk),
    .res_i          (s_res || in_game_reset),
    .en_i           (!pause_stopwatch),
    .s0_o           (s0),
    .s1_o           (s1),
    .s2_o           (s2),
    .s3_o           (s3),
    .s4_o           (s4),
    .s5_o           (s5),
    .val_x10ms_o    (frac_sec_val)
);

// game logic (fsm)
fsm_game #(.PAUSE_DURATINON_HW_TICKS(50_000_000)) game (
    .clk_i          (clk),
    .res_i          (res_stb),
    .btn_stb_i      (game_shoot_stb),
    .win_i          (frac_sec_val == '0),
    .reset_o        (in_game_reset),
    .pause_o        (pause_stopwatch),
    .msg_o          (msg)
);

led_strip #(
    .LED_NUM        (10),
    .CNT_LIM        (100)
) helping_led_strip (
    .cnt_i          (frac_sec_val),
    .sw_i           (sw),
    .led_o          (led)
);

// connection to peripheral pins
always_comb begin
    clk =           MAX10_CLK1_50;
    key_0_inv =     !KEY[0];
    key_1_inv =     !KEY[1];
    sw =            SW;
    LEDR =          led;
end

endmodule: zero_stopwatch_top
