module vending_machine (
    input  logic clk, rst_n,
    input  logic nickel, dime, // Pulses
    output logic dispense, change
);
    typedef enum logic [2:0] {S0, S5, S10, S15, S20} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S0;
        else        state <= next_state;
    end

    always_comb begin
        next_state = state; dispense = 0; change = 0;
        case (state)
            S0:  if (nickel) next_state = S5;  else if (dime) next_state = S10;
            S5:  if (nickel) next_state = S10; else if (dime) next_state = S15;
            S10: if (nickel) next_state = S15; else if (dime) next_state = S20;
            S15: begin dispense = 1; change = 0; next_state = S0; end // Exact change
            S20: begin dispense = 1; change = 1; next_state = S0; end // Return 5c change
            default: next_state = S0;
        endcase
    end
endmodule