module async_fifo #(parameter DEPTH_LOG2 = 4, WIDTH = 8) (
    // Write Domain
    input  logic wr_clk, wr_rst_n, wr_en,
    input  logic [WIDTH-1:0] wr_data,
    output logic full,
    
    // Read Domain
    input  logic rd_clk, rd_rst_n, rd_en,
    output logic [WIDTH-1:0] rd_data,
    output logic empty
);
    localparam DEPTH = 1 << DEPTH_LOG2;
    logic [WIDTH-1:0] memory [0:DEPTH-1];

    logic [DEPTH_LOG2:0] wr_ptr_bin, wr_ptr_gray, wr_ptr_gray_next;
    logic [DEPTH_LOG2:0] rd_ptr_bin, rd_ptr_gray, rd_ptr_gray_next;
    
    logic [DEPTH_LOG2:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    logic [DEPTH_LOG2:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;

    // --- WRITE DOMAIN LOGIC ---
    always_comb begin
        wr_ptr_gray_next = (wr_ptr_bin + 1'b1) ^ ((wr_ptr_bin + 1'b1) >> 1);
    end

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin <= 0; wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            memory[wr_ptr_bin[DEPTH_LOG2-1:0]] <= wr_data;
            wr_ptr_bin <= wr_ptr_bin + 1'b1;
            wr_ptr_gray <= wr_ptr_gray_next;
        end
    end

    // Sync Read Pointer into Write Domain
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_sync1 <= 0; rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end
    
    // Full condition: MSB and 2nd MSB differ, rest match (in Gray code)
    assign full = (wr_ptr_gray == {~rd_ptr_gray_sync2[DEPTH_LOG2:DEPTH_LOG2-1], 
                                    rd_ptr_gray_sync2[DEPTH_LOG2-2:0]});

    // --- READ DOMAIN LOGIC ---
    always_comb begin
        rd_ptr_gray_next = (rd_ptr_bin + 1'b1) ^ ((rd_ptr_bin + 1'b1) >> 1);
    end

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin <= 0; rd_ptr_gray <= 0; rd_data <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= memory[rd_ptr_bin[DEPTH_LOG2-1:0]];
            rd_ptr_bin <= rd_ptr_bin + 1'b1;
            rd_ptr_gray <= rd_ptr_gray_next;
        end
    end

    // Sync Write Pointer into Read Domain
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_gray_sync1 <= 0; wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end
    
    // Empty condition: Pointers are exactly identical
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

endmodule