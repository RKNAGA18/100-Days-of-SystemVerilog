module glitch_free_clk_mux (
    input  logic clk0, clk1, rst_n, select, // 0 for clk0, 1 for clk1
    output logic out_clk
);
    logic q0_ff1, q0_ff2;
    logic q1_ff1, q1_ff2;
    
    logic en0, en1;

    // Clock 0 Domain (Negative edge triggered)
    always_ff @(negedge clk0 or negedge rst_n) begin
        if (!rst_n) begin
            q0_ff1 <= 0; q0_ff2 <= 0;
        end else begin
            q0_ff1 <= ~select & ~q1_ff2; 
            q0_ff2 <= q0_ff1;
        end
    end

    // Clock 1 Domain (Negative edge triggered)
    always_ff @(negedge clk1 or negedge rst_n) begin
        if (!rst_n) begin
            q1_ff1 <= 0; q1_ff2 <= 0;
        end else begin
            q1_ff1 <= select & ~q0_ff2;
            q1_ff2 <= q1_ff1;
        end
    end

    assign en0 = q0_ff2;
    assign en1 = q1_ff2;
    
    // Final Glitch-Free Mux
    assign out_clk = (clk0 & en0) | (clk1 & en1);

endmodule