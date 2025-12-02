module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0    
);
    logic [31:0] PC;
    logic [31:0] ImmExt;                  // Sign-extended immediate value
    logic [31:0] instr;                   // InstrctionMemory output
    logic [31:0] RD2;                     // DataMemory input
    logic [31:0] SrcA, SrcB, ALUResult;   // ALU input & output
    logic [31:0] ReadData;                // DataMemory output
    logic [31:0] Result;                  // result of output mux
    logic [1:0] PCSrc;                    // PC mux controls signal
    logic [1:0] ImmSrc;                   // 2-bit Immediate source signal
    logic [2:0] ALUControl;               // ALU control signal
    logic ResultSrc;                      // result mux control signal
    logic EQ;                             // Equality output from ALU
    logic RegWrite, ALUSrc;               // Control signals
    logic MemWrite;                       // DataMemory WE

    // Program Counter
    program_counter #(.WIDTH(32)) PC_Reg (
        .clk(clk),
        .rst(rst),
        .PCSrc(PCSrc),
        .ImmOp(ImmExt),
        .ALUResult(ALUResult),
        .PC(PC)
    );

    // Instruction Memory
    instruction_memory #(
        .ADDRESS_WIDTH(32),
        .BYTE_WIDTH(8)
    ) InstructionMemory (
        .addr(PC),
        .dout(instr)
    );

    registerfile RegFile (
        .clk(clk),
        .WE3(RegWrite),
        .AD1(instr[19:15]),
        .AD2(instr[24:20]),
        .AD3(instr[11:7]),
        .WD3(Result),
        .RD1(SrcA),
        .RD2(RD2),
        .a0(a0)
    );

    // Control Unit
    controlunit controlunit (
        .op(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7_5(instr[30]),
        .Zero(EQ),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .PCSrc(PCSrc),
        .ALUControl(ALUControl),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite)
    );

    //Data memory
    data_mem DataMemory (
        .clk(clk),
        .A(ALUResult),
        .WE(MemWrite),
        .WD(RD2),
        .RD(ReadData)
    );

    // Sign Extension
    extend SignExtender (
        .instr(instr),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    // Result Mux
    mux Result (
        .in0(ALUResult),
        .in1(ReadData),
        .sel(ResultSrc),
        .out(Result)
    );

    // SrcB
    mux AluOperandMux (
        .in0(RD2),
        .in1(ImmExt),
        .sel(ALUSrc),
        .out(SrcB)
    );

    // ALU
    alu ArithmeticLogicUnit (
        .ALUop1(SrcA),
        .ALUop2(SrcB),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .EQ(EQ)
    );
endmodule
