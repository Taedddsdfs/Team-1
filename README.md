## Component: Program Counter  and Instruction Fetch (Lead: Tae hun)

### Key Features

- **Integrated Flow Control:** Handles `PC+4`, `Branch/JAL` (Relative), and `JALR` (Absolute) logic internally, simplifying the Fetch stage.

- **Robust Verification:** Validated using a custom **Google Test** framework, ensuring 100% functional coverage for all jump scenarios.

### Technical Highlight

- **Optimized Testing:** Engineered a C++ based testbench linked with GTest, enabling sub-second regression testing compared to traditional simulation waves.

- **Synchronous Design:** Implemented strict synchronous reset logic to guarantee deterministic startup states for system-level integration.


# 🚀 RISC-V CPU System Verification & F1 Demo Guide

| **Category** | **Details** |
| :--- | :--- |
| **Project** | Team-1 Single Cycle RISC-V CPU |
| **Environment** | Linux / WSL (Ubuntu 22.04 recommended) ||
| **Author** | Jingting|

> **Overview:** This document outlines the steps to reproduce the automated regression tests (5 Assembly Test Cases) and the F1 Light Sequence demonstration.

---

## 0. Prerequisites & Environment Setup

Before running the simulations, ensure the necessary toolchain is installed and the directory structure is correct.

### 1.1 Install Dependencies

Run the following commands to install the simulation and compilation tools:

```bash
# Update package list
sudo apt-get update

# 1. Install Verilator (HDL Simulator)
sudo apt-get install verilator

# 2. Install GCC Cross-Compiler (For compiling RISC-V Assembly)
sudo apt-get install gcc-riscv64-unknown-elf

# 3. Install Google Test (For the C++ Verification Framework)
sudo apt-get install libgtest-dev
# (Note: On standard Ubuntu/WSL, manual compilation of GTest is usually not required)

# 4. Install GTKWave (Optional, for waveform viewing)
sudo apt-get install gtkwave
```

### 1.2 Verify Directory Structure

Ensure your project root (repo) follows this strict structure, as the scripts rely on relative paths:

```
Plaintext

repo/
├── rtl/                     # Hardware Source Code
│   ├── top.sv
│   ├── ... (other .sv files)
│   └── gaussian.mem         # [CRITICAL] Data file for Test 5 must be here
├── tb/                      # Testbench & Tools
│   ├── asm/                 # Assembly Source (1_addi.s ... 5_pdf.s, f1.s)
│   ├── verify.cpp           # GTest Regression Testbench
│   ├── doit.sh              # Build Automation Script
│   └── compile.sh           # Assembly Compiler Script

```


## 1. Automated Regression Test (5 ASM Cases)

> **Objective:** Verify the CPU logic against 5 standard assembly programs, covering arithmetic, branching, memory access, and complex algorithms (PDF/Gaussian).

### Execution Steps

**Step 1: Navigate to the Testbench Directory**
```bash
cd repo/tb
```
**Step 2: Grant Execution Permissions Ensure the scripts are executable before running them.**

```Bash

chmod +x doit.sh compile.sh
```
**Step 3: Run the Verification Script Execute the following command. This script will automatically compile the hardware, link the Google Test library, and run the test cases defined in verify.cpp.**

```Bash

./doit.sh verify.cpp
```

✅ Expected Output
You should see a green "PASSED" message indicating all tests, including the complex Gaussian PDF calculation, have passed.

```Plaintext

[==========] Running 5 tests from 1 test suite.
[----------] Global test environment set-up.
[ RUN      ] CpuTestbench.Test1_AddiBne
[       OK ] CpuTestbench.Test1_AddiBne (xx ms)
[ RUN      ] CpuTestbench.Test2_LiAdd
[       OK ] CpuTestbench.Test2_LiAdd (xx ms)
...
[ RUN      ] CpuTestbench.Test5_Pdf
Data Memory: Loaded gaussian.mem from ../rtl/gaussian.mem
[       OK ] CpuTestbench.Test5_Pdf (xx ms)
[----------] Global test environment tear-down
[==========] 5 tests from 1 test suite ran.
[  PASSED  ] 5 tests.
Success! All 5 test(s) passed!

```
## 2. F1 Light Sequence DemoObjective: Compile and run the specific F1 starting light assembly program.
   
**Step 1: Compile the Assembly CodeUse the provided compile.sh script. This handles the RISC-V compilation, memory mapping (offset 0xBFC00000), and Hex formatting.**

```Bash
# Assuming you are still in the repo/tb/ directory
./compile.sh asm/f1.s
```
  ***System Action***: This command generates a program.hex file in the ../rtl/ directory. The CPU's Instruction Memory is hardwired to read this file upon reset.

**Step 2: Run the SimulationExecute the simulation using your top-level testbench (e.g., top_tb.cpp or whichever file you use for VBuddy/Waveforms).**

```Bash

./doit.sh tbSingleCycleF1.cpp
```
**Step 3: Verify Results**

- Via Waveform (GTKWave):

```Bash
gtkwave obj_dir/Vdut.vcd
```
Inspect the `a0` output signal. It should match the F1 sequence: `1` (001) $\to$ `3` (011) $\to$ `7` (111) $\to$ ...

 - Via VBuddy (If connected):Ensure the USB device is attached. The LEDs on the VBuddy should increment and then turn off, matching the simulation logic.
 
## 3. Troubleshooting Guide

**1. Test 5 Fails (Got a0 = 808 or 200)**

 - **Cause**: The rtl/gaussian.mem data file is missing, corrupted, or contains metadata tags (e.g., [source...]).
 
 - **Fix**: Ensure gaussian.mem contains only pure hexadecimal numbers and is located strictly in the repo/rtl/ directory.

**2. Verilator Error: "Did not find file"**
 - **Cause**: The script is being run from the wrong directory.

 - **Fix**: Always execute commands from inside the repo/tb/ directory.

**3. Linker Error:** "undefined reference to ticks"

- **Cause**: The C++ testbench is missing the global tick counter definition required by the header file.
- **Fix**: Add unsigned int ticks = 0; at the top of your .cpp testbench file.

***Visual demo*** **@^_^@**


![f1](https://github.com/user-attachments/assets/d05414e9-844d-4558-bd76-ae899fe05c2a)


## 🌊 Viewing Waveforms (Debugging)

If you enabled tracing in the Verilator command (**Step 2**), a `.vcd` file (usually `waveform.vcd` or similar) will be generated after running the simulation. You can view it using **GTKWave**:

```bash
# Install GTKWave if you haven't
sudo apt install gtkwave

# Open the waveform
gtkwave waveform.vcd
```
