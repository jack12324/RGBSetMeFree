;# Big Stall Forward
;# This test case engages multiple forwarding paths and stalls
;# It's a test for correctness
addi $r1, $R0, -1
addi $r1, $r1, 3000
st $r1, $r1
ld $r2, $r1
addi $r2, $r2, 4000
st $r2, $r2
ld $r3, $r1
ld $r4, $r2
addi $r8, $R0, 20 ; branch value
sub $r9, $r3, $r4 ; condition
beq $r8 ; to SUCCESS
nop
nop ; +4
nop ; +8
nop ; +12
; .exit
nop ; +16

; SUCCESS:
addi $r5, $R0, 999 ; +20
nop
nop
nop
nop
nop
; .exit
