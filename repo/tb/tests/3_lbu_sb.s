    .text
    .global main
main:
    li      a1, 0x100
    li      a2, 0x78
    sb      a2, 0(a1)
    lbu     a0, 0(a1)
    addi    a0, a0, 180
    ret
