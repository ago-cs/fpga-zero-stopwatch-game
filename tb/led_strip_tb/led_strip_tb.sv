`timescale  1ns/1ns

module led_strip_tb;

localparam LED_NUM  = 10;
localparam CNT_LIM  = 100;                          // 100 for counter 00..99
localparam CNT_W    = $clog2(CNT_LIM);

typedef struct {
    bit [CNT_W:0]   range_min_val;
    bit [CNT_W:0]   range_max_val;
} counter_range;

counter_range       valid_ranges[LED_NUM-1:0] = '{  // expected counter ranges for each led
    '{ 10, 19 },                                    //  #9
    '{ 20, 29 },                                    //  #8
    '{ 30, 39 },                                    //  #7
    '{ 40, 49 },                                    //  #6
    '{ 50, 59 },                                    //  #5
    '{ 60, 69 },                                    //  #4
    '{ 70, 79 },                                    //  #3
    '{ 80, 89 },                                    //  #2
    '{ 90, 99 },                                    //  #1
    '{  0,  9 }                                     //  #0
};

logic[CNT_W:0]      cnt;                            // counter value
logic[LED_NUM-1:0]  sw,                             // led enable (active high)
                    sw_t,                           // temporary storage for sw between tests
                    led;                            // led array lighting (active high)

logic               test_ok;                        // store cummulative test result

task automatic test_all_counter_values (
    input   counter_range               valid_ranges_i[LED_NUM-1:0],
    ref     logic[LED_NUM-1:0]          led_i,
    input   logic[LED_NUM-1:0]          sw_i,
    ref     logic[CNT_W:0]              cnt_o,
    output  logic                       test_ok_o
);

    test_ok_o = 1'b0;

    $display("\nTEST: LED ON for all CNT with SW = %0b (time: %0t)...", sw, $time);

    for(int i = LED_NUM - 1; i >= 0; i--) begin         // going from (LED_NUM - 1) down to 0
        for(int j = valid_ranges_i[i].range_min_val;
                j < valid_ranges_i[i].range_max_val + 1;
                j++) begin
            cnt_o = j;
            #4;
            assert(!(                                   // not
                    sw_i[i] ^                           //  corresponding switch differs
                    (led_i == (LED_NUM)'(1 << i))       //  from the and only valid led state
                )
            ) begin
                test_ok_o = 1'b1;
            end else begin
                test_ok_o = 1'b0;
                $display("Error: LED signal = %0b with CNT = %0d", led_i[i], cnt_o);
            end
            #1;
        end
    end

    if (test_ok_o)
        $display("  OK (time: %0t)", $time);
    else
        $error("  FAILED (time: %0t)", $time);

endtask: test_all_counter_values


led_strip #(
    .LED_NUM(LED_NUM),
    .CNT_LIM(CNT_LIM)
) DUT (
    .cnt_i          (cnt),
    .sw_i           (sw),
    .led_o          (led)
);

initial begin
    sw  = 'x;
    cnt = 'x;
    #5;

    $display("RULES:");
    for(int i = LED_NUM - 1; i >= 0; i--) begin     // going from (LED_NUM - 1) down to 0
        $display(
            "\tLED #%0d ON for CNT [%2d..%2d]",
            i,
            valid_ranges[i].range_min_val,
            valid_ranges[i].range_max_val);
    end
    #5;

    // all leds enabled
    sw = '1;
    test_all_counter_values(valid_ranges, led, sw, cnt, test_ok);

    sw  = 'x;
    cnt = 'x;
    #5;

    // move the only enabled led one by one starting from 0
    // 0000000001
    // 0000000010
    // ..
    // 1000000000
    for(int i = 0; i < LED_NUM; i++) begin
        sw = (CNT_W)'(1) << i;
        test_all_counter_values(valid_ranges, led, sw, cnt, test_ok);
        sw  = 'x;
        cnt = 'x;
        #5;
    end

    // add enabled leds one by one starting from 0
    // 0000000001
    // 0000000011
    // ..
    // 1111111111
    sw_t = '0;
    for(int i = 0; i < LED_NUM; i++) begin
        sw_t = sw_t + ((CNT_W)'(1) << i);
        sw = sw_t;
        test_all_counter_values(valid_ranges, led, sw, cnt, test_ok);
        sw  = 'x;
        cnt = 'x;
        #5;
    end

    assert(test_ok)
        $display("\nALL TESTS PASSED");
    else
        $error("\nNOT ALL TESTS PASSED");

    $stop();
end

endmodule: led_strip_tb
