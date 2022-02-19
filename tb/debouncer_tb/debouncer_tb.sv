`timescale  1ns/1ns

module debouncer_tb;

parameter TASKS_CNT         = 1000;             // total # of all clear and noisy signals in test
parameter DB_CNT_HW_TICKS   =  100;             // debouncer setting:
                                                //   minimal stable input signal length (in clock cycles)
                                                //   to get debounced output signal
parameter PULSE_LENGTH      =  200;             // # of stable clock cycles in generated signals

parameter CLEAR_TASK_CNT    = TASKS_CNT / 2;
parameter NOISE_TASK_CNT    = TASKS_CNT - CLEAR_TASK_CNT;

bit     clk;
bit     rst;
bit     rst_done;

logic   pin;            // input test pin signal
logic   pin_state;      // oupur test pin signal

bit     test_is_ok;     // summary test results

// describes the task for generation the signal of the following shape (_:low, -:high):
// _--_-___--_-__-----------------------_-___-_--_-_--________________
// ^ before      ^ stable               ^ after       ^ pause
typedef struct {
    int before_stable_duration;     // # of clock cycles before stable signal
    int stable_duration;            // # of clock cycles with stable HIGH signal
    int after_stable_duration;      // # of clock cycles after stable signal
    int pause_duration;             // # of clock cycles with stable LOW signal
} task_t;

// describes the statistics related to the recieved signal
typedef struct {
    int cnt;                        // # of catched debounced signals
    int max_duration;               // # of clock cycles of the longest signal duration in set
    int min_duration;               // # of clock cycles of the shortest signal duration in set
    int total_duration;             // # total amoung of cycles in HIGH debounced state
} pulse_stat_t;

// generates tasks with randomly filled parameters and put it in mailbox
task generate_tasks (
    mailbox #(task_t)   gt,                 // mailbox to store the tasks in
    int                 task_cnt,           // # of tasks to generate
    int                 stable_duration,    // duration of the stable HIGH signal shape
    bit                 clear_signal = 0    // 1: for stable signal, 0: for signal with the noise
);
    for (int i = 0; i < task_cnt; i++) begin
        task_t new_task;

        if (clear_signal) begin
            new_task.before_stable_duration = 0;
            new_task.after_stable_duration  = 0;
        end else begin
            // noise duration X generates randomly to be > 0 and < 1/4 of stable_duration
            new_task.before_stable_duration = $urandom_range(stable_duration / 4, 1);
            new_task.after_stable_duration  = $urandom_range(stable_duration / 4, 1);
        end

        new_task.stable_duration = stable_duration;
        new_task.pause_duration  = stable_duration;

        gt.put(new_task);
    end
endtask: generate_tasks

// receives debounced pin_state signal and fills the stats
task recieve_tasks(
    input  int          timeout,                // # of ticks we should not exceed in stable LOW or HIGH
    output pulse_stat_t signal_stat
);
    automatic int tick_counter  = 0;            // total ticks counter before we exceeded timeout
    automatic int duration      = 0;            // duration (ticks) of the particular state

    signal_stat.cnt             = 0;
    signal_stat.total_duration  = 0;
    signal_stat.max_duration    = 0;
    signal_stat.min_duration    = 2 ** 31 - 1;

    while (tick_counter < timeout) begin        // global loop until we exceeded timeout
        while (pin_state == 1'b0) begin         // #1st internal loop
            tick_counter += 1;                  //   while the signal has stable LOW value
            ##1;
            if (tick_counter > timeout)         //   exit if we reached timeout before we get HIGH
                return;
        end

        duration = 0;                           // reset previous duration of stable HIGH signal

        while (pin_state) begin                 // #2nd internal loop
                                                //   catch HIGH signal value and while it is still HIGH
            duration += 1;                      //   increasing duration in clock ticks of HIGH state
            tick_counter += 1;                  //   increasing overall test duration
            ##1;
            if (tick_counter > timeout)         //   exit if we reached timeout before we get LOW
                return;
        end

        signal_stat.cnt += 1;                       // increasing the # of catched debounced signals
        signal_stat.total_duration += duration;     // increasing the total duration of catched debounced signals

        if (duration > signal_stat.max_duration)    // increasing stats.max_duration if needed set
            signal_stat.max_duration = duration;

        if (duration < signal_stat.min_duration)    // decreasing stats.min_duration if needed set
            signal_stat.min_duration = duration;
    end

endtask: recieve_tasks

// generates value for signal pin mapped to debouncer.pin_i
task send_tasks(
    input mailbox #(task_t) st
);
    while (st.num != 0) begin
        task_t send_task;

        // get send_task object from the mailbox
        st.get(send_task);

        // generate random values (1/0) for pin signal
        // during "before_stable_duration" clock cycles
        for (int i = 0; i < send_task.before_stable_duration; i++) begin
            ##1;
            pin <= $urandom_range(1,0);
        end

        // generate strong HIGH level during "stable_duration" clock cycles
        for (int i = 0; i < send_task.stable_duration; i++) begin
            ##1;
            pin <= 1'b1;
        end

        // generate random values (1/0) for pin signal
        // during "after_stable_duration" clock cycles
        for (int i = 0; i < send_task.after_stable_duration; i++) begin
            ##1;
            pin <= $urandom_range(1,0);
        end

        // generate strong LOW level during "pause_duration" clock cycles
        for (int i = 0; i < send_task.pause_duration; i++) begin
            ##1;
            pin <= 1'b0;
        end
    end
endtask: send_tasks

task automatic test_report(
    input  int          sent_signal_count,      // # of signals were sent
    input  pulse_stat_t signal_stat,            // stats struct
    ref bit             is_test_ok              // test result
);
   assert(signal_stat.cnt == CLEAR_TASK_CNT) begin
        $display("    OK:");
    end else begin
        $display("    ERROR: : Not all sent pulses were recieved:");
        test_is_ok &= 0;
    end

    $display("\t Send pulses:            %0d", sent_signal_count);
    $display("\t Recieved pulses:        %0d", signal_stat.cnt);
    $display("\t Max pulse duration:     %0d", signal_stat.max_duration);
    $display("\t Min pulse duration:     %0d", signal_stat.min_duration);
    $display("\t Average pulse duration: %0f", signal_stat.total_duration / signal_stat.cnt);

endtask: test_report

initial
    forever
        #5 clk = !clk;

default clocking cb
    @ (posedge clk);
endclocking

initial begin
    test_is_ok  <= 1'b1;
    rst         <= 1'b0;
    ##1;
    rst         <= 1'b1;
    ##1;
    rst         <= 1'b0;
    rst_done = 1'b1;
end

debouncer #(
    .DB_CNT_HW_TICKS    (DB_CNT_HW_TICKS)
) DUT (
    .clk_i              (clk),
    .s_rst_i            (rst),

    .pin_i              (pin),
    .pin_state_o        (pin_state)
);

mailbox #(task_t)       gen_tasks           = new();
pulse_stat_t            clear_signal_stat;
pulse_stat_t            noise_signal_stat;

initial begin
    wait (rst_done);
    $display("Stating tests. Config:");
    $display("\t PULSE_LENGTH (stable time for each input pulse) = %0d", PULSE_LENGTH);
    $display("\t TASKS_CNT (count of task to send)               = %0d", TASKS_CNT);

    $display("\nStarting with sending %0d clear signals with no noise",CLEAR_TASK_CNT);

    generate_tasks(
        gen_tasks,                                  // mailbox
        CLEAR_TASK_CNT,                             // # of signals
        PULSE_LENGTH,                               // duration of stable signal part
        1);                                         // no noise

    fork
        send_tasks(gen_tasks);
        recieve_tasks(
            PULSE_LENGTH * CLEAR_TASK_CNT * 2,      // timeout =
                                                    //   # of clear signals *
                                                    //     (stable signal length for HIGH +
                                                    //       same signal length for LOW then)
            clear_signal_stat);
    join

    test_report(CLEAR_TASK_CNT, clear_signal_stat, test_is_ok);

    $display("\nStarting test #2: sending %0d signals with noise", NOISE_TASK_CNT);

    generate_tasks(
        gen_tasks,                                  // mailbox
        NOISE_TASK_CNT,                             // # of signals
        PULSE_LENGTH,                               // duration of stable signal part
        0);                                         // add some noise on both sides

    fork
        send_tasks(gen_tasks);
        recieve_tasks(
            PULSE_LENGTH * NOISE_TASK_CNT * 4,      // timeout = (should ratio > 2.5)
                                                    //   # of noisy signals *
                                                    //     (stable signal length for HIGH +
                                                    //       same signal length for LOW then +
                                                    //       2 * 1/4 noisy signal lenght)
            noise_signal_stat);
    join

    test_report(NOISE_TASK_CNT, noise_signal_stat, test_is_ok);

    assert(test_is_ok) begin
        $display("\nALL TESTS PASSED");
    end else begin
        $error("NOT ALL TESTS PASSED");
    end

    ##10;

    $stop();
end

endmodule
