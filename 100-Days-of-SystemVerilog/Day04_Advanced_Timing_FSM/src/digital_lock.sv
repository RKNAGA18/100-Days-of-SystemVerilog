module digital_lock (
    input  logic clk, rst_n, key_pressed,
    input  logic [3:0] key_val,
    output logic unlocked
);
    typedef enum logic [2:0] {IDLE, ST1, ST2, ST3, UNLOCKED} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end

    always_comb begin
        next_state = state; unlocked = 0;
        
        if (key_pressed) begin
            case (state)
                IDLE: if (key_val == 4'd3) next_state = ST1; else next_state = IDLE;
                ST1:  if (key_val == 4'd1) next_state = ST2; else next_state = IDLE; // Penalty: start over
                ST2:  if (key_val == 4'd4) next_state = ST3; else next_state = IDLE;
                ST3:  if (key_val == 4'd2) next_state = UNLOCKED; else next_state = IDLE;
                UNLOCKED: unlocked = 1; // Stay unlocked until reset
                default: next_state = IDLE;
            endcase
        end else if (state == UNLOCKED) begin
            unlocked = 1;
        end
    end
endmodule