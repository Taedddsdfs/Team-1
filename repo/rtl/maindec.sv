// maindec.sv  
module maindec (
    input  logic [6:0] op,

    output logic       ResultSrc, // 0: ALU, 1: Data memory
    output logic       MemWrite,
    output logic       Branch,
    output logic       ALUSrc,
    output logic       RegWrite,
    output logic       Jump,
    output logic [1:0] ImmSrc,    // 00: I, 01: S, 10: B, 11: J/U
    output logic [1:0] ALUOp      // 00: add, 01: branch(sub), 10: use funct3/7
);

    // RV32I opcodes
    localparam OPCODE_OP      = 7'b0110011; // R-type
    localparam OPCODE_OP_IMM  = 7'b0010011; // I-type ALU
    localparam OPCODE_LOAD    = 7'b0000011; // Loads
    localparam OPCODE_STORE   = 7'b0100011; // Stores
    localparam OPCODE_BRANCH  = 7'b1100011; // Branches
    localparam OPCODE_JAL     = 7'b1101111; // JAL
    localparam OPCODE_JALR    = 7'b1100111; // JALR
    localparam OPCODE_LUI     = 7'b0110111; // LUI
    localparam OPCODE_AUIPC   = 7'b0010111; // AUIPC

    always_comb begin
        ResultSrc = 1'b0;   // ALUResult
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        ALUSrc    = 1'b0;
        RegWrite  = 1'b0;
        Jump      = 1'b0;
        ImmSrc    = 2'b00;
        ALUOp     = 2'b00;

        unique case (op)
            // R-type: ADD/SUB/AND/OR/SLT...
            OPCODE_OP: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b0;
                // ResultSrc = 0 (ALU)
                ImmSrc    = 2'b00;
                ALUOp     = 2'b10;
            end

            // I-type ALU (ADDI/ANDI/ORI/SLTI...)
            OPCODE_OP_IMM: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                // ResultSrc = 0 (ALU)
                ImmSrc    = 2'b00;   // I-type
                ALUOp     = 2'b10;
            end

            // LOAD (LW/LBU...)
            OPCODE_LOAD: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b1;    // base + imm
                ResultSrc = 1'b1;    // from data memory
                ImmSrc    = 2'b00;   // I-type
                ALUOp     = 2'b00;   // ADD address
            end

            // STORE (SW/SB...)
            OPCODE_STORE: begin
                RegWrite  = 1'b0;
                MemWrite  = 1'b1;
                ALUSrc    = 1'b1;    // base + imm
                ImmSrc    = 2'b01;   // S-type
                ALUOp     = 2'b00;   // ADD
            end

            // BRANCH (BEQ/BNE...)
            OPCODE_BRANCH: begin
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                Branch    = 1'b1;
                ALUSrc    = 1'b0;
                ImmSrc    = 2'b10;   // B-type
                ALUOp     = 2'b01;   // SUB for compare
            end

            // JAL: rd = PC+4, PC <- PC + imm
            OPCODE_JAL: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                ImmSrc    = 2'b11;   // J-type
                ALUOp     = 2'b00;
            end

            // JALR: rd = PC+4, PC <- rs1 + imm
            OPCODE_JALR: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                ALUSrc    = 1'b1;    // rs1 + imm
                ImmSrc    = 2'b00;   // I-type
                ALUOp     = 2'b00;   // ADD
            end

            // LUI
            OPCODE_LUI: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b11;   // U-type
                ALUOp     = 2'b00;
            end

            // AUIPC
            OPCODE_AUIPC: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b11;   // U-type
                ALUOp     = 2'b00;   // ADD (PC + imm)
            end

            default: begin
            end
        endcase
    end

endmodule
