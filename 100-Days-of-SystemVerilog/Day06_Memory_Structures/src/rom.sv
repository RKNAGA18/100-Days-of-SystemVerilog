module rom #(parameter DEPTH = 256, WIDTH = 8) (
    input  logic clk,
    input  logic [$clog2(DEPTH)-1:0] addr,
    output logic [WIDTH-1:0] data_out
);
    // Declare the memory array
    logic [WIDTH-1:0] memory [0:DEPTH-1];

    // Load data from an external hex file during initialization
    initial begin
        $readmemh("init.hex", memory);
    end

    // Synchronous read (standard for block ROMs in FPGAs)
    always_ff @(posedge clk) begin
        data_out <= memory[addr];
    end
endmodule