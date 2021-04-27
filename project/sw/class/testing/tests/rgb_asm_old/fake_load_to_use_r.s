# Fake Hazard R
# Similar to "Fake Hazard" test case
# But this time, to R inst add
lw $r1, 400($r0)
add $r0, $r1, $r1
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
.exit
