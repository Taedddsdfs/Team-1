# RISC-V Design Team-1 Statement

## Overview

### Processor

### link to individual statements

### link to individual statements
[Jingting's Personal statement](/statements/Jingting_statement.md)

[Zhengran's Personal statement](/statements/Zhengran_statement.md)

[Tae Hun's Personal statement](/statements/Tae_statement.md)

[Fengye's Personal statement](/statements/Fengye_statement.md)


## Contribution Table

**Note:** o = Main Contributor; v = Co-Author

| Task | Item name |  Jingting | Zhengran | Tae Hun | Fengye |
|------|--------|---------|--------|---------|-------|
| Single cycle | F1 Program |o| | | |
| | program counter | | |o| |
| | instruction memory |v| |o| |
| | register file | | |v|o|
| | alu |v| | |o|
| | sign extension | |o| | |
| | data memory |o| | | |
| | control unit |v|o| | |
| | top |v|v|v|o| 
| | testbench and debug |v| |v|o|
| Pipeline | PRDE |o|v| | |
| | PREM |o|v| | |
| | PRFD |v|o| | |
| | PRMW |v|o| | |
| | hazard unit |o| | | |
| | top |v|o|v|v|
| | testbench and debug |v| | |o|
| Cache | cache_mem | |o| | |
| | top |o|v|v|v|
| | testbench and debug |v|o| | |

## Directory Structure
the structure of the main branch is as follows:

```markdown
repo
├──rtl
|   ├── PRDE.sv
|   ├── PREM.sv
|   ├── PRFD.sv
|   ├── PRMW.sv
|   ├── aludec.sv
|   ├── alu.sv
|   ├── data_cache.sv
|   ├── controlunit.sv
|   ├── data_mem.sv
|   ├── extend.sv
|   ├── hazard_unit.sv
|   ├── instruction_memory.sv
|   ├── maindec.sv
|   ├── mux2.sv
|   ├── program_counter.sv
|   ├── reg_file.sv
|   ├── mux3.sv
|   └── top.sv
└──tb
    ├── asm
    |   ├── 1_addi_bne.s
    |   ├── 2_li_add.s
    |   ├── 3_lbu_sb.s
    |   ├── 4_jal_ret.s
    |   ├── 5_pdf.s
    |   ├── f1_light.s
    |   └── program.s
    ├── c
    ├── reference
    └── tests
        ├── assemble.sh
        ├── compile.sh
        ├──doit.sh
        ├──verify.cpp
        ├──vbuddy.cpp
        ├──top_tb.cpp
        └──gaussian.mem
```
## Directories
1. [rtl](https://github.com/Taedddsdfs/Team-1/tree/main/repo/rtl): holds all the .sv programs for the module designs
2. [statements](https://github.com/Taedddsdfs/Team-1/tree/main/statements): holds the personal statements
3. [tb](https://github.com/Taedddsdfs/Team-1/tree/main/repo/tb):
    1) [asm](https://github.com/Taedddsdfs/Team-1/tree/main/repo/tb/asm): holds all the assembly code program .s
    2) [tests](https://github.com/Taedddsdfs/Team-1/tree/main/repo/tb/tests): holds all the cpp testbench programs of the modules in rtl
    3) the shell scripts .sh files

## Evidence of tests passing

### Test programs:
![Console after running tests]()

To run tests, change data_memory.sv and instruction_memory.sv to .../data.hex and .../program.hex respectively.

### F1:



link



To run F1 with Vbuddy, run F1.sh.

### PDF:


link



To run PDF with Vbuddy, run PDF.sh.
