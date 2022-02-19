module debouncer #(
    parameter           DB_CNT_HW_TICKS = 1048576   // number of ticks while the input signal
                                                    // have to have a constant value,
                                                    // signal assumed as stable
                                                    // when it has constant value durin
                                                    // DB_CNT_HW_TICKS clock cycles
) (
    input   logic       clk_i,
    input   logic       s_rst_i,

    input   logic       pin_i,                      // asynchronous signal to be synchronized
    output  logic       pin_state_o                 // synchronized output signal
);

localparam  DB_CNT_W    = $clog2(DB_CNT_HW_TICKS);
localparam  DB_CNT_MAX  = DB_CNT_HW_TICKS - 1;

logic [2:0]  pin_d;                                 // pin_i delayed signals

always_ff @(posedge clk_i) begin
    pin_d[0] <= pin_i;
    pin_d[1] <= pin_d[0];
    pin_d[2] <= pin_d[1];
end

logic [DB_CNT_W-1:0]    db_counter;
logic                   pin_differ;

logic                   db_counter_max;

assign db_counter_max = (db_counter == DB_CNT_MAX);

assign pin_differ = pin_d[2] ^ pin_d[1];            // pin_differ is
                                                    //  0 : pin has constant value during 2 clock cycles
                                                    //  1 : pin changed on the next clock cycle

always_ff @(posedge clk_i) begin
    if (s_rst_i) begin
        db_counter <= '0;
    end else begin
        if (db_counter_max || pin_differ) begin
            db_counter <= '0;
        end else begin
            db_counter <= db_counter + (DB_CNT_W)'(1);
        end
    end
end

always_ff @(posedge clk_i) begin
    if (s_rst_i) begin
        pin_state_o <= 1'b0;
    end else begin
        if (db_counter_max) begin
            pin_state_o <= pin_d[2];
        end
    end
end

endmodule: debouncer
