import datatype_package::*;

module fsm_game #(
    parameter PAUSE_DURATINON_HW_TICKS = 5000
) (
    input   logic       clk_i,          // clock
    input   logic       res_i,          // reset

    input   logic       btn_stb_i,      // button strobe
    input   logic       win_i,          // is ready to win

    output  logic       reset_o,        // for reset counter at start
    output  logic       pause_o,        // whether counter should go
    output  msg_t       msg_o           // display message or counter
);

localparam PAUSE_CNT_W  = $clog2(PAUSE_DURATINON_HW_TICKS);

logic [PAUSE_CNT_W-1:0] pause_cnt;      // puase counter
logic                   pause_done;     // signal that pause finished

// Main game FSM
game_state_t            state,          // FSM state
                        next_state;     // next FSM state

always_ff @(posedge clk_i) begin
    if (res_i) begin
        state <= IDLE_S;
    end else begin
        state <= next_state;
    end
end

always_comb begin
    next_state = state;
    case (state)
        IDLE_S:
            begin
                next_state = WELCOME_S;
            end
        WELCOME_S:
            begin
                if (btn_stb_i) begin
                    next_state = READY_S;
                end
            end
        READY_S:
            begin
                if (pause_done) begin
                    next_state = RUN_S;
                end
            end
        RUN_S:
            begin
                if (btn_stb_i) begin
                    next_state = SHOOT_S;
                end
            end
        SHOOT_S:
            begin
                if (pause_done || btn_stb_i) begin
                    if (win_i) begin
                        next_state = WIN_S;
                    end else begin
                        next_state = RUN_S;
                    end
                end
            end
        WIN_S:
            begin
                if (btn_stb_i) begin
                    next_state = IDLE_S;
                end else if (pause_done) begin
                    next_state = SCORE_S;
                end
            end
        SCORE_S:
            begin
                if (btn_stb_i) begin
                    next_state = IDLE_S;
                end else if (pause_done) begin
                    next_state = WIN_S;
                end
            end
        default:
            begin
                next_state = IDLE_S;
            end
    endcase
end

// Pause counter
always_ff @(posedge clk_i)
    if ((state == READY_S) || (state == SHOOT_S) || (state == WIN_S) || (state == SCORE_S))
        pause_cnt <= pause_done
            ? pause_cnt <= '0
            : pause_cnt + (PAUSE_CNT_W)'(1);
    else
        pause_cnt <= '0;

always_comb begin
    pause_done = (pause_cnt == (PAUSE_DURATINON_HW_TICKS - 1));
end

// Output signals logic
always_comb begin
    pause_o = 1'b1;
    msg_o   = EMPTY_MSG;
    reset_o = 1'b0;

    case (state)
        IDLE_S:
            begin
                pause_o = 1'b1;
                msg_o   = EMPTY_MSG;
                reset_o = 1'b1;
            end
        WELCOME_S:
            begin
                pause_o = 1'b1;
                msg_o = datatype_package::WELCOME_MSG;
                reset_o = 1'b0;
            end
        READY_S:
            begin
                pause_o = 1'b1;
                msg_o = READY_MSG;
                reset_o = 1'b0;
            end
        RUN_S:
            begin
                pause_o = 1'b0;
                msg_o = STOPWATCH_MSG;
                reset_o = 1'b0;
            end
        SHOOT_S:
            begin
                pause_o = 1'b1;
                msg_o = STOPWATCH_MSG;
                reset_o = 1'b0;
            end
        WIN_S:
            begin
                pause_o = 1'b1;
                msg_o = WIN_MSG;
                reset_o = 1'b0;
            end
        SCORE_S:
            begin
                pause_o = 1'b1;
                msg_o = STOPWATCH_MSG;
                reset_o = 1'b0;
            end
        default:
            begin
                pause_o = 1'b1;
                msg_o   = EMPTY_MSG;
                reset_o = 1'b0;
            end
    endcase
end

endmodule: fsm_game
