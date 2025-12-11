#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtop.h"
#include <unistd.h>

#include "vbuddy.cpp" 

#define MAX_SIM_CYC 100000

int main(int argc, char **argv, char **env) {
  int simcyc;
  int tick;

  Verilated::commandArgs(argc, argv);
  Vtop * top = new Vtop;
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace (tfp, 99);
  tfp->open ("top.vcd");

  if (vbdOpen()!=1) return(-1);

  printf("Setting VBuddy to LED Mode...\n");
  serial.writeString("$y,1\n"); 
  sleep(1); 

  top->clk = 1;
  top->rst = 1;

  for (simcyc=0; simcyc<MAX_SIM_CYC; simcyc++) {
    for (tick=0; tick<2; tick++) {
      tfp->dump (2*simcyc+tick);
      top->clk = !top->clk;
      top->eval ();
    }

    char buffer[50];
    int barValue = top->a0 & 0xFF; 
    sprintf(buffer, "$B,%d\n", barValue); 
    serial.writeString(buffer);

  
    printf("Cycle: %d, a0: %d\n", simcyc, top->a0);

    usleep(500000); 

    top->rst = (simcyc < 2);

    if (Verilated::gotFinish())  exit(0);
  }

  vbdClose();
  tfp->close();
  exit(0);
}
