
#include "testbench.h"
#include "vbuddy.cpp"
#include <unistd.h>

unsigned int ticks = 0;

class CpuTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 1;
        top->rst = 1;

    
        if (access("asm/f1_light.s", F_OK) == -1) {
            std::cerr << "[ERROR] asm/f1_light.s NOT found!" << std::endl;
            exit(1);
        }

      
        std::cout << "[DEBUG] Compiling asm/f1_light.s manually..." << std::endl;
        
        int ret = system(
            "riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o f1.o asm/f1_light.s && "
            "riscv64-unknown-elf-objcopy -O binary -j .text f1.o f1.bin && "
            "od -v -An -t x1 f1.bin | tr -s '\\n' | awk '{$1=$1};1' > program.hex"
        );

        if (ret != 0) {
             std::cerr << "[ERROR] Manual Compilation Failed!" << std::endl;
             exit(1);
        }

    
        if (access("program.hex", F_OK) == -1) {
            std::cerr << "[ERROR] program.hex STILL not found. This is impossible!" << std::endl;
            exit(1);
        } else {
            std::cout << "[SUCCESS] program.hex generated! Starting Simulation...\n" << std::endl;
        }
    }
};

TEST_F(CpuTestbench, RunvBuddy)
{
    int max_cycles = 10000;

    if (vbdOpen() != 1) {
        std::cout << "Error: VBuddy connection failed!" << std::endl;
        SUCCEED();
        return; 
    }
    
    vbdHeader("F1-Lights");
    vbdSetMode(1); 


    top->rst = 1; 
    for(int i=0; i<5; i++) {
        runSimulation(); 
    }
    top->rst = 0; 


    for (int i = 0; i < max_cycles; ++i)
    {
    
        std::cout << "Cycle: " << i << " | a0 = " << (int)top->a0 << std::endl;

        vbdBar(top->a0 & 0xFF);
        runSimulation();
        usleep(500000); 
    }

    vbdClose();
    SUCCEED();
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    testing::InitGoogleTest(&argc, argv);
    Verilated::mkdir("logs");
    auto res = RUN_ALL_TESTS();
    return res;
}