module sync_fifo #(parameter DEPTH = 16, WIDTH = 8) (
    input  logic clk, rst_n,
    input  logic wr_en, rd_en,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic full, empty
);
    logic [WIDTH-1:0] memory [0:DEPTH-1];
    
    // Pointers have an extra MSB to distinguish between full and empty
    logic [$clog2(DEPTH):0] wr_ptr, rd_ptr;

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[$clog2(DEPTH)] != rd_ptr[$clog2(DEPTH)]) && 
                   (wr_ptr[$clog2(DEPTH)-1:0] == rd_ptr[$clog2(DEPTH)-1:0]);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0; rd_ptr <= 0; data_out <= 0;
        end else begin
            if (wr_en && !full) begin
                memory[wr_ptr[$clog2(DEPTH)-1:0]] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (rd_en && !empty) begin
                data_out <= memory[rd_ptr[$clog2(DEPTH)-1:0]];
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end
endmodule