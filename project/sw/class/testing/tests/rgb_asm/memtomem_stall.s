;# Mem to Mem
;# This test case engages multiple forwarding paths and stalls with a twist-
;# Mem to mem is replaced with a stall
;# One stall is are expected.

; .cpuopts PATH_MEM_MEM=STALL
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
