#include "testbench.h"      // 课程自带的封装
#include <gtest/gtest.h>
#include <cstdlib>
#include <string>
#include <iostream>

static const int CYCLES = 10000;   // 每个程序最多跑这么多周期

unsigned int ticks = 0;

// 继承课程给的 Testbench 基类
class CpuTestbench : public Testbench {
protected:
    // 初始化顶层输入信号
    void initializeInputs() override {
        top->clk = 0;
        top->rst = 1;   // 先上电复位
    }

    // 做一次干净的复位：拉高 rst 跑几个周期，再拉低
    void applyReset() {
        top->rst = 1;
        runSimulation(2);   // 复位保持几个周期
        top->rst = 0;
    }

    // 通用的“跑一个汇编程序并检查 a0”的函数
    bool runProgram(const std::string &asmFile, uint32_t expected_a0, int maxCycles) {
        // 1) 调用 compile.sh 生成 ../rtl/program.hex
        std::string cmd = "./compile.sh " + asmFile;
        std::cout << "[INFO] Compiling: " << cmd << std::endl;

        int ret = std::system(cmd.c_str());
        if (ret != 0) {
            ADD_FAILURE() << "compile.sh failed for " << asmFile
                          << " (exit code = " << ret << ")";
            return false;
        }

        // 2) 复位 CPU，把 PC 和寄存器状态清干净
        applyReset();

        // 3) 跑 maxCycles 个周期，观察 top->a0
        for (int i = 0; i < maxCycles; ++i) {
            runSimulation(1);

            if (top->a0 == expected_a0) {
                std::cout << "[INFO] " << asmFile
                          << " reached a0 = " << expected_a0
                          << " at cycle " << i << std::endl;
                return true;
            }
        }

        // 如果跑完还没等到期望值，就认为失败
        ADD_FAILURE() << asmFile << ": a0 never reached expected value "
                      << expected_a0 << " within " << maxCycles << " cycles. "
                      << "Final a0 = " << top->a0;
        return false;
    }
};


// ============================================================================
// 1. ALU + LUI / 立即数指令综合功能测试
//    你的汇编里最后 a0 应该 = 22
// ============================================================================
TEST_F(CpuTestbench, AluAndLuiTest) {
    ASSERT_TRUE(runProgram("tests/1_alu_lui_test.s", 22, CYCLES));
}

// ============================================================================
// 2. LOAD / STORE / SB / LBU 测试
//    低 8 位相加，预期 a0 = 34
// ============================================================================
TEST_F(CpuTestbench, LoadStoreTest) {
    ASSERT_TRUE(runProgram("tests/2_load_store_test.s", 34, CYCLES));
}

// ============================================================================
// 3. Forwarding 测试（EX/MEM & MEM/WB 前递）
//    汇编最后构造 a0 = 17
// ============================================================================
TEST_F(CpuTestbench, ForwardingTest) {
    ASSERT_TRUE(runProgram("tests/3_forwarding_test.s", 17, CYCLES));
}

// ============================================================================
// 4. Load-Use Hazard 测试（必须插入 bubble）
//    如果 stall 正确，a0 = 0x57 = 87
// ============================================================================
TEST_F(CpuTestbench, LoadUseHazardTest) {
    ASSERT_TRUE(runProgram("tests/4_loaduse_hazard_test.s", 87, CYCLES));
}

// ============================================================================
// 5. Branch Flush 测试（跳转后一条指令必须被 flush）
//    如果 flush 正确：x1 仍为 0，x2 = 45 → a0 = 45
// ============================================================================
TEST_F(CpuTestbench, BranchFlushTest) {
    ASSERT_TRUE(runProgram("tests/5_branch_flushing_test.s", 45, CYCLES));
}

// ============================================================================
// 6. JAL / AUIPC / MUL （以及 JALR 的基本执行）
//    a0 = x3 + 1 = 22，如果 MUL 正确且中间没被破坏
// ============================================================================
TEST_F(CpuTestbench, JalAuipcMulTest) {
    ASSERT_TRUE(runProgram("tests/6_jal_auipc_mul_test.s", 22, CYCLES));
}


// ============================================================================
// GoogleTest 入口
// ============================================================================
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
