module sync_2ff (
    input  logic clk_dest, rst_n_dest,
    input  logic async_in,
    output logic sync_out
);
    logic sync_d1;

    always_ff @(posedge clk_dest or negedge rst_n_dest) begin
        if (!rst_n_dest) begin
            sync_d1  <= 1'b0;
            sync_out <= 1'b0;
        end else begin
            sync_d1  <= async_in;
            sync_out <= sync_d1;
        end
    end
endmodule