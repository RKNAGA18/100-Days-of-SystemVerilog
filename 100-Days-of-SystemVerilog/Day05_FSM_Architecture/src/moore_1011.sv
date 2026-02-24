module moore_1011 (
    input  logic clk, rst_n, seq_in,
    output logic detected
);
    typedef enum logic [2:0] {S_IDLE, S_1, S_10, S_101, S_1011} state_t;
    state_t state, next_state;

    // 1. State Memory
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= next_state;
    end

    // 2. Next State Logic (Combinational)
    always_comb begin
        next_state = state;
        case (state)
            S_IDLE: if (seq_in) next_state = S_1;    else next_state = S_IDLE;
            S_1:    if (seq_in) next_state = S_1;    else next_state = S_10;
            S_10:   if (seq_in) next_state = S_101;  else next_state = S_IDLE;
            S_101:  if (seq_in) next_state = S_1011; else next_state = S_10;
            S_1011: if (seq_in) next_state = S_1;    else next_state = S_10;
            default: next_state = S_IDLE;
        endcase
    end

    // 3. Output Logic (Moore: depends ONLY on state)
    assign detected = (state == S_1011);
endmodule