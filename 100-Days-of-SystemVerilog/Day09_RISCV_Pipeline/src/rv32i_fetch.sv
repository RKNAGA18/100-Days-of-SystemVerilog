module rv32i_fetch (
    input  logic        clk, rst_n,
    input  logic        stall,   
    input  logic        branch_take,
    input  logic [31:0] branch_addr,
    output logic [31:0] pc
);
    logic [31:0] next_pc;

    always_comb begin
        if (branch_take) begin
            next_pc = branch_addr;     
        end else begin
            next_pc = pc + 32'd4;     
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;      
        end else if (!stall) begin
            pc <= next_pc;             
        end
    end
endmodule
