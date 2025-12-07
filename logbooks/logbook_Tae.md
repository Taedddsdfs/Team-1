# Engineering Logbook: RISC-V Processor Design

**Author:** Taehun
**Role:** Core Module Lead (PC) & Verification Architect
**Module Focus:** Program Counter, Test Infrastructure, Control Flow Logic

---

## Part 1: Infrastructure Setup (Nov 30)

### 1.1 Repository Structure & Automation
**Goal:** Establish a clean workspace and automated build system.

* **Action:** Organized the repository into `rtl/` and `tb/` and configured the **`doit.sh`** build script.
* **Impact:** Adapted the instructor-provided build system to link **Google Test** libraries (`-lgtest`), reducing the build/test iteration time from minutes to seconds.

---

## Part 2: PC Module Architecture (Dec 1 - Dec 2)

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
* 
### 2.3 Verification Strategy (Unit Testing)
**Goal:** Verify the PC module's logic in isolation before system integration.

* **Testbench Architecture (`tb/tb.cpp`):**
    * Adopted **Google Test (GTest)** framework to create a self-checking testbench.
    * Implemented a `nextCycle()` helper function to simulate the clock edge (`posedge clk`).

* **Test Scenarios:**
    1.  **ResetTest:** Confirmed `PC` resets to `0` when `rst=1`.
    2.  **SequentialLogic:** Verified `PC` increments by 4 when `PCSrc=00`.
    3.  **BranchLogic:** Verified internal adder logic (`PC + ImmOp`) when `PCSrc=01`.
    4.  **JALRLogic:** Verified absolute address jumping (`PC = ALUResult`) when `PCSrc=10`.
        * *Note:* This was critical to ensure the `case` statement priority was correctly implemented in hardware.
   ## Test Success
![Test environment success](https://raw.githubusercontent.com/YourUsername/YourRepo/main/assets/image_9b0458.png)
---

## Part 3: Advanced Control Flow Verification (Dec 3 - Dec 5)

### 3.1 Handling JALR (Jump and Link Register)
**Challenge:** `JALR` requires jumping to an absolute address calculated by the ALU (`rs1 + imm`), unlike `JAL` which is relative.
**Solution:** Added the `2'b10` state to the PC mux to accept `ALUResult` directly as the next PC value. This created a necessary feedback loop from the Execute stage back to the Fetch stage.

### 3.2 F1 Program Verification
**Observation:** The F1 light sequence relies heavily on `BNE` loops.
**Debugging:** Verified that the `ImmOp` input correctly received the sign-extended immediate value, allowing the `PC <= PC + ImmOp` logic to jump backwards (negative offset) correctly.

