#include "testbench.h"
#include <verilated_cov.h>
#include <vector>
#include <bitset>

#define NAME            "program_counter"

//This test bench will test

class ProgramCounterTestbench : public Testbench
{
protected:
    //this is ran within the SetUp() inside the base test bench, which is ran before each test.
    void initializeInputs() override
    {
        top->clk = 1;
        top->rst = 1;
    }
};

//tests initial value after reset
TEST_F(ProgramCounterTestbench, initialTest)
{
    top->eval();
    EXPECT_EQ(top->PC, 0b00000);
}

TEST_F(ProgramCounterTestbench, NormalIncrementingTest){

    top->PCSrc = 0;
    top->rst = 0;

    for(int i = 0; i < 32; i++){
        EXPECT_EQ(top->PC, i*4);
        runSimulation(1);
    }

}

TEST_F(ProgramCounterTestbench, WrapAroundTest){
    top->rst = 0;
    top->PCSrc = 0;

    top->PC = 4294967292;
    runSimulation(1);
    EXPECT_EQ(top->PC, 0);
}

TEST_F(ProgramCounterTestbench, BranchTest){
    top->rst = 0;
    top->PCSrc = 1;
    top->ImmOp = 5; //set to PC relative addressing branch of +5 to PC

    runSimulation(1);
    EXPECT_EQ(top->PC, 5); //should be 0 + 5
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    testing::InitGoogleTest(&argc, argv);
    Verilated::mkdir("logs");
    auto res = RUN_ALL_TESTS();
    VerilatedCov::write(
        ("logs/coverage_" + std::string(NAME) + ".dat").c_str()
    );

    return res;
}
