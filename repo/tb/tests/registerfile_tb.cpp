/*
 *  Verifies the results of the mux, exits with a 0 on success.
 */

#include "testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class RGFTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 1;
        top->AD1 = 0;
        top->AD2 = 0;
        top->AD3 = 0;
        top->WD3 = 0;
        top->WE3 = 0;
        top->RD1 = 0;
        top->RD2 = 0;
    }
};

TEST_F(RGFTestbench, Reg0Test)
{
    top->AD3 = 0;
    top->WE3 = 1;
    top->WD3 = 0x12345678;

    runSimulation(1);

    top->AD1 = 0;

    top->eval();;

    EXPECT_EQ(top->RD1, 0);
}

TEST_F(RGFTestbench, AllRegFunctionTest)
{
    top->WE3 = 1;
    top->WD3 = 0x12345678;

    for(int i = 1; i < 32; i++){
        top->AD3 = i;

        runSimulation(1);

        top->AD1 = i;

        top->eval();

        EXPECT_EQ(top->RD1, 0x12345678);
    }

}

TEST_F(RGFTestbench, a0Test)
{
    top->AD3 = 10;
    top->WE3 = 1;
    top->WD3 = 0x12345678;

    runSimulation(1);

    top->AD1 = 10;

    top->eval();

    EXPECT_EQ(top->RD1, 0x12345678);
}

// int main(int argc, char **argv)
// {
//     top = new Vdut;
//     tfp = new VerilatedVcdC;

//     Verilated::traceEverOn(true);
//     top->trace(tfp, 99);
//     tfp->open("waveform.vcd");

//     testing::InitGoogleTest(&argc, argv);
//     auto res = RUN_ALL_TESTS();

//     top->final();
//     tfp->close();

//     delete top;
//     delete tfp;

//     return res;
// }