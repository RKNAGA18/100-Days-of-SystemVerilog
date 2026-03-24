module fixed_arbiter #(parameter REQ_WIDTH = 4) (
    input  logic [REQ_WIDTH-1:0] req,
    output logic [REQ_WIDTH-1:0] grant
);
    // Two's complement trick to isolate the least significant 1-bit.
    // If req = 0110 (Devices 1 and 2 requesting)
    // -req = 1010
    // req & -req = 0010 (Grants access to Device 1 only)
    assign grant = req & ~(req - 1'b1);
endmodule