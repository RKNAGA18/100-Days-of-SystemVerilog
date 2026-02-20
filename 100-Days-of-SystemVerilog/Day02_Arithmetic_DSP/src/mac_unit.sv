module mac_unit #(parameter N = 16) (
    input  logic clk, rst_n, clear,
    input  logic [N-1:0] a, b,
    output logic [(2*N)-1:0] accum
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)      accum <= '0;
        else if (clear)  accum <= '0;
        else             accum <= accum + (a * b);
    end
endmodule