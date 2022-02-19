`timescale  1ns/1ns

import datatype_package::*;

module fsm_game_tb;

localparam PAUSE_DURATINON_HW_TICKS = 5;

bit                 clk;
logic               res;

logic               btn_stb;                        // button strobe
logic               win;                            // is ready to win

logic               game_res;                       // in-game reset counter
logic               pause;                          // whether counter should go
msg_t               msg;                            // display message or counter

bit [4:0]           urnd_val;                       // random 32-bit value

logic               test_ok;                        // store cummulative test result

task automatic do_btn_strobe();
    $display("*\nBUTTON STROBE signal (time: %0t)", $time);
    btn_stb = 1;
    ##1 ;
    btn_stb = 0;
endtask: do_btn_strobe

task automatic assert_state (
    input shortint unsigned test_num_i,             // ## - test number
    input game_state_t      e_state_i,              // expected internal DUT.state value
    input game_state_t      a_state_i,              // actual internal DUT.state value
    input msg_t             e_msg_i,                // expected DUT.msg_o signal value
    input msg_t             a_msg_i,                // actual DUT.msg_o signal value
    input logic             e_pause_i,              // expected DUT.pause_o signal value
    input logic             a_pause_i,              // actual DUT.pause_o signal value
    input logic             e_reset_i,              // expected DUT.reset_o signal value
    input logic             a_reset_i,              // actual DUT.reset_o signal value
    ref   logic             test_ok_o               // cummulative test result
);

    $display(
        "\nTEST %0d: DUT.state = %0s, expected state = %0s (time: %0t)...",
        test_num_i,
        a_state_i,
        e_state_i,
        $time);

    assert(a_state_i == e_state_i)
    else begin
        test_ok_o &= 1'b0;
        $display("  error: DUT.state = %0s, expected value = %0s", a_state_i.name(), e_state_i.name());
    end

    assert(a_msg_i == e_msg_i)
    else begin
        test_ok_o &= 1'b0;
        $display("  error: DUT.msg_o = %0s, expected value = %0s", a_msg_i.name(), e_msg_i.name());
    end

    assert(a_pause_i == e_pause_i)
    else begin
        test_ok_o &= 1'b0;
        $display("  error: DUT.pause_o = %0b, expected value = %0b", a_pause_i, e_pause_i);
    end

    assert(a_reset_i == e_reset_i)
    else begin
        test_ok_o &= 1'b0;
        $display("  error: DUT.pause_o = %0b, expected value = %0b", a_reset_i, e_reset_i);
    end

    if (test_ok_o)
        $display("  OK (time: %0t)", $time);
    else
        $error("  Several actual values differs from their expected values (time: %0t)", $time);

endtask: assert_state

initial begin
    forever
        #5 clk = !clk;
end

default clocking cb @ (posedge clk);
endclocking

fsm_game #(.PAUSE_DURATINON_HW_TICKS(PAUSE_DURATINON_HW_TICKS)) DUT (
    .clk_i      (clk),
    .res_i      (res),
    .btn_stb_i  (btn_stb),
    .win_i      (win),
    .reset_o    (game_res),
    .pause_o    (pause),
    .msg_o      (msg)
);

initial begin
    clk     = 1'b0;

    win     = 1'b0;
    btn_stb = 1'b0;
    res     = 1'b1;
    ##1;
    res     = 1'b0;

    test_ok = 1'b1;

    // TEST 1:  IDLE_S state variables are valid
    assert_state(1,
        DUT.state,      IDLE_S,
        DUT.msg_o,      EMPTY_MSG,
        DUT.pause_o,    1'b1,
        DUT.reset_o,    1'b1,
        test_ok);

    // TEST 2:  Transition from IDLE_S to WELCOME_S state
    //          happen automatically on the next cycle after IDLE_S
    ##1;
    assert_state(2,
        DUT.state,      WELCOME_S,
        DUT.msg_o,      WELCOME_MSG,
        DUT.pause_o,    1'b1,
        DUT.reset_o,    1'b0,
        test_ok);

    // TEST 3:  Transition from WELCOME_S to READY_S state happen
    //          on the next cycle after button's positive strobe
    urnd_val = ($bits(urnd_val))'($urandom_range(4, 7));
    for(int i = 0; i < urnd_val; i++) begin
        ##1;
        // state still WELCOME_S until button click strobe
        assert_state(3,
            DUT.state,      WELCOME_S,
            DUT.msg_o,      WELCOME_MSG,
            DUT.pause_o,    1'b1,
            DUT.reset_o,    1'b0,
            test_ok);
    end
    do_btn_strobe();
    assert_state(3,
        DUT.state,      READY_S,
        DUT.msg_o,      READY_MSG,
        DUT.pause_o,    1'b1,
        DUT.reset_o,    1'b0,
        test_ok);

    // TEST 4:  Transition from READY_S to RUN_S state
    //          happen after PAUSE_DURATINON_HW_TICKS cycles
    //          (in for-loop we use PAUSE_DURATINON_HW_TICKS - 1
    //          as the 1st cycle is the latest of the previous test )
    for(int i = 0; i < PAUSE_DURATINON_HW_TICKS - 1; i++) begin
        ##1;
        assert_state(4,
            DUT.state,      READY_S,
            DUT.msg_o,      READY_MSG,
            DUT.pause_o,    1'b1,
            DUT.reset_o,    1'b0,
            test_ok);
    end
    ##1;
    assert_state(4,
        DUT.state,      RUN_S,
        DUT.msg_o,      STOPWATCH_MSG,
        DUT.pause_o,    1'b0,
        DUT.reset_o,    1'b0,
        test_ok);

    // TEST 5:  Transition from RUN_S to SHOOT_S state happen
    //          on the next cycle after button's positive strobe,
    //          Then transition from SHOOT_S to RUN_S state
    //          happen after PAUSE_DURATINON_HW_TICKS cycles
    //          as "win" signal == 0.
    urnd_val = ($bits(urnd_val))'($urandom_range(8, 15));
    for(int i = 0; i < urnd_val; i++) begin
        ##1;
        // state is still RUN_S until button click strobe
        assert_state(5,
            DUT.state,      RUN_S,
            DUT.msg_o,      STOPWATCH_MSG,
            DUT.pause_o,    1'b0,
            DUT.reset_o,    1'b0,
            test_ok);
    end
    do_btn_strobe();
    for(int i = 0; i < PAUSE_DURATINON_HW_TICKS; i++) begin
        assert_state(5,
            DUT.state,      SHOOT_S,
            DUT.msg_o,      STOPWATCH_MSG,
            DUT.pause_o,    1'b1,
            DUT.reset_o,    1'b0,
            test_ok);
        ##1;
    end
    // return to RUN_S state as counter was not 0
    assert_state(5,
        DUT.state,      RUN_S,
        DUT.msg_o,      STOPWATCH_MSG,
        DUT.pause_o,    1'b0,
        DUT.reset_o,    1'b0,
        test_ok);

    // TEST 6:  Transition from RUN_S to SHOOT_S state happen
    //          on the next cycle after button's positive strobe,
    //          Then transition from SHOOT_S to WIN_S state
    //          happen after PAUSE_DURATINON_HW_TICKS cycles
    //          as "win" signal == 1.
    urnd_val = ($bits(urnd_val))'($urandom_range(8, 15));
    for(int i = 0; i < urnd_val; i++) begin
        ##1;
        // state is still RUN_S until button click strobe
        assert_state(6,
            DUT.state,      RUN_S,
            DUT.msg_o,      STOPWATCH_MSG,
            DUT.pause_o,    1'b0,
            DUT.reset_o,    1'b0,
            test_ok);
    end
    win = 1'b1; // we are ready to win!
    do_btn_strobe();
    for(int i = 0; i < PAUSE_DURATINON_HW_TICKS; i++) begin
        assert_state(6,
            DUT.state,      SHOOT_S,
            DUT.msg_o,      STOPWATCH_MSG,
            DUT.pause_o,    1'b1,
            DUT.reset_o,    1'b0,
            test_ok);
        ##1;
    end
    assert_state(6,
        DUT.state,      WIN_S,
        DUT.msg_o,      WIN_MSG,
        DUT.pause_o,    1'b1,
        DUT.reset_o,    1'b0,
        test_ok);

    // TEST 7:  Transition from WIN_S to SCORE_S and back
    //          until button's positive strobe,
    //          then on the next cycle going to IDLE_S
    for(int j = 0; j < 3; j++) begin
        for(int i = 0; i < PAUSE_DURATINON_HW_TICKS; i++) begin
            assert_state(7,
                DUT.state,      WIN_S,
                DUT.msg_o,      WIN_MSG,
                DUT.pause_o,    1'b1,
                DUT.reset_o,    1'b0,
                test_ok);
            ##1;
        end
        for(int i = 0; i < PAUSE_DURATINON_HW_TICKS; i++) begin
            assert_state(7,
                DUT.state,      SCORE_S,
                DUT.msg_o,      STOPWATCH_MSG,
                DUT.pause_o,    1'b1,
                DUT.reset_o,    1'b0,
                test_ok);
            ##1;
        end
    end
    urnd_val = ($bits(urnd_val))'($urandom_range(1, PAUSE_DURATINON_HW_TICKS));
    for(int i = 0; i < urnd_val; i++) begin
        ##1;
    end
    do_btn_strobe();
    assert_state(7,
        DUT.state,      IDLE_S,
        DUT.msg_o,      EMPTY_MSG,
        DUT.pause_o,    1'b1,
        DUT.reset_o,    1'b1,
        test_ok);

    assert(test_ok)
        $display("\nALL TESTS PASSED");
    else
        $error("\nNOT ALL TESTS PASSED");

    ##7;
    $stop();
end

endmodule: fsm_game_tb
