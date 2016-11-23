    .ORG    0H

    JMP     RUN

END:
    XCHG
    MVI     M,$C9       ;RET
    LXI     H,TAPE
    LXI     D,ENDTAPE

    MOV A,E
    SUB L
    MOV C,A
    MOV A,D
    SBB H
    MOV B,A


    MVI     A,0h
WIPELOOP:
    MOV     M,A
    INX     H
    DCR     C
    JNZ     WIPELOOP


    LXI     H,TAPE
    CALL    DUMP    ;START THE COMPILED CODE
    LXI     H,BFCODE
    HLT

RUN:
    LXI     H,BFCODE
    LXI     D,DUMP

LOOP:                           ;PARSE THE KNOWN BF SYMBOLS -+<>[],.
    MVI     A,$2D       ;-
    SUB     M
    CZ      DEC

    MVI     A,$2B   ;+
    SUB     M
    CZ      INR

    MVI     A,$3C   ;<
    SUB     M
    CZ      LEFT

    MVI     A,$3E   ;>
    SUB     M
    CZ      RIGHT

    MVI     A,$24   ;$ - MARKS EOF
    SUB     M
    JZ      END

CONTINUE:
    INX     H
    JMP     LOOP

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; BRAINFUCK INSTRUCTIONS FOLLOW HERE;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DEC:                            ;-
    XCHG
    MVI     M,$35   ;DCR M
    INX     H
    XCHG
    RET
INR:                            ;+
    XCHG
    MVI     M,$34               ;INR M
    INX     H
    XCHG
    RET
LEFT:                           ;<
    XCHG
    MVI     M,$2B               ;DCX H
    INX     H
    XCHG
    RET
RIGHT:                          ;>
    XCHG
    MVI     M,$23               ;INX H
    INX     H
    XCHG
    RET

TAPE:                           ;ONCE WE'RE COMPILED, REUSE THIS SPACE
                                ;FOR THE BRAINFUCK TAPE

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; BRAINFUCK CODE FOLLOWS HERE      ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BFCODE:                         ;HELLO WORLD FROM
                                ;https://codegolf.stackexchange.com/questions/55422/hello-world/68494#68494
    DB      '--<-<<+[+[<+>---'
    DB      '>->->-<<<]>]<<--'
    DB      '.<++++++.<<-..<<'
    DB      '.<+.>>.>>.<<<.++'
    DB      '+.>>.>>-.<<<+.'
    DB      '$'                 ;EOF
ENDTAPE:
DUMP:    DS 20H
