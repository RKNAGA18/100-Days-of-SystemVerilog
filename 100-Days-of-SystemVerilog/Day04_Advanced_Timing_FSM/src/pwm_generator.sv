module pwm_generator #(parameter RESOLUTION = 8) (
    input  logic clk, rst_n,
    input  logic [RESOLUTION-1:0] duty, // 0 to 255
    output logic pwm_out
);
    logic [RESOLUTION-1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0; pwm_out <= 0;
        end else begin
            counter <= counter + 1'b1;
            // If counter is less than duty, output 1
            pwm_out <= (counter < duty) ? 1'b1 : 1'b0;
        end
    end
endmodule