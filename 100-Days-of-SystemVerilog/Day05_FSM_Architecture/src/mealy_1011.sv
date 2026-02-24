module mealy_1011 (
    input  logic clk, rst_n, seq_in,
    output logic detected
);
    typedef enum logic [1:0] {S_IDLE, S_1, S_10, S_101} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= next_state;
    end

    always_comb begin
        next_state = state;
        detected = 1'b0; // Default output
        
        case (state)
            S_IDLE: if (seq_in) next_state = S_1;   else next_state = S_IDLE;
            S_1:    if (seq_in) next_state = S_1;   else next_state = S_10;
            S_10:   if (seq_in) next_state = S_101; else next_state = S_IDLE;
            S_101: begin
                if (seq_in) begin
                    next_state = S_1; 
                    detected = 1'b1; // Mealy: Output depends on state AND input
                end else begin
                    next_state = S_10;
                end
            end
            default: next_state = S_IDLE;
        endcase
    end
endmodule