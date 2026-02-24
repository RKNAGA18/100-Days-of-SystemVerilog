module spi_master (
    input  logic clk, rst_n,
    input  logic start_tx,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic sclk, mosi, cs_n,
    input  logic miso,
    output logic tx_done
);
    typedef enum logic [1:0] {IDLE, SHIFT, DONE} state_t;
    state_t state, next_state;
    
    logic [7:0] shift_reg, next_shift_reg;
    logic [3:0] bit_cnt, next_bit_cnt;
    logic sclk_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; shift_reg <= 0; bit_cnt <= 0; sclk_reg <= 0;
        end else begin
            state <= next_state;
            shift_reg <= next_shift_reg;
            bit_cnt <= next_bit_cnt;
            
            // Toggle SCLK during SHIFT state to generate the SPI clock
            if (state == SHIFT) sclk_reg <= ~sclk_reg;
            else sclk_reg <= 0;
        end
    end

    always @(*) begin
        next_state = state;
        next_shift_reg = shift_reg;
        next_bit_cnt = bit_cnt;
        mosi = shift_reg[7]; // Send MSB first
        rx_data = shift_reg;
        cs_n = 1'b1; // Active low chip select
        sclk = sclk_reg;
        tx_done = 0;

        case (state)
            IDLE: begin
                if (start_tx) begin
                    next_shift_reg = tx_data;
                    next_bit_cnt = 0;
                    next_state = SHIFT;
                end
            end
            SHIFT: begin
                cs_n = 1'b0; // Pull CS low to activate slave
                // Capture MISO on the rising edge of our generated SCLK
                if (sclk_reg == 1'b1) begin
                    next_shift_reg = {shift_reg[6:0], miso};
                    next_bit_cnt = bit_cnt + 1'b1;
                    if (bit_cnt == 7) next_state = DONE;
                end
            end
            DONE: begin
                tx_done = 1'b1;
                next_state = IDLE;
            end
        endcase
    end
endmodule