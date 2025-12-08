/* verilator lint_off UNUSED */
module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic trigger,
    output  logic [DATA_WIDTH-1:0] a0    
);
    // signal definition
    logic [31:0] PC, PCPlus4;         // PC and PC+4
    logic [31:0] instr;               // 
    logic [31:0] ImmExt;              // IMM after being extended
    logic [31:0] RD1, RD2;            
    logic [31:0] SrcA, SrcB;          // final input to ALU  (after Mux )
    logic [31:0] ALUResult;           // ALU calculated data
    logic [31:0] ReadData;            // Data Memory 
    logic [31:0] Result;              // write back to register
    
    // Control Unit 
    logic [1:0] PCSrc;                // PC next jump 
    logic [1:0] ResultSrc;            // (00:ALU, 01:Mem, 10:PC+4)
    logic       MemWrite;             // en of mem write
    logic [3:0] ALUControl;           
    logic       ALUSrc;               // ALU B(0:Reg, 1:Imm)
    logic       ALUSrcA;              // ALU A (0:Reg, 1:PC)
    logic [2:0] ImmSrc;               
    logic       RegWrite;             // en write to reg
    logic       EQ;                   // ALU comaparison (Zero flag)

    
    
   

    // 1. 计算 PC + 4 ( return address of JAL/JALR )
    assign PCPlus4 = PC + 32'd4;

    // 2. Program Counter
    program_counter #(.WIDTH(32)) PC_Reg (
        .clk(clk),
        .rst(rst),
        .PCSrc(PCSrc),
        .ImmOp(ImmExt),       // Branch/JAL 
        .ALUResult(ALUResult),// JALR 
        .PC(PC)
    );

    // 3. Instruction Memory
    instruction_memory #(
        .DATA_WIDTH(32),
        .BYTE_WIDTH(8)
    ) InstructionMemory (
        .addr(PC),
        .dout(instr)
    );

    // 4. Register File
    registerfile RegFile (
        .clk(clk),
        .WE3(RegWrite),
        .AD1(instr[19:15]),
        .AD2(instr[24:20]),
        .AD3(instr[11:7]),
        .WD3(Result),      //  Result Mux
        .RD1(RD1),         // output RD1，not SrcA
        .RD2(RD2),
        .a0(a0)
    );

    // 5. Control Unit
    controlunit controlunit (
        .op(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7_5(instr[30]),
        .funct7_0(instr[25]),
        .Zero(EQ),
        // Outputs
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ALUSrcA(ALUSrcA),     //  ALUSrcA
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite)
    );

    // 6. Sign Extension
    extend SignExtender (
        .instr(instr),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );


    // ALU choose Mux (Data Path )
    
    // 7. SrcA Mux ( Rs1 or PC) - for AUIPC/JAL
    mux2 #(32) srca_mux (
        .d0(RD1),       // 0: regdata
        .d1(PC),        // 1: PC (AUIPC)
        .s (ALUSrcA),
        .y (SrcA)       // ALU A
    );

    // 8. SrcB Mux (Rs2 or Imm)
    mux2 #(32) srcb_mux (
        .d0(RD2),       //0: regdata
        .d1(ImmExt),    // 1: imm
        .s (ALUSrc),
        .y (SrcB)       // ALU B 
    );

    // 9. ALU
    alu ArithmeticLogicUnit (
        .ALUop1(SrcA),       
        .ALUop2(SrcB),        
        .ALUControl(ALUControl),
        .ALUout(ALUResult),
        .EQ(EQ)
    );

    // 10. Data Memory
     data_mem DataMemory (
        .clk(clk),
        .A(ALUResult),
        .WE(MemWrite),
        .funct3(instr[14:12]),  // 【修复这里】必须把指令的 funct3 连进去！
        .WD(RD2),             
        .RD(ReadData)
    );

    // 11. 
    // 00: ALUResult, 01: ReadData, 10: PC+4
    mux3 #(32) ResultMux (
        .d0(ALUResult),
        .d1(ReadData),
        .d2(PCPlus4),
        .s (ResultSrc),
        .y (Result)
    );

endmodule
/* verilator lint_on UNUSED */


