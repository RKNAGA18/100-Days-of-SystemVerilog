module uart_tx (
    input  logic clk, rst_n,
    input  logic baud_tick,      // From the Baud Generator
    input  logic tx_start,
    input  logic [7:0] tx_data,
    output logic tx_pin,         // The physical wire
    output logic tx_busy
);
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state, next_state;

    logic [7:0] shift_reg, next_shift_reg;
    logic [2:0] bit_cnt, next_bit_cnt;

    // State & Data Memory
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            shift_reg <= 0;
            bit_cnt <= 0;
        end else if (baud_tick) begin // Only transition on baud ticks!
            state <= next_state;
            shift_reg <= next_shift_reg;
            bit_cnt <= next_bit_cnt;
        end
    end

    // Next State & Output Logic
    always @(*) begin
        next_state = state;
        next_shift_reg = shift_reg;
        next_bit_cnt = bit_cnt;
        tx_pin = 1'b1; // Default to HIGH (Idle state for UART)
        tx_busy = 1'b1;

        case (state)
            IDLE: begin
                tx_busy = 1'b0;
                if (tx_start) begin
                    next_shift_reg = tx_data;
                    next_bit_cnt = 0;
                    next_state = START;
                end
            end
            START: begin
                tx_pin = 1'b0; // Start bit is LOW
                next_state = DATA;
            end
            DATA: begin
                tx_pin = shift_reg[0]; // Send LSB first
                next_shift_reg = {1'b0, shift_reg[7:1]}; // Shift right
                if (bit_cnt == 7) next_state = STOP;
                else              next_bit_cnt = bit_cnt + 1'b1;
            end
            STOP: begin
                tx_pin = 1'b1; // Stop bit is HIGH
                next_state = IDLE;
            end
        endcase
    end
endmodule