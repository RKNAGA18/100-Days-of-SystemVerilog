module advanced_fifo #(
    parameter DEPTH = 32, 
    parameter WIDTH = 8,
    parameter ALMOST_FULL_LVL = 28,
    parameter ALMOST_EMPTY_LVL = 4
)(
    input  logic clk, rst_n,
    input  logic wr_en, rd_en,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic full, empty, almost_full, almost_empty
);
    logic [WIDTH-1:0] memory [0:DEPTH-1];
    logic [$clog2(DEPTH):0] count;
    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;

    assign full = (count == DEPTH);
    assign empty = (count == 0);
    assign almost_full = (count >= ALMOST_FULL_LVL);
    assign almost_empty = (count <= ALMOST_EMPTY_LVL);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0; rd_ptr <= 0; count <= 0; data_out <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: begin // Write only
                    memory[wr_ptr] <= data_in;
                    wr_ptr <= wr_ptr + 1'b1;
                    count <= count + 1'b1;
                end
                2'b01: begin // Read only
                    data_out <= memory[rd_ptr];
                    rd_ptr <= rd_ptr + 1'b1;
                    count <= count - 1'b1;
                end
                2'b11: begin // Simultaneous Read & Write
                    memory[wr_ptr] <= data_in;
                    data_out <= memory[rd_ptr];
                    wr_ptr <= wr_ptr + 1'b1;
                    rd_ptr <= rd_ptr + 1'b1;
                    // Count remains the same
                end
            endcase
        end
    end
endmodule