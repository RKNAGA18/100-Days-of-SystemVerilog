module parallel_shift_reg #(parameter N = 8) (
    input  logic clk, rst_n,
    input  logic load_en, shift_en,
    input  logic [N-1:0] p_in,
    input  logic s_in, // Serial input to feed into the empty spot
    output logic [N-1:0] q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= '0;
        end else if (load_en) begin
            q <= p_in; // Parallel Load
        end else if (shift_en) begin
            q <= {q[N-2:0], s_in}; // Shift Left
        end
    end
endmodule