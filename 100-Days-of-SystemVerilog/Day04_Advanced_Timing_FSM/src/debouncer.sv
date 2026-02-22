module debouncer #(parameter WAIT_TIME = 16'hFFFF) (
    input  logic clk, rst_n, noisy_in,
    output logic clean_out
);
    logic [15:0] count;
    logic sync_1, sync_2; // Double-flop for metastability

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_1 <= 0; sync_2 <= 0;
            count <= 0; clean_out <= 0;
        end else begin
            sync_1 <= noisy_in;
            sync_2 <= sync_1;
            
            if (sync_2 == clean_out) begin
                count <= 0; // Reset counter if no change
            end else begin
                count <= count + 1'b1;
                if (count == WAIT_TIME) begin
                    clean_out <= sync_2; // Update output after stable period
                    count <= 0;
                end
            end
        end
    end
endmodule