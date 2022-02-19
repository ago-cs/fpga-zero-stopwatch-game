`timescale  1ns/1ns

import datatype_package::*;

module seg7_mux_tb;

bit         clk;
msg_t       msg;                    // message type

logic[7:0]  seg_empty       [6];    // 8seg message "empty"
logic[7:0]  seg_welcome     [6];    // 8seg message "welcome"
logic[7:0]  seg_ready       [6];    // 8seg message "ready"
logic[7:0]  seg_win         [6];    // 8seg segment "win"
logic[7:0]  seg_stopwatch   [6];    // 8seg segment "stopwatch"

logic[7:0]  seg_result      [6];    // result segments

logic       test_ok;

seg7_mux DUT (
    .msg_i              (msg),

    .seg_empty_i        (seg_empty),
    .seg_welcome_i      (seg_welcome),
    .seg_ready_i        (seg_ready),
    .seg_win_i          (seg_win),
    .seg_stopwatch_i    (seg_stopwatch),

    .seg_o              (seg_result)
);

task automatic assert_msg_seg (
    input msg_t         e_msg_i,    // expected DUT message
    input logic[7:0]    e_seg_i[6], // expected DUT output segment values
    input msg_t         a_msg_i,    // actual DUT message
    input logic[7:0]    a_seg_i[6], // expected DUT output segment values
    ref   logic         test_ok_o   // cummulative test result
);

    $display("\nTEST: %0s (time: %0t)...", e_msg_i, $time);

    assert(a_msg_i    == e_msg_i
        && a_seg_i[0] == e_seg_i[0]
        && a_seg_i[1] == e_seg_i[1]
        && a_seg_i[2] == e_seg_i[2]
        && a_seg_i[3] == e_seg_i[3]
        && a_seg_i[4] == e_seg_i[4]
        && a_seg_i[5] == e_seg_i[5]
    )
    begin
        $display("  OK:");
    end else begin
        test_ok_o &= 1'b0;
        $display("ERROR:");
    end

    $display(
        "\tExpected: DUT.msg_i = %13s, DUT.seg_o = { %2d, %2d, %2d, %2d, %2d, %2d }",
        e_msg_i.name(), e_seg_i[0], e_seg_i[1], e_seg_i[2], e_seg_i[3], e_seg_i[4], e_seg_i[5]
    );
    $display(
        "\tActual  : DUT.msg_i = %13s, DUT.seg_o = { %2d, %2d, %2d, %2d, %2d, %2d }",
        a_msg_i.name(), a_seg_i[0], a_seg_i[1], a_seg_i[2], a_seg_i[3], a_seg_i[4], a_seg_i[5]
    );

endtask: assert_msg_seg

initial begin
    forever
        #5 clk = !clk;
end

default clocking cb @ (posedge clk);
endclocking

always_comb begin
    seg_empty = {
        (8)'(0), (8)'(1), (8)'(2), (8)'(3), (8)'(4), (8)'(5)
    };

    seg_welcome = {
        (8)'(6), (8)'(7), (8)'(8), (8)'(9), (8)'(10), (8)'(11)
    };

    seg_ready = {
        (8)'(12), (8)'(13), (8)'(14), (8)'(15), (8)'(16), (8)'(17)
    };

    seg_win = {
        (8)'(18), (8)'(19), (8)'(20), (8)'(21), (8)'(22), (8)'(23)
    };

    seg_stopwatch = {
        (8)'(24), (8)'(25), (8)'(26), (8)'(27), (8)'(28), (8)'(29)
    };
end

initial begin
    test_ok <= 1'b1;
    clk     <= 1'b0;
    ##5;

    // TEST1: EMPTY_MSG
    msg = EMPTY_MSG;
    #1;
    assert_msg_seg (msg, seg_empty, DUT.msg_i, DUT.seg_o, test_ok);
    ##10;

    // TEST2: WELCOME_MSG
    msg = WELCOME_MSG;
    #1;
    assert_msg_seg (msg, seg_welcome, DUT.msg_i, DUT.seg_o, test_ok);
    ##10;

    // TEST3: READY_MSG
    msg = READY_MSG;
    #1;
    assert_msg_seg (msg, seg_ready, DUT.msg_i, DUT.seg_o, test_ok);
    ##10;

    // TEST4: WIN_MSG
    msg = WIN_MSG;
    #1;
    assert_msg_seg (msg, seg_win, DUT.msg_i, DUT.seg_o, test_ok);
    ##10;

    // TEST5: STOPWATCH_MSG
    msg = STOPWATCH_MSG;
    #1;
    assert_msg_seg (msg, seg_stopwatch, DUT.msg_i, DUT.seg_o, test_ok);
    ##10;

    // Overall Report
    assert(test_ok)
        $display("\nALL TESTS PASSED!");
    else
        $error("\nNOT ALL TESTS PASSED!\n(see errors above)");

    $stop();
end

endmodule: seg7_mux_tb
