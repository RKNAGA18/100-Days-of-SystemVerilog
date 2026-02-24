module uart_baud #(
    parameter CLK_FREQ  = 100_000_000, // 100 MHz
    parameter BAUD_RATE = 115200
)(
    input  logic clk, rst_n,
    output logic baud_tick
);
    // Calculate the wrap-around value for the counter
    localparam MAX_COUNT = CLK_FREQ / BAUD_RATE;
    logic [$clog2(MAX_COUNT)-1:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            baud_tick <= 0;
        end else begin
            if (count == MAX_COUNT - 1) begin
                count <= 0;
                baud_tick <= 1'b1; // Pulse for 1 clock cycle
            end else begin
                count <= count + 1'b1;
                baud_tick <= 1'b0;
            end
        end
    end
endmodule