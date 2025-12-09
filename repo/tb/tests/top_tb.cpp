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

  // 1. 设置 LED 模式 (ASCII 协议)
  // 根据 PDF Task 2，我们需要配合 flag 模式 [cite: 150]
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

    // --- 【关键修改】尝试 ASCII 协议的 vbdBar ---
    // 之前用的 serial.writeChar('B') 是二进制协议，可能你的固件不支持
    // 这里我们改用 "$B,数值\n" 的文本格式试试
    char buffer[50];
    int barValue = top->a0 & 0xFF; // PDF 要求 Mask 0xFF [cite: 163]
    sprintf(buffer, "$B,%d\n", barValue); 
    serial.writeString(buffer);
    // ------------------------------------------

    // 终端打印
    printf("Cycle: %d, a0: %d\n", simcyc, top->a0);

    // 保持 usleep 延时，确保数据不堵塞
    usleep(500000); 

    top->rst = (simcyc < 2);

    if (Verilated::gotFinish())  exit(0);
  }

  vbdClose();
  tfp->close();
  exit(0);
}
