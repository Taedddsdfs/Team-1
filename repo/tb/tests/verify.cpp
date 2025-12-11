#include <iostream>
#include <cstdlib>
#include <utility>

// 包含你提供的头文件
#include "cpu_testbench.h"

// 定义基础时钟周期
#define CYCLES 10000

// --- 调试辅助函数：检查文件是否生成成功 ---
// 这将帮助我们确认 assemble.sh 是否真的工作了
void debug_file_status() {
    std::cout << "\n[DEBUG] Checking environment..." << std::endl;
    std::cout << "  > Current Directory: " << std::flush;
    std::system("pwd");
    std::cout << "  > program.hex status: " << std::flush;
    // 如果文件不存在，ls 会报错，我们就知道问题出在 assemble.sh 没跑通
    std::system("ls -l program.hex 2>/dev/null || echo 'FILE NOT FOUND!'");
    std::cout << "  > data.hex status:    " << std::flush;
    std::system("ls -l data.hex 2>/dev/null || echo 'FILE NOT FOUND!'");
    std::cout << "[DEBUG] End check.\n" << std::endl;
}

// Test 1: ADDI 和 BNE
TEST_F(CpuTestbench, TestAddiBne)
{
    // 调用脚本编译汇编代码
    setupTest("1_addi_bne");
    
    // 调试：看看 hex 文件在不在
    debug_file_status();
    
    // 初始化并复位 (Verilog 会在这里尝试 $readmemh)
    initSimulation();
    
    // 运行
    runSimulation(CYCLES);
    
    EXPECT_EQ(top_->a0, 254);
}

// Test 2: LI 和 ADD
TEST_F(CpuTestbench, TestLiAdd)
{
    setupTest("2_li_add");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1000);
}

// Test 3: LBU 和 SB
TEST_F(CpuTestbench, TestLbuSb)
{
    setupTest("3_lbu_sb");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}

// Test 4: JAL 和 RET
TEST_F(CpuTestbench, TestJalRet)
{
    setupTest("4_jal_ret");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 53);
}

// Test 5: Gaussian Blur (PDF)
TEST_F(CpuTestbench, TestPdf)
{
    setupTest("5_pdf");
    
    // 准备数据文件
    // 确保 reference/gaussian.mem 存在于你运行 make 的那个目录下
    setData("reference/gaussian.mem");
    
    debug_file_status(); // 再次检查数据文件是否就位
    
    initSimulation();
    
    // 算法需要更多时间
    runSimulation(CYCLES * 100);
    
    EXPECT_EQ(top_->a0, 15363);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    Verilated::commandArgs(argc, argv);
    return RUN_ALL_TESTS();
}