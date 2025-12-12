## 📝 Personal Statement: RISC-V Processor Design

**Author:** Taehun  
**Role:** Core Module Lead (PC), Co-Author (Register File, Control Unit, Top-Level for pipeline and cache) & Verification Architect & Reference
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
* **Evidence:** [View Commit ed53660](https://github.selfsdad/Team-1/commit/ed53660) (Implemented Role 1: PC with internal flow control logic)

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

## Part 5: Verification and Reference Programs

### 5.1 Comprehensive Functional Verification
**Role:** Designed and executed a comprehensive verification suite to test the processor's core functionality and performance under various workloads.
* **Reference Programs:** Utilized four specific memory reference files to test the processor's capability to correctly handle and compute different data patterns:
    * `gaussian.mem`: Tested complex arithmetic and data processing integrity.
    * `noisy.mem`: Tested robustness against varied and potentially extreme input data.
    * `triangle.mem`: Verified sequential and predictable data handling.
    * `sine.mem`: Tested floating-point emulation/fixed-point arithmetic (depending on implementation) and periodic data calculations.
* **Outcome:** Successful execution and verification against known outputs confirmed the functional correctness of the integrated pipeline, hazard unit, and register operations across diverse computational tasks.
#### Gaussian
<img width="535" height="319" alt="648907a1d6739317108170d5c5037dc0" src="https://github.com/user-attachments/assets/bdfe2820-0640-4576-85e8-25ee0b519083" />

#### Noisy
<img width="535" height="319" alt="11c8f53ea9267f8409c92a8df10b684d" src="https://github.com/user-attachments/assets/7e5429df-9e7e-46b2-bd40-6d9c380c9e54" />

#### Triangle
<img width="535" height="319" alt="222891c765fedada2d7eee3851997c3b" src="https://github.com/user-attachments/assets/7c97293a-e450-45b6-a66a-48b45c955e38" />
---

## Part 6: Pipelined Processor Integration & Cache (Co-Author)

### 6.1 5-Stage Pipelined Datapath Assembly
**Role:** Co-authored the top-level integration, establishing the **5-Stage Pipelined Architecture** (IF, ID, EX, MEM, WB).
* **Core Mechanism:** Connected four pipeline registers (`PRFD`, `PRDE`, `PREM`, `PRMW`) to transfer control and data signals, optimizing for instruction throughput.
* **Memory Stage Upgrade:** Integrated the **`data_cache`** module in the Memory (M) stage, replacing the simple `data_mem`. This structural change introduced considerations for handling cache hits/misses, demonstrating an understanding of the memory hierarchy. 


### 6.2 Hazard Resolution Implementation
**Key Contribution:** Integrated and configured the **Hazard Unit** to manage pipeline dependencies.
* **Data Forwarding:** Implemented **forwarding paths** using 3-to-1 MUXes in the Execute (EX) stage, delivering results (from MEM or WB) to the ALU inputs (`SrcAE`, `SrcBE`) to minimize stalls.
* **Control Hazard Resolution:** Enabled the Hazard Unit to generate the `FlushD` signal upon a taken branch (`PCSrcE` high), immediately invalidating instructions in the Decode stage.

---

## Part 7: Reflection

**What I learned:**

1.  **Pipelining Complexity:** Transitioning to pipelined design highlighted that complexity shifts from component logic to **system integration** and **hazard management**. The performance challenge lies in coordinating data flow and timing across the pipeline registers.

2.  **Memory Hierarchy Integration:** Replacing the simple memory with a **cache** (Part 6.1) introduced real-world performance considerations. This demonstrated that optimizing a CPU requires balancing core logic with the speed of external resources (memory access latency).

3.  **Architectural Trade-offs:** The initial decision to encapsulate PC logic (Part 2) simplified the final Top-Level wiring (Part 6), reinforcing the value of **strategic upfront design** even in modular hardware.

4.  **Design for Testability (DFT):** The use of the `a0` output port (Part 3) proved invaluable, allowing the team to debug complex, concurrent issues across the five pipeline stages, confirming the importance of designing with the "tester" mindset.
