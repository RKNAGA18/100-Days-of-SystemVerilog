module dual_port_ram #(parameter DEPTH = 256, WIDTH = 8) (
    input  logic clk,
    input  logic we,
    input  logic [$clog2(DEPTH)-1:0] write_addr,
    input  logic [$clog2(DEPTH)-1:0] read_addr,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    logic [WIDTH-1:0] memory [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (we) begin
            memory[write_addr] <= data_in;
        end
        data_out <= memory[read_addr];
    end
endmodule