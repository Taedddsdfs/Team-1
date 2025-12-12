# RISC-V Design Team-1 Statement

## Overview

### Processor

### link to individual statements

### link to individual statements
[Jingting's Personal statement](/statements/Jingting_statement.md)

[Zhengran's Personal statement](/statements/Zhengran_statement.md)

[Tae Hun's Personal statement](/statements/Tae_statement.md)

[Fengye's Personal statement](/statements/Fengye_statement.md)


## Contribution Table

**Note:** o = Main Contributor; v = Co-Author

| Task | Item name |  Jingting | Zhengran | Tae Hun | Fengye |
|------|--------|---------|--------|---------|-------|
| Single cycle | F1 Program |o| | | |
| | program counter | | |o| |
| | instruction memory |v| |o| |
| | register file | | |v|o|
| | alu |v| | |o|
| | sign extension | |o| | |
| | data memory |v| | |o |
| | control unit |v|o| | |
| | top |v|v|v|o| 
| | testbench and debug |v| |v|o|
| Pipeline | PRDE |o|v| | |
| | PREM |o|v| | |
| | PRFD |v|o| | |
| | PRMW |v|o| | |
| | hazard unit |o| | | |
| | top |v|o|v|v|
| | testbench and debug |v| | |o|
| Cache | cache_mem |v|o| | |
| | top |o|v|v|v|
| | testbench and debug |o|v| | |

## Directory Structure
the structure of the main branch is as follows:

```markdown
repo
repo
├── rtl
│   ├── PRDE.sv
│   ├── PREM.sv
│   ├── PRFD.sv
│   ├── PRMW.sv
│   ├── aludec.sv
│   ├── alu.sv
│   ├── data_cache.sv
│   ├── controlunit.sv
│   ├── data_mem.sv
│   ├── extend.sv
│   ├── hazard_unit.sv
│   ├── instruction_memory.sv
│   ├── maindec.sv
│   ├── mux2.sv
│   ├── mux3.sv
│   ├── program_counter.sv
│   ├── reg_file.sv
│   └── top.sv
│
└── tb
    ├── asm
    │   ├── 1_addi_bne.s
    │   ├── 2_li_add.s
    │   ├── 3_lbu_sb.s
    │   ├── 4_jal_ret.s
    │   ├── 5_pdf.s
    │   ├── f1_light.s
    │   └── program.s
    │
    ├── c
    │
    ├── reference
    │   └── gaussian.mem
    │
    ├── tests
    │   ├── base_testbench.h
    │   ├── cpu_testbench.h
    │   ├── testbench.h
    │   ├── verify.cpp
    │   ├── vbuddy.cpp
    │   ├── top-f1
    │   └── top-f1Wave
    │—— base_testbench.h
    |--- testbench.h
    ├── assemble.sh
    ├── compile.sh
    ├── doit.sh
    └── vbuddy.cfg

```
## Directories
1. [rtl](https://github.com/Taedddsdfs/Team-1/tree/main/repo/rtl): holds all the .sv programs for the module designs
2. [statements](https://github.com/Taedddsdfs/Team-1/tree/main/statements): holds the personal statements
3. [tb](https://github.com/Taedddsdfs/Team-1/tree/main/repo/tb):
    1) [asm](https://github.com/Taedddsdfs/Team-1/tree/main/repo/tb/asm): holds all the assembly code program .s
    2) [tests](https://github.com/Taedddsdfs/Team-1/tree/main/repo/tb/tests): holds all the cpp testbench programs of the modules in rtl
    3) the shell scripts .sh files


## RISC-V CPU System Verification with F1 Demo and Vbuddy Graph Plots

| **Category** | **Details** |
| :--- | :--- |
| **Project** | Team-1 RISC-V CPU |
| **Environment** | Linux / WSL (Ubuntu 22.04 recommended) ||
| **Author** | Jingting|

> **Overview:** This document outlines the steps to reproduce the automated regression tests (5 Assembly Test Cases)， the F1 Light Sequence demonstration and vbuddy graph plots.

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

Ensure your project root (repo) follows the structure showing above, as the scripts rely on relative paths


## 1. Automated Regression Test (5 ASM Cases)

> **Objective:** Verify the CPU logic against 5 standard assembly programs, covering arithmetic, branching, memory access, and complex algorithms (PDF/Gaussian).

### Execution Steps

**macOS: GoogleTest Environment Setup（Optional)**

On macOS, if you installed GoogleTest via Homebrew:

```bash
brew install googletest
```
Must set the following environment variables before running the Verilator tests.

```bash
GTEST_ROOT=$(brew --prefix googletest)

export CPLUS_INCLUDE_PATH="$GTEST_ROOT/include:$CPLUS_INCLUDE_PATH"
export LIBRARY_PATH="$GTEST_ROOT/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$GTEST_ROOT/lib:$LD_LIBRARY_PATH"
```

**Step 1: Navigate to the Testbench Directory**
```
Ubuntu
cd repo/tb
```
**Step 2: Grant Execution Permissions Ensure the scripts are executable before running them.**

```
Ubuntu
chmod +x doit.sh compile.sh
```
**Step 3: Run the Verification Script Execute the following command. This script will automatically compile the hardware, link the Google Test library, and run the test cases defined in verify.cpp.**

```Bash
Ubuntu
./doit.sh tests/verify.cpp
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
## 2. F1 Light Sequence Demo

Objective: Compile and run the specific F1 starting light assembly program.

**1. Prerequisites**

-**Software**: Verilator, RISC-V Toolchain (riscv64-unknown-elf), USBIPD (for WSL users).

-**Hardware**: VBuddy connected via USB.

**2. Setup (Hardware)**

Connect VBuddy.

(WSL Users) Attach USB in PowerShell (Admin): `usbipd attach --wsl --busid <BUSID>`.

Verify in Linux terminal: ls /dev/ttyUSB* should show the device. (if it is not /dev/ttyUSB0, change the content in vbuddy.cfg)

**3. Execution Navigate to the testbench folder and run the driver script:**

make sure u r under tb, by typing `cd Team-1/repo/tb`

**If connect with vBuddy to see the LED, run:**
```
Ubuntu
./doit.sh tests/top-f1.cpp
```

**If u only need the waveform:**

```
Ubuntu
./doit.sh tests/top-f1Wave.cpp
```
   
**4: Verify Results**

- Via Waveform (GTKWave):

```
Ubuntu
gtkwave waveform.vcd
```

Inspect the `a0` output signal. It should match the F1 sequence: `1` (001) $\to$ `3` (011) $\to$ `7` (111) $\to$ ...

![cb55b41c4c94d52068841811881add9f](https://github.com/user-attachments/assets/19d85035-5b3c-49bd-acf1-899bc04db50e)


 - Via VBuddy (If connected):Ensure the USB device is attached. The LEDs on the VBuddy should increment and then turn off, matching the simulation logic.
   ***Visual demo*** **@^_^@**


![f1](https://github.com/user-attachments/assets/d05414e9-844d-4558-bd76-ae899fe05c2a)
 
## 3.Vbuddy Graph Plots:



## Viewing Waveforms (Debugging)

If you enabled tracing in the Verilator command (**Step 2**), a `.vcd` file (usually `waveform.vcd` or similar) will be generated after running the simulation. You can view it using **GTKWave**:

```bash
# Install GTKWave if you haven't
sudo apt install gtkwave

# Open the waveform
gtkwave waveform.vcd
```

## Evidence of tests passing

### Test programs:
![Console after running tests]()

To run tests, change data_memory.sv and instruction_memory.sv to .../data.hex and .../program.hex respectively.

### F1:



link



To run F1 with Vbuddy, run F1.sh.

### PDF:

Graphs generated after viewing from Vbuddy:

#### Gaussian
<img width="535" height="319" alt="648907a1d6739317108170d5c5037dc0" src="https://github.com/user-attachments/assets/bdfe2820-0640-4576-85e8-25ee0b519083" />

#### Noisy
<img width="535" height="319" alt="11c8f53ea9267f8409c92a8df10b684d" src="https://github.com/user-attachments/assets/7e5429df-9e7e-46b2-bd40-6d9c380c9e54" />

#### Triangle
<img width="535" height="319" alt="222891c765fedada2d7eee3851997c3b" src="https://github.com/user-attachments/assets/7c97293a-e450-45b6-a66a-48b45c955e38" />

To run PDF with Vbuddy, run PDF.sh.
