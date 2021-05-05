addi $r1, $R0, 1	;0
addi $r2, $R0, 2	;1
addi $r3, $R0, 3	;2
addi $r4, $R0, 4	;3 Assert IO at 4th clock cycle, cpu should fininish these instructions
addi $r5, $R0, 5	;4
addi $r6, $R0, 6	;5
addi $r7, $R0, 7 	;6
addi $r8, $R0, 8	;7
addi $r9, $R0, 9 	;8
addi $r10, $R0, 10	;9
addi $r11, $R0, 11	;10
nop			;11
jmp 11			;12 infinite loop
addi $r1, $R0, 13	;13
addi $r2, $R0, 14	;14
jmp 11			;15 jump to infinite loop