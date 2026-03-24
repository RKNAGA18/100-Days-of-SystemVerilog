module round_robin_arbiter #(parameter N = 4) (
    input  logic clk, rst_n,
    input  logic [N-1:0] req,
    output logic [N-1:0] grant
);
    logic [N-1:0] priority_mask;
    logic [N-1:0] masked_req;
    logic [N-1:0] unmasked_grant, masked_grant;

    // 1. Calculate unmasked grant (Standard fixed priority)
    assign unmasked_grant = req & ~(req - 1'b1);

    // 2. Calculate masked grant (Ignore devices that recently had access)
    assign masked_req = req & priority_mask;
    assign masked_grant = masked_req & ~(masked_req - 1'b1);

    // 3. Final Grant: Use masked if available, else wrap around to unmasked
    assign grant = (masked_req != 0) ? masked_grant : unmasked_grant;

    // Update the priority mask state memory
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            priority_mask <= '1; // All 1s initially
        end else if (grant != 0) begin
            // If grant is 0010, priority_mask becomes 1100 (shifting focus to higher bits)
            priority_mask <= ~((grant - 1'b1) | grant);
        end
    end
endmodule