module d_ff (
    input  logic clk, rst_n, d,
    output logic q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 1'b0;
        else        q <= d;
    end
endmodule

module t_ff (
    input  logic clk, rst_n, t,
    output logic q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 1'b0;
        else if (t) q <= ~q; // Toggle if T is 1
    end
endmodule

module jk_ff (
    input  logic clk, rst_n, j, k,
    output logic q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 1'b0;
        else begin
            case ({j, k})
                2'b00: q <= q;       // Hold
                2'b01: q <= 1'b0;    // Reset
                2'b10: q <= 1'b1;    // Set
                2'b11: q <= ~q;      // Toggle
            endcase
        end
    end
endmodule