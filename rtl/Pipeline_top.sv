module top #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    output logic [DATA_WIDTH-1:0] a0 // 用于调试观测
);


    // --- Fetch Stage (F) ---
    logic [DATA_WIDTH-1:0] PCF, PCNextF, PCPlus4F;
    logic [DATA_WIDTH-1:0] InstrF;
    logic StallF; // 来自 Hazard Unit

    // --- Decode Stage (D) ---
    // Right of PRFD
    logic [DATA_WIDTH-1:0] InstrD, PCD, PCPlus4D;
    
    // Control Unit Outputs
    logic [1:0] ResultSrcD;
    logic       MemWriteD;
    logic       BranchD, JumpD; // 注意：Pipeline中PCSrc通常在E阶段决定，这里只传原始信号
    logic [3:0] ALUControlD;
    logic       ALUSrcD, ALUSrcAD; // ALUSrcA 是你 maindec 里特有的
    logic [2:0] ImmSrcD;
    logic       RegWriteD;
    logic [2:0] Funct3D; // data_mem 需要这个来决定 LB/SB/LW/SW

    // Data Signals
    logic [DATA_WIDTH-1:0] RD1D, RD2D, ImmExtD;
    logic [4:0] Rs1D, Rs2D, RdD;
    logic StallD, FlushD; // 来自 Hazard Unit

    // --- Execute Stage (E) ---
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
    logic [DATA_WIDTH-1:0] SrcAE, SrcBE; // 最终进入ALU的数据
    logic [DATA_WIDTH-1:0] ForwardAE_Val, ForwardBE_Val; // 前递后的数据
    logic [DATA_WIDTH-1:0] ALUResultE;
    logic [DATA_WIDTH-1:0] PCTargetE; // 跳转目标
    logic       ZeroE; // ALU Zero Flag
    logic       PCSrcE; // 最终决定的跳转信号
    logic       FlushE; // 来自 Hazard Unit
    logic [1:0] ForwardAE, ForwardBE; // 来自 Hazard Unit

    // --- Memory Stage (M) ---
    // Right of PREM
    logic       RegWriteM, MemWriteM;
    logic [1:0] ResultSrcM;
    logic [2:0] Funct3M;
    
    logic [DATA_WIDTH-1:0] ALUResultM, WriteDataM, PCPlus4M;
    logic [DATA_WIDTH-1:0] ReadDataM;
    logic [4:0] RdM;

    // --- Writeback Stage (W) ---
    // Right of PRMW
    logic       RegWriteW;
    logic [1:0] ResultSrcW;
    
    logic [DATA_WIDTH-1:0] ALUResultW, ReadDataW, PCPlus4W;
    logic [DATA_WIDTH-1:0] ResultW; // 最终写回寄存器的值
    logic [4:0] RdW;


    //==============================================================
    // 模块实例化 (Module Instantiations)
    //==============================================================

    // -------------------------------------------------------------
    // Fetch Stage
    // -------------------------------------------------------------
    
    // PC Mux (决定下一条指令地址)
    // 使用 mux3 甚至 mux2 都可以，这里逻辑是：如果PCSrcE有效，跳到PCTargetE，否则PC+4
    mux2 #(32) pcmux (
        .d0(PCPlus4F),
        .d1(PCTargetE),
        .s (PCSrcE), 
        .y (PCNextF)
    );

    // Program Counter (寄存器)
   program_counter pc_inst (
    .clk(clk),
    .rst(rst),
    .en (~StallF),      // 连接 Stall 信号
    .next_pc(PCNextF),  // 连接来自 mux 的 next_pc
    .pc(PCF)            // 输出当前 PC
);
    // Instruction Memory (你提供的接口)
    instruction_memory #(32, 32, 8) imem (
        .addr(PCF),
        .dout(InstrF)
    );

    // PC + 4 Adder
    assign PCPlus4F = PCF + 4;

    // -------------------------------------------------------------
    // IF/ID Pipeline Register (PRFD)
    // -------------------------------------------------------------
    // 这是一个新模块，你需要根据此接口去实现
    PRFD prfd_inst (
        .clk(clk), .rst(rst), .clr(FlushD), .en(~StallD),
        .instr_f(InstrF), .pc_f(PCF), .pcplus4_f(PCPlus4F),
        // Output
        .instr_d(InstrD), .pc_d(PCD), .pcplus4_d(PCPlus4D)
    );

    // -------------------------------------------------------------
    // Decode Stage
    // -------------------------------------------------------------
    
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD  = InstrD[11:7];
    assign Funct3D = InstrD[14:12]; // 提取funct3用于后续内存控制

    // Control Unit (你提供的接口)
    // 注意：在单周期中PCSrc是输出，但在流水线中，Branch/Jump需要传到EX阶段结合Zero判断
    // 所以这里的 Zero 输入我们暂时给 0，PCSrc 输出悬空不接，我们只取 Jump 和 Branch
    controlunit ctl (
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7_5(InstrD[30]),
    .funct7_0(InstrD[25]), 
    // .Zero(),             // [删除]
    // .PCSrc(),            // [删除]

    // Outputs
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .ALUControl(ALUControlD),
    .ALUSrc(ALUSrcD),
    .ALUSrcA(ALUSrcAD),
    .ImmSrc(ImmSrcD),
    .RegWrite(RegWriteD),

    .Branch(BranchD),       // [新增] 连接到 Top 定义的信号
    .Jump(JumpD)            // [新增] 连接到 Top 定义的信号
);
    
    // 补：因为 ControlUnit 内部逻辑没有显式输出 Branch/Jump 信号供外部流水线使用(它内部算好了PCSrc)
    // 但你的 maindec 实际上输出了 Branch 和 Jump。
    // *重要*：建议修改 controlunit 让他把 maindec 的 Branch 和 Jump 暴露出来。
    // 这里我假设你已经把 controlunit 的 maindec 的 Branch/Jump 连到了 controlunit 的输出端口。
    // 如果没有，你需要去修改 controlunit.sv 添加 output logic Branch, Jump。
    // 这里假设 controlunit 有这两个端口：
    // .Branch(BranchD), .Jump(JumpD) 
    
    // 临时逻辑：重新实例化 maindec 来获取 Branch 和 Jump (如果不想改 controlunit)
    // 为了严谨，我这里假设你修改了 controlunit 暴露了这两个信号。
    // logic BranchD, JumpD; // 已经在上面定义

    // Extend Unit (你提供的接口)
    extend ext (
        .instr(InstrD),
        .ImmSrc(ImmSrcD),
        .ImmExt(ImmExtD)
    );

    // Register File
    // 还没出现的接口，占坑。标准 32x32 寄存器堆
    reg_file rf (
        .clk(clk),
        .we3(RegWriteW),
        .a1(Rs1D), .a2(Rs2D), .a3(RdW),
        .wd3(ResultW),
        .rd1(RD1D), .rd2(RD2D)
    );

    // -------------------------------------------------------------
    // ID/EX Pipeline Register (PRDE)
    // -------------------------------------------------------------
    PRDE prde_inst (
        .clk(clk), .rst(rst), .clr(FlushE),
        // Control Inputs
        .regwrite_d(RegWriteD), .resultsrc_d(ResultSrcD), .memwrite_d(MemWriteD),
        .jump_d(JumpD), .branch_d(BranchD), .alucontrol_d(ALUControlD),
        .alusrc_d(ALUSrcD), .alusrca_d(ALUSrcAD), .funct3_d(Funct3D),
        // Data Inputs
        .rd1_d(RD1D), .rd2_d(RD2D), .pcd(PCD), .rs1_d(Rs1D), .rs2_d(Rs2D), .rd_d(RdD), .immext_d(ImmExtD), .pcplus4_d(PCPlus4D),
        
        // Outputs (到 E 阶段)
        .regwrite_e(RegWriteE), .resultsrc_e(ResultSrcE), .memwrite_e(MemWriteE),
        .jump_e(JumpE), .branch_e(BranchE), .alucontrol_e(ALUControlE),
        .alusrc_e(ALUSrcE), .alusrca_e(ALUSrcAE), .funct3_e(Funct3E),
        .rd1_e(RD1E), .rd2_e(RD2E), .pce(PCE), .rs1_e(Rs1E), .rs2_e(Rs2E), .rd_e(RdE), .immext_e(ImmExtE), .pcplus4_e(PCPlus4E)
    );

    // -------------------------------------------------------------
    // Execute Stage
    // -------------------------------------------------------------

    // Forwarding Muxes (3-to-1)
    // 处理数据冒险：从 MEM 或 WB 阶段前递数据
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

    // ALU SrcA Mux (你代码中有 ALUSrcA，用于 AUIPC/JAL 等)
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

    // ALU (你提供的接口)
    alu alu_inst (
        .ALUControl(ALUControlE),
        .ALUop1(SrcAE),
        .ALUop2(SrcBE),
        .ALUout(ALUResultE),
        .EQ(ZeroE)
    );

    // Branch Address Adder
    assign PCTargetE = PCE + ImmExtE;

    always_comb begin
        if (BranchE) begin
            case (Funct3E)
                3'b000: BranchTakenE = ZeroE;        // BEQ
                3'b001: BranchTakenE = ~ZeroE;       // BNE
                // 如果还需要支持 BLT/BGE，需要 ALU 输出更多标志位
                default: BranchTakenE = 1'b0;
            endcase
        end else begin
            BranchTakenE = 1'b0;
        end
    end

    // Pipeline Branch Logic (PCSrc Logic)
    // 只有在 BEQ/BNE 且 条件满足，或者 Jump 指令时才跳转
    // 注意：你的 controlunit 里区分了 BEQ 和 BNE，这里简化处理，假设 ALU ZeroE 反映了结果
    // 实际上你需要根据 funct3E 和 ZeroE 来判断是 BEQ 还是 BNE 还是 BLT 等。
    // 简单起见（假设 control unit 的 branch 信号已经包含了类型判断的需求）：
    assign PCSrcE = BranchTakenE | JumpE;

    // -------------------------------------------------------------
    // EX/MEM Pipeline Register (PREM)
    // -------------------------------------------------------------
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

    // -------------------------------------------------------------
    // Memory Stage
    // -------------------------------------------------------------

    // Data Memory (你提供的接口)
    // 注意：你的 data_mem 需要 funct3 来判断 LBU/SB 等
    data_mem #(32, 17, 8) dmem (
        .clk(clk),
        .WE(MemWriteM),
        .funct3(Funct3M), // 这里一定要传入 funct3
        .A(ALUResultM),
        .WD(WriteDataM),
        .RD(ReadDataM)
    );

    // -------------------------------------------------------------
    // MEM/WB Pipeline Register (PRMW)
    // -------------------------------------------------------------
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

    // -------------------------------------------------------------
    // Writeback Stage
    // -------------------------------------------------------------

    // Result Mux (选择最终写入寄存器的数据)
    // 00: ALU, 01: Mem, 10: PC+4
    mux3 #(32) result_mux (
        .d0(ALUResultW),
        .d1(ReadDataW),
        .d2(PCPlus4W),
        .s(ResultSrcW),
        .y(ResultW)
    );

    assign a0 = ResultW; // Output for debug

    // -------------------------------------------------------------
    // Hazard Unit
    // -------------------------------------------------------------
    // 尚未出现的接口，占坑。这是流水线的核心控制大脑。
    hazard_unit hu (
        .rs1_d(Rs1D), .rs2_d(Rs2D),
        .rs1_e(Rs1E), .rs2_e(Rs2E),
        .rd_e(RdE), .rd_m(RdM), .rd_w(RdW),
        .regwrite_e(RegWriteE), .regwrite_m(RegWriteM), .regwrite_w(RegWriteW),
        .resultsrc_e(ResultSrcE), // 用于检测 Load-Use Hazard
        .pcsrc_e(PCSrcE),         // 用于 Control Hazard (Branch flush)
        
        // Outputs
        .stall_f(StallF), .stall_d(StallD),
        .flush_d(FlushD), .flush_e(FlushE),
        .forward_a(ForwardAE), .forward_b(ForwardBE)
    );

endmodule