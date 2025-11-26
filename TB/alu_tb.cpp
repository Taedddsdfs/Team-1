#include "Valu.h"
#include "verilated.h"
#include <iostream>
#include <iomanip>
#include <cstdint>

bool test(Valu* top,
              uint8_t  ctrl,
              uint32_t op1,
              uint32_t op2,
              uint32_t expect_out,
              uint8_t  expect_eq,
              const char* name)
{
    top->ALUctrl = ctrl;
    top->ALUop1  = op1;
    top->ALUop2  = op2;

    top->eval();

    uint32_t got_out = top->ALUout;
    uint8_t  got_eq  = top->EQ;

    bool pass = (got_out == expect_out) && (got_eq == expect_eq);

    if (pass) {
        std::cout << "  [PASS]\n";
    } else {
        std::cout << "  [FAIL] (expect out=0x"
                  << std::hex << std::setw(8) << expect_out
                  << " EQ=" << std::dec << (int)expect_eq << ")\n";
    }

    return pass;
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Valu* top = new Valu;

    bool all_pass = true;

    // ctrl 000: ADD
    all_pass &= test(top, 0b000, 1, 2, 3, 0, "ADD 1+2");
    all_pass &= test(top, 0b000, 0x00000000, 0x00000000, 0x00000000, 1, "ADD 0+0");

    // ctrl 001: SUB
    all_pass &= test(top, 0b001, 5, 3, 2, 0, "SUB 5-3");
    // 相等时结果为 0，EQ 应为 1（最后那行 EQ = (ALUout==0) ? 1 : 0）
    all_pass &= test(top, 0b001, 10, 10, 0, 1, "SUB 10-10");

    // ctrl 010: AND
    all_pass &= test(top, 0b010, 0xF0F0F0F0, 0x0FF00FF0, 0x00F000F0, 0, "AND");

    // ctrl 011: OR
    all_pass &= test(top, 0b011, 0xF0F0F0F0, 0x0FF00FF0, 0xFFF0FFF0, 0, "OR");

    // ctrl 101: SLT (Set Less Than, 结果为 0 或 1)
    all_pass &= test(top, 0b101, 3, 10, 1, 0, "SLT 3<10");
    all_pass &= test(top, 0b101, 10, 3, 0, 0, "SLT 10<3"); // out=0 => EQ=0

    // default 分支：比如 ctrl=100，ALUout 应为 0，EQ=1
    all_pass &= test(top, 0b100, 0x12345678, 0x87654321, 0, 1, "DEFAULT");

    if (all_pass) {
        std::cout << "\n===== ALL ALU TESTS PASSED =====\n";
    } else {
        std::cout << "\n===== SOME ALU TESTS FAILED =====\n";
    }

    top->final();
    delete top;
    return all_pass ? 0 : 1;
}
