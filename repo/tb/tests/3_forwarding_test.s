    .text
    .globl _start
_start:
    # x1 = 1
    addi x1, x0, 1

    # EX/MEM → EX 前递测试：
    # x2 = x1 + 2  (需要从上一条写 x1 的结果前递)
    addi x2, x1, 2       # hazard: x1 just written

    # 再一条紧跟使用 x2：
    # x3 = x2 + 3  (继续前递链)
    addi x3, x2, 3

    # 插入一条和依赖无关的指令，让第一个结果进入 WB：
    addi x4, x0, 10      # 不依赖前面，避免你误以为是特殊 case

    # MEM/WB → EX 前递测试：
    # 现在 x1 的值已经在 WB:
    # x5 = x1 + x3 = 1 + (1+2+3) = 7
    add  x5, x1, x3

    # 再综合一下：
    # x6 = x5 + x4 = 7 + 10 = 17
    add  x6, x5, x4

    # 最终签名 a0 = x6
    add  x10, x6, x0     # a0 = 17

done:
    beq x0, x0, done
