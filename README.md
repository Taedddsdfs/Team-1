# 🚀 Team-1: Single Cycle RISC-V CPU  TESTBENCH workflow

* **--- Jingting&Team-1** *

Welcome to the Team-1 RISC-V Project. This repository contains the implementation and verification environment for a Single Cycle RISC-V CPU.

## 🛠️ Prerequisites (Environment Setup)

Before running the simulation, ensure you are running on **WSL (Windows Subsystem for Linux)** or a **native Linux environment** and have the necessary tools installed:

* **G++**: Compiler supporting C++17
* **Verilator**: For simulation
* **Google Test**: For unit testing
* **RISC-V Toolchain**: For compiling assembly tests
* **Bash**

### Install dependencies on Ubuntu/WSL

Run the following commands to install the required packages:

```bash
# Update package list
sudo apt update

# Install Verilator, GTest, and RISC-V GCC
sudo apt install verilator libgtest-dev google-mock libgtest-dev gcc-riscv64-unknown-elf
```
## 📂 Project Structure Check

Please ensure your directory structure looks like this before running commands. **You must execute commands from the root directory (`repo/`).**

```text
repo/
├── rtl/               # SystemVerilog source files
├── obj_dir/           # Generated C++ model (created by Verilator)
├── tb/
│   └── tests/
│       ├── Top_singleCycle_tb.cpp   # <--- Check for this file
│       └── compile_singleCycle.sh   # <--- Check for this file
└── ...
```
### Step 2: Generate Verilator Model & Library

**Important:** Before compiling the testbench, you must generate the C++ model from the SystemVerilog files.

```bash
# 1. Generate C++ model (Ignore non-fatal warnings)
verilator -Wall -Wno-fatal --cc --trace rtl/top.sv --prefix Vdut -O3 --CFLAGS "-std=c++17" -Irtl

# 2. Build the static library (creates obj_dir/Vdut__ALL.a)
make -j -C obj_dir -f Vdut.mk
```

### Step 3: Grant Permission to Script

Ensure the assembly compilation script is executable so the testbench can invoke the assembler.

```bash
chmod +x tb/tests/compile_singleCycle.sh
```

### Step 4: Compile the Testbench 🏗️

Link the Google Test framework, Verilator library, and your testbench together.

> **Note:** The command below assumes standard Verilator paths on Ubuntu/WSL. If you installed Verilator in a custom location, you may need to adjust the include paths.

```bash
g++ -std=c++17 \
  -Iobj_dir \
  -I/usr/share/verilator/include \
  -I/usr/share/verilator/include/vltstd \
  -Itb/tests \
  tb/tests/Top_singleCycle_tb.cpp \
  obj_dir/Vdut__ALL.a \
  /usr/share/verilator/include/verilated.cpp \
  /usr/share/verilator/include/verilated_vcd_c.cpp \
  -lgtest -lgtest_main -lpthread \
  -o sim_cpu
```

### Step 5: Run the Simulation ▶️

Execute the binary to run all test cases defined in the testbench.

```bash
./sim_cpu
```

## ✅ Expected Output

If the simulation runs successfully, you should see the **Google Test** summary indicating that all tests passed:

```text
[==========] Running 5 tests from 1 test suite.
[----------] Global test environment set-up.
[----------] 5 tests from CpuTestbench
[ RUN      ] CpuTestbench.Test1_AddiBne
[       OK ] CpuTestbench.Test1_AddiBne (XX ms)
[ RUN      ] CpuTestbench.Test2_Arithmetic
[       OK ] CpuTestbench.Test2_Arithmetic (XX ms)
...
[==========] 5 tests from 1 test suite ran. (XX ms total)
[  PASSED  ] 5 tests.
```

## 🌊 Viewing Waveforms (Debugging)

If you enabled tracing in the Verilator command (**Step 2**), a `.vcd` file (usually `waveform.vcd` or similar) will be generated after running the simulation. You can view it using **GTKWave**:

```bash
# Install GTKWave if you haven't
sudo apt install gtkwave

# Open the waveform
gtkwave waveform.vcd
```
