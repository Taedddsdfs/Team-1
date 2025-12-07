Personal Statement: RISC-V Processor Design

**Author:** Taehun
**Role:** Core Module Lead (PC) & Verification Architect
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
![Test Execution Result](https://github.com/user-attachments/assets/91cd052b-0b3a-40cf-ae83-a3657b3f3d3b)

---

## Part 3: Reflection
**What I learned:**
1.  **Architectural Trade-offs:** I initially attempted a fine-grained modular approach (separating PC, Adder, and Mux), but realized that the complex control paths required for instructions like `JALR` created excessive top-level wiring overhead. This taught me that **strategic encapsulation** often yields cleaner, more maintainable hardware than strict modularity.

2.  **Verification Reliability:** I gained deep insight into the importance of **synchronous design**. Integrating Google Test demonstrated how **Automated Regression Testing** saves significant debugging time compared to manual waveform inspection.

3.  **Process Efficiency (DevOps):** Setting up the build automation script (`doit.sh`) taught me that **investing in tooling upfront** drastically reduces iteration time. Enabling sub-second testing allowed me to fail fast and fix fast, which was critical for meeting the deadline.
