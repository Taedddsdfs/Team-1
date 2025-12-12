module top #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    // Output port for debugging/verification (exposing Register x10 / a0)
    output logic [DATA_WIDTH-1:0] a0  
);

    // --- Data Path Wires and Registers ---
    logic [31:0] PC;            // Program Counter current value
    logic [31:0] ImmExt;        // Sign-extended immediate value output from Extend unit
    logic [31:0] instr;         // Instruction read from Instruction Memory
    logic [31:0] RD2;           // Data read from Register File port 2 (Write Data for Memory)
    logic [31:0] SrcA, SrcB, ALUResult; // ALU inputs and output
    logic [31:0] ReadData;      // Data read from Data Memory
    logic [31:0] Result_pre;    // (Unused in this version, typically for forwarding/pipelining)
    logic [31:0] PCPlus4;       // PC + 4 (Sequential execution target)
    logic [31:0] Result;        // Final data to be written back to Register File (from Result Mux)
    
    // --- Control Signals ---
    logic [1:0] PCSrc;          // PC Mux selector (PC+4, Branch/Jump)
    logic [1:0] ImmSrc;         // Immediate Extender type selector (I, S, B, U, J type)
    logic [2:0] ALUControl;     // Specific ALU operation code
    logic [1:0] ResultSrc;      // Result Mux selector (ALU Result, Data Memory, PC+4)
    logic EQ;                   // Equality flag output from ALU (for Branch instructions)
    logic RegWrite, ALUSrc;     // Register File Write Enable, ALU Source B Mux selector
    logic MemWrite;             // Data Memory Write Enable

    // --- Combinational Logic ---
    // PC + 4 Adder (PC for sequential execution)
    assign PCPlus4 = PC + 32'd4;

    // --- Module Instantiations ---
    
    // 1. Program Counter (PC)
    // Stores the address of the instruction being executed
    program_counter #(.WIDTH(32)) PC_Reg (
        .clk(clk),
        .rst(rst),
        .PCSrc(PCSrc),      // Selects next PC source
        .ImmOp(ImmExt),     // Used for PC-relative branches/jumps
        .ALUResult(ALUResult), // Used for JALR (ALU calculated target)
        .PC(PC)             // Current PC output
    );

    // 2. Instruction Memory
    // Fetches the instruction based on the current PC value
    instruction_memory #(
        .DATA_WIDTH(32),
        .BYTE_WIDTH(8)
    ) InstructionMemory (
        .addr(PC),
        .dout(instr)
    );

    // 3. Register File (RF)
    // Reads source operands (RD1, RD2) and writes back result (WD3)
    registerfile RegFile (
        .clk(clk),
        .WE3(RegWrite),         // Write Enable
        .AD1(instr[19:15]),     // rs1 address
        .AD2(instr[24:20]),     // rs2 address
        .AD3(instr[11:7]),      // rd address
        .WD3(Result),           // Write Data from Result Mux
        .RD1(SrcA),             // Read Data 1 (ALU Source A)
        .RD2(RD2),              // Read Data 2 (ALU Source B / Memory Write Data)
        .a0(a0)                 // Debug/Output for x10
    );

    // 4. Control Unit
    // Decodes instruction fields to generate all necessary control signals
    controlunit controlunit (
        .op(instr[6:0]),        // Opcode
        .funct3(instr[14:12]),  // Function code 3
        .funct7_5(instr[30]),   // Function code 7 (bit 5)
        .Zero(EQ),              // ALU Zero flag for branch decision
        
        // Control Outputs
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .PCSrc(PCSrc),
        .ALUControl(ALUControl),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite)
    );

    // 5. Data Memory
    // Handles load/store operations
    data_mem DataMemory (
        .clk(clk),
        .A(ALUResult),          // Memory Address (from ALU)
        .WE(MemWrite),          // Write Enable
        .WD(RD2),               // Write Data (from Register File)
        .RD(ReadData)           // Read Data output
    );

    // 6. Sign Extension (Extend Unit)
    // Expands the immediate field of the instruction based on type
    extend SignExtender (
        .instr(instr),
        .ImmSrc(ImmSrc),        // Immediate type selector from Control Unit
        .ImmExt(ImmExt)
    );

    // 7. Result Mux (mux4)
    // Selects the final value to write back to the Register File
    // 00: ALU Result, 01: Data Memory Read Data, 10: PC + 4 (for JAL/JALR link address)
    mux4 ResultMux (
        .in0(ALUResult),
        .in1(ReadData),
        .in2(PCPlus4),
        .in3(ImmExt),           // (Used for LUI/AUIPC in some implementations)
        .sel(ResultSrc),
        .out(Result)
    );

    // 8. ALU Operand Mux (SrcB)
    // Selects the second operand for the ALU (Register Data or Immediate Value)
    mux AluOperandMux (
        .in0(RD2),              // Register data
        .in1(ImmExt),           // Immediate value
        .sel(ALUSrc),
        .out(SrcB)              // ALU Source B input
    );

    // 9. Arithmetic Logic Unit (ALU)
    // Performs arithmetic and logical operations
    alu ArithmeticLogicUnit (
        .ALUop1(SrcA),          // ALU Source A (from RegFile RD1)
        .ALUop2(SrcB),          // ALU Source B (from Mux)
        .ALUControl(ALUControl),// Specific operation code
        .ALUout(ALUResult),     // ALU Result output
        .EQ(EQ)                 // Equality flag output
    );
endmodule
