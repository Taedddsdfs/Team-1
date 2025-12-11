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
Team21
├──rtl
|   ├── PRDE.sv
|   ├── PREM.sv
|   ├── PRFD.sv
|   ├── PRMW.sv
|   ├── adder.sv
|   ├── alu.sv
|   ├── cache_2way.sv
|   ├── control_unit.sv
|   ├── data_memory.sv
|   ├── data_memory_cache.sv
|   ├── hazard_unit.sv
|   ├── instruction_memory.sv
|   ├── mux.sv
|   ├── pcmuxsel.sv
|   ├── programcounter.sv
|   ├── register.sv
|   ├── sign_extend.sv
|   ├── top.sv
│   └── twobitmux.sv
├──statements
|   ├── images
│   │   └── ...
|   ├── Anson.md
|   ├── Callum.md
|   ├── Peter.md
│   └── Yikai.md
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
        └── doit.sh
```

