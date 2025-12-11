# RISC V RV32I Design Coursework

---

Zhengran Han         CID: 02583845        

---

### Introduction 

My main contribution in the group was implementing the datapath and control logic needed for pipelining and cache. I designed the sign-extension unit and control unit for the single-cycle CPU, then extended them with the PRDE stage and pipelined top module. I also implemented the 2-way data cache module and helped debug the cache-related testbench so that the pipelined CPU passes the provided tests.

---

### Overview

* [Sign Extension Unit](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/extend.sv)
* [control_unit](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/controlunit.sv)
* [PRFD-pipeline](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/PRFD.sv)
* [PRMW-pipeline](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/PRMW.sv)
* [top-pipeline]()
* [cache_memory](https://github.com/Taedddsdfs/Team-1/blob/main/repo/rtl/data_cache.sv)
* [debug for cache]()
