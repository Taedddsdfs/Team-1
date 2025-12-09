module program_counter #(
    parameter WIDTH = 32
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             en,      // [新增] Enable 信号，连接到 ~StallF
    input  logic [WIDTH-1:0] next_pc, // [修改] 直接输入下一条地址，逻辑在外部处理
    output logic [WIDTH-1:0] pc
);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'b0; // [修改] 通常复位为 0，原代码 0xBFC00000 也可以，看需求
        end 
        else if (en) begin // [新增] 只有在不暂停(Stall=0)时才更新 PC
            pc <= next_pc;
        end
        // [注释] 删除了原本内部的 case(PCSrc) 逻辑，移交给了 Top 的 mux
    end

endmodule
