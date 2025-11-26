module alu (
    input logic  [2:0]   ALUctrl,
    input logic  [31:0]  ALUop1,
    input logic  [31:0]  ALUop2,
    output logic [31:0]  ALUout,
    output logic EQ,
);

always_comb begin
        ALUout = 32'b0;
        EQ = 0;

        case (ALUctrl)
            3'b000: ALUout = ALUop1 + ALUop2; // ADD
            3'b001: begin                     // SUB
                ALUout = ALUop1 - ALUop2;
                EQ = (ALUout == 0);           // Set EQ flag if ALUop1 == ALUop2
            end
            3'b010:     ALUout = ALUop1 & ALUop2; //AND
            3'b011:     ALUout = ALUop1 | ALUop2; //OR
            3'b101:     ALUout = (ALUop1 < ALUop2) ? 1 : 0; // SLT (Set Less Than)
            default: ALUout = 32'b0;    
        endcase
        
        EQ = (ALUop1 == ALUop2) ? 1 : 0; 
    end
endmodule
