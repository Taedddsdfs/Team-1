RISC-V Design Coursework
---

Fengye TIAN

CID:  02575253

---

## Single-cycle

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
| Item | WIDTH |
|------|--------|
| Address | 16 bits |
| Data | 32 bits |
| BYTE | 8 bits |

that is, having an array with addresses ranging from 0 to 2^16-1, with a data width of 32 bits.

address is taken from the lower 16 bits of A(ALUout)
```
assign addr = A[ADDRESS_WIDTH-1:0];
```

Two instructions executed are:

#### LBU
```
if ((A >= 32'h0000_1000) && (A <= 32'h0001_FFFF)) //if not in the interval, return 0
        RD = {24'b0, mem[addr]};
    else
        RD = 32'h0;
```

#### SB
```
if (WE && (A >= 32'h0000_1000) && (A <= 32'h0001_FFFF))
        mem[addr] <= WD[7:0];
```
notice that wrting only occurs when there is a rising edge in clk.

### Correction and Enhancement of the rest of RISC-V

Once we combined our design to see if it could work for the program.S. Problems came up immediately.

#### aludec.sv

First, in the aludec.sv, we did not actually implement the I-type instructions decoder. Instead, it is mixed in R-type, with the same ALUop:
```
2'b10: begin
                unique case (funct3)
                    3'b000: begin
                        // R-type (ADD / SUB)
                        if (funct7_5)
                            ALUControl = ALUCTRL_SUB;
                        else
                            ALUControl = ALUCTRL_ADD;
                    end
```

However, some bits in R-type is treated as immediate in I-type, so it would be better to separate these two different types with a new ALUop(2'b11)
```
2'b11: begin
                // I-type
                unique case (funct3)
                    3'b000: ALUControl = ALUCTRL_ADD; // ADDI
                    3'b111: ALUControl = ALUCTRL_AND; // ANDI
                    3'b110: ALUControl = ALUCTRL_OR;  // ORI
                    3'b010: ALUControl = ALUCTRL_SLT; // SLTI
                    default: ALUControl = ALUCTRL_ADD;
                endcase
            end
```

#### extend.sv

In extend unit, instructions like LUI and AUIPC are not specified. There is only JAL,
```
 2'b11: begin
                // J / U mixed
                unique case (instr[6:0])
                    7'b1101111: begin
                    // JAL: J-type
                    ImmExt = {{11{instr[31]}},
                              instr[31],
                              instr[19:12],
                              instr[20],
                              instr[30:21],
                              1'b0};
                    end
```

Now LUI and AUIPC added,
```
7'b0110111,    // LUI
                    7'b0010111: begin // AUIPC
                    // U-type: imm[31:12] << 12
                    ImmExt = {instr[31:12], 12'b0};
                    end
```

#### maindec.sv

Correspondingly, LUI and AUIPC are also defined in main decoder:
```
OPCODE_LUI: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;    // rs1(x0) + ImmExt(U-type) = Imm
                ImmSrc    = 2'b11;   // U-type
                ALUOp     = 2'b00;
            end

            // AUIPC
            OPCODE_AUIPC: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b11;   // U-type
                ALUOp     = 2'b00;   // ADD (PC + imm)
            end
```

#### mux4 and top

In addition to mux we already have, mux4 should be also implemented in top to achieve JAL.
```
mux4 ResultMux (
        .in0(ALUResult),
        .in1(ReadData),
        .in2(PCPlus4),
        .in3(ImmExt),
        .sel(ResultSrc),
        .out(Result)
    );
```
Four choices available in PC writeback.



## Pipeline

### Checking functionality and testbench.

My main job is to do the final examination and refinement of our whole pipelined RISC-V. Therefore I wrote some program to see if all instructions types being supposed to be function work.

Firstly, I checked some basic alu instructions. Addi, Xori, Ori, Andi and especially Lui which takes only high 20 bits and extends.

alu_lui_test
```
    .text
    .globl _start
_start:
    addi x1, x0, 5
    addi x2, x0, 12
    add x3, x1, x2
    sub x4, x3, x1

    xor x5, x3, x4
    or  x6, x3, x4
    and x7, x3, x4
    slt x8, x1, x2
    sltu x9, x2, x1

    andi x11, x6, 0xF     # x11 = 0x1d & 0x0f = 0x0d (13)
    ori  x12, x0, 0x123   # x12 = 0x00000123
    xori x13, x11, 0x5    # x13 = 0x0d ^ 0x05 = 0x08

    lui  x14, 0x12345     # x14 = 0x12345_000

    # = 0 + 1 + 0 + 13 + 8 = 22
    add  x10, x7, x8
    add  x10, x10, x9
    add  x10, x10, x11
    add  x10, x10, x13    # a0 = 22

done:
    beq x0, x0, done
```

Second is the most important part of pipeline RISC-V, hazard handling. The first hazard I check is the load/store problem, I would like to see if there is a stall when I implement a load/store command.

load_store_test
```
    .text
    .globl _start
_start:
    lui   x1, 0x0
    addi  x1, x1, 0x300     # base address 0x300
    addi  x2, x0, 0x55
    sb    x2, 0(x1)         # mem[0x300] = 0x55

    # Load-Use：
    lbu   x3, 0(x1)         # load in EX stage

    # 2. bubble
    addi  x4, x3, 1         # if no stall，value got might be 0 or trash

    addi  x5, x4, 1         # x5 = (0x55 + 1) + 1 = 0x57 if hazard handled

    # assign：a0 = x5
    add   x10, x5, x0

done:
    beq x0, x0, done

```

The third one is the forwarding function, RISC-V should forward the data came up to data fetch immediatly since some program may need it, thus no data mistake being made.

forwarding_test
```
    .text
    .globl _start
_start:
    # x1 = 1
    addi x1, x0, 1

    addi x2, x1, 2       # hazard: x1 just written

    addi x3, x2, 3

    # no relation, first instruction go to WB：
    addi x4, x0, 10

    # MEM/WB → EX forwarding test：
    # x1 is now in WB:
    # x5 = x1 + x3 = 1 + (1+2+3) = 7
    add  x5, x1, x3

    # sum up：
    # x6 = x5 + x4 = 7 + 10 = 17
    add  x6, x5, x4

    # assign a0 = x6
    add  x10, x6, x0     # a0 = 17

done:
    beq x0, x0, done
```
.
.
.

<img width="481" height="535" alt="截屏2025-12-11 19 31 22" src="https://github.com/user-attachments/assets/d9b4f8e6-ac1f-40e2-acf9-040b33eff712" />

Having done these tests, surprisingly we pass all of them!!!
