# Forwarding Basic
# Tests two forwarding paths (data hazards only) with varying instruction formats, no stalls should occur
# Paths: EX-EX, MEM-EX

# t >= 12

# EX-EX I -> I
addi $r12, $r0, 100
addi $r1, $r12, 50

# MEM-EX I -> I
addi $r12, $r0, 200
sll $r0, $r0, 0
addi $r2, $r12, 50

# EX-EX I -> R
addi $r13, $r0, 10
add $r3, $r12, $r13

# MEM-EX I -> R
addi $r13, $r0, 20
sll $r0, $r0, 0
add $r4, $r12, $r13

# EX-EX and MEM-EX Case I & I -> R
addi $r12, $r0, 600
addi $r13, $r0, 800
add $r5, $r12, $r13

# EX-EX Case I & R -> I
addi $r6, $r5, 200

# EX-EX and MEM-EX Case R & R -> R
add $r7, $r6, $r5

sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0
sll $r0, $r0, 0

.exit
