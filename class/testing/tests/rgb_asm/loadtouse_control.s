addi $r1, $R0, 2000
st $r1, $r1
ld $r2, $r1 ; originally 4($r1)
addi $r8, $R0, 20 ; branch value
sub $r9, $r1, $r2 ; condition
beq $r8
addi $r3, $R0, 15 ; +0
nop ; +4
nop ; +8
nop ; +12
;.exit
nop ; +16

;SUCCESS:
addi $r4, $R0, 15  ; +20
nop
nop
nop
nop

