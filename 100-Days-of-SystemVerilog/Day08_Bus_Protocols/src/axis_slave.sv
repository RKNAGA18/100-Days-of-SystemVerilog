module axis_slave #(parameter WIDTH = 32) (
    input  logic clk, rst_n,
    input  logic s_tvalid,
    output logic s_tready,
    input  logic [WIDTH-1:0] s_tdata,
    input  logic s_tlast,
    input  logic internal_fifo_full
);
    assign s_tready = !internal_fifo_full;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic
        end else if (s_tvalid && s_tready) begin
            
            if (s_tlast) begin
                // End of packet processing (e.g., verify CRC)
            end
        end
    end
endmodule