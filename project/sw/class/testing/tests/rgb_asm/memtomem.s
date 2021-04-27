;# Mem to Mem
;# This test case engages multiple forwarding paths and stalls
;# No stalls are expected.
addi $r1, $R0, -3000
sti $r1, 9000
ldi $r2, 9000
sti $r2, 10000
ldi $r3, 10000
NOP
NOP
NOP
NOP
NOP
NOP
