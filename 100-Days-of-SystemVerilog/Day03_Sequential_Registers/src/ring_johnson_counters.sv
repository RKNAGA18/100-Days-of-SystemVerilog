module ring_counter #(parameter N = 4) (
    input  logic clk, rst_n,
    output logic [N-1:0] q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= {{N-1{1'b0}}, 1'b1}; // Initialize to 00..01
        else        q <= {q[N-2:0], q[N-1]};
    end
endmodule

module johnson_counter #(parameter N = 4) (
    input  logic clk, rst_n,
    output logic [N-1:0] q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= '0; // Initialize to 00..00
        else        q <= {q[N-2:0], ~q[N-1]}; // Invert MSB and feed to LSB
    end
endmodule