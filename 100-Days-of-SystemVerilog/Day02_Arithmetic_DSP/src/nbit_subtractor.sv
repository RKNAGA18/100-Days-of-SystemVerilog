module nbit_subtractor #(parameter N = 32) (
    input  logic [N-1:0] a,
    input  logic [N-1:0] b,
    output logic [N-1:0] diff,
    output logic         borrow_out
);
    logic [N:0] temp;
    always @(*) begin
        // a - b is equivalent to a + (~b) + 1
        temp = {1'b0, a} + {1'b0, ~b} + 1'b1;
        diff = temp[N-1:0];
        borrow_out = ~temp[N]; // 0 means borrow occurred
    end
endmodule