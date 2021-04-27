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
subi $r3, $r2, 50 ;
sub $r3, $r2, $r2 ;

; Ors and Ands (Basic Logic)
or $r1, $R0, $r1 ; $r1 = 300
or $r2, $R0, $R0 ; $r2 = 0
xor $r3, $r1, $r2 ; $r3 = 300
and $r4, $r2, $r1 ; $r4 = 0
and $r4, $r1, $r3 ; $r4 = 300
neg $r5, $r4 ; $r5 = -300

; Shifts
sll $r2, $r9, $r9 ; $r2 = 1<<1 = 2
slr $r3, $r2, $r9 ; $r3 = 2>>1 = 1
sar $r4, $r1, $R0 ; $r4 = 300>>0 = 300
sll $r8, $r2, $r9 ; r8 = 2<<1 = 4 for branching later

; Stores
st $r1, $r1 ; [300] = 300 this might be bad address, idk
sti $r4, 1024 ; [1024] = 300 this might be bad address, idk

; Loads
ld $r5, $r1 ; r5 = 300
ldi $r6, 1024 ; r6 = 300

; executed Branches and nops and RIN
nop
rin
nop
nop
nop
nop

add $r7, $R0, $R0 ; r7 = 0
beq $r8
nop ; skipped
add $r7, $R0, $r3 ; r7 = 1
bne $r8
nop ; skipped
sub $r7, $R0, $r3 ; r7 = -1
bon $r8
nop ; skipped
add $r7, $r3, $r3 ; r7 = 2
bnn $r8
nop ; skipped

; not executed Jumps
sll $r9, $r8, $r3 ; r9 = 4<<1 = 8
add $r9, $r8, $r9 ; r9 = 4 + 8 = 12
bnn $r9 ; skip the following jumps cause infinite loop 
jmp 268443648 ; hex 1000_2000, where our instruction mem starts
jal 268443648 ; same as JMP but saves address of the next instruction (JR) to LR
jr $LR ; if jumps are not skipped, this would jump to itself for no reason :D


nop
nop
nop
nop
nop


; end
