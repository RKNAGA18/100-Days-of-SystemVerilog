module cpu_control_fsm (
    input  logic clk, rst_n,
    input  logic [6:0] opcode,     // Simulated RISC-V opcode
    output logic fetch_en, decode_en, exec_en, mem_en, wb_en
);
    typedef enum logic [2:0] {FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= FETCH;
        else        state <= next_state;
    end

    always_comb begin
        // Default assignments to prevent latches
        next_state = state;
        fetch_en = 0; decode_en = 0; exec_en = 0; mem_en = 0; wb_en = 0;

        case (state)
            FETCH: begin
                fetch_en = 1;
                next_state = DECODE;
            end
            DECODE: begin
                decode_en = 1;
                next_state = EXECUTE;
            end
            EXECUTE: begin
                exec_en = 1;
                // If Load/Store opcode (e.g., 0000011), go to MEMORY, else skip to WRITEBACK
                if (opcode == 7'b0000011 || opcode == 7'b0100011) next_state = MEMORY;
                else next_state = WRITEBACK;
            end
            MEMORY: begin
                mem_en = 1;
                next_state = WRITEBACK;
            end
            WRITEBACK: begin
                wb_en = 1;
                next_state = FETCH; // Loop back for next instruction
            end
            default: next_state = FETCH;
        endcase
    end
endmodule