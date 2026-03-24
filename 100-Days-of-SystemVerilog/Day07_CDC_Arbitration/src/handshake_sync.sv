module handshake_sync #(parameter WIDTH = 8) (
    input  logic clk_src, rst_n_src,
    input  logic req_in,
    input  logic [WIDTH-1:0] data_in,
    output logic ready_src,         // Tells source we are ready for new data
    
    input  logic clk_dest, rst_n_dest,
    input  logic ack_dest,          // Destination says it read the data
    output logic req_dest,
    output logic [WIDTH-1:0] data_out
);
    logic req_sync1, req_sync2;
    logic ack_sync1, ack_sync2;
    
    // Source Domain: Synchronize ACK back from Destination
    always_ff @(posedge clk_src or negedge rst_n_src) begin
        if (!rst_n_src) begin
            ack_sync1 <= 0; ack_sync2 <= 0;
        end else begin
            ack_sync1 <= ack_dest; ack_sync2 <= ack_sync1;
        end
    end
    
    // Source is ready when the handshake is fully complete (req_in and ack_sync2 are both 0)
    assign ready_src = ~req_in & ~ack_sync2;

    // Destination Domain: Synchronize REQ from Source
    always_ff @(posedge clk_dest or negedge rst_n_dest) begin
        if (!rst_n_dest) begin
            req_sync1 <= 0; req_sync2 <= 0; data_out <= 0;
        end else begin
            req_sync1 <= req_in; req_sync2 <= req_sync1;
            
            // Latch data when REQ safely arrives
            if (req_sync2 && !ack_dest) begin
                data_out <= data_in;
            end
        end
    end
    
    assign req_dest = req_sync2;
endmodule