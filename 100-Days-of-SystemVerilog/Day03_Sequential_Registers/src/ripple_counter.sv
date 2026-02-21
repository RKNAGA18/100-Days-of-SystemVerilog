module ripple_counter #(parameter N = 4) (
    input  logic clk, rst_n,
    output logic [N-1:0] count
);
    // Bit 0 is clocked by the main clock
    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) count[0] <= 1'b0;
        else        count[0] <= ~count[0];
    end

    // Subsequent bits are clocked by the PREVIOUS bit (The Ripple)
    genvar i;
    generate
        for (i = 1; i < N; i++) begin : ripple_stage
            always_ff @(negedge count[i-1] or negedge rst_n) begin
                if (!rst_n) count[i] <= 1'b0;
                else        count[i] <= ~count[i];
            end
        end
    endgenerate
endmodule