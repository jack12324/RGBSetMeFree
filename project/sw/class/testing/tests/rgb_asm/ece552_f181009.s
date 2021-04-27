;# ECE 552
;# based on In-Class Exercise 10/09/2018
;# Credit: Professor Joshua San Miguel @ UW-Madison

;# Extra dependency to induce initial stall
ldi $r1, 0

;# The "Exercise"
or $r3, $r1, $r5
ld $r2, $r3
ld $r3, $r2
or  $r4, $r3, $r4

;# No ops
nop
nop
nop
nop
;.exit
