module register_file (
    input  logic clk, rst_n,
    input  logic we,
    input  logic [4:0] rs1, rs2, rd, // 5 bits = 32 registers
    input  logic [31:0] write_data,
    output logic [31:0] read_data1, read_data2
);
    // 32 registers, each 32 bits wide
    logic [31:0] registers [0:31];
    integer i;

    // Synchronous Write Port
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear all registers on reset
            for (i = 0; i < 32; i = i + 1) registers[i] <= 32'h0;
        end else if (we && rd != 5'd0) begin
            // Write to rd, UNLESS it is x0 (Register 0)
            registers[rd] <= write_data;
        end
    end

    // Asynchronous Read Ports (Combinational)
    // We bypass the memory array if asking for x0 to guarantee it is always 0.
    assign read_data1 = (rs1 == 5'd0) ? 32'h0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'h0 : registers[rs2];

endmodule