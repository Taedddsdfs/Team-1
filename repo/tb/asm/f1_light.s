main:
    j loop

loop:
    jal ra, subroutine
    addi a0, zero, 0x0
    j loop
    ret

subroutine:
    addi a0, zero, 0x1
    addi a0, zero, 0x3
    addi a0, zero, 0x7
    addi a0, zero, 0xf
    addi a0, zero, 0x1f
    addi a0, zero, 0x3f
    addi a0, zero, 0x7f
    addi a0, zero, 0xff
    addi a0, zero, 0x00
    ret