# Fake Hazards
# Tests a few so called "fake hazards"
# i.e. certain cases which may get picked up as hazards by hazard detection but aren't really
# No stalls are expected

# WAW
addi $r1, $r1, 100
addi $r1, $r0, 100
ldi $r2, 50
or $r2, ,$r2, $r0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sw $r1, 100($r0)
sw $r2, 104($r0)

# WAW Loads, after Following Stores
lw $r3, 104($r0)
lw $r3, 100($r0)

# Arithmetic and Writing to the Zero Register
addi $r0, $r0, 500
sub $r0, $r0, $r0
lw $r0, 104($r0)
add $r0, $r0, $r0
sll $r0, $r0, 0
addu $r0, $r0, $r0

# Check to make sure corrupting random forward didn't happen...
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
.exit
