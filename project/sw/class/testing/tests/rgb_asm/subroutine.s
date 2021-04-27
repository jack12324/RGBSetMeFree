jmp 100671512 ; 100,671,488 is our starting inst mem, to MAIN

; MULTI: #$r1 = $r3 * $r2
addi $r1, $R0, 0 ; +4

; MULTI_B:
add $r1, $r1, $r3 ; +8
addi $r2, $r2, -1 ; +12
bne $r2, $R0, MULTI_B ; +16
jr $LR ; +20

; MAIN:  #calculates $r1 <- 5 * 4 = 20
addi $r3, $R0, 5 ; +24
addi $r2, $R0, 4 ; +28
jal 100671492 ; +32    to MULTI
sll $R0, $R0, $R0 ; +36
sll $R0, $R0, $R0 ; +40
