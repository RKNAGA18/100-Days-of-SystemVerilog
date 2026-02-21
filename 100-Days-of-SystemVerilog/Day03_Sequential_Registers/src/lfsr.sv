module lfsr #(parameter N = 8) (
    input  logic clk, rst_n,
    output logic [N-1:0] q
);
    // Taps for 8-bit LFSR: bits 8, 6, 5, 4 (Indices 7, 5, 4, 3)
    logic feedback;
    assign feedback = q[7] ^ q[5] ^ q[4] ^ q[3];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 8'hFF; // LFSR cannot be initialized to 0!
        else        q <= {q[N-2:0], feedback};
    end
endmodule