module toggle_sync (
    input  logic clk_src, rst_n_src, 
    input  logic pulse_in,          // Fast domain pulse
    
    input  logic clk_dest, rst_n_dest,
    output logic pulse_out          // Slow domain pulse
);
    logic toggle_src;
    logic sync_d1, sync_d2, sync_d3;

    // 1. Source Domain: Toggle a register on every incoming pulse
    always_ff @(posedge clk_src or negedge rst_n_src) begin
        if (!rst_n_src) toggle_src <= 1'b0;
        else if (pulse_in) toggle_src <= ~toggle_src;
    end

    // 2. Destination Domain: 2-FF sync followed by edge detection
    always_ff @(posedge clk_dest or negedge rst_n_dest) begin
        if (!rst_n_dest) begin
            sync_d1 <= 1'b0;
            sync_d2 <= 1'b0;
            sync_d3 <= 1'b0; // 3rd flop for edge detection
        end else begin
            sync_d1 <= toggle_src;
            sync_d2 <= sync_d1;
            sync_d3 <= sync_d2;
        end
    end

    // Pulse is generated when the synchronized toggle signal changes state
    assign pulse_out = sync_d2 ^ sync_d3; 
endmodule
