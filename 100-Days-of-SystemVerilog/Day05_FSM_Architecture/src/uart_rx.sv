module uart_rx (
    input  logic clk, rst_n,
    input  logic baud_tick, // Aligned to middle of bit
    input  logic rx_pin,    // The physical wire
    output logic [7:0] rx_data,
    output logic rx_done
);
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state, next_state;

    logic [7:0] shift_reg, next_shift_reg;
    logic [2:0] bit_cnt, next_bit_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; shift_reg <= 0; bit_cnt <= 0;
        end else if (baud_tick || state == IDLE) begin 
            // IDLE needs to constantly poll without waiting for baud_tick
            state <= next_state;
            shift_reg <= next_shift_reg;
            bit_cnt <= next_bit_cnt;
        end
    end

    always @(*) begin
        next_state = state;
        next_shift_reg = shift_reg;
        next_bit_cnt = bit_cnt;
        rx_data = shift_reg;
        rx_done = 1'b0;

        case (state)
            IDLE: begin
                if (rx_pin == 1'b0) begin // Start bit detected!
                    next_bit_cnt = 0;
                    next_state = START;
                end
            end
            START: begin
                next_state = DATA;
            end
            DATA: begin
                next_shift_reg = {rx_pin, shift_reg[7:1]}; // Shift in from MSB
                if (bit_cnt == 7) next_state = STOP;
                else              next_bit_cnt = bit_cnt + 1'b1;
            end
            STOP: begin
                if (rx_pin == 1'b1) rx_done = 1'b1; // Valid stop bit
                next_state = IDLE;
            end
        endcase
    end
endmodule