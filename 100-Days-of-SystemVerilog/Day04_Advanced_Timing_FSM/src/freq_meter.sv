module freq_meter (
    input  logic ref_clk, rst_n, // Known clock (e.g., 100MHz)
    input  logic target_sig,     // Unknown signal
    output logic [31:0] frequency
);
    logic [31:0] edge_count, window_count;
    logic target_d1, target_d2;
    logic rising_edge;

    // Synchronize target signal to ref_clk domain and detect edge
    always_ff @(posedge ref_clk or negedge rst_n) begin
        if (!rst_n) begin
            target_d1 <= 0; target_d2 <= 0;
        end else begin
            target_d1 <= target_sig; target_d2 <= target_d1;
        end
    end
    assign rising_edge = target_d1 & ~target_d2;

    always_ff @(posedge ref_clk or negedge rst_n) begin
        if (!rst_n) begin
            window_count <= 0; edge_count <= 0; frequency <= 0;
        end else begin
            if (window_count == 32'd99_999_999) begin // 1 second window
                frequency <= edge_count;
                edge_count <= 0;
                window_count <= 0;
            end else begin
                window_count <= window_count + 1'b1;
                if (rising_edge) edge_count <= edge_count + 1'b1;
            end
        end
    end
endmodule