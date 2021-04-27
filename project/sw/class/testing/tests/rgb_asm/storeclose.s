# Store Close
# Tests several adjacent store operations
addi $r1, $R0, 1
addi $r2, $R0, 2 
addi $r3, $R0, 3
addi $r4, $R0, 4
addi $r5, $R0, 5
addi $r6, $R0, 6

# Store these three using store operations, hope these addresses are legal
sti $r1, 900
sti $r2, 901
sti $r3, 902
sti $r4, 904
sti $r5, 906
sti $r6, 910

# Unload
ldi $r7, 900
ldi $r8, 901
ldi $r9, 902
ldi $r10, 904
ldi $r11, 906
ldi $r12, 910

sll $R0, $R0, $R0
sll $R0, $R0, $R0
sll $R0, $R0, $R0
sll $R0, $R0, $R0
sll $R0, $R0, $R0

