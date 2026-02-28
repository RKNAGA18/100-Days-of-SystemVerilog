module single_port_ram #(parameter DEPTH = 256, WIDTH = 8) (
    input  logic clk,
    input  logic we, // Write Enable
    input  logic [$clog2(DEPTH)-1:0] addr,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    logic [WIDTH-1:0] memory [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (we) begin
            memory[addr] <= data_in;
        end
        // "Write-First" behavior: reading the same address we are writing 
        // will output the newly written data.
        data_out <= memory[addr]; 
    end
endmodule