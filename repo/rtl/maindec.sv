// maindec.sv
module maindec (
    input  logic [6:0] op,

    output logic       ResultSrc, 
    output logic       MemWrite,
    output logic       Branch,
    output logic       ALUSrc,
    output logic       RegWrite,
    output logic       Jump,
    output logic [1:0] ImmSrc,    // 00: I, 01: S, 10: B, 11: J (or U later)
    output logic [1:0] ALUOp      // 00: add, 01: branch(sub), 10: use funct3/7
);

    // RV32I opcodes we care
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
        ResultSrc = 2'b00; // ALU result
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        ALUSrc    = 1'b0;
        RegWrite  = 1'b0;
        Jump      = 1'b0;
        ImmSrc    = 2'b00; // I-type
        ALUOp     = 2'b00; // add

        unique case (op)
            OPCODE_OP: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b0;       // rs2
                ResultSrc = 2'b00;      // ALU
                ImmSrc    = 2'b00;      // don't care
                ALUOp     = 2'b10;      // use funct3/funct7
            end

            // I-type ALU 
            OPCODE_OP_IMM: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;       // immediate
                ResultSrc = 2'b00;      // ALU
                ImmSrc    = 2'b00;      // I-type imm
                ALUOp     = 2'b10;      // use funct3
            end

            // LOAD: LW 
            OPCODE_LOAD: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b1;       // base + imm
                ResultSrc = 2'b01;      // from data memory
                ImmSrc    = 2'b00;      // I-type imm
                ALUOp     = 2'b00;      // ADD for address
            end

            // STORE: SW
            OPCODE_STORE: begin
                RegWrite  = 1'b0;
                MemWrite  = 1'b1;
                ALUSrc    = 1'b1;       // base + imm
                ResultSrc = 2'b00;      // don't care
                ImmSrc    = 2'b01;      // S-type imm
                ALUOp     = 2'b00;      // ADD
            end

            // BRANCH: BEQ/BNE/...
            OPCODE_BRANCH: begin
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                Branch    = 1'b1;
                ALUSrc    = 1'b0;       // compare rs1, rs2
                ResultSrc = 2'b00;      // don't care
                ImmSrc    = 2'b10;      // B-type imm
                ALUOp     = 2'b01;      // SUB (for compare)
            end

            // JAL: PC-relative jump, rd = PC+4
            OPCODE_JAL: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;       // target from PC and ImmExt in PC logic
                ResultSrc = 2'b10;      // write back PC+4
                ImmSrc    = 2'b11;      // J-type imm
                ALUOp     = 2'b00;      // don't care
            end

            // JALR: rs1 + imm, rd = PC+4
            OPCODE_JALR: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b1;    
                ResultSrc = 2'b10;      // PC+4
                ImmSrc    = 2'b00;     
                ALUOp     = 2'b00;      // ADD
            end

            // LUI: rd = imm << 12 
            OPCODE_LUI: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                ResultSrc = 2'b00;      
                ImmSrc    = 2'b11;      
                ALUOp     = 2'b00;
            end

            // AUIPC: rd = PC + imm
            OPCODE_AUIPC: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;       
                ResultSrc = 2'b00;      
                ImmSrc    = 2'b11;      
                ALUOp     = 2'b00;     
            end

            default: begin
            end
        endcase
    end

endmodule
