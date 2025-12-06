module controlunit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    input  logic       Zero,

    output logic [1:0] PCSrc,
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
    logic branch_taken;
    assign is_beq = (op == 7'b1100011) && (funct3 == 3'b000);
    assign is_bne = (op == 7'b1100011) && (funct3 == 3'b001);
    assign branch_taken = Branch & ((is_beq & Zero) | (is_bne & ~Zero));
    always_comb begin
        if (op == 7'b1100111) begin // JALR Opcode
            PCSrc = 2'b10; 
        end else if (Jump || branch_taken) begin // JAL or Successful Branch
            PCSrc = 2'b01;
        end else begin
            PCSrc = 2'b00;
        end
    end
endmodule
