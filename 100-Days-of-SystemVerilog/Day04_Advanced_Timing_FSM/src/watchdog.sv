module watchdog #(parameter TIMEOUT = 32'h00FF_FFFF) (
    input  logic clk, rst_n, kick, enable,
    output logic sys_reset
);
    logic [31:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= TIMEOUT; sys_reset <= 0;
        end else if (enable) begin
            if (kick) begin
                count <= TIMEOUT; sys_reset <= 0;
            end else if (count == 0) begin
                sys_reset <= 1; // System hung! Fire reset.
            end else begin
                count <= count - 1'b1; sys_reset <= 0;
            end
        end
    end
endmodule