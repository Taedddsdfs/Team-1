#include "testbench.h"
#include <iostream>
unsigned int ticks = 0;
// define test tool
class CpuTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->rst = 1;
    }
};

// Test 1: control flow algebra (addi, bne)
TEST_F(CpuTestbench, Test1_AddiBne)
{
    // 1. all assmbely must be within the asm folder
    int ret = system("tb/tests/compile_singleCycle.sh tb/asm/1_addi_bne.s");
    ASSERT_EQ(ret, 0) << "Compilation failed for 1_addi_bne.s";

    // 2. rst
    top->rst = 1;
    runSimulation(5);
    top->rst = 0;

    // 3
    // simulate255 loops 
    runSimulation(2000); 

    //test
    EXPECT_EQ(top->a0, 254) << "Test 1 Failed: a0 should be 254";
}


// Test 2: large imm loading

TEST_F(CpuTestbench, Test2_LiAdd)
{
    int ret = system("tb/tests/compile_singleCycle.sh tb/asm/2_li_add.s");
    ASSERT_EQ(ret, 0) << "Compilation failed for 2_li_add.s";

    top->rst = 1;
    runSimulation(5);
    top->rst = 0;

    //small number of loops works good
    runSimulation(100);

    
    // 10000 + (-9000) = 1000
    EXPECT_EQ(top->a0, 1000) << "Test 2 Failed: a0 should be 1000";
}

// Test 3: mem write and read (sb, lbu)

TEST_F(CpuTestbench, Test3_LbuSb)
{
    int ret = system("tb/tests/compile_singleCycle.sh tb/asm/3_lbu_sb.s");
    ASSERT_EQ(ret, 0) << "Compilation failed for 3_lbu_sb.s";

    top->rst = 1;
    runSimulation(5);
    top->rst = 0;

    runSimulation(100);

    // test result 
    // 100 + 200 = 300
    // expected result is 300
    EXPECT_EQ(top->a0, 300) << "Test 3 Failed: a0 should be 300";
}


// Test 4: subroutine call (jal, ret)
TEST_F(CpuTestbench, Test4_JalRet)
{
    int ret = system("tb/tests/compile_singleCycle.sh tb/asm/4_jal_ret.s");
    ASSERT_EQ(ret, 0) << "Compilation failed for 4_jal_ret.s";

    top->rst = 1;
    runSimulation(5);
    top->rst = 0;

    runSimulation(200);


    // intitial 50，call 3 times add_one
    // 50 + 1 + 1 + 1 = 53
    EXPECT_EQ(top->a0, 53) << "Test 4 Failed: a0 should be 53";
}


// Test 5:PDF 

TEST_F(CpuTestbench, Test5_PDF)
{
    int ret = system("tb/tests/compile_singleCycle.sh tb/asm/5_pdf.s");
    ASSERT_EQ(ret, 0) << "Compilation failed for 5_pdf.s";

    top->rst = 1;
    runSimulation(5);
    top->rst = 0;

    // The PDF program involves extensive looping (constructing a 256-bin distribution).
    // It requires many cycles; allocating 100,000 cycles here to be safe.
    // Your top.sv should automatically load the data file (e.g., gaussian.mem) into Data Memory.
    // If the data file is missing, this test may fail (resulting in 0).
    runSimulation(100000);

    // test results
    // expected = 15363
    EXPECT_EQ(top->a0, 15363) << "Test 5 Failed: a0 should be 15363. Check if data memory is initialized correctly.";
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    testing::InitGoogleTest(&argc, argv);
    // Verilated::mkdir("logs");
    auto res = RUN_ALL_TESTS();
    return res;
}
