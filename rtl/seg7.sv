import datatype_package::seg_symbol_t;

module seg7
(
    input   logic[0:3]  val_i,      // decimal value
    input   logic       pnt_i,      // show point?
    input   logic       hzero_i,    // hide if zero digit?
    output  logic[7:0]  seg_o       // 8-bit segment sequence
);

always_comb begin
    unique casez (val_i)
        0: seg_o = hzero_i ? { 1'b1, SEG_OFF } : { !pnt_i, SEG_0 };
        1: seg_o = { !pnt_i, SEG_1 };
        2: seg_o = { !pnt_i, SEG_2 };
        3: seg_o = { !pnt_i, SEG_3 };
        4: seg_o = { !pnt_i, SEG_4 };
        5: seg_o = { !pnt_i, SEG_5 };
        6: seg_o = { !pnt_i, SEG_6 };
        7: seg_o = { !pnt_i, SEG_7 };
        8: seg_o = { !pnt_i, SEG_8 };
        9: seg_o = { !pnt_i, SEG_9 };
        default: seg_o = { 1'b1, SEG_OFF };
    endcase
end

endmodule: seg7
