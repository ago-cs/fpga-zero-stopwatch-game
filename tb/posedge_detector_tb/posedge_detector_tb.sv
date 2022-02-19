`timescale  1ns/1ns

module posedge_detector_tb;

bit     clk;
logic   data_in;
logic   data_out;

initial begin
    forever
        #5 clk = !clk;
end

default clocking cb @ (posedge clk);
endclocking

posedge_detector DUT (
    .clk_i         ( clk      ),
    .d_i           ( data_in  ),
    .posedge_stb_o ( data_out )
);

initial begin @( posedge clk )
    data_in = 1'bx;
    ##1;
    data_in = 0;
    ##1;

    data_in = 1;
    #1;
    $display("\nTest #1: Both signals DUT.d_i and DUT.posedge_stb_o rising together...");
    assert((data_in == 1'b1) && (data_out == 1'b1)) begin
        $display("OK");
    end else begin
        $error("data_out = %0b, data_in = %0b", data_out, data_in);
    end

    ##1;
    $display("\nTest #2:  DUT.posedge_stb_o goes low even if DUT.d_i continue has high value...");
    assert((data_in == 1'b1) && (data_out == 1'b0)) begin
        $display("OK");
    end else begin
        $error("data_out = %0b, data_in = %0b", data_out, data_in);
    end

    ##3;
    $stop();
end

endmodule: posedge_detector_tb
