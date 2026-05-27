module skid_buffer #(parameter WIDTH = 32) (
    input  logic clk, rst_n,
    input  logic             s_valid,
    output logic             s_ready,
    input  logic [WIDTH-1:0] s_data,
    output logic             m_valid,
    input  logic             m_ready,
    output logic [WIDTH-1:0] m_data
);
    logic [WIDTH-1:0] skid_data;
    logic             skid_valid;
    assign s_ready = !skid_valid || m_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_valid    <= 0;
            skid_valid <= 0;
            m_data     <= 0;
            skid_data  <= 0;
        end else begin
            if (m_ready || !m_valid) begin
                m_valid <= s_valid || skid_valid;
                if (skid_valid) begin
                    m_data <= skid_data;    
                    skid_valid <= 0;
                end else if (s_valid) begin
                    m_data <= s_data;       
                end
            end else if (s_valid && s_ready) begin
                skid_valid <= 1;
                skid_data  <= s_data;        
            end
        end
    end
endmodule