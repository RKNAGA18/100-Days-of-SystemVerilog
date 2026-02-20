module fir_filter #(parameter TAPS = 4, parameter N = 16) (
    input  logic [N-1:0] data_in [TAPS],
    input  logic [N-1:0] coeffs [TAPS],
    output logic [(2*N)-1:0] filter_out
);
    always_comb begin
        filter_out = '0;
        for (int i = 0; i < TAPS; i++) begin
            filter_out = filter_out + (data_in[i] * coeffs[i]);
        end
    end
endmodule