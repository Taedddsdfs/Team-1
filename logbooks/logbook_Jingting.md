# 📔 Team-1 RISC-V Single Cycle CPU - Development Logbook

* **Author:** Jingting 
* **Period:** Dec 1, 2025 - Dec 6, 2025
* **Platform:** WSL (Ubuntu 22.04) on Windows

---

## 📅 Day 1: Environment Setup & Compilation Struggles
**Date:** Dec 1, 2025
**Objective:** Clone the repository and compile the initial simulation environment using Verilator.

### 🔴 Problem 1: Git Clone Failure
* **Issue:** Attempted to clone a subdirectory URL (`.../tree/single-cycle/repo/rtl`), resulting in "repository not found".
* **Solution:** Learned that Git clones the root. Cloned the full repo and checked out the `single-cycle` branch.

### 🔴 Problem 2: Directory Chaos
* **Issue:** Scripts (`f1.sh`) failed with "No such file" errors.
* **Root Cause:** Running scripts from inside `tb/tests/` instead of the project root `repo/`, breaking relative paths like `rtl/top.sv`.
* **Solution:** Established a standard workflow: **Always execute commands from the `repo/` root directory.**

### 🔴 Problem 3: C++ Linking Errors
* **Issue:** "Multiple definition of ..." errors during Verilator compilation.
* **Root Cause:** `tbSingleCycleF1.cpp` included `vbuddy.cpp` directly, but the command line also compiled `vbuddy.cpp`, causing double definitions.
* **Solution:** Removed `vbuddy.cpp` from the Verilator command arguments since it was already included in the header. Added missing `<string>` headers to `vbuddy.cpp`.

> **✅ Status:** Compilation successful (`obj_dir/Vtop` generated).

---

## 📅 Day 2: The "VBuddy" Hardware Integration
**Date:** Dec 2, 2025
**Objective:** Connect the Verilator simulation to the physical VBuddy hardware (F1 Lights Test).

### 🔴 Problem 1: WSL USB Access
* **Issue:** Error opening port: `/dev/ttyUSB0` and Segmentation fault.
* **Solution:**
    1.  Created `vbuddy.cfg` config file.
    2.  Used Windows PowerShell (`usbipd attach`) to pass-through the USB device to WSL.
    3.  Granted permissions in Linux: `sudo chmod 777 /dev/ttyUSB0`.

### 🔴 Problem 2: Communication Hang ("Loading rom..." Freeze)
* **Issue:** Simulation stuck at initialization.
* **Root Cause:** Handshake signals (`ack`) in `vbdHeader` were blocking because the VBuddy hardware wasn't responding in time.
* **Solution:** Implemented a "Hot-Plug" reset strategy and used the physical **Black Reset Button** on VBuddy to sync the connection.

### 🔴 Problem 3: The "Dark LED" Mystery (Protocol Mismatch)
* **Issue:** Terminal showed correct CPU logic (`a0` sequence: 1, 3, 7...), but physical LEDs remained off.
* **Debug:** Verified CPU logic was perfect. Suspected driver incompatibility.
* **Solution:** Discovered the VBuddy firmware required **ASCII Protocol** (`$B,val`) instead of the Raw Binary Protocol (`'B', val`) used in the original driver.
* **Fix:** Rewrote `vbdBar()` in `vbuddy.cpp` to send ASCII strings. Success! F1 Lights worked.

> **✅ Status:** Hardware loop closed. Visual verification passed.

---

## 📅 Day 3: Moving to Industrial Verification (Google Test)
**Date:** Dec 4, 2025
**Objective:** Migrating from manual visual tests to automated Unit Tests using Google Test (GTest).

### 🔄 Refactoring
Adopted a structured C++ Testbench architecture:
* `base_testbench.h`: GTest setup/teardown.
* `testbench.h`: Clock drive (`runSimulation`).
* `Top_singleCycle_tb.cpp`: Specific test cases.

### 🔴 Problem 1: Linker Errors
* **Issue:** `undefined reference to 'ticks'`.
* **Solution:** Defined the global variable `unsigned int ticks = 0;` in the top-level testbench file.

### 🔴 Problem 2: Dependency Hell
* **Issue:** `fatal error: gtest/gtest.h: No such file`.
* **Solution:** Installed libgtest-dev via apt.

> **✅ Status:** Testbench infrastructure ready.

---

## 📅 Day 4: Automation & The Final "Magic Number" Bug
**Date:** Dec 5-6, 2025
**Objective:** Pass all 5 assembly test cases (`addi`, `li`, `lbu`, `jal`, `pdf`) automatically.

### 🔴 Problem 1: Script Paths
* **Issue:** `sh: 1: tb/tests/compile.sh: not found`.
* **Solution:** Fixed relative paths in `system()` calls to match the root execution context (`tb/tests/compile_singleCycle.sh`).

### 🔴 Problem 2: The "63 vs 254" Data Corruption
* **Issue:** Test1_AddiBne Failed. Expected **254**, got **63**.
* **Investigation:** The simulation was running, but data was garbage.
* **Root Cause:** The RISC-V compilation script (`compile_singleCycle.sh`) used an obsolete flag `--width=4` for `objcopy`, which the local toolchain ignored. This resulted in a malformed `program.hex`.
* **Solution:** Updated the script to use `--verilog-data-width=4`.

### 🏁 Final Result
Re-ran `./sim_cpu`:

```text
[==========] Running 5 tests from 1 test suite.
[  PASSED  ] 5 tests.
```

