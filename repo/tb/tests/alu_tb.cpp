/*
 *  Verifies the results of the alu, exits with a 0 on success.
 */

#include "base_testbench.h"

#define OPCODE_ADD      0b000
#define OPCODE_SUB      0b001
#define OPCODE_AND      0b010
#define OPCODE_OR       0b011
#define OPCODE_SLT      0b101

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ALUTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->ALUop1 = 0;
        top->ALUop2 = 0;
        top->ALUControl = 0;
    }
};

TEST_F(ALUTestbench, ADDTest)
{
    int op1 = 1;
    int op2 = 2;

    top->ALUop1 = op1;
    top->ALUop2 = op2;
    top->ALUControl = OPCODE_ADD;

    top->eval();

    EXPECT_EQ(top->ALUout, op1 + op2);
    EXPECT_EQ(top->EQ, 0);
}

TEST_F(ALUTestbench, SUBTest)
{
    int op1 = 5;
    int op2 = 5;

    top->ALUop1 = op1;
    top->ALUop2 = op2;
    top->ALUControl = OPCODE_SUB;

    top->eval();

    EXPECT_EQ(top->ALUout, op1 - op2);
    EXPECT_EQ(top->EQ, 1);
}

TEST_F(ALUTestbench, ANDTest)
{
    int op1 = 0b0011;
    int op2 = 0b0101;

    top->ALUop1 = op1;
    top->ALUop2 = op2;
    top->ALUControl = OPCODE_AND;

    top->eval();

    EXPECT_EQ(top->ALUout, op1 & op2);
    EXPECT_EQ(top->EQ, 0);
}

TEST_F(ALUTestbench, ORTest)
{
    int op1 = 0b0011;
    int op2 = 0b0101;

    top->ALUop1 = op1;
    top->ALUop2 = op2;
    top->ALUControl = OPCODE_OR;

    top->eval();

    EXPECT_EQ(top->ALUout, op1 | op2);
    EXPECT_EQ(top->EQ, 0);
}

TEST_F(ALUTestbench, SetIfLessThanTest)
{
    int op1 = 0b0011; // 3
    int op2 = 0b0101; // 5

    top->ALUop1 = op1;
    top->ALUop2 = op2;
    top->ALUControl = OPCODE_SLT;

    top->eval();

    EXPECT_EQ(top->ALUout, 1);
    EXPECT_EQ(top->EQ, 0);
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
