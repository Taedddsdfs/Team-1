#include <iostream>
#include <cstdlib>
#include <utility>


#include "cpu_testbench.h"

#define CYCLES 10000

void debug_file_status() {
    std::cout << "\n[DEBUG] Checking environment..." << std::endl;
    std::cout << "  > Current Directory: " << std::flush;
    std::system("pwd");
    std::cout << "  > program.hex status: " << std::flush;
    std::system("ls -l program.hex 2>/dev/null || echo 'FILE NOT FOUND!'");
    std::cout << "  > data.hex status:    " << std::flush;
    std::system("ls -l data.hex 2>/dev/null || echo 'FILE NOT FOUND!'");
    std::cout << "[DEBUG] End check.\n" << std::endl;
}

TEST_F(CpuTestbench, TestAddiBne)
{
    setupTest("1_addi_bne");
    
    debug_file_status();
    
    initSimulation();
    
    runSimulation(CYCLES);
    
    EXPECT_EQ(top_->a0, 254);
}

TEST_F(CpuTestbench, TestLiAdd)
{
    setupTest("2_li_add");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1000);
}

TEST_F(CpuTestbench, TestLbuSb)
{
    setupTest("3_lbu_sb");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}

TEST_F(CpuTestbench, TestJalRet)
{
    setupTest("4_jal_ret");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 53);
}

TEST_F(CpuTestbench, TestPdf)
{
    setupTest("5_pdf");
    
    
    setData("reference/gaussian.mem");
    
    debug_file_status(); 
    
    initSimulation();
    
    runSimulation(CYCLES * 100);
    
    EXPECT_EQ(top_->a0, 15363);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    Verilated::commandArgs(argc, argv);
    return RUN_ALL_TESTS();
}
