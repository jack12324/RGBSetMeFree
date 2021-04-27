# "No stall"
# This test cases tries to catch several instructions that
# may accidentally cause stalls but do not require them

# Load to use, separated by no-op
addi $r1, $R0, 700
sti $r1, 700
addi $r1, $R0, 500
sti $r1, 200
ldi $r1, 200
sll $R0, $R0, $R0
ldi $r1, 200

# Stores followed directly by a load
addi $r2, $R0, 15

sti $r2, 1015
ldi $r3, 1015
sti $r2, 3015
ldi $r4, 3015
sti $r2, 5015
ldi $r5, 5015

sll $R0, $R0, $R0
sll $R0, $R0, $R0
sll $R0, $R0, $R0
sll $R0, $R0, $R0
sll $R0, $R0, $R0
