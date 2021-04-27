# Fake Load to Use
# Load to use to an instruction writing to the zero register
# No stalls expected
lw $r0, 5000($r0)
add $r0, $r0, $r0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
.exit
