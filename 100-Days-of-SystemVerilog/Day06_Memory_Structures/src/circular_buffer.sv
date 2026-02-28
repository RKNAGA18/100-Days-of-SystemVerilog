module circular_buffer #(parameter DEPTH = 16, WIDTH = 8) (
    input  logic clk, rst_n,
    input  logic write_en, read_en,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    logic [WIDTH-1:0] memory [0:DEPTH-1];
    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            data_out <= '0;
        end else begin
            if (write_en) begin
                memory[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1; // Automatically wraps around
            end
            if (read_en) begin
                data_out <= memory[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1; // Automatically wraps around
            end
        end
    end
endmodule