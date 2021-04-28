jmp 100671520 ; 100,671,488 is our starting inst mem, to MAIN

; MULTI: ;#$r1 = $r3 * $r2
addi $r1, $R0, 0 ; +4

; MULTI_B:
add $r1, $r1, $r3 ; +8
addi $r2, $r2, -1 ; +12
addi $r8, $R0, -20 ; branch value +16
sub $r9, $r2, $R0 ; condition +20
bne $r8 ; to MULTI_B +24
jr $LR ; +28

; MAIN:  ;#calculates $r1 <- 5 * 4 = 20
addi $r3, $R0, 5 ; +32
addi $r2, $R0, 4 ; +36
jal 100671492 ; +40    to MULTI
sll $R0, $R0, $R0 ; +44
sll $R0, $R0, $R0 ; +48
