    .text
    .global main
main:
    li      a0, 0
    jal     ra, my_func
    addi    a0, a0, 11
    ret
my_func:
    li      a0, 42
    ret
