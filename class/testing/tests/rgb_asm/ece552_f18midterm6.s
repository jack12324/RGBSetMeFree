;# ECE 552
;# based on Fall 2018 Midterm Problem 6
;# Credit: Professor Joshua San Miguel @ UW-Madison

;# Setup
addi $r1, $R0, 1000
addi $r2, $R0, 1
addi $r3, $R0, 1002
addi $r4, $R0, 1000
nop
nop
nop

;# Execution a.k.a. The Midterm
; I1:
add $r1, $r1, $r2 ; -16
addi $r8, $R0, -16 ; -12
sub $r9, $r1, $r3 ; -8
bne $r9 ; -4   to I1
addi $r4, $r4, 8
ld $r1, $r4
addi $r4, $r4, 4
st $r1, $r4

;# No ops to get until sw inst
;# Reaches WB
nop
nop
nop
nop
;.exit
