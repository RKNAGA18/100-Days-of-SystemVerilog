module lzc #(parameter N = 32) (
    input  logic [N-1:0] data,
    output logic [$clog2(N):0] count
);
    always_comb begin
        count = N;
        for (int i = 0; i < N; i++) begin
            if (data[i]) begin
                count = N - 1 - i;
            end
        end
    end
endmodule