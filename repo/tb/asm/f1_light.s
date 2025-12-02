# initialization
main: 
    ADDI t0, zero, 1      # t0 is the random number generated in lfsr and needs a initial value.
    ADDI s2, zero, 255    # threshold value (all lights on)

    lfsr7_loop:
    ANDI a2, t0, 0x40
    ANDI a1, t0, 0x4
    SRLI a2, a2, 6  # shift a1 to the right most
    SRLI a1, a1, 2  # shift a2 to the right most
    SLLI t0, t0, 1  # shift t0 left 1 unit
    XOR a3, a1, a2  # a1 XOR a2
    ADD t0, t0, a3  # t0 is the count number(random number)
    ANDI t0, t0, 0x7F # extract the last 7 bits
    BEQ t6, zero, lfsr7_loop # go next only when trigger(t6) equals to 1, or it goes to lfsr loop again

lighting_loop:
    JAL  counter_loop
    SLLI t1, a0, 1     
    ADDI a0, t1, 1       #  shift left 1 bits and  ADD 1 to it to produce the next light.
    BNE  a0, s2, lighting_loop      # enter the randomdelay loop when a0 = s2(255).

# when random number is generated, start the delay loop  
randomdelay_loop:   
    ADDI a4,t0,0
    SLLI a4, a4, 1
random:
    ADDI a4, a4, -1     
    BNE  zero, a4, random

reset:
    LI a0, 0  # reset the light and register
    LI t6, 0
    J lfsr7_loop

counter_loop:
    LI t2, 36 # count 36 cycles for 1 second delay
count:
    ADDI t2, t2, -1
    BNE t2,zero, count
    RET
