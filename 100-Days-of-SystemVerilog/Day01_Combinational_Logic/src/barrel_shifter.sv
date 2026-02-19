module barrel_shifter #(
  parameter WIDTH = 32,
  parameter SHIFT_BITS = $clog2(WIDTH)
)(
  input  logic [WIDTH-1:0]      data_in,
  input  logic [SHIFT_BITS-1:0] shift_amt,
  input  logic                  dir_left, // 1 for Left, 0 for Right
  output logic [WIDTH-1:0]      data_out
);
  always_comb begin
    if (dir_left) data_out = data_in << shift_amt;
    else          data_out = data_in >> shift_amt;
  end
endmodule