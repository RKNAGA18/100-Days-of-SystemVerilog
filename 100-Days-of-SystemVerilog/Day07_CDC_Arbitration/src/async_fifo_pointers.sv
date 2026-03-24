module async_fifo_pointers #(parameter DEPTH_LOG2 = 4) (
    // Domain 1 (e.g., Write Domain)
    input  logic clk_1, rst_n_1,
    input  logic [DEPTH_LOG2:0] ptr_bin_1,
    
    // Domain 2 (e.g., Read Domain)
    input  logic clk_2, rst_n_2,
    output logic [DEPTH_LOG2:0] ptr_bin_sync_2
);
    logic [DEPTH_LOG2:0] ptr_gray_1;
    logic [DEPTH_LOG2:0] sync_d1, sync_d2;
    logic [DEPTH_LOG2:0] bin_converted;
    integer i;

    // 1. Convert Domain 1 Binary to Gray
    assign ptr_gray_1 = ptr_bin_1 ^ (ptr_bin_1 >> 1);

    // 2. Synchronize Gray pointer into Domain 2
    always_ff @(posedge clk_2 or negedge rst_n_2) begin
        if (!rst_n_2) begin
            sync_d1 <= '0; sync_d2 <= '0;
        end else begin
            sync_d1 <= ptr_gray_1;
            sync_d2 <= sync_d1;
        end
    end

    // 3. Convert Synchronized Gray back to Binary in Domain 2
    always_comb begin
        bin_converted[DEPTH_LOG2] = sync_d2[DEPTH_LOG2];
        for (i = DEPTH_LOG2-1; i >= 0; i = i - 1) begin
            bin_converted[i] = bin_converted[i+1] ^ sync_d2[i];
        end
    end

    assign ptr_bin_sync_2 = bin_converted;
endmodule