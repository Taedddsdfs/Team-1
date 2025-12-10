module alu #(
    parameter DATA_WIDTH = 32
)(
    input  logic [3:0]            ALUControl, 
    input  logic [DATA_WIDTH-1:0] ALUop1,
    input  logic [DATA_WIDTH-1:0] ALUop2,
    output logic [DATA_WIDTH-1:0] ALUout,
    output logic                  EQ
);

    always_comb begin
        ALUout = 32'b0;
        
        case (ALUControl)
            4'b0000: ALUout = ALUop1 + ALUop2;       // ADD
            4'b0001: ALUout = ALUop1 - ALUop2;       // SUB
            
            //logic
            4'b0010: ALUout = ALUop1 & ALUop2;       // AND
            4'b0011: ALUout = ALUop1 | ALUop2;       // OR
            4'b0100: ALUout = ALUop1 ^ ALUop2;       // XOR 
            
            4'b0101: ALUout = ALUop1 << ALUop2[4:0]; // SLL (Shift Left Logical)
            4'b0110: ALUout = ALUop1 >> ALUop2[4:0]; // SRL (Shift Right Logical)
            4'b0111: ALUout = $signed(ALUop1) >>> ALUop2[4:0]; // SRA (signed)
            4'b1111: ALUout = ALUop2;

            //compare
            
            // SLT:  (Signed)
            // Control Unit: 3'b010 -> 4'b1000
            4'b1000: ALUout = ($signed(ALUop1) < $signed(ALUop2)) ? 32'd1 : 32'd0; 

            // SLTU:  (Unsigned)
            // comparison Control Unit  3'b011 -> 4'b1001
            4'b1001: ALUout = (ALUop1 < ALUop2) ? 32'd1 : 32'd0; 

            4'b1010: ALUout = ALUop1 * ALUop2;       // MUL

            default: ALUout = 32'b0;
        endcase
        
        //  Zero Flag
        EQ = (ALUout == 32'b0); 
    end

endmodule
