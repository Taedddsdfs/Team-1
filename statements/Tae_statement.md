## 📝 Personal Statement: RISC-V Processor Design

**Author:** Taehun  
**Role:** Core Module Lead (PC), Co-Author (Register File, Control Unit, Top-Level) & Verification Architect  & Reference
**Module Focus:** Program Counter, Test Infrastructure, Control Flow Logic

---

## 📝 Personal Statement: RISC-V Processor Design

**Author:** Taehun  
**Role:** Core Module Lead (PC), Co-Author (All Modules) & Verification Architect  
**Module Focus:** Pipelined Datapath, Hazard Resolution, System Integration

---

## Part 1: Infrastructure Setup

### 1.1 Repository Structure & Automation
**Goal:** Establish a clean workspace and automated build system.
* **Action:** Organized the repository into `rtl/` and `tb/` folders and configured the build script.
* **Evidence:** [View Commit c567e11](https://github.com/Taedddsdfs/Team-1/commit/c567e11) (Resolved conflicts and moved files to structured directories)
* **Impact:** Adapted the build system to link **Google Test** libraries, reducing test iteration time from minutes to seconds.

---

## Part 2: PC Module Architecture & Implementation

### 2.1 Design Decision: Integrated Next-PC Logic
**Goal:** Implement the Program Counter with built-in flow control.
* **Evolution:** Initially planned to use separate Adder and Mux modules.
* **Decision:** Integrated Next-PC logic directly into the `program_counter` module to reduce top-level wiring complexity.
* **Evidence:** [View Commit ed53660](https://github.com/Taedddsdfs/Team-1/commit/ed53660) (Implemented Role 1: PC with internal flow control logic)

### 2.2 Synchronous Reset Implementation
**Issue:** Initial designs utilizing asynchronous reset caused undefined states (`X`) during simulation startup.
**Fix:** Adopted strict **Synchronous Reset** (`if (rst)` inside `always_ff`).
* **Result:** The PC reliably initializes to `32'h0`, ensuring deterministic behavior for GTest.

### 2.3 Verification Strategy (Unit Testing)
**Goal:** Verify logic in isolation using a C++ testbench.
* **Verified Scenarios:**
    1.  **Reset & Sequential:** Confirmed PC increments by 4.
    2.  **Branch/JAL:** Verified relative jumping.
    3.  **JALR (Critical):** Verified absolute address jumping (`PC = ALUResult`).
* **Outcome:** Passed all tests including corner cases (Warm-up cycles for reset).


---

## Part 3: Register File Implementation (Co-Author)

### 3.1 3-Port Architecture & Zero Register Protection
**Goal:** Design a multi-port memory unit compliant with RISC-V ISA specifications.
* **Implementation:** Developed a dual-read, single-write (`2R1W`) register file to support standard instruction formats (two source registers `rs1`, `rs2` and one destination `rd`).
* **Safety Mechanism:** Implemented hardware-level write protection for **Register x0**.
    * *Logic:* Added a conditional check `if (WE3 && (AD3 != 5'd0))` to ensure writes to address `0` are physically ignored, enforcing the RISC-V requirement that `x0` remains hardwired to zero.

### 3.2 Design for Verification (The 'a0' Port)
**Decision:** Exposed internal register state for black-box testing.
* **Action:** Added a dedicated output port `a0` connected to `registers[10]`.
* **Reasoning:** In RISC-V calling conventions, `x10` (a0) holds function return values. Exposing this port allowed the testbench to verify program execution results immediately at the top level without needing to inspect internal waveforms or memory dumps.

---

## Part 4: Control Unit Logic (Co-Author)

### 4.1 Advanced Flow Control Implementation
**Role:** Collaborated on extending the decoding logic to support complex branching and absolute jumps.
* **Branch Logic:** Assisted in refining the `branch_taken` signal to support `BNE` (Branch if Not Equal) alongside `BEQ`, enabling the processor to handle `loops` and `conditional statements` correctly.
* **Indirect Jumps (JALR):** Contributed to the `PCSrc` multiplexing logic, ensuring that `JALR` instructions (`7'b1100111`) correctly bypass the relative adder and load the target address directly from the ALU.


---

## Part 5: Pipelined Processor Integration (Co-Author)

### 5.1 5-Stage Pipelined Datapath Assembly
**Role:** Co-authored the top-level integration, successfully transitioning the design to a **5-Stage Pipelined Architecture** (IF, ID, EX, MEM, WB).
* **Core Mechanism:** Connected four pipeline registers (`PRFD`, `PRDE`, `PREM`, `PRMW`) to transfer control and data signals between adjacent stages, optimizing for instruction throughput.
* **Integration Focus:** Managed the complex routing of control signals (e.g., `ResultSrcW`, `RegWriteW`) to the Writeback stage and Register File, ensuring data coherency across all pipeline stages.


### 5.2 Hazard Resolution Implementation
**Key Contribution:** Integrated and configured the **Hazard Unit** to maintain data integrity and performance.
* **Data Forwarding:** Implemented **forwarding paths** using 3-to-1 MUXes in the Execute (EX) stage, allowing results from the MEM or WB stage (`ALUResultM`, `ResultW`) to be immediately used by subsequent instructions (`SrcAE`, `SrcBE`), eliminating most data stalls.
* **Control Hazard Resolution:** Enabled the Hazard Unit to detect taken branches (`PCSrcE` high) and generate the `FlushD` signal, immediately invalidating instructions in the Decode stage to prevent incorrect execution.

---

## Part 6: Reflection

**What I learned:**

1.  **Pipelining Complexity:** Transitioning to pipelined design highlighted that complexity shifts from component logic to **system integration** and **hazard management**. The performance challenge lies in coordinating data flow and timing across the pipeline registers.

2.  **Hazard Unit Importance:** Implementing data forwarding and stalling mechanisms demonstrated the crucial trade-off between **latency (single-cycle)** and **throughput (pipelined)**, proving essential for maximizing the Instruction Per Cycle (IPC) rate.

3.  **Architectural Trade-offs:** The initial decision to encapsulate PC logic (Part 2) simplified the final Top-Level wiring (Part 5), reinforcing the value of **strategic upfront design** even in modular hardware.

4.  **Design for Testability (DFT):** The use of the `a0` output port (Part 3) proved invaluable, allowing the team to debug complex, concurrent issues across the five pipeline stages efficiently, confirming the importance of designing with the "tester" mindset.
