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
        top->trigger = 0; 

        if (access("reference/gaussian.mem", F_OK) != -1) {
            system("cp reference/gaussian.mem gaussian.mem");
            std::cout << "[DEBUG] Copied gaussian.mem (Assuming it's clean)." << std::endl;
        } else if (access("gaussian.mem", F_OK) == -1) {
            std::cerr << "[WARNING] gaussian.mem not found!" << std::endl;
        }

 
        if (access("asm/5_pdf.s", F_OK) == -1) {
            std::cerr << "[ERROR] asm/5_pdf.s NOT found!" << std::endl;
            exit(1);
        }

        std::cout << "[DEBUG] Compiling asm/5_pdf.s manually..." << std::endl;
        int ret = system(
            "riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o pdf.o asm/5_pdf.s && "
            "riscv64-unknown-elf-objcopy -O binary -j .text pdf.o pdf.bin && "
            "od -v -An -t x1 pdf.bin | tr -s '\\n' | awk '{$1=$1};1' > program.hex"
        );

        if (ret != 0) {
             std::cerr << "[ERROR] Compilation Failed!" << std::endl;
             exit(1);
        }
    }
};

TEST_F(CpuTestbench, RunPDFPlot)
{
  
    int max_cycles = 1000000; 

    if (vbdOpen() != 1) {
        std::cout << "Error: VBuddy connection failed!" << std::endl;
        SUCCEED();
        return; 
    }
    
    vbdHeader("Gaussian-PDF");


    top->rst = 1; 
    top->trigger = 0;
    for(int i=0; i<5; i++) {
        runSimulation(); 
    }
    top->rst = 0; 

    top->trigger = 1; 


    bool plotting_started = false;

    for (int i = 0; i < max_cycles; ++i)
    {
        int data_val = (int)top->a0;
        
    
        if (!plotting_started) {
            if (data_val != 0) {
                plotting_started = true;
                std::cout << "[DEBUG] Valid data detected at cycle " << i << ". Plotting starts!" << std::endl;
            }
        }

     
        if (plotting_started) {
            vbdPlot(data_val, 0, 255);
        }
        
        runSimulation();
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