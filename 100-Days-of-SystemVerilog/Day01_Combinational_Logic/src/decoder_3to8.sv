module decoder_3to8 (
  input  logic [2:0] in,
  input  logic       en,
  output logic [7:0] out
);
  always_comb begin
    if (en) out = 8'b1 << in;
    else    out = 8'b0;
  end
endmodule