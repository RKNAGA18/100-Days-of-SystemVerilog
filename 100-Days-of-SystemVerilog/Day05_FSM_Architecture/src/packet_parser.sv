module packet_parser (
    input  logic clk, rst_n, rx_valid,
    input  logic [7:0] rx_data,
    output logic [7:0] payload,
    output logic payload_valid, error_flag
);
    typedef enum logic [2:0] {IDLE, READ_LEN, READ_DATA, CHECK_CRC} state_t;
    state_t state, next_state;

    logic [7:0] length_cnt, next_length_cnt;
    logic [7:0] expected_crc, next_expected_crc;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; length_cnt <= 0; expected_crc <= 0;
        end else begin
            state <= next_state;
            length_cnt <= next_length_cnt;
            expected_crc <= next_expected_crc;
        end
    end

    always_comb begin
        next_state = state;
        next_length_cnt = length_cnt;
        next_expected_crc = expected_crc;
        payload = 8'h00; payload_valid = 0; error_flag = 0;

        case (state)
            IDLE: begin
                if (rx_valid && rx_data == 8'hAA) begin // Start of Frame
                    next_state = READ_LEN;
                    next_expected_crc = 8'h00;
                end
            end
            READ_LEN: begin
                if (rx_valid) begin
                    next_length_cnt = rx_data;
                    // FIXED: Replaced the ternary operator with explicit if-else for the enum
                    if (rx_data > 0) next_state = READ_DATA;
                    else             next_state = IDLE;
                end
            end
            READ_DATA: begin
                if (rx_valid) begin
                    payload = rx_data;
                    payload_valid = 1;
                    next_expected_crc = expected_crc ^ rx_data; // Simple XOR CRC
                    next_length_cnt = length_cnt - 1'b1;
                    if (length_cnt == 1) next_state = CHECK_CRC;
                end
            end
            CHECK_CRC: begin
                if (rx_valid) begin
                    if (rx_data != expected_crc) error_flag = 1;
                    next_state = IDLE;
                end
            end
        endcase
    end
endmodule