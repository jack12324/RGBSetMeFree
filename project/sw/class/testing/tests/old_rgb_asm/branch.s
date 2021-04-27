ldi $r9, SYM

SYM:
    addi $r1, $r1, 1
    addi $r2, $r0, 1000
    sub $r3, $r1, $r2
    bne $r9
.exit
