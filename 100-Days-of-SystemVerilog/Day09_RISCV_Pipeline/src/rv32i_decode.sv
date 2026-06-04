module rv32i_decode (
    input  logic [31:0] instr,
    output logic [4:0]  rs1, rs2, rd,
    output logic [31:0] imm_ext,
    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic        alu_src,  
    output logic [1:0]  alu_op,    
    output logic        branch
);
    logic [6:0] opcode;
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];

    always_comb begin
        case (opcode)
            7'b0010011: imm_ext = {{20{instr[31]}}, instr[31:20]}; 
            7'b0100011: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011: imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            default:    imm_ext = 32'h0;
        endcase
    end

    always_comb begin
        reg_write = 0; mem_read = 0; mem_write = 0; 
        alu_src = 0; alu_op = 2'b00; branch = 0;

        case (opcode)
            7'b0110011: begin
                reg_write = 1; alu_op = 2'b10;
            end
            7'b0010011: begin 
                reg_write = 1; alu_src = 1; alu_op = 2'b00;
            end
            7'b0000011: begin 
                reg_write = 1; alu_src = 1; mem_read = 1; alu_op = 2'b00;
            end
            7'b0100011: begin 
                alu_src = 1; mem_write = 1; alu_op = 2'b00;
            end
            7'b1100011: begin 
                branch = 1; alu_op = 2'b01; 
            end
        endcase
    end
endmodule
