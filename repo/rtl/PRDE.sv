module PRDE #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  clr,      // FlushE: 用于Branch跳转时清除D阶段的指令

    // --- 控制信号输入 (来自 Control Unit) ---
    input  logic                  regwrite_d,   // 写寄存器堆
    input  logic [1:0]            resultsrc_d,  // 结果来源 (ALU/Mem/PC)
    input  logic                  memwrite_d,   // 写内存
    input  logic                  jump_d,       // JAL/JALR
    input  logic                  branch_d,     // BEQ/BNE
    input  logic [3:0]            alucontrol_d, // ALU 操作码
    input  logic                  alusrc_d,     // ALU SrcB 选择 (Reg/Imm)
    input  logic                  alusrca_d,    // ALU SrcA 选择 (Reg/PC) - 你的maindec特有 [cite: 18]
    input  logic [2:0]            funct3_d,     // data_mem 需要用来做 SB/LB 判断 

    // --- 数据信号输入 (来自 Register File 和 Extend) ---
    input  logic [DATA_WIDTH-1:0] rd1_d,        // 寄存器读数据 1
    input  logic [DATA_WIDTH-1:0] rd2_d,        // 寄存器读数据 2
    input  logic [DATA_WIDTH-1:0] pcd,          // 当前 PC
    input  logic [4:0]            rs1_d,        // 源寄存器 1 地址 (用于 Hazard 检测)
    input  logic [4:0]            rs2_d,        // 源寄存器 2 地址 (用于 Hazard 检测)
    input  logic [4:0]            rd_d,         // 目标寄存器地址
    input  logic [DATA_WIDTH-1:0] immext_d,     // 立即数扩展结果
    input  logic [DATA_WIDTH-1:0] pcplus4_d,

    // --- 输出到 Execute 阶段 (加 _e 后缀) ---
    output logic                  regwrite_e,
    output logic [1:0]            resultsrc_e,
    output logic                  memwrite_e,
    output logic                  jump_e,
    output logic                  branch_e,
    output logic [3:0]            alucontrol_e,
    output logic                  alusrc_e,
    output logic                  alusrca_e,
    output logic [2:0]            funct3_e,

    output logic [DATA_WIDTH-1:0] rd1_e,
    output logic [DATA_WIDTH-1:0] rd2_e,
    output logic [DATA_WIDTH-1:0] pce,
    output logic [4:0]            rs1_e,
    output logic [4:0]            rs2_e,
    output logic [4:0]            rd_e,
    output logic [DATA_WIDTH-1:0] immext_e,
    output logic [DATA_WIDTH-1:0] pcplus4_e
);

    always_ff @(posedge clk) begin
        if (rst || clr) begin
            // 发生 Flush 时，控制信号必须清零 (变成 NOP)，防止错误的写入内存或寄存器
            regwrite_e   <= 1'b0;
            resultsrc_e  <= 2'b0;
            memwrite_e   <= 1'b0;
            jump_e       <= 1'b0;
            branch_e     <= 1'b0;
            alucontrol_e <= 4'b0;
            alusrc_e     <= 1'b0;
            alusrca_e    <= 1'b0;
            funct3_e     <= 3'b0;
            
            // 数据信号清零 (其实数据不清零也可以，只要控制信号是0就不会有副作用)
            rd1_e        <= '0;
            rd2_e        <= '0;
            pce          <= '0;
            rs1_e        <= '0;
            rs2_e        <= '0;
            rd_e         <= '0;
            immext_e     <= '0;
            pcplus4_e    <= '0;
        end
        else begin
            // 正常传递
            regwrite_e   <= regwrite_d;
            resultsrc_e  <= resultsrc_d;
            memwrite_e   <= memwrite_d;
            jump_e       <= jump_d;
            branch_e     <= branch_d;
            alucontrol_e <= alucontrol_d;
            alusrc_e     <= alusrc_d;
            alusrca_e    <= alusrca_d;
            funct3_e     <= funct3_d;

            rd1_e        <= rd1_d;
            rd2_e        <= rd2_d;
            pce          <= pcd;
            rs1_e        <= rs1_d;
            rs2_e        <= rs2_d;
            rd_e         <= rd_d;
            immext_e     <= immext_d;
            pcplus4_e    <= pcplus4_d;
        end
    end

endmodule