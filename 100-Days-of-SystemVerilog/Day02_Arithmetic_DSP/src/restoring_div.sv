module restoring_div #(parameter N = 16) (
    input  logic clk, rst_n, start,
    input  logic [N-1:0] dividend, divisor,
    output logic [N-1:0] quotient, remainder,
    output logic ready
);
    logic [N-1:0] m, q;
    logic [N:0]   a;
    logic [$clog2(N):0] count;
    
    typedef enum logic [1:0] {IDLE, CALC, DONE} state_t;
    state_t state;

    // 1. COMBINATIONAL MATH (Outside the clock block)
    logic [N:0] next_a;
    logic [N-1:0] next_q;
    logic [N:0] sub_a;

    always @(*) begin
        next_a = {a[N-1:0], q[N-1]};
        next_q = {q[N-2:0], 1'b0};
        sub_a  = next_a - m;
    end

    // 2. SEQUENTIAL LOGIC (Flip-Flops)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; ready <= 0;
            quotient <= '0; remainder <= '0;
            a <= '0; m <= '0; q <= '0; count <= '0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 0;
                    if (start && divisor != 0) begin
                        m <= divisor; q <= dividend;
                        a <= '0; count <= N;
                        state <= CALC;
                    end
                end
                
                CALC: begin
                    if (count > 0) begin
                        if (sub_a[N]) begin
                            a <= next_a;     
                            q <= next_q;     
                        end else begin
                            a <= sub_a;      
                            q <= {next_q[N-1:1], 1'b1}; 
                        end
                        count <= count - 1;
                    end else begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    quotient <= q; remainder <= a[N-1:0];
                    ready <= 1; state <= IDLE;
                end
            endcase
        end
    end
endmodule