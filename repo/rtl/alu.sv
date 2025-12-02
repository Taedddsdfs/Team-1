module alu #(
    parameter DATA_WIDTH = 32
)(
    input logic  [2:0]   ALUControl,
    input logic  [DATA_WIDTH-1:0]  ALUop1,
    input logic  [DATA_WIDTH-1:0]  ALUop2,
    output logic [DATA_WIDTH-1:0]  ALUout,
    output logic EQ,
);

always_comb begin
        ALUout = 32'b0;
        EQ = 0;

        case (ALUctrl)
            3'b000: ALUout = ALUop1 + ALUop2; // ADD
            3'b001: ALUout = ALUop1 - ALUop2; // SUB (Set EQ flag if ALUop1 == ALUop2)
            3'b010: ALUout = ALUop1 & ALUop2; //AND
            3'b011: ALUout = ALUop1 | ALUop2; //OR
            3'b101: ALUout = (ALUop1 < ALUop2) ? 1 : 0; // SLT (Set Less Than)
            default: ALUout = 32'b0;    
        endcase
        
        EQ = (ALUop1 == ALUop2) ? 1 : 0; 
    end
endmodule
