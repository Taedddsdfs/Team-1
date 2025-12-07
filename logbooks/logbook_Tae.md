# 📔 Engineering Logbook: RISC-V Processor Design

**Author:** Taehun
**Role:** Core Module Lead (PC) & Verification Architect
**Module Focus:** Program Counter, Test Infrastructure, Control Flow Logic

---

## 📅 Part 1: Infrastructure Setup (Nov 30)

### 1.1 Repository Structure & Automation
**Goal:** Establish a clean workspace and automated build system.

* **Action:** Organized the repository into `rtl/` and `tb/` and developed **`build.sh`**.
* **Impact:** The script automates Verilator and GTest compilation, linking standard flags (`-Wall -g -std=c++11`). This reduced the build/test iteration time from minutes to seconds.

---

## 📅 Part 2: PC Module Architecture (Dec 1 - Dec 2)

### 2.1 Design Decision: Integrated Next-PC Logic
**Goal:** Implement the Program Counter with built-in flow control.

* **Implementation:** Instead of using an external adder and mux, I integrated the Next-PC logic directly into the `program_counter` module using a `case` statement.
    * **Code Structure:**
        ```systemverilog
        case (PCSrc)
            2'b00: PC <= PC + 4;      // Sequential
            2'b01: PC <= PC + ImmOp;  // Branch / JAL (Internal Adder)
            2'b10: PC <= ALUResult;   // JALR (Absolute Address)
        endcase
        ```
* **Benefit:** This encapsulates the fetch logic, simplifying the top-level schematic and reducing wiring complexity.

### 2.2 Synchronous Reset Implementation
**Issue:** Initial designs using asynchronous reset caused undefined states (`X`) at simulation time zero.
**Fix:** Adopted strict **Synchronous Reset** (`if (rst)` inside `always_ff @(posedge clk)`).
* **Result:** The PC reliably initializes to `32'h0` only on the rising clock edge, ensuring deterministic startup behavior essential for GTest verification.

---

## 📅 Part 3: Advanced Control Flow Verification (Dec 3 - Dec 5)

### 3.1 Handling JALR (Jump and Link Register)
**Challenge:** `JALR` requires jumping to an absolute address calculated by the ALU (`rs1 + imm`), unlike `JAL` which is relative.
**Solution:** Added the `2'b10` state to the PC mux to accept `ALUResult` directly as the next PC value. This created a necessary feedback loop from the Execute stage back to the Fetch stage.

### 3.2 F1 Program Verification
**Observation:** The F1 light sequence relies heavily on `BNE` loops.
**Debugging:** Verified that the `ImmOp` input correctly received the sign-extended immediate value, allowing the `PC <= PC + ImmOp` logic to jump backwards (negative offset) correctly.

---

## 📅 Part 4: Final System Integration (Dec 6)

### 4.1 Integration & Evidence
**Goal:** Finalize deliverables.
* **Outcome:** Successfully ran the Gaussian PDF reference program (`5_pdf.s`).
* **Verification:** Validated that the PC correctly sequenced through 1,000,000+ cycles without drifting, proving the robustness of the reset and mux logic.
