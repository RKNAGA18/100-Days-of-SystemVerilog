module crossbar_4x4 #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] in0, in1, in2, in3,
    input  logic [1:0] sel0, sel1, sel2, sel3, // Which input routes to each output
    output logic [WIDTH-1:0] out0, out1, out2, out3
);
    // Route to Output 0
    always_comb begin
        case (sel0)
            2'b00: out0 = in0;
            2'b01: out0 = in1;
            2'b10: out0 = in2;
            2'b11: out0 = in3;
        endcase
    end

    // Route to Output 1
    always_comb begin
        case (sel1)
            2'b00: out1 = in0;
            2'b01: out1 = in1;
            2'b10: out1 = in2;
            2'b11: out1 = in3;
        endcase
    end

    // Route to Output 2
    always_comb begin
        case (sel2)
            2'b00: out2 = in0;
            2'b01: out2 = in1;
            2'b10: out2 = in2;
            2'b11: out2 = in3;
        endcase
    end

    // Route to Output 3
    always_comb begin
        case (sel3)
            2'b00: out3 = in0;
            2'b01: out3 = in1;
            2'b10: out3 = in2;
            2'b11: out3 = in3;
        endcase
    end
endmodule