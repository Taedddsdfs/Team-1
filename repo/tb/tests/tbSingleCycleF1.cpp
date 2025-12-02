#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtop.h"
#include "vbuddy.cpp"

#define MAX_SIM_CYC 100000

int main(int argc, char **argv, char **env) {
    int simcyc;
    int tick;

    Verilated::commandArgs(argc, argv);
    // Init top verilog instance
    Vtop* top = new Vtop;
    
    // Init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("top.vcd");

    // Init Vbuddy
    if (vbdOpen()!=1) return (-1);
    vbdHeader("RISC-V CPU"); // Optional: Change title as needed

    // Initialize simulation inputs
    top->clk = 1;
    top->rst = 1;      // Assert reset initially
    top->trigger = 0;

    // Simulation loop
    for (simcyc=0; simcyc<MAX_SIM_CYC; simcyc++) {
        
        // Dump variables into VCD file and toggle clock
        for (tick=0; tick<2; tick++) {
            tfp->dump (2*simcyc+tick);
            top->clk = !top->clk;
            top->eval();
        }

        // Release reset signal after 2 clock cycles
        if (simcyc > 2) top->rst = 0; 

        //Output to Vbuddy
        // Display 'a0' value on the LED bar (Useful for F1 light sequence or progress bars)
        // Mask with 0xFF to ensure it fits the 8-bit LED bar
        vbdBar(top->a0 & 0xFF);
        
        // Display 'a0' value on the 7-segment display (Useful for seeing exact values)
        // Even if the F1 program doesn't use it, it helps with debugging
        vbdHex(4, (int(top->a0) >> 16) & 0xF);
        vbdHex(3, (int(top->a0) >> 8) & 0xF);
        vbdHex(2, (int(top->a0) >> 4) & 0xF);
        vbdHex(1, int(top->a0) & 0xF);

        // Input from Vbuddy
        // Read Vbuddy flag state and pass it to the 'trigger' input of the CPU
        // NOTE: Programs that don't use 'trigger' will simply ignore this signal.
        top->trigger = vbdFlag();

        // Debug Print
        // printf("Cycle: %d, a0: %d\n", simcyc, top->a0);

        // Check for simulation end conditions
        // Exit if Verilog calls $finish or user presses 'q' on Vbuddy
        if(Verilated::gotFinish() || (vbdGetkey() == 'q')){
            vbdBar(0); // Turn off LEDs before exit
            break;     // Break out of the simulation loop
        }
    }

    // Cleanup and exit
    vbdClose();
    tfp->close();
    delete top;
    exit(0);
}