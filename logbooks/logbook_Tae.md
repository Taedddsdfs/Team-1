# Engineering Logbook: RISC-V Processor Design

**Author:** Taehun
**Role:** Core Module Lead (PC) & Verification Architect
**Module Focus:** Program Counter, Test Infrastructure, Control Flow Logic

---

## Part 1: Infrastructure Setup

### 1.1 Repository Structure & Automation
**Goal:** Establish a clean workspace and automated build system.
* **Action:** Organized the repository into `rtl/` and `tb/` and configured the **`doit.sh`** build script.
* **Impact:** Adapted the instructor-provided build system to link **Google Test** libraries (`-lgtest`), reducing the build/test iteration time **from minutes to seconds**.

---

## Part 2: PC Module Architecture

### 2.1 Design Decision: Integrated Next-PC Logic (Updated)
**Goal:** Implement the Program Counter with built-in flow control.
* **Evolution:** Initially planned to implement **PC, Mux, and Adder as separate modules (sv file)**.
* **Issue:** Found that interconnecting these separate components at the top level created unnecessary wiring complexity and made debugging difficult.
* **Decision & Implementation:** Merged them into a single `program_counter` module.
    * Used a `case` statement to handle Next-PC logic (PC+4, Branch, JALR) internally.
    * **Benefit:** Significantly reduced top-level structural complexity and improved code readability.

### 2.2 Synchronous Reset Implementation
**Issue:** Initial designs using asynchronous reset caused undefined states (`X`) at simulation time zero.
**Fix:** Adopted strict **Synchronous Reset**.
* **Result:** The PC reliably initializes to `32'h0` only on the rising clock edge, ensuring deterministic startup behavior essential for GTest verification.

### 2.3 Verification Strategy (Unit Testing)
**Goal:** Verify the PC module's logic in isolation before system integration.
* **Testbench Architecture:** Used **Google Test (GTest)** for self-checking verification.
* **Verified Scenarios:**
    1.  **ResetTest:** Confirmed `PC` resets to `0`.

    2.  **SequentialLogic:** Verified `PC` increments by 4.
    3.  **BranchLogic:** Verified relative jumping (`PC + ImmOp`).
    4.  **JALRLogic (Critical):** Verified absolute address jumping (`PC = ALUResult`).
        * *Validation:* Confirmed correct jump to `0x1000` after a warm-up cycle, proving the priority of the `2'b10` control signal.

---

## Part 3: Final System Integration

### 3.1 Robustness Verification
**Outcome:** Successfully verified all control flow paths (Sequential, Branch, JAL, JALR).
**Evidence:** The testbench passed all scenarios with 100% assertions met. 
<img width="959" height="198" alt="image" src="https://github.com/user-attachments/assets/2e565e74-794e-412a-9fb1-0d430a80e1e7" />

