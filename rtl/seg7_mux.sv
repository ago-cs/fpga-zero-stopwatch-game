import datatype_package::*;

module seg7_mux
(
    input   msg_t       msg_i,                  // message type

    input   logic[7:0]  seg_empty_i     [6],    // 8seg message "empty"
    input   logic[7:0]  seg_welcome_i   [6],    // 8seg message "welcome"
    input   logic[7:0]  seg_ready_i     [6],    // 8seg message "ready"
    input   logic[7:0]  seg_win_i       [6],    // 8seg segment "win"
    input   logic[7:0]  seg_stopwatch_i [6],    // 8seg segment "stopwatch"

    output  logic[7:0]  seg_o           [6]     // output segments
);

always_comb begin
    case (msg_i)
        EMPTY_MSG:
            begin
                seg_o = seg_empty_i;
            end
        WELCOME_MSG:
            begin
                seg_o = seg_welcome_i;
            end
        READY_MSG:
            begin
                seg_o = seg_ready_i;
            end
        WIN_MSG:
            begin
                seg_o = seg_win_i;
            end
        STOPWATCH_MSG:
            begin
                seg_o = seg_stopwatch_i;
            end
        default:
            begin
                seg_o = seg_empty_i;
            end
    endcase
end

endmodule: seg7_mux
