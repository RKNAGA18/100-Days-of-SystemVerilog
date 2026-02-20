module fp_adder_align (
    input  logic [15:0] a, b, // IEEE 754 Half Precision
    output logic [10:0] aligned_mantissa_a, aligned_mantissa_b,
    output logic [4:0]  common_exp
);
    logic [4:0] exp_a, exp_b;
    logic [4:0] exp_diff;
    
    always @(*) begin
        exp_a = a[14:10]; exp_b = b[14:10];
        // Implied '1' bit for normalized numbers
        aligned_mantissa_a = {1'b1, a[9:0]}; 
        aligned_mantissa_b = {1'b1, b[9:0]};
        
        if (exp_a > exp_b) begin
            exp_diff = exp_a - exp_b;
            aligned_mantissa_b = aligned_mantissa_b >> exp_diff;
            common_exp = exp_a;
        end else begin
            exp_diff = exp_b - exp_a;
            aligned_mantissa_a = aligned_mantissa_a >> exp_diff;
            common_exp = exp_b;
        end
    end
endmodule