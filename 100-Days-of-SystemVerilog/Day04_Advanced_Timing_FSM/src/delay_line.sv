module delay_line #(parameter MAX_DELAY = 16) (
    input  logic clk, rst_n, sig_in,
    input  logic [$clog2(MAX_DELAY)-1:0] delay_cycles,
    output logic sig_out
);
    logic [MAX_DELAY-1:0] shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) shift_reg <= '0;
        else        shift_reg <= {shift_reg[MAX_DELAY-2:0], sig_in};
    end

    // Tap into the shift register at the programmed index
    assign sig_out = shift_reg[delay_cycles];
endmodule