module PRFD #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  clr,      // FlushD: 当发生跳转时，清除刚才取出的错误指令
    input  logic                  en,       // ~StallD: 当发生Load-Use冒险时，保持当前值不变(冻结)

    // --- 来自 Fetch 阶段的输入 ---
    input  logic [DATA_WIDTH-1:0] instr_f,  // 从指令内存取出的指令
    input  logic [DATA_WIDTH-1:0] pc_f,     // 当前指令的PC
    input  logic [DATA_WIDTH-1:0] pcplus4_f,// PC + 4

    // --- 输出到 Decode 阶段 ---
    output logic [DATA_WIDTH-1:0] instr_d,
    output logic [DATA_WIDTH-1:0] pc_d,
    output logic [DATA_WIDTH-1:0] pcplus4_d
);

    always_ff @(posedge clk) begin
        if (rst) begin
            // 复位时清零
            instr_d   <= 32'b0;
            pc_d      <= 32'b0;
            pcplus4_d <= 32'b0;
        end
        else if (clr) begin
            // 冲刷 (Flush): 比如Branch预测失败，不仅要改PC，还要把刚取进来的指令变成NOP(0)
            instr_d   <= 32'b0;
            pc_d      <= 32'b0;
            pcplus4_d <= 32'b0;
        end
        else if (en) begin
            // 使能 (Enable): 正常流动。如果 en=0 (Stall)，这里就不执行，值保持不变
            instr_d   <= instr_f;
            pc_d      <= pc_f;
            pcplus4_d <= pcplus4_f;
        end
        // hidden else: 保持原值 (Stall 状态)
    end

endmodule