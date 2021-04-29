;;# Forwarding Control
;;# Tests out various formats of EX-ID forwarding and stalls used when a Load-to-use into a branch occurs
;;# As well as branch prediction flushing
; Note: no .exit in our programming, maybe add jmp to end?

addi $r1, $R0, 1
sti $r1, 3000
addi $r2, $R0, 50
addi $r8, $R0, 8 ; branch value
sub $r9, $R0, $r2 ; condition
bne $r8 ; to FIRST
addi $r3, $R0, -1 ; +0
;.exit
nop ; +4

; FIRST:
add $r4, $R0, $r2 ; +8
; SECOND:
addi $r18, $R0, 20 ; branch value
sub $r19, $r4, $R0 ; condition
bne $r18 ; to LOOP
addi $r5, $R0, 1 ; +0
nop ; +4
nop ; +8
nop ; +12
;.exit
nop ; +16

; LOOP:
sub $r4, $r4, $r1 ; +20
jmp 100671524 ; to SECOND

addi $r3, $R0, -1
;.exit

