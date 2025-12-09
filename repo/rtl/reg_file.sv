// [修改] 模块名改为 reg_file 以匹配 Top 中的实例化
module reg_file #(
    parameter ADDRESS_WIDTH = 5,
    parameter DATA_WIDTH = 32
) (
    input  logic                   clk,
    input  logic                   we3, // [修改] 端口名匹配 Top (WE3 -> we3)
    input  logic [ADDRESS_WIDTH-1:0] a1,  // [修改] AD1 -> a1
    input  logic [ADDRESS_WIDTH-1:0] a2,  // [修改] AD2 -> a2
    input  logic [ADDRESS_WIDTH-1:0] a3,  // [修改] AD3 -> a3
    input  logic [DATA_WIDTH-1:0]    wd3, // [修改] WD3 -> wd3
    output logic [DATA_WIDTH-1:0]    rd1, // [修改] RD1 -> rd1
    output logic [DATA_WIDTH-1:0]    rd2,  // [修改] RD2 -> rd2
    output logic [DATA_WIDTH-1:0]    a0  // 调试用，可保留
);
    logic [DATA_WIDTH-1:0] registers [2**ADDRESS_WIDTH-1:0];

    // 读逻辑 (组合逻辑) - 保持不变
    always_comb begin
        rd1 = (a1 == 5'd0) ? 32'd0 : registers[a1];
        rd2 = (a2 == 5'd0) ? 32'd0 : registers[a2];
        // a0 = registers[10];
    end

    // 写逻辑 [修改] 建议改为 negedge clk (下降沿写入)
    // 这样如果在同一个周期对同一个寄存器既读又写，前半周期写入，后半周期就能读到新值
    always_ff @(negedge clk) begin 
        if (we3 && (a3 != 5'd0)) begin
            registers[a3] <= wd3;
        end
    end
    assign a0 = registers[10];

endmodule
