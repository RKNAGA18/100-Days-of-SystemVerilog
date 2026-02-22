module pulse_gen #(parameter MAX_WIDTH = 255) (
    input  logic clk, rst_n, trigger,
    input  logic [$clog2(MAX_WIDTH)-1:0] width,
    output logic pulse_out
);
    logic [$clog2(MAX_WIDTH)-1:0] count;
    logic active;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0; active <= 0; pulse_out <= 0;
        end else begin
            if (trigger && !active) begin
                active <= 1; count <= width; pulse_out <= 1;
            end else if (active) begin
                if (count > 1) begin
                    count <= count - 1'b1;
                end else begin
                    active <= 0; pulse_out <= 0;
                end
            end
        end
    end
endmodule