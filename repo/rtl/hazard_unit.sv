module hazard_unit (
    // --- Fetch / Decode 阶段信号 ---
    input  logic [4:0] rs1_d, rs2_d,
    
    // --- Execute 阶段信号 ---
    input  logic [4:0] rs1_e, rs2_e, rd_e,
    input  logic       pcsrc_e,         // 分支跳转信号 (Branch Taken or Jump)
    input  logic [1:0] resultsrc_e,     // 用于检测 Load 指令 (ResultSrcE == 2'b01)
    input  logic       regwrite_e,      // 虽然 load-use 也可以只看 resultsrc，但加上这个更严谨
    
    // --- Memory 阶段信号 ---
    input  logic [4:0] rd_m,
    input  logic       regwrite_m,
    
    // --- Writeback 阶段信号 ---
    input  logic [4:0] rd_w,
    input  logic       regwrite_w,
    
    // --- 输出控制信号 ---
    output logic       stall_f,    // 冻结 PC
    output logic       stall_d,    // 冻结 IF/ID 寄存器
    output logic       flush_d,    // 清空 IF/ID (变为 NOP) - 用于跳转
    output logic       flush_e,    // 清空 ID/EX (变为 NOP) - 用于 Load-Use 或 跳转
    output logic [1:0] forward_a,  // 控制 SrcA Mux
    output logic [1:0] forward_b   // 控制 SrcB Mux
);

    logic lwStall; // Load-Use Hazard 标志位

    // =========================================================================
    // 1. Forwarding Logic (前递逻辑) - 解决 Data Hazard
    // =========================================================================
    // 00: No Forwarding (use RegFile output)
    // 01: Forward from WB Stage (ResultW)
    // 10: Forward from MEM Stage (ALUResultM)
    
    always_comb begin
        // Forward A (处理 Rs1)
        if      ((rs1_e == rd_m) && regwrite_m && (rs1_e != 0)) forward_a = 2'b10; // Priority: MEM (最新)
        else if ((rs1_e == rd_w) && regwrite_w && (rs1_e != 0)) forward_a = 2'b01; // Secondary: WB
        else                                                    forward_a = 2'b00;
        
        // Forward B (处理 Rs2)
        if      ((rs2_e == rd_m) && regwrite_m && (rs2_e != 0)) forward_b = 2'b10;
        else if ((rs2_e == rd_w) && regwrite_w && (rs2_e != 0)) forward_b = 2'b01;
        else                                                    forward_b = 2'b00;
    end

    // =========================================================================
    // 2. Stalling Logic (暂停逻辑) - 解决 Load-Use Hazard
    // =========================================================================
    // 当 EX 阶段是 Load 指令 (ResultSrcE == 01)，且 Load 的目标寄存器 (rd_e)
    // 刚好是 D 阶段指令的源寄存器 (rs1_d 或 rs2_d) 时，发生 Load-Use 冒险。
    
    always_comb begin
        // ResultSrcE == 2'b01 表示这是一个 Load 指令
        if ((resultsrc_e == 2'b01) && ((rd_e == rs1_d) || (rd_e == rs2_d)) && (rd_e != 0)) 
            lwStall = 1'b1;
        else 
            lwStall = 1'b0;
    end
    
    // =========================================================================
    // 3. Control Output Logic (输出赋值)
    // =========================================================================
    
    // Stall F & D: 如果发生 Load-Use，冻结 PC 和 IF/ID
    assign stall_f = lwStall;
    assign stall_d = lwStall;
    
    // Flush D: 如果发生跳转 (PCSrcE)，清除 Decode 阶段的指令 (因为它取错了)
    assign flush_d = pcsrc_e;
    
    // Flush E: 
    // 1. 如果 Load-Use (lwStall)，需要把由 D 阶段传下来的指令变成 NOP (Bubble)，防止它执行
    // 2. 如果发生跳转 (PCSrcE)，也需要清除当前 Decode 刚传上来的指令
    assign flush_e = lwStall || pcsrc_e;

endmodule