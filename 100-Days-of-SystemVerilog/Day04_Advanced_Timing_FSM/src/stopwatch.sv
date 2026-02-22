module stopwatch (
    input  logic clk, rst_n, start_stop, clear,
    output logic [6:0] centiseconds, // 0-99
    output logic [5:0] seconds       // 0-59
);
    logic [23:0] tick_count; // To divide 100MHz down to 100Hz (10ms)
    logic running;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_count <= 0; centiseconds <= 0; seconds <= 0; running <= 0;
        end else if (clear) begin
            tick_count <= 0; centiseconds <= 0; seconds <= 0; running <= 0;
        end else begin
            if (start_stop) running <= ~running; // Toggle run state
            
            if (running) begin
                if (tick_count == 24'd999_999) begin // 10ms passed
                    tick_count <= 0;
                    if (centiseconds == 99) begin
                        centiseconds <= 0;
                        if (seconds == 59) seconds <= 0;
                        else seconds <= seconds + 1'b1;
                    end else begin
                        centiseconds <= centiseconds + 1'b1;
                    end
                end else begin
                    tick_count <= tick_count + 1'b1;
                end
            end
        end
    end
endmodule