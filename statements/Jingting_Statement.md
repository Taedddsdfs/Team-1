
*Statement of Jingting* 
## F1 Program & Testbench Environment

**Role**: Lead Contributor Module: Single Cycle Processor - F1 Program & Testbench Integration


**1. Overview & Operational Principles**

I designed and implemented the full software-hardware verification environment for the Single Cycle RISC-V CPU. This involved developing the f1_light.s assembly program and creating a robust C++ testbench architecture that supports two distinct operational modes: Real-time Physical Visualization (VBuddy) and **High-Speed Waveform Debugging (GTKWave)**.

**Operational Logic of the Dual-Mode Testbench**: To ensure both visual verification and detailed signal analysis, I wrote two separate driver files sharing a common compilation core:

**-Mode A**: Physical Visualization (top-f1.cpp)

VBuddy Integration: I utilized the VBuddy API to bridge the simulation and physical hardware. The testbench captures the CPU's output register (`top->a0`) at every clock cycle and transmits it to the VBuddy driver via vbdBar(`top->a0 & 0xFF`).

Synchronization: A critical design choice was the insertion of usleep(500000) (500ms delay) within the main simulation loop. This slows down the multi-GHz simulation speed to match human persistence of vision, allowing the "Formula 1" LED sequence to be observed clearly on the physical LED bar.

Hardware Setup: I explicitly added `vbdSetMode(1)` in the initialization phase to switch the VBuddy from its default text mode to LED bar mode, ensuring the visual output matched the internal register state.

**-Mode B**: Waveform Simulation (top-f1Wave.cpp)

Optimized for GTKWave: Unlike the physical mode, I designed this testbench for speed. I removed all VBuddy dependencies and sleep delays (usleep).

Cycle-Accurate Tracing: This version runs a continuous loop for a fixed number of cycles (600 cycles), allowing the Verilator model to rapidly generate a dense .vcd file. This was essential for debugging internal signal propagation in GTKWave without the overhead of hardware IO blocking the simulation.

**The evidence and the detailed verification steps are showing in README of the main branch. ^_^**

**2. Automated Toolchain Integration**

A major contribution was refactoring the build process to be atomic and self-contained within the C++ testbench.

Embedded Compilation Logic: Instead of relying on fragile external shell scripts (compile.sh), I embedded the RISC-V toolchain commands directly into the initializeInputs() method of the CpuTestbench class.

Execution Flow:

**-Assembly:** `riscv64-unknown-elf-as` compiles `asm/f1_light.s` to an object file.

**-Binary Extraction:**`riscv64-unknown-elf-objcopy` extracts the `.text section.`

**-Hex Formatting:** `od and awk` convert the binary into the `program.hex` format required by Verilog's `$readmemh.`

Robustness: By using `system()` calls with strict return code checking (`if (ret != 0)`), I ensured the simulation aborts immediately if the assembly fails, preventing the "Silent Failure" scenario where the CPU would simulate an empty memory file.

**3. Key Challenges & Resolutions**

**(1) The "Silent" Instruction Failure (0KB Hex Bug):** I diagnosed an issue where the CPU clock was toggling but a0 remained 0. I traced this to a failure in the external build script. My resolution was to move the compilation logic inside the C++ testbench, guaranteeing that program.hex is regenerated correctly every time the simulation binary is run.

**(2) VBuddy Mode Mismatch:** I identified that the VBuddy hardware defaults to text mode, ignoring LED commands. I fixed this by implementing the `vbdSetMode(1)` initialization call in top-f1.cpp, enabling the LED bar interface.

**(3) Path Dependency Conflicts:** To resolve "file not found" errors when running tests from different directories, I standardized the include paths (e.g., `#include "testbench.h"`) and hardcoded the relative paths for assembly files, ensuring the testbench can reliably locate resources regardless of the execution context.

## Arithmetic Logic Unit (ALU) & Control Unit Integration

**Role:** Co-Author 

### 1. PC-Relative Addressing Support (Jumps)
I extended the Control Unit to support PC-relative branch and jump calculations, specifically for the JAL (Jump and Link) instruction.

**Architecture Change:** I introduced a conditional override logic on the ALUSrcA control line.
![alt text](7d4a38237384d644aac6b80c59820526.jpg)

**Logic:** By adding a multiplexing condition (op == 7'b1101111) at the Control Unit output, I forced the ALU's first operand to switch from the Register File to the Program Counter (PC) during jump operations.

**Impact:** This enabled the ALU to perform PC + Immediate calculations essential for determining jump targets, a mechanism structurally similar to AUIPC, thereby completing the processor's control flow capabilities.

### 2. Optimized LUI Execution (Internal Forwarding)
I implemented the LUI (Load Upper Immediate) instruction logic entirely within the ALU, avoiding the need for additional external multiplexers in the datapath. * Mechanism: Instead of routing a "hardcoded zero" to the first ALU operand to perform an addition (0 + Immediate), I modified the ALU's combinational logic to include a dedicated "Pass-Through" mode (Case 4'b1111).

**Result:** This allows the ALU to directly forward the second operand (the Immediate on SrcB) to the output. This approach simplifies the top-level wiring and isolates the LUI operation from the Register File's read ports, preventing any potential data dependency hazards on the unused RD1 line.


**Implementation:** In the ALU hardware, this signal triggers a bypass mode that explicitly ignores the first operand and outputs the second operand (Immediate) directly (ALUout = ALUop2). This ensures LUI operations are atomic and decoupled from arithmetic logic, preventing potential hazards involving uninitialized RD1 values.

### 3. Datapath Extension for Procedure Calls (JAL/JALR)  
**By *H&H* book, I redesigned the Writeback stage logic by replacing the standard 2-to-1 multiplexer with a custom 3-to-1 multiplexer** (`mux3`).

**Purpose:** The original architecture lacked a pathway to save the return address.

**Implementation:** I routed the PC + 4 signal from the fetch stage directly to the third input of this new multiplexer.

**Result:** Controlled by the extended 2-bit ResultSrc signal, this allows the Register File to capture the return address, fully enabling function call support (Jump and Link) in the processor.

![alt text](image.png)





## Data Memory & Testbench Co-DevelopmentRole: 

**Role:** Co-Author 

### 1. Data Memory Architecture Enhancements (`data_mem.sv`)**

I co-developed the data memory subsystem, focusing on resolving critical addressing issues and extending instruction support for the Gaussian distribution algorithm.

-**Byte-Level Addressing Logic:**

To support sub-word operations required by the SB (Store Byte) and LBU (Load Byte Unsigned) instructions, I refined the read/write logic within `data_mem.sv` by implementing a funct3-based masking mechanism.

--**Write Logic:** For SB (funct3), I ensured only the target byte (bits 7:0) is written to mem[addr] while preserving the upper 24 bits, preventing data corruption in adjacent memory cells.

--**Read Logic:** For LBU, I implemented zero-extension logic (`{24'b0, mem[addr]}`) to correctly map 8-bit memory values to the 32-bit register width.

-**Solving the "Gaussian" Aliasing Hazard:**

During the testing of the Gaussian PDF program (`5_pdf.s`), I diagnosed a critical memory aliasing bug where the variable initialization at `0x100` overwrote the source data loaded at `0x10000`.

--**Root Cause Analysis:** I identified that the initial ADDRESS_WIDTH (16 bits) truncated 0x10000 to 0x0000, causing a collision.

--**Architecture Fix:** I expanded the address width to 17 bits ($2^{17}$ locations) and implemented offset loading. This physically isolated the data section from the variable section to ensure correct program execution.

```SystemVerilog
$display("Loading gaussian.mem to address 0x10000...");
$readmemh("reference/gaussian.mem", mem, 17'h10000);
``` 


### 2. Testbench Refactoring & Debugging (`top-f1.cpp`)
I played a key role in stabilizing the verification environment, transitioning the project from fragile manual scripts to a robust, self-contained C++ testing framework.

-**Automated Toolchain Integration:**
I addressed the "Silent Instruction Failure" caused by external script dependencies. I refactored the CpuTestbench class to embed the compilation commands directly. By using system() calls to invoke riscv64-unknown-elf-as, objcopy, and od within the testbench, I ensured that the program.hex file is regenerated atomically before every simulation run.

-**Physical Hardware Debugging (VBuddy):**
I resolved a protocol mismatch where the VBuddy LEDs remained unresponsive despite correct simulation waveforms. I updated the driver logic to format integer outputs into ASCII strings and explicitly injected vbdSetMode(1) to enable the LED Bar interface, successfully bridging the gap between simulation and physical reality.


## Hazard Unit & Pipeline Registers (PRDE/PREM)
Role: Main Contributor
![alt text](db2cd5a4e779cfbd98402f90a566f9d3.png)

### 1. Hazard Unit Design 
I designed and implemented the hazard_unit, the central control logic responsible for maintaining data integrity and execution flow in the pipelined architecture.

- **Data Forwarding (RAW Hazard Resolution):** 
To resolve Read-After-Write hazards without stalling, I implemented a forwarding mechanism that bypasses the Register File. The unit detects if source registers (`rs1_e`,` rs2_e`) in the Execute stage match destination registers in the Memory (`rd_m`) or Writeback (`rd_w`) stages. It prioritizes the most recent data (Memory stage) over the Writeback stage to ensure the ALU receives the correct operands.
- **Load-Use Hazard Detection:** I implemented specific logic to detect when an instruction attempts to read a value immediately after a Load instruction. The unit checks if the previous instruction is a Load (`resultsrc_e == 2'b01`) and if the destination matches the current source registers. Upon detection, it asserts stall_f and stall_d to freeze the PC and Decode stages, inserting a bubble to allow memory access time.
- **Control Hazard Management:** To handle branch mispredictions, I linked the pcsrc_e signal (Branch Taken) to the flush controls. When a branch is taken, the unit asserts flush_d and flush_e, ensuring that instructions erroneously fetched in the delay slots are discarded before they affect the processor state.

### 2. Pipeline Registers Implementation (PRDE & PREM)
I architected the two critical intermediate pipeline registers, PRDE (Decode $\to$ Execute) and PREM (Execute $\to$ Memory), to support the Hazard Unit's requirements.

#### PRDE (Decode/Execute Register):
- **Synchronous Flushing:** I integrated a clr (Clear) input connected to the Hazard Unit. This allows the pipeline to synchronously reset all control signals (regwrite, branch, jump) to zero during a control hazard, effectively converting invalid instructions into NOPs.

- **Hazard Signal Propagation:** 
I ensured that register addresses (rs1, rs2) are propagated from Decode to Execute. This is physically required for the Hazard Unit to perform the comparisons described above.

- **Control Extension:** 
I included the alusrca signal in the pipeline width, enabling the PC-relative addressing logic (JAL) I designed in the Control Unit to function correctly across pipeline stages.
#### PREM (Execute/Memory Register):
- **Stage Isolation:** I designed this register to strictly separate the arithmetic logic from the memory interface, latching the aluresult and writedata.

- **ranularity Support:** I persisted the `funct3` signal into the Memory stage. This ensures the Data Memory interface has the necessary context to perform Byte (LB/SB) or Half-word operations correctly, rather than defaulting to full-word access.

Collaborative Note
PRFD & PRMW Registers: The Fetch-Decode (PRFD) and Memory-Writeback (PRMW) pipeline registers were implemented by my teammate **Zhengran**. 

*please refer to his statement here: https://github.com/Taedddsdfs/Team-1/blob/main/statements/Zhengran_statement.md*


## Cache System & Top-Level Integration
Role: Main Contributor 

Module: Cache debug & Processor Top-Level Integration

### 1. Top-Level System Integration (top.sv)
I was responsible for the final assembly of the processor, integrating the 5-stage pipeline, hazard management, and the new memory hierarchy into a cohesive system.

- **Cache Integration:** I replaced the standard data_memory module with a 2-way Set-Associative data_cache in the Memory Stage. This required precise mapping of the pipeline's control signals (MemWriteM, Funct3M) to the cache's write-enable and granularity interfaces.

- **Pipeline Orchestration:** I wired the hazard_unit outputs (StallF, StallD, FlushE) to the respective pipeline registers (PRFD, PRDE) and the Program Counter. This integration ensures that the cache latencies or pipeline hazards correctly pause the fetch/decode logic or flush invalid instructions.

- **Control Flow Completion:** I finalized the branch and jump target calculations in the Execute stage. By implementing the PCTargetE logic (selecting between PCE + Imm for branches and SrcAE + Imm for jumps), I successfully enabled the JAL functionality supported by my earlier control unit modifications.

### 2. Cache Architecture Debugging & Optimization
The transition from ideal memory to a realistic cache introduced significant complexity. I diagnosed and resolved three critical implementation bugs that were causing test failures:

#### Address Alignment & Byte Packing 

**Issue:** Early tests showed corrupted data in register a0 when loading words from non-aligned boundaries.

**Diagnosis:** The cache logic initially accessed memory using raw addresses, causing offsets.

**Resolution:** I implemented word-alignment logic (addr_word_base) to force all memory accesses to align with 4-byte boundaries. I then reconstructed the output data by repacking the bytes {mem[+3], ... mem[+0]} based on the offset, ensuring correct LW behavior.

#### Write-Through Coherency (Store Byte Bug)

**Issue:** The "Store-then-Load" sequence failed. Stores (specifically SB) updated the backing memory, but the cache lines retained old data ("stale data"), causing subsequent loads to return incorrect values.

**Resolution:** I implemented a "Read-Modify-Write" strategy for the write-through policy. Instead of just writing to memory, the logic now fetches the current cache line, merges the new byte (for SB) or half-word (for SH) into the existing word, and updates the specific cache way. This guarantees data consistency between the cache and main memory.

#### Granularity Compliance (LBU vs LW)

**Issue:** The cache initially treated all loads identically, failing to distinguish between signed (LW, LB) and unsigned (LBU) extensions.

**Resolution:** I synchronized the cache's behavior with the funct3 control signal. I added logic to explicitly zero-extend the output for LBU operations, ensuring the cache's behavior matched the RISC-V ISA specification and the reference memory model.

To find out more about cache_mem, please refer to my teammate **Zhengran's statement**, he is the main contributor: https://github.com/Taedddsdfs/Team-1/blob/main/statements/Zhengran_statement.md*
