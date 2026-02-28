module cache_tag_lookup #(
    parameter TAG_WIDTH = 20,
    parameter INDEX_WIDTH = 8  // 256 cache lines
)(
    input  logic clk, rst_n,
    input  logic we, // Write new tag (on cache miss/fill)
    input  logic [TAG_WIDTH+INDEX_WIDTH-1:0] cpu_addr,
    input  logic flush, // Clear all valid bits
    output logic cache_hit
);
    // The Tag RAM array. Each entry stores {Valid_Bit, Tag}
    logic [TAG_WIDTH:0] tag_ram [0:(1<<INDEX_WIDTH)-1];
    
    logic [INDEX_WIDTH-1:0] index;
    logic [TAG_WIDTH-1:0] tag;
    
    assign index = cpu_addr[INDEX_WIDTH-1:0];
    assign tag   = cpu_addr[TAG_WIDTH+INDEX_WIDTH-1:INDEX_WIDTH];

    integer i;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            for (i = 0; i < (1<<INDEX_WIDTH); i = i + 1) begin
                tag_ram[i] <= '0; // Clears the valid bit
            end
        end else if (we) begin
            // On a fill, set valid bit to 1 and store the tag
            tag_ram[index] <= {1'b1, tag};
        end
    end

    // Combinational Hit Detection
    logic valid_bit;
    logic [TAG_WIDTH-1:0] stored_tag;
    
    assign valid_bit  = tag_ram[index][TAG_WIDTH];
    assign stored_tag = tag_ram[index][TAG_WIDTH-1:0];
    
    assign cache_hit = valid_bit && (stored_tag == tag);

endmodule