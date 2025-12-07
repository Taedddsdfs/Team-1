#include "testbench.h"
#include <cstdlib>

#define CYCLES 150000

unsigned int ticks = 0;

class CpuTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 1;
        top->rst = 0;
    }
};

TEST_F(CpuTestbench, BaseProgramTest1)
{
    bool success = false;
    system("./compile.sh asm/program.S");

    for (int i = 0; i < CYCLES; i++)
    {
        runSimulation(1);
        if (top->a0 == 254)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "Counter did not reach 254";
    }
}

TEST_F(CpuTestbench, BaseProgramTest2)
{
    bool success = false;
    system("./compile.sh asm/2_li_add.s");

    for (int i = 0; i < CYCLES; i++)
    {
        runSimulation(1);
        if (top->a0 == 1000)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "Counter did not reach 1000";
    }
}

TEST_F(CpuTestbench, BaseProgramTest3)
{
    bool success = false;
    system("./compile.sh asm/3_lbu_sb.s");

    for (int i = 0; i < CYCLES; i++)
    {
        runSimulation(1);
        if (top->a0 == 300)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "Counter did not reach 300";
    }
}

TEST_F(CpuTestbench, BaseProgramTest4)
{
    bool success = false;
    system("./compile.sh asm/4_jal_ret.s");

    for (int i = 0; i < CYCLES; i++)
    {
        runSimulation(1);
        if (top->a0 == 53)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "Counter did not reach 53";
    }
}

TEST_F(CpuTestbench, BaseProgramTest5)
{
    bool success = false;
    system("./compile.sh asm/5_pdf.s");

    for (int i = 0; i < CYCLES; i++)
    {
        runSimulation(1);
            std::cout << "Cycle " << i
              << "  PC = 0x"  << std::hex << top->dbg_pc
              << "  t1 = "    << std::dec << top->dbg_t1
              << "  a4 = "    << top->dbg_a4
              << "  ALUCtrl = " << std::hex << (int)top->dbg_alu_ctrl
              << "  a0 = "    << std::dec << top->a0
              << "  s1 = "    << std::dec << top->dbg_s1
              << std::endl;
        if (top->a0 == 15363)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "Counter did not reach 15363";
    }
}

// Note this is how we are going to test your CPU. Do not worry about this for
// now, as it requires a lot more instructions to function
// TEST_F(CpuTestbench, Return5Test)
// {
//     system("./compile.sh c/return_5.c");
//     runSimulation(100);
//     EXPECT_EQ(top->a0, 5);
// }

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
