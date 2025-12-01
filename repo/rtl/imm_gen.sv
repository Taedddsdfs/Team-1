module extend (
    input  logic [31:0] instr,
    input  logic [1:0]  ImmSrc,
    output logic [31:0] ImmExt
);

    always_comb begin
        unique case (ImmSrc)
            2'b00: begin
                // I-type: instr[31:20]
                ImmExt = {{20{instr[31]}}, instr[31:20]};
            end
            2'b01: begin
                // S-type: instr[31:25] & instr[11:7]
                ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            2'b10: begin
                // B-type: imm[12|10:5|4:1|11|0] = instr[31|30:25|11:8|7|0]
                ImmExt = {{19{instr[31]}},
                          instr[31],
                          instr[7],
                          instr[30:25],
                          instr[11:8],
                          1'b0};
            end
            2'b11: begin
                // J-type: JAL
                ImmExt = {{11{instr[31]}},
                          instr[31],
                          instr[19:12],
                          instr[20],
                          instr[30:21],
                          1'b0};
            end
            default: ImmExt = 32'b0;
        endcase
    end
endmodule