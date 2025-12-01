| RegisterFile | ALU |
|------|--------|
| clk | ALUop1 |
| WE3 | ALUop2 |
| AD1 | ALUctrl |
| AD2 | ALUout |
| AD3 | EQ |
| WD3 |
| RD1 |
| RD2 |
| a0 |



### Control Unit

| Signal    | Dir | Width | Description                    |
|-----------|-----|-------|--------------------------------|
| opcode    | in  | 7     | instr[6:0]                     |
| funct3    | in  | 3     | instr[14:12]                   |
| funct7    | in  | 7     | instr[31:25]                   |
| RegWrite  | out | 1     | write enable for regfile (WE3) |
| MemRead   | out | 1     | enable data memory read        |
| MemWrite  | out | 1     | enable data memory write       |
| MemToReg  | out | 1     | 1: write back from mem         |
| ALUSrc    | out | 1     | 1: ALUop2 from imm, 0: RD2     |
| Branch    | out | 1     | this is a branch instruction   |
| Jal       | out | 1     | JAL                            |
| Jalr      | out | 1     | JALR                           |
| ALUctrl   | out | 3     | to ALU                         |


### ImmGen

| Signal | Dir | Width | Description                          |
|--------|-----|-------|--------------------------------------|
| instr  | in  | 32    | full instruction word                |
| imm    | out | 32    | sign-extended immediate for ALU      |
