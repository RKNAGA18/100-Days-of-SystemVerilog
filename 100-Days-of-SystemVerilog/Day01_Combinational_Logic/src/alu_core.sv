import alu_pkg::*;

module alu_core #(
  parameter WIDTH = 32
)(
  input  logic [WIDTH-1:0] a, b,
  input  alu_op_e          op,
  output logic [WIDTH-1:0] result,
  output logic             zero_flag
);
  always_comb begin
    unique case (op)
      ADD: result = a + b;
      SUB: result = a - b;
      AND: result = a & b;
      OR:  result = a | b;
      XOR: result = a ^ b;
      SLL: result = a << b[4:0]; // Shift by lower 5 bits max
      SRL: result = a >> b[4:0];
      default: result = '0;
    endcase
    zero_flag = (result == '0);
  end
endmodule