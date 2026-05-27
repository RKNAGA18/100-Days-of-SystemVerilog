module apb_slave (
    input  logic pclk, presetn,
    input  logic psel,     
    input  logic penable,  
    input  logic pwrite,   
    input  logic [31:0] paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic pready  
);
    
    logic [31:0] reg0, reg1, reg2, reg3;
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            reg0 <= 0; reg1 <= 0; reg2 <= 0; reg3 <= 0;
        end else if (psel && penable && pwrite) begin
            case (paddr[3:2]) 
                2'b00: reg0 <= pwdata;
                2'b01: reg1 <= pwdata;
                2'b10: reg2 <= pwdata;
                2'b11: reg3 <= pwdata;
            endcase
        end
    end

    always_comb begin
        prdata = 32'h00000000;
        if (psel && !pwrite) begin
            case (paddr[3:2])
                2'b00: prdata = reg0;
                2'b01: prdata = reg1;
                2'b10: prdata = reg2;
                2'b11: prdata = reg3;
            endcase
        end
    end
    assign pready = 1'b1;
endmodule