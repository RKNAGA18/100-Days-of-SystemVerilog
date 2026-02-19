module gray_converter #(
  parameter WIDTH = 4
)(
  input  logic [WIDTH-1:0] bin_in,
  input  logic [WIDTH-1:0] gray_in,
  output logic [WIDTH-1:0] bin_out,
  output logic [WIDTH-1:0] gray_out
);
  // Binary to Gray is a simple shift and XOR
  assign gray_out = bin_in ^ (bin_in >> 1);

  // Gray to Binary requires a cascading XOR (done beautifully in a loop)
  always_comb begin
    bin_out[WIDTH-1] = gray_in[WIDTH-1];
    for (int i = WIDTH-2; i >= 0; i--) begin
      bin_out[i] = bin_out[i+1] ^ gray_in[i];
    end
  end
endmodule