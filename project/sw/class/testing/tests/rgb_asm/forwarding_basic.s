# Forwarding Basic
# Tests two forwarding paths (data hazards only) with varying instruction formats, no stalls should occur
# Paths: EX-EX, MEM-EX

# EX-EX I -> I
addi $r1, $R0, 100
addi $r2, $r1, 50

# MEM-EX I -> I
addi $r1, $R0, 200
NOP
addi $r3, $r1, 50

# EX-EX I -> R
addi $r4, $R0, 10
add $r5, $r1, $r4

# MEM-EX I -> R
addi $r4, $R0, 20
NOP
add $r6, $r1, $r4

# EX-EX and MEM-EX Case I & I -> R
addi $r1, $R0, 600
addi $r4, $R0, 800
add $r7, $r1, $r4

# EX-EX Case I & R -> I
addi $r8, $r7, 200

# EX-EX and MEM-EX Case R & R -> R
add $r9, $r8, $r7

NOP
NOP
NOP
NOP
NOP
NOP
NOP
