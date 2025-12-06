RISC-V Design Coursework
---

Fengye TIAN

CID:  02575253

---

### ALU
<img width="347" height="273" alt="截屏2025-11-30 20 08 33" src="https://github.com/user-attachments/assets/cb21ff2e-cd1f-4ca9-bd3f-1103e876b551" />

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
<img width="218" height="405" alt="截屏2025-11-30 20 09 00" src="https://github.com/user-attachments/assets/88bb6a26-5817-437d-8240-f545a43357a2" />

The register file is mainly used for reading and writing data to registers.

In the register file, we have a total of 32 registers, each store a 32-bit value, defined as follow:
```
logic [DATA_WIDTH-1:0] registers [2**ADDRESS_WIDTH-1:0];
```

Two important notices are:
1. register[0] (x0) cannot be modified, stay constant 0:
```
assign registers[0] = 0;
```

2. a0 takes the value of register[10]:
```
a0 = registers[10];
```

RD1 and RD2 get values from register file with AD1 and AD2, as follow:
```
RD1 = registers[AD1];
RD2 = registers[AD2];
```

When the write_enable signal is high, data WD3 should be written to register[AD3]:
```
always_ff @(posedge clk)
    if (WE3 && (AD3 != 5'd0))       registers[AD3] <= WD3;
```

CAREFUL!! x0 must not be written!

Specification:
| Item | WIDTH |
|------|--------|
| Address | 5 bits |
| Data | 32 bits |

---
### Data Memory
<img width="290" height="76" alt="截屏2025-11-30 20 22 26" src="https://github.com/user-attachments/assets/98c563fa-e08e-4e6b-a166-2177f2d372d4" />

The data memory is one of the two memories in the RISC-V CPU. It is in charge of storing data and loading data back to registers. Given by project brief, the mapping can be defined as follow:
```
logic [BYTE_WIDTH-1:0] mem [2**ADDRESS_WIDTH-1:0]; // Data memory from 0x00010000 to 0x0001FFFF
logic [ADDRESS_WIDTH-1:0] addr;
```

In this case, since the address we actually used are 0x00001000 and 0x00001001, the memory space width is defined as:
