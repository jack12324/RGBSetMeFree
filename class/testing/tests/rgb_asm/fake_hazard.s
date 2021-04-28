;# Fake Hazards
;# Tests a few so called "fake hazards"
;# i.e. certain cases which may get picked up as hazards by hazard detection but aren't really
;# No stalls are expected

;# WAW
addi $r1, $r1, 100
addi $r1, $R0, 100
addi $r2, $R0, 50
nop
nop
nop
sti $r1, 100
sti $r2, 104

;# WAW Loads, after Following Stores
ldi $r3, 104
ldi $r3, 100

;# Arithmetic and Writing to the Zero Register
addi $R0, $R0, 500
sub $R0, $R0, $R0
ldi $R0, 104
add $R0, $R0, $R0
sll $R0, $R0, $R0
add $R0, $R0, $R0

;# Check to make sure corrupting random forward didn't happen...
nop
nop
nop
nop
nop
;.exit
