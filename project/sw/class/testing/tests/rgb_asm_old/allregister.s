ldi $r1, Exception
addi $r0, $r0, 50
add $r0, $r0, $r0
beq $r1
Exception:
.exit
