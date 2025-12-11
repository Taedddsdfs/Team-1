module aludec (
    input  logic [1:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic       funct7_5,   // instr[30]
    input  logic       funct7_0,
    input  logic       opb5,       

    output logic [3:0] ALUControl
);

    
    localparam ALUCTRL_ADD  = 4'b0000;
    localparam ALUCTRL_SUB  = 4'b0001;
    localparam ALUCTRL_AND  = 4'b0010;
    localparam ALUCTRL_OR   = 4'b0011;
    localparam ALUCTRL_XOR  = 4'b0100;
    localparam ALUCTRL_SLT  = 4'b1000; 
    localparam ALUCTRL_SLTU = 4'b1001; 
    localparam ALUCTRL_MUL  = 4'b1010; 
    localparam ALUCTRL_LUI  = 4'b1111;   //Special case for LUI

    always_comb begin
        unique case (ALUOp)
            // 00: LW/SW 
            2'b00: begin
                ALUControl = ALUCTRL_ADD;
            end

            // 01: BEQ/BNE 
            2'b01: begin
                ALUControl = ALUCTRL_SUB;
            end

            // 10: R-Type or I-Type (ADDI/SLTI )
            2'b10: begin
                unique case (funct3)
                    // ADD / SUB / mul
                    3'b000: begin
                        if (opb5) begin
                            if(funct7_5)
                            ALUControl = ALUCTRL_SUB;
                        else if (funct7_0)         
                            ALUControl = ALUCTRL_MUL;
                        else
                            ALUControl = ALUCTRL_ADD;
                    end
                    else begin 
                        ALUControl = ALUCTRL_ADD;
                    end
                    end
            

                    // SLL 
                    // 3'b001: ALUControl = ALUCTRL_SLL;

                    // SLT 
                    3'b010: begin
                        ALUControl = ALUCTRL_SLT;
                    end

                    // SLTU 
                    3'b011: begin
                        ALUControl = ALUCTRL_SLTU;
                    end

                    // XOR
                    3'b100: begin
                        ALUControl = ALUCTRL_XOR;
                    end


                    // OR
                    3'b110: begin
                        ALUControl = ALUCTRL_OR;
                    end

                    // AND
                    3'b111: begin
                        ALUControl = ALUCTRL_AND;
                    end


                    default: begin
                        ALUControl = ALUCTRL_ADD;
                    end
            
               
               
                endcase
            end
                 //Special case for LUI
                 2'b11: begin
                    ALUControl = ALUCTRL_LUI;
                end
            
                default: begin
                ALUControl = ALUCTRL_ADD;
            end
        endcase
    end

endmodule
