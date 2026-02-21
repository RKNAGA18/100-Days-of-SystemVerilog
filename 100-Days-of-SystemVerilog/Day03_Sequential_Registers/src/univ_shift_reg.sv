module univ_shift_reg #(parameter N = 8) (
    input  logic clk, rst_n,
    input  logic [1:0] mode, // 00:Hold, 01:Shift Left, 10:Shift Right, 11:Load
    input  logic [N-1:0] p_in,
    input  logic s_in_left, s_in_right,
    output logic [N-1:0] q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= '0;
        else begin
            case (mode)
                2'b00: q <= q; // Hold
                2'b01: q <= {q[N-2:0], s_in_right}; // Shift Left
                2'b10: q <= {s_in_left, q[N-1:1]};  // Shift Right
                2'b11: q <= p_in; // Parallel Load
            endcase
        end
    end
endmodule