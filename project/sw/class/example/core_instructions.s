; Core Instructions
; -
; This test tests each arithmetic (i.e. all except loads, stores, branches or jumps)
; instruction in the MIPS core instruction set

; Adds and Subtractions
addi $r1, $r1, 100 ; $r1 = 100
addi $r1, $r1, 200 ; $r1 = 300
addi $r9, $R0, 1 ; $r9 = 1
add $r2, $R0, $r1 ; $r2 = 0 + $r1 (300)
add $r2, $r1, $R0 ; $r2 = 300
sub $r3, $r2, 50 ;
subi $r3, 50, $r2 ;

; Ors and Ands (Basic Logic)
or $r1, $R0, $r1 ; $r1 = 300
or $r2, $R0, $R0 ; $r2 = 0
xor $r3, $r1, $r2 ; $r3 = 300
and $r4, $r2, $r1 ; $r4 = 0
and $r4, $r1, $r3 ; $r4 = 300
neg $r5, $r4 ; $r5 = -300

; Shifts
sll $r2, $r9, ? ; $r2 = 1<<?
srl $r4, $a1, 1 ; $s2 = 1

; Stores
sb $a0, 1024($zero)
sh $a0, 2048($zero)
sw $a0, 3072($zero)

; Loads
lbu $t1, 0x1024($zero)
lhu $t2, 0x2048($zero)
lw $t3, 0x3072($zero)

; Branches and CV Setting
slt $s3, $s1, $s2 ; $s3 = 0
slti $s4, $s1, 0x100 ; $s4 = 1
sltiu $s5, $zero, -1 ; $s5 = 1 - Note in unsigned -1 is the largest integer
sltu $s6, $zero, $a0 ; $s6 = 1 - same as previous

beq $v0, $v0, SKIP_1
ori $k0, $zero, -1 ; error condition

SKIP_1:
bne $s3, $s5, SKIP_2
ori $k0, $zero, -1

TMP:
jr $ra
ori $k0, $zero, -1

SKIP_2:
j SKIP_3
ori $k0, $zero, -1

SKIP_3:
jal TMP
sll $zero, $zero, 0 ; No-op
sll $zero, $zero, 0 ; No-op
sll $zero, $zero, 0 ; No-op
sll $zero, $zero, 0 ; No-op
