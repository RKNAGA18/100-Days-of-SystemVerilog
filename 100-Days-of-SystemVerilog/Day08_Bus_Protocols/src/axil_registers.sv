module axil_registers (
    input  logic clk, rst_n,
    input  logic [31:0] s_axi_awaddr,
    input  logic s_axi_awvalid,
    output logic s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic s_axi_wvalid,
    output logic s_axi_wready,
    output logic [1:0] s_axi_bresp,
    output logic s_axi_bvalid,
    input  logic s_axi_bready
);
    logic [31:0] control_reg;

    assign s_axi_awready = 1'b1;
    assign s_axi_wready  = 1'b1;
    assign s_axi_bresp   = 2'b00;

    logic write_happening;
    assign write_happening = s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            control_reg <= 0;
            s_axi_bvalid <= 0;
        end else begin
            if (write_happening) begin
                control_reg <= s_axi_wdata; 
                s_axi_bvalid <= 1;          
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 0;  
            end
        end
    end
endmodule