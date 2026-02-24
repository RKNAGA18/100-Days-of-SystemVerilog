module spi_slave (
    input  logic clk, rst_n, // Main system clock
    input  logic sclk, mosi, cs_n, // Wires from Master
    output logic miso,
    input  logic [7:0] tx_data, // Data to send back to Master
    output logic [7:0] rx_data, // Data received from Master
    output logic rx_valid
);
    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;
    
    // Edge detection for SCLK (to cross into our local clk domain safely)
    logic sclk_d1, sclk_d2;
    logic sclk_rising, sclk_falling;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_d1 <= 0; sclk_d2 <= 0;
        end else begin
            sclk_d1 <= sclk; sclk_d2 <= sclk_d1;
        end
    end
    assign sclk_rising = sclk_d1 & ~sclk_d2;
    assign sclk_falling = ~sclk_d1 & sclk_d2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 0; bit_cnt <= 0; rx_valid <= 0; rx_data <= 0;
        end else if (cs_n == 1'b0) begin // Chip is selected
            rx_valid <= 0;
            
            // Shift data OUT on falling edge
            if (sclk_falling) begin
                if (bit_cnt == 0) shift_reg <= tx_data; // Load new byte
                else shift_reg <= {shift_reg[6:0], 1'b0};
            end
            
            // Capture data IN on rising edge
            if (sclk_rising) begin
                shift_reg[0] <= mosi;
                bit_cnt <= bit_cnt + 1'b1;
                
                if (bit_cnt == 7) begin
                    rx_data <= {shift_reg[7:1], mosi};
                    rx_valid <= 1'b1;
                end
            end
        end else begin
            bit_cnt <= 0; // Reset if CS goes high
        end
    end

    // MISO is driven combinationally from the MSB of the shift register
    assign miso = (cs_n == 1'b0) ? shift_reg[7] : 1'bz; // High-Z when not selected

endmodule