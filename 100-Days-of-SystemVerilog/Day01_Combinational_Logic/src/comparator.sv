module comparator #(
  parameter WIDTH = 32
)(
  input  logic [WIDTH-1:0] a, b,
  output logic eq, lt, gt
);
  always_comb begin
    eq = (a == b);
    lt = (a < b);
    gt = (a > b);
  end
endmodule