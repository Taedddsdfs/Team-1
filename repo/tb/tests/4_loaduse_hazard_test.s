    .text
    .globl _start
_start:
    # 在 x1 指向一块内存，写入一个已知值 0x55
    lui   x1, 0x0
    addi  x1, x1, 0x300     # base address 0x300
    addi  x2, x0, 0x55
    sb    x2, 0(x1)         # mem[0x300] = 0x55

    # 现在做 Load-Use：
    # 1. 从内存加载到 x3
    lbu   x3, 0(x1)         # load in EX stage

    # 2. 紧接着使用 x3 作为操作数 —— 必须插入 bubble
    addi  x4, x3, 1         # 如果没 stall，可能用到旧值 0 或垃圾

    # 再做一步运算确保传播结果：
    addi  x5, x4, 1         # x5 = (0x55 + 1) + 1 = 0x57 if hazard handled

    # 签名：a0 = x5
    add   x10, x5, x0

done:
    beq x0, x0, done
