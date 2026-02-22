module traffic_light (
    input  logic clk, rst_n,
    output logic [2:0] lights // {Red, Yellow, Green}
);
    typedef enum logic [1:0] {GREEN, YELLOW, RED} state_t;
    state_t state, next_state;
    
    logic [7:0] timer;
    logic reset_timer;

    // State Memory & Timer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= RED; timer <= 0;
        end else begin
            state <= next_state;
            if (reset_timer) timer <= 0;
            else             timer <= timer + 1'b1;
        end
    end

    // Next State & Output Logic
    always_comb begin
        next_state = state;
        reset_timer = 0;
        lights = 3'b100; // Default Red

        case (state)
            GREEN: begin
                lights = 3'b001;
                if (timer == 8'd100) begin // Stay green for 100 ticks
                    next_state = YELLOW; reset_timer = 1;
                end
            end
            YELLOW: begin
                lights = 3'b010;
                if (timer == 8'd20) begin // Stay yellow for 20 ticks
                    next_state = RED; reset_timer = 1;
                end
            end
            RED: begin
                lights = 3'b100;
                if (timer == 8'd120) begin // Stay red for 120 ticks
                    next_state = GREEN; reset_timer = 1;
                end
            end
        endcase
    end
endmodule