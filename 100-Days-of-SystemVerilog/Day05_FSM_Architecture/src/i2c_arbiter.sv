module i2c_arbiter (
    input  logic clk, rst_n,
    input  logic sda_in,       // What is actually on the physical wire
    input  logic tx_bit,       // What we are trying to send
    input  logic transmit_en,  // Are we currently transmitting?
    output logic sda_out,      // What we drive to the wire
    output logic arb_lost      // Flag if we lost the bus
);
    typedef enum logic [1:0] {IDLE, TRANSMIT, ARB_LOSS} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end

    always_comb begin
        next_state = state;
        sda_out = 1'b1; // I2C is open-drain, default is High-Z (1)
        arb_lost = 1'b0;

        case (state)
            IDLE: begin
                if (transmit_en) next_state = TRANSMIT;
            end
            TRANSMIT: begin
                sda_out = tx_bit;
                // Collision Detection: We sent a 1, but the wire is pulled to 0 by someone else!
                if (tx_bit == 1'b1 && sda_in == 1'b0) begin
                    next_state = ARB_LOSS;
                end else if (!transmit_en) begin
                    next_state = IDLE;
                end
            end
            ARB_LOSS: begin
                arb_lost = 1'b1;
                if (!transmit_en) next_state = IDLE; // Wait for controller to clear transmission
            end
        endcase
    end
endmodule