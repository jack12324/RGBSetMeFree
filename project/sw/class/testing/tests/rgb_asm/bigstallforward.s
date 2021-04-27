# Big Stall Forward
# This test case engages multiple forwarding paths and stalls
# It's a test for correctness
ldi $r9, SUCCESS

addi $r1, $r0, -1
sw $r1, 3000($r1)
lw $r2, 3000($r1)
sw $r2, 4000($r2)
lw $r3, 3000($r1)
lw $r4, 4000($r2)
sub $r1, $r3, $r4
beq $r9
sll $r1, $r1, 0
sll $r1, $r1, 0
sll $r1, $r1, 0
sll $r1, $r1, 0
.exit
sll $r1, $r1, 0

SUCCESS:
addi $r1, $r0, 999
sll $r1, $r1, 0
sll $r1, $r1, 0
sll $r1, $r1, 0
sll $r1, $r1, 0
sll $r1, $r1, 0
.exit
