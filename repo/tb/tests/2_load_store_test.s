    .text
    .globl _start
_start:
    # 基地址 x1 = 0x200 (随便挑一块不会和 gaussian.mem 冲突的区域)
    lui   x1, 0x0
    addi  x1, x1, 0x200

    # x2 = 0xAABBCCDD
    li x2, 0xAABBCCDD

    # SW x2, 0(x1)
    sw    x2, 0(x1)

    # 再 LW 回来到 x3，应该等于 0xAABBCCDD
    lw    x3, 0(x1)

    # 用 SB 改写最低字节为 0x11:
    # mem[x1+0] = 0x11
    addi  x4, x0, 0x11
    sb    x4, 0(x1)

    # 再用 LBU 读回低字节到 x5：应为 0x11
    lbu   x5, 0(x1)

    # 再 LW 一次，查看32位组合：
    # 期望为：0xAABBCC11 （只改最低字节）
    lw    x6, 0(x1)

    # 构造签名 a0：
    # 只用一些低位来判断是否存取正确
    #   low8(x5) = 0x11
    #   low8(x6) = 0x11
    #   (x3 == 0xAABBCCDD) ? 1 : 0
    # 为了不用分支判断，我们粗暴一点：
    #   先假设：a0 = (x5 & 0xFF) + (x6 & 0xFF)
    #   = 0x11 + 0x11 = 0x22 = 34
    # 如果 SW/LW/SB/LBU 出错，这个值大概率不会是 34

    andi  x7, x5, 0xFF
    andi  x8, x6, 0xFF
    add   x10, x7, x8    # a0 = 34 (0x22) 如果一切正常

done:
    beq x0, x0, done
