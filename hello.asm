        INCLUDE "layout.asm"

        ORG BFSTART
        
        DB      '--<-<<+[+[<+>---'
        DB      '>->->-<<<]>]<<--'
        DB      '.<++++++.<<-..<<'
        DB      '.<+.>>.>>.<<<.++'
        DB      '+.>>.>>-.<<<+.'
        DB      '$'                 ;EOF
BFEND:
SIZE    EQU BFEND-BFSTART
        DS MAXSIZE-SIZE
        NOP