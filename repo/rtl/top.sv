module top #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    output logic [DATA_WIDTH-1:0] a0 
);


    //Fetch Stage (F)
    logic [DATA_WIDTH-1:0] PCF, PCNextF, PCPlus4F;
    logic [DATA_WIDTH-1:0] InstrF;
    logic StallF; // Hazard Unit

    // Decode Stage (D)
    // Right of PRFD
    logic [DATA_WIDTH-1:0] InstrD, PCD, PCPlus4D;
    
    // Control Unit Outputs
    logic [1:0] ResultSrcD;
    logic       MemWriteD;
    logic       BranchD, JumpD; 
    logic [3:0] ALUControlD;
    logic       ALUSrcD, ALUSrcAD; // ALUSrcA is from maindec 
    logic [2:0] ImmSrcD;
    logic       RegWriteD;
    logic [2:0] Funct3D; 

    // Data Signals
    logic [DATA_WIDTH-1:0] RD1D, RD2D, ImmExtD;
    logic [4:0] Rs1D, Rs2D, RdD;
    logic StallD, FlushD; // Hazard Unit

    // Execute Stage (E)
    // Right of PRDE
    logic       RegWriteE, MemWriteE, JumpE, BranchE;
    logic [1:0] ResultSrcE;
    logic [3:0] ALUControlE;
    logic       ALUSrcE, ALUSrcAE;
    logic [2:0] Funct3E;
    logic       BranchTakenE;
    
    logic [DATA_WIDTH-1:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E;
    logic [4:0] Rs1E, Rs2E, RdE;
    
    // ALU Logic
    logic [DATA_WIDTH-1:0] SrcAE, SrcBE; 
    logic [DATA_WIDTH-1:0] ForwardAE_Val, ForwardBE_Val; 
    logic [DATA_WIDTH-1:0] ALUResultE;
    logic [DATA_WIDTH-1:0] PCTargetE; 
    logic       ZeroE; // ALU Zero Flag
    logic       PCSrcE; 
    logic       FlushE; //  Hazard Unit
    logic [1:0] ForwardAE, ForwardBE; // Hazard Unit

    // Memory Stage (M)
    // Right of PREM
    logic       RegWriteM, MemWriteM;
    logic [1:0] ResultSrcM;
    logic [2:0] Funct3M;
    
    logic [DATA_WIDTH-1:0] ALUResultM, WriteDataM, PCPlus4M;
    logic [DATA_WIDTH-1:0] ReadDataM;
    logic [4:0] RdM;

    //Writeback Stage (W)
    // Right of PRMW
    logic       RegWriteW;
    logic [1:0] ResultSrcW;
    
    logic [DATA_WIDTH-1:0] ALUResultW, ReadDataW, PCPlus4W;
    logic [DATA_WIDTH-1:0] ResultW; 
    logic [4:0] RdW;


  

   
    // Fetch Stage

    
    // PC Mux 
    mux2 #(32) pcmux (
        .d0(PCPlus4F),
        .d1(PCTargetE),
        .s (PCSrcE), 
        .y (PCNextF)
    );

    // Program Counter
   program_counter pc_inst (
    .clk(clk),
    .rst(rst),
    .en (~StallF),      
    .next_pc(PCNextF),  
    .pc(PCF)            
);
    // Instruction Memory 
    instruction_memory #(32, 32, 8) imem (
        .addr(PCF),
        .dout(InstrF)
    );

    // PC + 4 Adder
    assign PCPlus4F = PCF + 4;

    
    // IF/ID Pipeline Register (PRFD)
   
    PRFD prfd_inst (
        .clk(clk), .rst(rst), .clr(FlushD), .en(~StallD),
        .instr_f(InstrF), .pc_f(PCF), .pcplus4_f(PCPlus4F),
        // Output
        .instr_d(InstrD), .pc_d(PCD), .pcplus4_d(PCPlus4D)
    );

    // Decode Stage
   
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD  = InstrD[11:7];
    assign Funct3D = InstrD[14:12]; // fetch funct3

    // Control Unit 
    controlunit ctl (
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7_5(InstrD[30]),
    .funct7_0(InstrD[25]), 


    // Outputs
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .ALUControl(ALUControlD),
    .ALUSrc(ALUSrcD),
    .ALUSrcA(ALUSrcAD),
    .ImmSrc(ImmSrcD),
    .RegWrite(RegWriteD),

    .Branch(BranchD),       
    .Jump(JumpD)           
);
    
  
   

    // Extend Unit 
    extend ext (
        .instr(InstrD),
        .ImmSrc(ImmSrcD),
        .ImmExt(ImmExtD)
    );

    // Register File
    reg_file rf (
        .clk(clk),
        .we3(RegWriteW),
        .a1(Rs1D), .a2(Rs2D), .a3(RdW),
        .wd3(ResultW),
        .rd1(RD1D), .rd2(RD2D),
        .a0(a0)
    );

    // ID/EX Pipeline Register (PRDE)
    PRDE prde_inst (
        .clk(clk), .rst(rst), .clr(FlushE),
        // Control Inputs
        .regwrite_d(RegWriteD), .resultsrc_d(ResultSrcD), .memwrite_d(MemWriteD),
        .jump_d(JumpD), .branch_d(BranchD), .alucontrol_d(ALUControlD),
        .alusrc_d(ALUSrcD), .alusrca_d(ALUSrcAD), .funct3_d(Funct3D),
        // Data Inputs
        .rd1_d(RD1D), .rd2_d(RD2D), .pcd(PCD), .rs1_d(Rs1D), .rs2_d(Rs2D), .rd_d(RdD), .immext_d(ImmExtD), .pcplus4_d(PCPlus4D),
        
        // Outputs 
        .regwrite_e(RegWriteE), .resultsrc_e(ResultSrcE), .memwrite_e(MemWriteE),
        .jump_e(JumpE), .branch_e(BranchE), .alucontrol_e(ALUControlE),
        .alusrc_e(ALUSrcE), .alusrca_e(ALUSrcAE), .funct3_e(Funct3E),
        .rd1_e(RD1E), .rd2_e(RD2E), .pce(PCE), .rs1_e(Rs1E), .rs2_e(Rs2E), .rd_e(RdE), .immext_e(ImmExtE), .pcplus4_e(PCPlus4E)
    );

  
    // Execute Stage
    // Forwarding Muxes (3-to-1)
    mux3 #(32) forward_a_mux (
        .d0(RD1E),       // No Forwarding
        .d1(ResultW),    // Forward from WB
        .d2(ALUResultM), // Forward from MEM
        .s(ForwardAE),
        .y(ForwardAE_Val)
    );

    mux3 #(32) forward_b_mux (
        .d0(RD2E),
        .d1(ResultW),
        .d2(ALUResultM),
        .s(ForwardBE),
        .y(ForwardBE_Val)
    );

    // ALU SrcA Mux 
    // 0: Rs1 (Forwarded), 1: PC
    mux2 #(32) srca_mux (
        .d0(ForwardAE_Val),
        .d1(PCE),
        .s(ALUSrcAE),
        .y(SrcAE)
    );

    // ALU SrcB Mux (Immediate vs Register)
    // 0: Rs2 (Forwarded), 1: Imm
    mux2 #(32) srcb_mux (
        .d0(ForwardBE_Val),
        .d1(ImmExtE),
        .s(ALUSrcE),
        .y(SrcBE)
    );

    // ALU 
    alu alu_inst (
        .ALUControl(ALUControlE),
        .ALUop1(SrcAE),
        .ALUop2(SrcBE),
        .ALUout(ALUResultE),
        .EQ(ZeroE)
    );

    // Branch Address Adder
   assign PCTargetE = (BranchE) ? (PCE + ImmExtE) : (SrcAE + ImmExtE);

    always_comb begin
        if (BranchE) begin
            case (Funct3E)
                3'b000: BranchTakenE = ZeroE;        // BEQ
                3'b001: BranchTakenE = ~ZeroE;       // BNE
                default: BranchTakenE = 1'b0;
            endcase
        end else begin
            BranchTakenE = 1'b0;
        end
    end

    assign PCSrcE = BranchTakenE | JumpE;


    // EX/MEM Pipeline Register (PREM)

    PREM prem_inst (
        .clk(clk), .rst(rst),
        // Control
        .regwrite_e(RegWriteE), .resultsrc_e(ResultSrcE), .memwrite_e(MemWriteE), .funct3_e(Funct3E),
        // Data
        .aluresult_e(ALUResultE), .writedata_e(ForwardBE_Val), .rd_e(RdE), .pcplus4_e(PCPlus4E),
        
        // Outputs
        .regwrite_m(RegWriteM), .resultsrc_m(ResultSrcM), .memwrite_m(MemWriteM), .funct3_m(Funct3M),
        .aluresult_m(ALUResultM), .writedata_m(WriteDataM), .rd_m(RdM), .pcplus4_m(PCPlus4M)
    );

   
    // Memory Stage
  

    // Data Memory 
    data_mem #(32, 17, 8) dmem (
        .clk(clk),
        .WE(MemWriteM),
        .funct3(Funct3M), //  funct3
        .A(ALUResultM),
        .WD(WriteDataM),
        .RD(ReadDataM)
    );

  
    // MEM/WB Pipeline Register (PRMW)
 
    PRMW prmw_inst (
        .clk(clk), .rst(rst),
        // Control
        .regwrite_m(RegWriteM), .resultsrc_m(ResultSrcM),
        // Data
        .aluresult_m(ALUResultM), .readdata_m(ReadDataM), .rd_m(RdM), .pcplus4_m(PCPlus4M),
        
        // Outputs
        .regwrite_w(RegWriteW), .resultsrc_w(ResultSrcW),
        .aluresult_w(ALUResultW), .readdata_w(ReadDataW), .rd_w(RdW), .pcplus4_w(PCPlus4W)
    );

    
    // Writeback Stage


    // Result Mux (mux3)
    // 00: ALU, 01: Mem, 10: PC+4
    mux3 #(32) result_mux (
        .d0(ALUResultW),
        .d1(ReadDataW),
        .d2(PCPlus4W),
        .s(ResultSrcW),
        .y(ResultW)
    );

    //assign a0 = ResultW; // Output for debug

    // Hazard Unit
  
    hazard_unit hu (
        .rs1_d(Rs1D), .rs2_d(Rs2D),
        .rs1_e(Rs1E), .rs2_e(Rs2E),
        .rd_e(RdE), .rd_m(RdM), .rd_w(RdW),
        .regwrite_e(RegWriteE), .regwrite_m(RegWriteM), .regwrite_w(RegWriteW),
        .resultsrc_e(ResultSrcE), //  Load-Use Hazard
        .pcsrc_e(PCSrcE),         //  Control Hazard (Branch flush)
        
        // Outputs
        .stall_f(StallF), .stall_d(StallD),
        .flush_d(FlushD), .flush_e(FlushE),
        
    );

endmodule
