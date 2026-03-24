module gray_counter #(parameter WIDTH = 4) (
    input  logic clk, rst_n,
    input  logic enable,
    output logic [WIDTH-1:0] gray_out,
    output logic [WIDTH-1:0] bin_out
);
    logic [WIDTH-1:0] bin_next;
    logic [WIDTH-1:0] gray_next;

    // Combinational logic for next state
    always_comb begin
        bin_next = bin_out + enable;
        // Binary to Gray conversion: shift right by 1 and XOR with original
        gray_next = bin_next ^ (bin_next >> 1);
    end

    // Sequential memory
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bin_out  <= '0;
            gray_out <= '0;
        end else begin
            bin_out  <= bin_next;
            gray_out <= gray_next;
        end
    end
endmodule