module seq_multiplier #(parameter N = 32) (
    input  logic clk, rst_n, start,
    input  logic [N-1:0] a, b,
    output logic [(2*N)-1:0] prod,
    output logic ready
);
    logic [(2*N)-1:0] multiplicand;
    logic [N-1:0] multiplier;
    logic [$clog2(N):0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prod <= '0; ready <= 0; count <= '0;
        end else if (start) begin
            multiplicand <= { {N{1'b0}}, a };
            multiplier <= b;
            prod <= '0;
            count <= N;
            ready <= 0;
        end else if (count > 0) begin
            if (multiplier[0]) prod <= prod + multiplicand;
            multiplicand <= multiplicand << 1;
            multiplier <= multiplier >> 1;
            count <= count - 1;
        end else begin
            ready <= 1;
        end
    end
endmodule