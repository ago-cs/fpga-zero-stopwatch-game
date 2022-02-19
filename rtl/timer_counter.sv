module timer_counter #(
    parameter TICKS_COUNT_TO_RESET = 10
)(
    input   logic                                   clk_i,
    input   logic                                   en_i,
    input   logic                                   res_i,
    output  logic[($clog2(TICKS_COUNT_TO_RESET)):0] cnt_o,
    output  logic                                   c_stb_o
);

logic[($clog2(TICKS_COUNT_TO_RESET)):0] delay;

localparam CNT_W   = $clog2(TICKS_COUNT_TO_RESET);
localparam CNT_MAX = TICKS_COUNT_TO_RESET - 1;

always_ff @(posedge clk_i) begin
    if (res_i) begin
        cnt_o <= '0;
    end else begin
        delay <= cnt_o;
        if(en_i) begin
            if (cnt_o == CNT_MAX) begin
                cnt_o <= '0;
            end else begin
                cnt_o <= (CNT_W)'(cnt_o + 1);
            end
        end
    end
end

always_comb begin
    c_stb_o = en_i && (delay == CNT_MAX);
end

endmodule: timer_counter
