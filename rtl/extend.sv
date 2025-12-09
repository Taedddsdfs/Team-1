/* verilator lint_off UNUSED */
module extend (
    input  logic [31:0] instr,
    input  logic [2:0]  ImmSrc,  
    output logic [31:0] ImmExt
);

    always_comb begin
        unique case (ImmSrc)
            // I-type (ADDI, LW, JALR)
            3'b000: begin
                ImmExt = {{20{instr[31]}}, instr[31:20]};
            end
            
            // S-type (SW)
            3'b001: begin
                ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            
            // B-type (BEQ)
            3'b010: begin
                ImmExt = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end
            
            // J-type (JAL)
            3'b011: begin
                ImmExt = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            // U-type (LUI, AUIPC)  
            3'b100: begin
                // U-Type 20MSB
                ImmExt = {instr[31:12], 12'b0}; 
            end

            default: ImmExt = 32'b0;
        endcase
    end
endmodule
/* verilator lint_on UNUSED */

