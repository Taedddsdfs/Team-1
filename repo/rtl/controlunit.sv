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
    logic       maindec_ALUSrcA; 

    maindec u_maindec (
        .op       (op),
        .ResultSrc(ResultSrc),
        .MemWrite (MemWrite),
        .Branch   (Branch),
        .ALUSrc   (ALUSrc),
        .ALUSrcA  (maindec_ALUSrcA),  
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


    assign ALUSrcA = (op == 7'b1101111) ? 1'b1 : maindec_ALUSrcA;

endmodule

