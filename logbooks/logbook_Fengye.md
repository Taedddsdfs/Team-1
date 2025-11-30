RISC-V Design Coursework
---

Fengye TIAN

CID:  02575253

---

### ALU
The ALU unit takes two operands and ALUctrl as inputs to make arithmetic operations to them, according to the table below:
| ALUCtrl | Command |
|------|--------|
| 000 | add |
| 001 | subtract |
| 010 | and |
| 011 | or|
| 101 | set less than |

This can be achieved by the case statement:
```
case (ALUctrl)
            3'b000: ALUout = ALUop1 + ALUop2; // ADD
            3'b001: ALUout = ALUop1 - ALUop2; // SUB (Set EQ flag if ALUop1 == ALUop2)
            3'b010: ALUout = ALUop1 & ALUop2; //AND
            3'b011: ALUout = ALUop1 | ALUop2; //OR
            3'b101: ALUout = (ALUop1 < ALUop2) ? 1 : 0; // SLT (Set Less Than)
            default: ALUout = 32'b0;    
        endcase
```
