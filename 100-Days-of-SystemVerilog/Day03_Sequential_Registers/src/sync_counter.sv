module sync_counter #(parameter N = 8) (
    input  logic clk, rst_n, en, up_down, // 1 for Up, 0 for Down
    output logic [N-1:0] count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else if (en) begin
            if (up_down) count <= count + 1'b1;
            else         count <= count - 1'b1;
        end
    end
endmodule