module array_multiplier #(parameter N = 4) (
    input  logic [N-1:0] a,
    input  logic [N-1:0] b,
    output logic [(2*N)-1:0] prod
);
    logic [N-1:0] partials [N];
    logic [(2*N)-1:0] accum;

    always_comb begin
        accum = '0;
        for (int i = 0; i < N; i++) begin
            partials[i] = b[i] ? a : '0;
            accum = accum + (partials[i] << i);
        end
        prod = accum;
    end
endmodule