module controlunit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    input  logic       funct7_0,
    
    output logic [1:0] ResultSrc, 
    output logic       MemWrite,
    output logic [3:0] ALUControl,
    output logic       ALUSrc,
    output logic       ALUSrcA,   
    output logic [2:0] ImmSrc,    
    output logic       RegWrite,
    output logic       Branch,    
    output logic       Jump       
);
    logic [1:0] ALUOp;
    logic       maindec_ALUSrcA; // 临时信号

    maindec u_maindec (
        .op       (op),
        .ResultSrc(ResultSrc),
        .MemWrite (MemWrite),
        .Branch   (Branch),
        .ALUSrc   (ALUSrc),
        .ALUSrcA  (maindec_ALUSrcA),  // 接到临时信号
        .RegWrite (RegWrite),
        .Jump     (Jump),
        .ImmSrc   (ImmSrc),
        .ALUOp    (ALUOp)
    );

    aludec u_aludec (
        .ALUOp     (ALUOp),
        .funct3    (funct3),
        .funct7_5  (funct7_5),
        .funct7_0  (funct7_0),
        .opb5      (op[5]),    
        .ALUControl(ALUControl)
    );

    
    // JAL (Opcode 1101111) 需要 PC 作为基址。
    // 如果 maindec 没有为 JAL 设置 ALUSrcA=1，在这里强制修正。
    // JALR (Opcode 1100111) 使用 Rs1 (ALUSrcA=0)，保持默认。
    // AUIPC (0010111) 也需要 PC。
    assign ALUSrcA = (op == 7'b1101111) ? 1'b1 : maindec_ALUSrcA;

endmodule

