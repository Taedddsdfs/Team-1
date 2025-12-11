# RISC V RV32I Design Coursework

---

Zhengran Han         CID: 02583845        

---

### Introduction 

My main contribution in the group was implementing the datapath and control logic needed for pipelining and cache. I designed the sign-extension unit and control unit for the single-cycle CPU, then extended them with the PRDE stage and pipelined top module. I also implemented the 2-way data cache module and helped debug the cache-related testbench so that the pipelined CPU passes the provided tests.

---

### Overview

* [Sign Extension Unit](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/extend.sv)
* [control_unit](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/controlunit.sv)
* [PRFD-pipeline](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/PRFD.sv)
* [PRMW-pipeline](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/PRMW.sv)
* [top-pipeline]()
* [cache_memory](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/data_cache.sv)
* [debug for cache]()

---

### Pipeline Registers (Co-op with Jingting)

The registers can divide different stage of the CPU. 

In this RISC-V processor we divide each instruction into the following stages: Fetch, Decode, Execute, Memory, Writeback.

Hence we got the following resigters:
Which gives us 4 different pipeline registers:

- [PRFD]()
- [PRDE]()
- [PREM]()
- [PRMW]()

(ps: I did PREM and PRMW)


---

### Sign Extension

I wrote the extend module for our CPU. Its job is to take the 32-bit instruction and output a correctly sign-extended immediate value for different instruction types.

The key idea is to look at the ImmSrc control signal and decide how to slice and rearrange bits from instr. For example, I-type instructions
just use bits 31:20, S-type uses 31:25 and 11:7, B-type and J-type need a more “scrambled” layout (because of the RISC-V encoding), and U-type 
simply shifts the upper 20 bits left by 12.

I implemented this with a case statement inside always_comb.

``` systemverilog

always_comb begin
    unique case (ImmSrc)
        // I-type (ADDI, LW, JALR)
        3'b000: begin
            ImmExt = {{20{instr[31]}}, instr[31:20]};
        end

        // S-type 
        3'b001: begin
            ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        end

        // B-type 
        3'b010: begin
            ImmExt = {{19{instr[31]}}, instr[31], instr[7],
                      instr[30:25], instr[11:8], 1'b0};
        end

        // J-type 
        3'b011: begin
            ImmExt = {{11{instr[31]}}, instr[31], instr[19:12],
                      instr[20], instr[30:21], 1'b0};
        end

        // U-type 
        3'b100: begin
            ImmExt = {instr[31:12], 12'b0};
        end

        default: ImmExt = 32'b0;
    endcase
end
```
---

### Control Unit

I firstly designed this part and Fengye debug and modify it.



