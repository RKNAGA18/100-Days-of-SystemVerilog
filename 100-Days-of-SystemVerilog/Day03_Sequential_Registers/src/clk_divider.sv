module clk_div_even #(parameter DIV = 4) (
    input  logic clk, rst_n,
    output logic clk_out
);
    logic [$clog2(DIV)-1:0] count;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0; clk_out <= 0;
        end else if (count == (DIV/2) - 1) begin
            count <= '0; clk_out <= ~clk_out;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule

// Divide by 3 with 50% duty cycle
module clk_div_odd_3 (
    input  logic clk, rst_n,
    output logic clk_out
);
    logic [1:0] count;
    logic t1, t2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin count <= 0; t1 <= 0; end
        else begin
            if (count == 2) count <= 0;
            else count <= count + 1;
            
            if (count < 1) t1 <= 1;
            else t1 <= 0;
        end
    end

    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) t2 <= 0;
        else t2 <= t1;
    end

    assign clk_out = t1 | t2; // OR gate combines pos/neg edges
endmodule