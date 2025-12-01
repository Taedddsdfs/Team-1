module controlunit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    input  logic       Zero,

    output logic       PCSrc,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic [2:0] ALUControl,
    output logic       ALUSrc,
    output logic [1:0] ImmSrc,
    output logic       RegWrite
);

    logic [1:0] ALUOp;
    logic       Branch;
    logic       Jump;

    maindec u_maindec (
        .op       (op),
        .ResultSrc(ResultSrc),
        .MemWrite (MemWrite),
        .Branch   (Branch),
        .ALUSrc   (ALUSrc),
        .RegWrite (RegWrite),
        .Jump     (Jump),
        .ImmSrc   (ImmSrc),
        .ALUOp    (ALUOp)
    );

    aludec u_aludec (
        .ALUOp     (ALUOp),
        .funct3    (funct3),
        .funct7_5  (funct7_5),
        .ALUControl(ALUControl)
    );

    logic is_beq, is_bne;
    assign is_beq = (op == 7'b1100011) && (funct3 == 3'b000);
    assign is_bne = (op == 7'b1100011) && (funct3 == 3'b001);

    assign PCSrc = (Branch & ((is_beq &  Zero) | (is_bne & ~Zero)))
                 | Jump;

endmodule