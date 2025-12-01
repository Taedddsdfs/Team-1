module program_counter (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [31:0] next_pc_i,
    output logic [31:0] pc_o
);
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pc_o <= 32'b0;
        end else begin
            pc_o <= next_pc_i;
        end
    end
endmodule
