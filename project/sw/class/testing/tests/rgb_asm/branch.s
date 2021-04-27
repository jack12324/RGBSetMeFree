;SYM:
addi $r1, $r1, 1 ; -20
addi $r2, $R0, 1000 ; -16
addi $r8, $R0, -20 ; -12
sub $r9, $r1, $r2 ; -8
bne $r8 ; to SYM -4
;.exit
