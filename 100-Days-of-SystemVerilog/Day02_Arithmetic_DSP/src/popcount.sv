module popcount #(parameter N = 32) (
    input  logic [N-1:0] data,
    output logic [$clog2(N):0] count
);
    always_comb begin
        count = '0;
        for (int i = 0; i < N; i++) begin
            count = count + data[i];
        end
    end
endmodule