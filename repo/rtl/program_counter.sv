module program_counter #(
    parameter WIDTH = 32
)(
    input  logic             clk,
    input  logic             rst,
    
    // three states
    input  logic [1:0]       PCSrc,      
    
    // JAL (PC + Imm)
    input  logic [31:0]      ImmOp,      
    
    // JALR 
    input  logic [31:0]      ALUResult,  
    
    output logic [WIDTH-1:0] PC
);

    always_ff @(posedge clk) begin
        if (rst) begin
            PC <= 32'h0;
        end else begin
            case (PCSrc)
                2'b00: PC <= PC + 32'd4;      // Normal (Next Instr)
                2'b01: PC <= PC + ImmOp;      // Branch / JAL (PC + Imm)
                2'b10: PC <= ALUResult;       // JALR (Rs1 + Imm) 
                default: PC <= PC + 32'd4;    
            endcase
        end
    end

endmodule
