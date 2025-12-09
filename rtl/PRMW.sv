module PRMW #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,

    // --- 控制信号输入 ---
    // 到这一步，MemWrite 已经用完了，不需要传了
    input  logic                  regwrite_m,
    input  logic [1:0]            resultsrc_m,

    // --- 数据信号输入 ---
    input  logic [DATA_WIDTH-1:0] aluresult_m,
    input  logic [DATA_WIDTH-1:0] readdata_m,  // 从内存读出的数据 (Load指令用)
    input  logic [4:0]            rd_m,        // 最终要写哪个寄存器
    input  logic [DATA_WIDTH-1:0] pcplus4_m,

    // --- 输出到 Writeback 阶段 (加 _w 后缀) ---
    output logic                  regwrite_w,
    output logic [1:0]            resultsrc_w,

    output logic [DATA_WIDTH-1:0] aluresult_w,
    output logic [DATA_WIDTH-1:0] readdata_w,
    output logic [4:0]            rd_w,
    output logic [DATA_WIDTH-1:0] pcplus4_w
);

    always_ff @(posedge clk) begin
        if (rst) begin
            regwrite_w   <= 1'b0;
            resultsrc_w  <= 2'b0;
            
            aluresult_w  <= '0;
            readdata_w   <= '0;
            rd_w         <= '0;
            pcplus4_w    <= '0;
        end
        else begin
            regwrite_w   <= regwrite_m;
            resultsrc_w  <= resultsrc_m;

            aluresult_w  <= aluresult_m;
            readdata_w   <= readdata_m;
            rd_w         <= rd_m;
            pcplus4_w    <= pcplus4_m;
        end
    end

endmodule