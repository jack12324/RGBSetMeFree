;# Fake Load to Use
;# Load to use to an instruction writing to the zero register
;# No stalls expected
ldi $R0, 5000
add $R0, $R0, $R0
nop
nop
nop
nop
nop
nop
;.exit
