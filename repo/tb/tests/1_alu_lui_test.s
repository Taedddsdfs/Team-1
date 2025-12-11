    .text
    .globl _start
_start:
    # x1 = 5, x2 = 12
    addi x1, x0, 5
    addi x2, x0, 12

    # x3 = x1 + x2 = 17
    add x3, x1, x2

    # x4 = x3 - x1 = 12
    sub x4, x3, x1

    # x5 = x3 XOR x4 = 17 ^ 12 = 0x00000009
    xor x5, x3, x4

    # x6 = x3 OR x4 = 0x0000001d
    or  x6, x3, x4

    # x7 = x3 AND x4 = 0x00000000
    and x7, x3, x4

    # 有符号比较：5 < 12 → 1
    slt x8, x1, x2

    # 无符号比较：12 < 5 ? → 0
    sltu x9, x2, x1

    # I-type 立即数逻辑测试
    andi x11, x6, 0xF     # x11 = 0x1d & 0x0f = 0x0d (13)
    ori  x12, x0, 0x123   # x12 = 0x00000123
    xori x13, x11, 0x5    # x13 = 0x0d ^ 0x05 = 0x08

    # LUI: 只看高 20 位扩展
    lui  x14, 0x12345     # x14 = 0x12345_000

    # 最终签名：随便构造一个复杂一点的值
    # 这里我们让 a0 = x7 + x8 + x9 + x11 + x13
    # = 0 + 1 + 0 + 13 + 8 = 22
    add  x10, x7, x8
    add  x10, x10, x9
    add  x10, x10, x11
    add  x10, x10, x13    # a0 = 22

done:
    beq x0, x0, done
