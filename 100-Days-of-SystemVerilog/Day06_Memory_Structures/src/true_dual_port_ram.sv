module true_dual_port_ram #(parameter DEPTH = 256, WIDTH = 8) (
    input  logic clk,
    input  logic we_a, we_b,
    input  logic [$clog2(DEPTH)-1:0] addr_a, addr_b,
    input  logic [WIDTH-1:0] data_in_a, data_in_b,
    output logic [WIDTH-1:0] data_out_a, data_out_b
);
    logic [WIDTH-1:0] memory [0:DEPTH-1];

    // Port A
    always_ff @(posedge clk) begin
        if (we_a) memory[addr_a] <= data_in_a;
        data_out_a <= memory[addr_a];
    end

    // Port B
    always_ff @(posedge clk) begin
        if (we_b) memory[addr_b] <= data_in_b;
        data_out_b <= memory[addr_b];
    end
endmodule