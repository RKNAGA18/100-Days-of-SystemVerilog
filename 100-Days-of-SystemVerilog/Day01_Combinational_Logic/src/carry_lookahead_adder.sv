module carry_lookahead_adder #(
  parameter WIDTH = 4
)(
  input  logic [WIDTH-1:0] a, b,
  input  logic             cin,
  output logic [WIDTH-1:0] sum,
  output logic             cout
);
  logic [WIDTH-1:0] p, g;
  logic [WIDTH:0]   c;

  assign c[0] = cin;
  assign cout = c[WIDTH];

  always_comb begin
    for (int i = 0; i < WIDTH; i++) begin
      p[i] = a[i] ^ b[i];
      g[i] = a[i] & b[i];
      sum[i] = p[i] ^ c[i];
      c[i+1] = g[i] | (p[i] & c[i]);
    end
  end
endmodule