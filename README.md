RISC-V RV32I Pipelined Processor Design & Debugging Report
Author: [Your Name/Team Name]

Date: 2025-12-09

Subject: Conversion from Single-Cycle to 5-Stage Pipeline, Hazard Handling, and Verification

1. Introduction (引言)
本项目的主要任务是将基于 SystemVerilog 的单周期 RISC-V 处理器重构为五级流水线（5-Stage Pipeline）架构。目标是通过指令级并行（ILP）提高 CPU 的吞吐量。

在今天的开发冲刺中，我主要完成了数据通路的最终整合、流水线寄存器（Pipeline Registers）的互连、以及最关键的——通过 Google Test 框架结合 Verilator 进行全覆盖的指令集验证。

这一过程并非一帆风顺，从最初的“全零输出”到最终的点亮所有测试点（包括复杂的 Gaussian Blur 算法），我经历了一系列涉及 Testbench 环境、RTL 信号连接、控制单元逻辑以及内存加载机制的复杂 Bug。

2. Pipelined Architecture Design (流水线架构设计)
为了实现流水线，我将处理器的逻辑划分为五个独立的阶段。每个阶段之间通过流水线寄存器（Pipeline Register）进行隔离，确保时钟信号能同步推动指令在不同阶段流动。

2.1 The 5 Stages
Fetch (IF):

核心模块: program_counter, instruction_memory, mux2 (PCMux)

功能: 根据当前 PC 从指令内存中取指。PC 的更新逻辑在这里处理（正常 +4 或 跳转）。

设计细节: 引入了 StallF 信号（来自 Hazard Unit），当发生 Load-Use Hazard 时，保持 PC 不变。

Decode (ID):

核心模块: controlunit, reg_file, extend

功能: 对 IF 阶段传来的指令进行解码，读取寄存器堆（RegFile），并扩展立即数（ImmExt）。

设计细节: 这里是控制信号生成的源头。所有的控制信号（如 MemWrite, RegWrite, Jump 等）在这里产生，并随流水线寄存器向后传递。

Execute (EX):

核心模块: alu, mux3 (Forward Muxes), mux2 (Src Muxes)

功能: 执行算术逻辑运算，计算跳转目标地址（PCTarget）。

设计细节: 这是数据冒险（Data Hazard）解决的核心区域。通过 ForwardAE 和 ForwardBE 信号控制的三路 MUX，决定 ALU 的输入是来自寄存器、WB 阶段的前递数据，还是 MEM 阶段的前递数据。

Memory (MEM):

核心模块: data_mem

功能: 处理 Load/Store 指令，访问数据内存。

设计细节: 这一阶段的 ALUResultM 也是前递逻辑的重要数据源。

Writeback (WB):

核心模块: mux3 (ResultMux)

功能: 将最终结果（来自 ALU、DataMemory 或 PC+4）写回寄存器堆。

2.2 Pipeline Registers (流水线寄存器)
为了隔离各阶段，我实现了四个流水线寄存器模块。它们采用后缀命名法（如 _d, _e, _m, _w）来严格区分不同阶段的信号，防止跨阶段的信号竞争。

PRFD: IF -> ID。负责传递 InstrF, PCF, PCPlus4F。包含 StallD 和 FlushD 逻辑。

PRDE: ID -> EX。这是最宽的寄存器，传递所有控制信号（RegWriteD 等）和数据（RD1D, RD2D 等）。包含 FlushE 逻辑（用于 Control Hazard）。

PREM: EX -> MEM。传递 ALU 计算结果和写内存数据。

PRMW: MEM -> WB。传递最终读取的数据和 ALU 结果。

3. Debugging Log & Solutions (调试日志与解决方案)
今天的调试过程是一场从环境到 RTL 逻辑的深度排查。以下是按时间顺序记录的关键 Bug 及其解决思路。

Bug 1: 全局测试失败与 Testbench 污染
现象: 运行 5 个测试用例，全部 FAIL，且所有测试的输出 a0 均为 0。日志显示在运行纯汇编测试（如 TestAddiBne）时，系统依然在打印 Loading gaussian.mem...。

分析: 这是 C++ Testbench (verify.cpp) 设计模式 的问题。

Fixture 污染: SetUp() 函数中包含了全局的内存加载逻辑。这意味着每个测试开始前都会错误地加载高斯模糊的数据文件，干扰了指令内存的初始化。

指令加载失效: 由于 Verilator 的机制，C++ 端并没有正确地将 program.hex 注入到 RTL 内存中。

解决方案: 重构 verify.cpp，实施测试隔离：

移除了 SetUp() 中的加载逻辑。

实现了 setupTest(name) 函数，每个 TEST_F 单独调用。它负责调用 assemble.sh 生成特定测试的 hex 文件。

实现了 setData(file) 函数，仅在 TestPdf 中显式调用以加载 gaussian.mem。

关键代码变更: 确保 Verilog 侧使用 $readmemh，并配合 C++ 侧正确的文件生成顺序（先生成 hex，再 new Vdut）。

Bug 2: 致命的“未驱动信号” (Undriven Signal)
现象: 环境修复后，测试结果依然为 0。Verilator 报出 Warning: Signal is not driven: 'a0' in instance top.rf.

分析: 这是一个典型的 RTL 连接错误。 虽然 top.sv 定义了输出端口 a0，但在 reg_file.sv 内部，我声明了 output a0，却从未将内部的寄存器数组（registers）连接到这个端口。就像买了一台没插电源的显示器。

解决方案: 在 rtl/reg_file.sv 中添加赋值语句：

代码段

assign a0 = registers[10]; // RISC-V 标准中 x10 寄存器即为 a0 (函数返回值/参数)
此修正立竿见影，测试开始有了非零输出。

Bug 3: JALR 跳转逻辑错误 (The JALR Bug)
现象: TestAddi, TestLi 通过，但 TestJalRet 和 TestPdf 失败。这两个测试都涉及函数调用（Jump and Link）和返回（Return / JALR）。

分析: 这是本次调试中最隐蔽的 逻辑错误。 在 top.sv 的 Execute 阶段，我最初的跳转目标计算逻辑是：

代码段

assign PCTargetE = PCE + ImmExtE; // 错误逻辑
这个公式对于分支指令（BEQ/BNE）和 JAL 是正确的，因为它们都是 PC 相对寻址。 但是，RET 指令实际上是 JALR x0, 0(x1)，它是 基址寄存器相对寻址。RISC-V 规范规定 JALR 的目标是 Rs1 + Imm。 由于我的设计强制使用 PC 作为基准，导致 RET 指令跳到了错误的地址（通常是死循环），程序跑飞。

解决方案: 我们需要区分“基于 PC 的跳转”和“基于寄存器的跳转”。

修改 controlunit.sv: 强制 JAL 指令将 ALUSrcA 设为 1（选择 PC）。而 JALR 保持 ALUSrcA 为 0（选择 Rs1）。

代码段

assign ALUSrcA = (op == 7'b1101111) ? 1'b1 : maindec_ALUSrcA;
修改 top.sv: 利用 ALU 的输入源 SrcAE（它已经被 ControlUnit 正确选择了 PC 或 Rs1）来计算跳转目标：

代码段

// 如果是 Branch，依然用 PC+Imm；如果是 Jump (JAL/JALR)，则用 SrcAE+Imm
assign PCTargetE = (BranchE) ? (PCE + ImmExtE) : (SrcAE + ImmExtE);
Bug 4: 内存数据加载 (The Gaussian Mem Issue)
现象: TestJalRet 修复后通过了，但 TestPdf 依然失败。

分析: TestPdf 运行的是高斯模糊算法，它需要从 Data Memory 的特定地址（0x10000）读取图像数据。如果内存是空的，算法读取到的全是 0，计算结果自然错误。 之前的 verify.cpp 虽然生成了 data.hex，但 Verilog 侧的 data_mem.sv 可能没有正确读取该文件，或者文件名不匹配。

解决方案 (Quick Fix): 采用了“硬编码”方式验证逻辑。在 rtl/data_mem.sv 中显式指定加载路径：

代码段

initial begin
    $readmemh("tests/gaussian.mem", mem, 17'h10000);
end
虽然这降低了通用性，但它证实了 CPU 逻辑的正确性。最终的 [ PASSED ] 5 tests 证明了这一点。

4. Implementation Principles & Design Methodology (实现原理与设计思路)
4.1 从单周期到流水线的思维转变
在单周期设计中，最长的路径（Critical Path，通常是 Load 指令）决定了时钟周期。而在流水线设计中，我们将指令执行拆解。我的设计思路是：“切割与隔离”。

数据通路切割: 我首先在 top.sv 中根据功能将连线切断，插入 PRFD, PRDE 等寄存器模块。

信号命名规范: 这是一个关键的设计决策。我强制要求所有信号带上阶段后缀（如 RegWriteD, RegWriteE, RegWriteM, RegWriteW）。这不仅让代码可读性增强，更防止了不小心在 EX 阶段使用了 ID 阶段信号这种常见的时序错误。

4.2 冒险控制单元 (Hazard Unit) 的设计
虽然流水线提高了吞吐量，但带来了冒险。我设计的 hazard_unit 集中处理以下逻辑：

Data Hazard (RAW): 当 EX 阶段需要的源操作数（Rs1E, Rs2E）依赖于 MEM 或 WB 阶段尚未写回的结果时，Hazard Unit 比较寄存器地址（RdM/W vs Rs1/2E）。

策略: Forwarding (前递)。通过控制 EX 阶段的 MUX，直接将后面阶段的结果“借”给 ALU，避免了停顿，保持了流水线满载。

Load-Use Hazard: 当上一条指令是 Load，且下一条指令需要用该数据时，前递无法解决（因为数据还在内存里）。

策略: Stall (停顿)。Hazard Unit 检测到 ResultSrcE == 01 (Load) 且目标寄存器匹配时，拉高 StallF 和 StallD，并拉高 FlushE（插入气泡）。

Control Hazard (Branch/Jump): 当分支发生时，流水线中已经取出的后续指令是错误的。

策略: Flush (冲刷)。当 PCSrcE 有效（决定跳转）时，我立即置位 FlushD 和 FlushE，清除 ID 和 EX 阶段的错误指令。

4.3 验证驱动开发 (Verification Driven Development)
今天的成功很大程度上归功于建立了一个可靠的 Testbench。

自动化汇编: 利用 assemble.sh 动态生成机器码，使得我可以编写 .s 汇编文件直接测试特定指令（如 addi, jal, ret）。

黑盒测试: 通过监测 a0 寄存器的值来判断测试是否通过，这让我不必盯着波形图看每一根线，极大提高了调试效率。

5. Conclusion & Reflection (总结与反思)
今天的开发过程深刻体现了软硬件协同工作的重要性。

RTL 并非孤岛: 很多时候，Bug 不在 Verilog 代码里，而在 C++ Testbench 的构建方式（如全局加载污染）或工具链的配置（如 hex 文件生成路径）上。

协议的重要性: RISC-V 规范细节决定成败。JALR 的目标地址计算错误是一个典型的“想当然”错误，必须严格遵循 ISA 文档。

调试技巧: 在复杂系统中，**“分而治之”**是王道。如果不先把 JAL（Test 4）修好，就不可能修好依赖函数调用的 TestPdf（Test 5）。通过将问题隔离为“环境问题”、“连接问题”、“逻辑问题”，我们逐个击破了障碍。

目前的 CPU 已经能够运行复杂的高斯模糊算法，证明了流水线架构、冒险处理单元以及数据通路的正确性。接下来的工作将是优化内存加载机制（去除硬编码），并尝试更复杂的基准测试。

End of Report
