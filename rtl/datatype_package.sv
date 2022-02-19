package datatype_package;

typedef enum logic [2:0] {
    EMPTY_MSG,
    WELCOME_MSG,
    READY_MSG,
    WIN_MSG,
    STOPWATCH_MSG
} msg_t;

typedef enum logic [2:0] {
    IDLE_S,
    WELCOME_S,
    READY_S,
    RUN_S,
    SHOOT_S,
    WIN_S,
    SCORE_S
} game_state_t;

typedef enum logic [6:0] {
    SEG_OFF     = 7'b1111111,

    SEG_0       = 7'b1000000,
    SEG_1       = 7'b1111001,
    SEG_2       = 7'b0100100,
    SEG_3       = 7'b0110000,
    SEG_4       = 7'b0011001,
    SEG_5       = 7'b0010010,
    SEG_6       = 7'b0000010,
    SEG_7       = 7'b1111000,
    SEG_8       = 7'b0000000,
    SEG_9       = 7'b0010000,

    SEG_G       = 7'b1000010,
    SEG_U       = 7'b1000001,
    SEG_P       = 7'b0001100,
    SEG_E       = 7'b0000110,
    SEG_R       = 7'b0101111,
    SEG_A       = 7'b0001000,
    SEG_T       = 7'b0000111,

    SEG_DASH    = 7'b0111111

} seg_symbol_t;

endpackage:datatype_package
