module axis_master #(parameter WIDTH = 32, PKT_LEN = 4) (
    input  logic clk, rst_n,
    input  logic start_tx, 
    output logic m_tvalid,
    input  logic m_tready,
    output logic [WIDTH-1:0] m_tdata,
    output logic m_tlast
);
    logic [7:0] count;
    logic active;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_tvalid <= 0;
            m_tdata  <= 0;
            m_tlast  <= 0;
            count    <= 0;
            active   <= 0;
        end else begin
            if (start_tx && !active) begin
                active   <= 1;
                m_tvalid <= 1;
                m_tdata  <= 32'hAAAA_0000;
                count    <= 1;
                m_tlast  <= 0;
            end else if (active && m_tready && m_tvalid) begin
                if (count == PKT_LEN - 1) begin
                    m_tlast <= 1;
                end
                
                if (count == PKT_LEN) begin
                    // Packet complete
                    active   <= 0;
                    m_tvalid <= 0;
                    m_tlast  <= 0;
                end else begin
                    m_tdata <= m_tdata + 1'b1;
                    count   <= count + 1'b1;
                end
            end
        end
    end
endmodule