
#include "Vregisterfile.h"
#include "verilated.h"
#include <iostream>
#include <iomanip>

void tick(Vregisterfile* top) {
    top->clk = 0;
    top->eval();

    top->clk = 1;
    top->eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vregisterfile* top = new Vregisterfile;

    // initialize
    top->clk = 0;
    top->rst = 1;
    top->WE3 = 0;
    top->AD1 = 0;
    top->AD2 = 0;
    top->AD3 = 0;
    top->WD3 = 0;

    //reset clk
    std::cout << "[INFO] Apply reset...\n";
    for (int i = 0; i < 3; ++i) tick(top);
    top->rst = 0;

    bool all_pass = true;

    // ===========================
    // Test 1:  x5 = 0x12345678
    // ===========================
    std::cout << "[TEST1] Write x5 = 0x12345678, then read back\n";

    top->WE3 = 1;
    top->AD3 = 5;                 // x5
    top->WD3 = 0x12345678;
    tick(top);                    // writing

    // stop writing
    top->WE3 = 0;

    top->AD1 = 5;                 // read x5
    top->AD2 = 0;                 // read x0
    top->eval();

    uint32_t rd1 = top->RD1;
    uint32_t rd2 = top->RD2;

    if (rd1 != 0x12345678) {
        std::cout << "[FAIL] x5 read = 0x" << std::hex << rd1
                  << ", expected 0x12345678\n";
        all_pass = false;
    } else {
        std::cout << "[PASS] x5 = 0x12345678 ok\n";
    }

    if (rd2 != 0x00000000) {
        std::cout << "[FAIL] x0 should be 0, got 0x" << std::hex << rd2 << "\n";
        all_pass = false;
    } else {
        std::cout << "[PASS] x0 still 0 as expected\n";
    }

    // ===========================
    // Test 2: write x0，see if the command is ignored
    // ===========================
    std::cout << "[TEST2] Try to write x0, should be ignored\n";

    top->WE3 = 1;
    top->AD3 = 0;                 // x0
    top->WD3 = 0xFFFFFFFF;
    tick(top);                    
    top->WE3 = 0;

    top->AD1 = 0;                 // read x0
    top->eval();
    rd1 = top->RD1;

    if (rd1 != 0x00000000) {
        std::cout << "[FAIL] x0 can NOT be written, got 0x"
                  << std::hex << rd1 << "\n";
        all_pass = false;
    } else {
        std::cout << "[PASS] x0 write ignored, still 0\n";
    }

    // ===========================
    // Test 3: write x10 and check
    // ===========================
    std::cout << "[TEST3] Write x10 = 0xDEADBEEF and check RD1 & a0\n";

    top->WE3 = 1;
    top->AD3 = 10;                // x10
    top->WD3 = 0xDEADBEEF;
    tick(top);
    top->WE3 = 0;

    top->AD1 = 10;                // RD1 read x10
    top->eval();
    rd1 = top->RD1;
    uint32_t a0 = top->a0;

    if (rd1 != 0xDEADBEEF) {
        std::cout << "[FAIL] x10 read = 0x" << std::hex << rd1
                  << ", expected 0xDEADBEEF\n";
        all_pass = false;
    } else {
        std::cout << "[PASS] x10 = 0xDEADBEEF ok\n";
    }

    if (a0 != 0xDEADBEEF) {
        std::cout << "[FAIL] a0 = 0x" << std::hex << a0
                  << ", expected 0xDEADBEEF\n";
        all_pass = false;
    } else {
        std::cout << "[PASS] a0 output correct: 0xDEADBEEF\n";
    }

    // ===========================
    // result
    // ===========================
    if (all_pass) {
        std::cout << "\n===== ALL TESTS PASSED =====\n";
    } else {
        std::cout << "\n===== SOME TESTS FAILED =====\n";
    }

    top->final();
    delete top;
    return all_pass ? 0 : 1;
}
