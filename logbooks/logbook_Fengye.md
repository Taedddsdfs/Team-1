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


Then it gets the output called ALUout.

Also, the ALU has to compare the value of two operands to see if they are equal and set the EQ signal:
```
EQ = (ALUop1 == ALUop2) ? 1 : 0;
```

---
### Register File
The register file is mainly used for reading and writing data to registers.

In the register file, we have a total of 32 registers, each store a 32-bit value, defined as follow:
```
parameter ADDRESS_WIDTH = 5,
              DATA_WIDTH = 32

logic [DATA_WIDTH-1:0] registers [2**ADDRESS_WIDTH-1:0];
```

Two important notices are:
1. register[0](x0) cannot be modified, stay constant 0:
```
assign registers[0] = 0;
```

2. a0 takes the value of register[10]:
```
a0 = registers[10];
```

