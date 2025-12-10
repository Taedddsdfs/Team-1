// maindec.sv  
module maindec (
    input  logic [6:0] op,

    output logic [1:0] ResultSrc, 
    output logic       MemWrite,
    output logic       Branch,
    output logic       ALUSrc,
    output logic       ALUSrcA,   
    output logic       RegWrite,
    output logic       Jump,
    output logic [2:0] ImmSrc,    
    output logic [1:0] ALUOp      
);
    localparam OPCODE_OP      = 7'b0110011; 
    localparam OPCODE_OP_IMM  = 7'b0010011; 
    localparam OPCODE_LOAD    = 7'b0000011; 
    localparam OPCODE_STORE   = 7'b0100011; 
    localparam OPCODE_BRANCH  = 7'b1100011; 
    localparam OPCODE_JAL     = 7'b1101111; 
    localparam OPCODE_JALR    = 7'b1100111; 
    localparam OPCODE_LUI     = 7'b0110111; 
    localparam OPCODE_AUIPC   = 7'b0010111; 

    always_comb begin
        ResultSrc = 2'b00;  
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        ALUSrc    = 1'b0;
        ALUSrcA   = 1'b0;   // <---  0 (Rs1)
        RegWrite  = 1'b0;
        Jump      = 1'b0;
        ImmSrc    = 3'b000; 
        ALUOp     = 2'b00;

        unique case (op)
            // R-type
            OPCODE_OP: begin
                RegWrite  = 1'b1;
                // ALUSrcA = 0 (Default) -> Rs1
                ImmSrc    = 3'b000; 
                ALUOp     = 2'b10;
            end

            // I-type ALU 
            OPCODE_OP_IMM: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                // ALUSrcA = 0 (Default) -> Rs1
                ImmSrc    = 3'b000; 
                ALUOp     = 2'b10;
            end

            // LOAD 
            OPCODE_LOAD: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b1;    
                ResultSrc = 2'b01;   
                ImmSrc    = 3'b000;  
                ALUOp     = 2'b00;   
            end

            // STORE 
            OPCODE_STORE: begin
                RegWrite  = 1'b0;
                MemWrite  = 1'b1;
                ALUSrc    = 1'b1;    
                ImmSrc    = 3'b001;  
                ALUOp     = 2'b00;   
            end

            // BRANCH 
            OPCODE_BRANCH: begin
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                Branch    = 1'b1;
                // ALUSrcA = 0 (Default) -> Rs1
                ImmSrc    = 3'b010;  
                ALUOp     = 2'b01;   
            end

            // JAL
            OPCODE_JAL: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                ImmSrc    = 3'b011;  
                ALUOp     = 2'b00;
                ResultSrc = 2'b10;   
            end

            // JALR
            OPCODE_JALR: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                ALUSrc    = 1'b1;    
                // ALUSrcA = 0 (Default) -> Rs1 (Rs1 + Imm)
                ImmSrc    = 3'b000;  
                ALUOp     = 2'b00;   
                ResultSrc = 2'b10;   
            end

            // LUI
            OPCODE_LUI: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                // ALUSrcA = 0 (Default) ->  ALU = 0(Rs1=x0) + Imm
                ImmSrc    = 3'b100;  
                ALUOp     = 2'b11;     //change from 00 to 11 
            end

            // AUIPC
            OPCODE_AUIPC: begin
                RegWrite  = 1'b1;
                ImmSrc    = 3'b100;  
                ALUOp     = 2'b00;   
                ALUSrc    = 1'b1;    
                
                // AUIPC choose PC！
                ALUSrcA   = 1'b1;    // A = PC
            end

            default: begin
                RegWrite  = 1'b0;
                ResultSrc = 2'b00;
                MemWrite  = 1'b0;
                Branch    = 1'b0;
                ALUSrc    = 1'b0;
                ALUSrcA   = 1'b0; // Default
                Jump      = 1'b0;
                ImmSrc    = 3'b000;
                ALUOp     = 2'b00;
            end
        endcase
    end

endmodule
