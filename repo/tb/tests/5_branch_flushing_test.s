    .text
    .globl _start
_start:
    # 先把 x1,x2 设为已知值
    addi x1, x0, 0
    addi x2, x0, 0

    # 使条件恒真：x5 = 0
    addi x5, x0, 0

    # BEQ x5, x0, target   → 一定跳
    beq  x5, x0, target

    # 这条指令应该被 flush 掉，不能执行
    addi x1, x0, 123       # 如果 branch flush 错了，会写入 x1=123

target:
    # 这里执行 addi x2, ...
    addi x2, x0, 45

    # 签名：
    #   预期：x1 == 0, x2 == 45
    #   我们可以简单设 a0 = x1 + x2 = 45
    add  x10, x1, x2       # a0 = 45 if flush is correct

done:
    beq x0, x0, done
