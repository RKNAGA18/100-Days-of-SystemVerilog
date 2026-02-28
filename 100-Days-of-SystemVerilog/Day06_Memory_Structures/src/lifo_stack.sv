module lifo_stack #(parameter DEPTH = 16, WIDTH = 32) (
    input  logic clk, rst_n,
    input  logic push, pop,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic full, empty
);
    logic [WIDTH-1:0] memory [0:DEPTH-1];
    logic [$clog2(DEPTH):0] sp; // Stack Pointer (needs extra bit to track full state)

    assign full  = (sp == DEPTH);
    assign empty = (sp == 0);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sp <= 0;
            data_out <= '0;
        end else begin
            if (push && !full) begin
                memory[sp] <= data_in;
                sp <= sp + 1'b1;
            end else if (pop && !empty) begin
                sp <= sp - 1'b1;
                data_out <= memory[sp - 1'b1]; // Read the top of the stack
            end
        end
    end
endmodule