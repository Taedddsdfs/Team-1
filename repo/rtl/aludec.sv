
module aludec (
    input  logic [1:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic       funct7_5,   // instr[30]

    output logic [2:0] ALUControl
);

    localparam ALUCTRL_ADD = 3'b000;
    localparam ALUCTRL_SUB = 3'b001;
    localparam ALUCTRL_AND = 3'b010;
    localparam ALUCTRL_OR  = 3'b011;
    localparam ALUCTRL_SLT = 3'b101;

    always_comb begin
        unique case (ALUOp)
            2'b00: begin
                ALUControl = ALUCTRL_ADD;
            end

            2'b01: begin
                ALUControl = ALUCTRL_SUB;
            end

            2'b10: begin
                unique case (funct3)
                    3'b000: begin
                        // ADD / SUB / ADDI
                        if (funct7_5)
                            ALUControl = ALUCTRL_SUB;
                        else
                            ALUControl = ALUCTRL_ADD;
                    end

                    3'b111: begin
                        // AND 
                        ALUControl = ALUCTRL_AND;
                    end

                    3'b110: begin
                        // OR 
                        ALUControl = ALUCTRL_OR;
                    end

                    3'b010: begin
                        // SLT 
                        ALUControl = ALUCTRL_SLT;
                    end

                    default: begin
                        ALUControl = ALUCTRL_ADD;
                    end
                endcase
            end

            default: begin
                ALUControl = ALUCTRL_ADD;
            end
        endcase
    end

endmodule