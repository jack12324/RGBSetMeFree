nop
nop
nop
nop
nop
nop
addi $r1, $R0, 4 ; skip instruction so 4
add $r2, $R0, $R0 ; results in 0, Z flag set
beq $r1 
neg $r1, $r1 ; shouldn't execute, should skip over
nop
nop
nop
nop
nop

