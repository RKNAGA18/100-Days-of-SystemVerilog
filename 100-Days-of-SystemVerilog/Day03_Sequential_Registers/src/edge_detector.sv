module edge_detector (
    input  logic clk, rst_n, sig_in,
    output logic rising_edge, falling_edge, any_edge
);
    logic sig_d1, sig_d2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_d1 <= 1'b0; sig_d2 <= 1'b0;
        end else begin
            sig_d1 <= sig_in; // Current state
            sig_d2 <= sig_d1; // Previous state
        end
    end

    assign rising_edge  =  sig_d1 & ~sig_d2;
    assign falling_edge = ~sig_d1 &  sig_d2;
    assign any_edge     =  sig_d1 ^  sig_d2;
endmodule