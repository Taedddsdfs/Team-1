module PRFD #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  clr,      
    input  logic                  en,       

    input  logic [DATA_WIDTH-1:0] instr_f,  
    input  logic [DATA_WIDTH-1:0] pc_f,     
    input  logic [DATA_WIDTH-1:0] pcplus4_f,

    output logic [DATA_WIDTH-1:0] instr_d,
    output logic [DATA_WIDTH-1:0] pc_d,
    output logic [DATA_WIDTH-1:0] pcplus4_d
);

    always_ff @(posedge clk) begin
        if (rst) begin
            instr_d   <= 32'b0;
            pc_d      <= 32'b0;
            pcplus4_d <= 32'b0;
        end
        else if (clr) begin
            instr_d   <= 32'b0;
            pc_d      <= 32'b0;
            pcplus4_d <= 32'b0;
        end
        else if (en) begin
            instr_d   <= instr_f;
            pc_d      <= pc_f;
            pcplus4_d <= pcplus4_f;
        end
    end


endmodule
