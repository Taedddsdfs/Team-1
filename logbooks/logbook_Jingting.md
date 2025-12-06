# 📔 RISC-V Single Cycle CPU Dev Log | Nov 30 – Dec 6

> **Sprint Week Record:** From basic architecture setup to full functional verification via Gaussian distribution calculation.

## Project Info

| Category | Details |
| :--- | :--- |
| **Project Name** | Team-1 RISC-V Single Cycle CPU Design & Verification |
| **Author** | Jingting |
| **Role** | RTL Designer, Verification Engineer, Toolchain Manager |
| **Platform** | WSL (Ubuntu 22.04) on Windows |
| **Cycle** | Nov 30, 2025 – Dec 6, 2025 |

---

## 📖 Introduction

This week was the critical sprint week for the RISC-V single-cycle processor development. The main goal was to transition from a basic instruction set implementation to a fully functional CPU capable of supporting complex assembly programs (such as Gaussian distribution calculation).

**Evolution of Work Focus:**
* **Early Phase:** Dedicated to establishing the basic datapath and JALR jump logic.
* **Mid Phase:** Underwent a toolchain refactoring, shifting from manual compilation to an automated testing framework (GTest).
* **Late Phase (Dec 6 Final Battle):** Focused on instruction set extension (Multiplication support), deep debugging of memory architecture (solving address aliasing), and fully passing 5 standard assembly test cases.

---

## 📅 Part 1: Early Work Review (Nov 30 – Dec 3)

### 1.1 Architecture Implementation & Critical Path Fix (Nov 30)
**Goal:** Implement the basic single-cycle architecture and adapt to the instruction requirements of the F1 Light program.

In the early stages of the project, we coded the RTL based on the standard Harris & Harris single-cycle model. However, when testing the F1 start-up program, we discovered that the standard model could not support subroutine calls and returns, leading to the first major architectural refactoring.



#### 🔧 JALR & PC Mux Logic Refactoring
* **Problem Background:** The F1 program makes extensive use of `JAL` (Jump and Link) and `JALR` (Jump and Link Register). The standard model's `PCSrc` (1-bit) can only select between `PC+4` and `BranchTarget`. It lacks a path to write `ALUResult` directly back to the PC (required for `JALR`, where the target is `rs1 + imm`).
* **Solution:**
    1.  **Control Unit Upgrade:** Expanded `PCSrc` to a 2-bit signal and introduced priority logic.
    2.  **Datapath Modification:** Upgraded the PC Input Mux from 2-to-1 to 3-to-1:
        * `2'b00`: Normal Fetch (`PC + 4`) —— Sequential execution.
        * `2'b01`: Branch/Jump (`PC + Imm`) —— Used for `BEQ`, `BNE`, `JAL`.
        * `2'b10`: Register Indirect (`ALUResult`) —— Dedicated to `JALR` (Function return).
    3.  **Physical Connection:** Established a feedback path from the ALU output back to the Fetch Stage.

### 1.2 Memory System Byte Addressing Adaptation (Dec 1)
**Goal:** Resolve the conflict between the RISC-V 32-bit word length and the 8-bit memory width.

**Instruction Memory (`instr_mem.sv`):**
* **Challenge:** 8-bit wide ROM vs. 32-bit RISC-V instructions.
* **Implementation:** Designed splicing logic based on Little Endian. It reads 4 consecutive byte addresses in a single cycle:
    ```verilog
    data = {rom[a+3], rom[a+2], rom[a+1], rom[a]};
    ```

**Data Memory (`data_mem.sv`):**
* **Implementation:** Implemented support for `SB` (Store Byte) and `LBU` (Load Byte Unsigned). Introduced masking logic to ensure `SB` only writes to the specific byte channel selected by the lower two bits of the address, without destroying the other 24 bits in the word.

### 1.3 Toolchain Migration & Visual Debugging (Dec 2 – 3)
**Goal:** Establish a reliable compilation flow and connect VBuddy for visual verification.

**Toolchain Migration (The GCC Shift):**
* **Decision:** Abandoned RARS simulator; fully migrated to the industry-standard `riscv64-unknown-elf-gcc` toolchain.
* **Flow:** `.s` (Assembly) → `.o` (Object) → `.bin` (Binary) → `.hex` (Formatted text for `$readmemh` alignment).

**VBuddy Protocol Fix:**
* **Phenomenon:** Simulation waveforms showed the CPU running correctly, but the physical VBuddy LEDs remained off.
* **Root Cause:** The VBuddy firmware expects ASCII string commands (e.g., `"$B,255\n"`) via USB serial, whereas our testbench was sending raw binary integers.
* **Fix:** Modified the driver code to use `sprintf` to format integers into the required ASCII strings. Verification passed on the physical device thereafter.

---

## 📅 Part 2: Compile Environment Migration & Preliminary Debug (Dec 4 – Dec 5)

### 2.1 Script Crisis & Standardized Build (Dec 4)
**Issue:** Manually typing verilator commands became unmaintainable, and hardcoded paths caused "File Not Found" errors.
**Decision:** Scrapped custom scripts and fully adapted to the instructor-provided build system (`doit.sh`) to leverage the GTest automation framework.

### 2.2 Cross-Platform Adaptation (macOS to Linux) (Dec 5)
**Goal:** Run scripts originally developed for macOS on a WSL (Ubuntu) environment.

| Error Type | Error Message | Solution |
| :--- | :--- | :--- |
| **GTest Path** | `GoogleTest not found` | Removed macOS hardcoded paths; switched to Linux standard linker flags `-lgtest -lgtest_main -lpthread`. |
| **Module Definition** | `Filename 'top' does not match MODULE` | Verilator requires one module per file. Split `mux2` and `mux3` definitions from the bottom of `top.sv` into separate files `rtl/mux2.sv` and `rtl/mux3.sv`. |

### 2.3 Hardware Adapter for Linker Script (Dec 5)
**Goal:** Solve the issue where the program "runs away" (executes invalid instructions) after power-up.

**CRITICAL INSIGHT:**
The `compile.sh` linker script sets the code section base address to `0xBFC00000`, while the CPU hardware resets the PC to `0x0`. The CPU fetches from address 0, but the code actually resides 3GB away.

**Hardware Fix (Co-design):**
* **PC Reset:** Modified `program_counter.sv` logic to reset `PC <= 32'hBFC00000`.
* **Address Mapping:** Implemented address masking in `instruction_memory.sv`, mapping the virtual high address to the physical ROM's low address space (`addr[11:0]`).

---

## 📅 Part 3: Deep Debug & Multi-File Testing (Dec 6 – Final Battle)

### 3.1 Overview
Today's core task was **Debugging**. Through collaboration with AI, we systematically troubleshot issues ranging from simple arithmetic errors to complex memory aliasing, ultimately passing all 5 standard assembly test files.

### 3.2 Debug Record: The Road to Clearance

#### ✅ Test 1: `1_addi_bne.s` (Basic Instructions)
* **Status:** PASS
* **Significance:** Proved that the basic fetch, decode, execute pipeline is clear, and BNE branch logic is correct.

#### ✅ Test 2: `2_li_add.s` (Immediate Load & Addition)
* **Failure:** Expected `a0 = 1000`, Got `a0 = -1000` (Addition became Subtraction).
* **Root Cause:** The ALU Decoder relied solely on the 30th bit (`funct7[5]`) to distinguish ADD from SUB.
* **Trap:** `ADDI` is an I-Type instruction, but its immediate value 1000 (`0x3E8`) happens to have a 1 at the 30th bit position. The decoder misidentified it as an R-Type SUB instruction.
* **Fix:** Introduced the 5th bit of the Opcode (`opb5`) as an input.
    ```verilog
    if (opb5 && funct7_5) ALUControl = SUB; else ALUControl = ADD;
    ```

#### ✅ Test 3: `3_lbu_sb.s` (Byte Read/Write)
* **Failure:** Result deviated massively.
* **Root Cause:** Although named "Byte" operations, the logic was still performing "Word" (32-bit) operations. `SB` overwrote neighboring bytes, and `LBU` failed to zero-extend the high bits.
* **Fix:**
    1.  Passed the `funct3` signal all the way to `data_mem`.
    2.  Implemented complete case logic: `SB` only writes to `mem[addr]` (8 bits), `LBU` reads `mem[addr]` and pads the upper 24 bits with zeros.

#### ✅ Test 4: `4_jal_ret.s` (Function Call)
* **Status:** PASS
* **Significance:** Re-verified the correctness of the PC Mux `2'b10` path and the `JALR` logic loop.

#### ✅ Test 5: `5_pdf.s` (Gaussian Distribution - Final BOSS)


[Image of Gaussian distribution curve]

Experienced three stages of failure and repair:

**Stage 1: Missing Functionality ❌**
* **Phenomenon:** Incorrect result.
* **Analysis:** The PDF algorithm involves squaring, but `alu.sv` lacked `MUL` instruction support.
* **Fix:** Added `*` operator in ALU and `funct7[0]` detection in Control Unit.

**Stage 2: Missing Data (Result = 200) ❌**
* **Analysis:** Result was equal to `max_count` (200), implying all data read from memory was 0.
* **Fix:** Correctly loaded the `gaussian.mem` data file in the testbench.

**Stage 3: Memory Aliasing ❌ -> ✅**
* **Phenomenon:** Result became 808 or 952, and the program crashed midway.
* **Root Cause (CRITICAL):**
    * *Assembly Definition:* Data at `0x10000`, Variables at `0x100`.
    * *Hardware Reality:* Data memory address width was only 16 bits (`0x10000` truncated to `0x0000`).
    * *Consequence:* The Gaussian data was loaded at the beginning of memory (`0x0`). When the program initialized the variable area (`0x100`), it wiped out its own source data due to the overlap!
* **Ultimate Fix:**
    1.  **Expansion:** Extended data memory address width to 17 bits (128KB).
    2.  **Offset Loading:** `$readmemh(..., mem, 17'h10000)` to physically isolate data and variables.
    3.  **Cleaning:** Used `sed` to clean labels from the `.mem` file.
    4.  **Timing:** Increased simulation cycles to 1,000,000.

**Final Result:**
```text
[ RUN      ] CpuTestbench.Test5_Pdf
[       OK ] CpuTestbench.Test5_Pdf
[  PASSED  ] 5 tests.
