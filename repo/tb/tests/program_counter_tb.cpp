#include "testbench.h"
#include "Vdut.h"
#include <gtest/gtest.h>

unsigned int ticks = 0;

class ProgramCounterTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 1;
        top->rst = 1; 
        top->PCSrc = 0;
        top->ImmOp = 0;
        top->ALUResult = 0;
    }
};

TEST_F(ProgramCounterTestbench, InitialTest)
{
    top->rst = 1;
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
    EXPECT_EQ(top->PC, 0);
}

TEST_F(ProgramCounterTestbench, NormalIncrementingTest){
    top->PCSrc = 0; 
    top->rst = 0;   
    
    runSimulation(1); 

    for(int i = 0; i < 32; i++){
        EXPECT_EQ(top->PC, i*4);
        runSimulation(1);
    }
}

TEST_F(ProgramCounterTestbench, JALRTest){
    top->rst = 0;
    top->PCSrc = 0; 
    

    runSimulation(1);

    
    top->PCSrc = 2;          
    top->ALUResult = 0x1000; 
    top->ImmOp = 0;         
    

    runSimulation(1);
    

    EXPECT_EQ(top->PC, 0x1000); 
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
