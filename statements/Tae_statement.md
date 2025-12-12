## 📝 Personal Statement: RISC-V Processor Design

**Author:** Taehun  
**Role:** Core Module Lead (PC), Co-Author (Register File, Control Unit, Top-Level) & Verification Architect  & Reference
**Module Focus:** Program Counter, Test Infrastructure, Control Flow Logic

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

## Part 5: Top-Level Integration (Co-Author)

### 5.1 System Integration & Data Path Wiring
**Role:** Co-assembled the top-level module, interconnecting core components to form the complete single-cycle processor.
* **Component Instantiation:** Connected the `Program Counter`, `Register File`, `ALU`, and `Memory` modules based on the RISC-V datapath architecture.
* **Signal Routing:** Managed internal wiring for critical data paths, including `PCPlus4` for sequential execution and `ResultSrc` multiplexing to handle data write-back from Memory, ALU, or PC.

### 5.2 Top-Level Output for Verification
**Focus:** Ensured observability for the testbench.
* **Mechanism:** Routed the `a0` output from the Register File through the top module hierarchy, allowing the verification script to capture the processor's final state directly from the `top` module interface.


---

## Part 6: Reflection

**What I learned:**

1.  **Architectural Trade-offs:** I initially attempted a fine-grained modular approach (separating PC, Adder, and Mux), but realized that the complex control paths required for instructions like `JALR` created excessive top-level wiring overhead. This taught me that **strategic encapsulation** often yields cleaner, more maintainable hardware than strict modularity.

2.  **Verification Reliability:** I gained deep insight into the importance of **synchronous design**. Integrating Google Test demonstrated how **Automated Regression Testing** saves significant debugging time compared to manual waveform inspection.

3.  **Process Efficiency (DevOps):** Setting up the build automation script (`doit.sh`) taught me that **investing in tooling upfront** drastically reduces iteration time. Enabling sub-second testing allowed me to fail fast and fix fast, which was critical for meeting the deadline.

4.  **Design for Testability (DFT):** Through the Register File implementation, I learned that hardware design isn't just about functionality but also about **observability**. Adding the `a0` output port seemed redundant for the logic itself but proved critical for the verification pipeline, teaching me to design with the "tester" mindset from day one.
