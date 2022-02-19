module led_strip #(
    parameter LED_NUM   = 10,
    parameter CNT_LIM   = 100                       // 100 for counter 00..99
) (
    input   logic[$clog2(CNT_LIM):0]    cnt_i,      // counter value
    input   logic[LED_NUM-1:0]          sw_i,       // led array enable (0 for always off)
    output  logic[LED_NUM-1:0]          led_o       // led array lighting
);

localparam CNT_DELTA        = CNT_LIM / LED_NUM;    // number of counter ticks
                                                    // for a single led
                                                    // i.e, time for a single led

// This implements the following combination
// between led_o and cnt_i
//         0         00..09
//         1         90..99
//         2         80..89
//         3         70..79
//         4         60..69
//         5         50..59
//         6         40..49
//         7         30..39
//         8         20..29
//         9         10..19
always_comb begin
    led_o = '0;

    led_o[0] =
        sw_i[0]
            && (cnt_i >= 0)
            && (cnt_i < CNT_DELTA);

    for(int i = 1; i < LED_NUM; i++) begin
        led_o[LED_NUM - i] =
            sw_i[LED_NUM - i]
                && (cnt_i >= (i *  CNT_DELTA))
                && (cnt_i < ((i + 1) * CNT_DELTA));
    end
end

endmodule: led_strip
