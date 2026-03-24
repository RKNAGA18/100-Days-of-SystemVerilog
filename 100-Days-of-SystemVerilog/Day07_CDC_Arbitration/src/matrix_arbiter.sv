module matrix_arbiter (
    input  logic clk, rst_n,
    input  logic [3:0] req,
    output logic [3:0] grant
);
    // 4x4 Priority Matrix: matrix[i][j] = 1 means i has priority over j
    logic [3:0] matrix [0:3];
    logic [3:0] wins;

    // Combinational Grant Logic
    always_comb begin
        grant = 4'b0000;
        wins[0] = req[0] & (matrix[0][1] | ~req[1]) & (matrix[0][2] | ~req[2]) & (matrix[0][3] | ~req[3]);
        wins[1] = req[1] & (matrix[1][0] | ~req[0]) & (matrix[1][2] | ~req[2]) & (matrix[1][3] | ~req[3]);
        wins[2] = req[2] & (matrix[2][0] | ~req[0]) & (matrix[2][1] | ~req[1]) & (matrix[2][3] | ~req[3]);
        wins[3] = req[3] & (matrix[3][0] | ~req[0]) & (matrix[3][1] | ~req[1]) & (matrix[3][2] | ~req[2]);

        // Break ties securely (fallback fixed priority)
        if      (wins[0]) grant[0] = 1'b1;
        else if (wins[1]) grant[1] = 1'b1;
        else if (wins[2]) grant[2] = 1'b1;
        else if (wins[3]) grant[3] = 1'b1;
    end

    // Sequential Matrix Update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize upper triangle to 1 (0 beats 1, 1 beats 2, etc.)
            matrix[0] <= 4'b1110;
            matrix[1] <= 4'b1100;
            matrix[2] <= 4'b1000;
            matrix[3] <= 4'b0000;
        end else if (grant != 0) begin
            // If a device gets the grant, it loses priority against everyone else
            if (grant[0]) begin matrix[0] <= 4'b0000; matrix[1][0] <= 1; matrix[2][0] <= 1; matrix[3][0] <= 1; end
            if (grant[1]) begin matrix[1] <= 4'b0000; matrix[0][1] <= 1; matrix[2][1] <= 1; matrix[3][1] <= 1; end
            if (grant[2]) begin matrix[2] <= 4'b0000; matrix[0][2] <= 1; matrix[1][2] <= 1; matrix[3][2] <= 1; end
            if (grant[3]) begin matrix[3] <= 4'b0000; matrix[0][3] <= 1; matrix[1][3] <= 1; matrix[2][3] <= 1; end
        end
    end
endmodule