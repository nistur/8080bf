    ORG    0H

NEGTAPE EQU 10H
    
    JMP     RUN

END:
    XCHG
    MVI     M, 0C9H       ;RET
    LXI     H,TAPE
    LXI     D,ENDTAPE

    MOV A,E
    SUB L
    MOV C,A
    MOV A,D
    SBB H
    MOV B,A


    MVI     A,0H
WIPELOOP:
    MOV     M,A
    INX     H
    DCR     C
    JNZ     WIPELOOP


    LXI     H,TAPE+NEGTAPE      ;LEAVE SOME TAPE CELLS AS NEGATIVE CELLS
                                ;THIS IS NON-STANDARD, BUT SOME BF PROGRAMS
                                ;APPEAR TO EXPECT IT 
    CALL    DUMP                ;START THE COMPILED CODE
    LXI     H,BFCODE
    HLT


STACK:   DS 10H                 ;KEEP THE STACK OUTSIDE OF THE REWRITTEN BIT

TAPE:                           ;ONCE WE'RE COMPILED, REUSE THIS SPACE
                                ;FOR THE BRAINFUCK TAPE
LOOPSTACK:  DS 10H              ;WE NEED SOMEWHERE TO STORE THE
                                ;JMP TARGETS FOR THE [] LOOPS
RUN:
    LXI     H,STACK
    SPHL
    LXI     H,LOOPSTACK
    LXI     D,LOOPSTACK+2
    MOV     M,E
    INX     H
    MOV     M,D
    LXI     H,BFCODE
    LXI     D,DUMP

LOOP:                           ;PARSE THE KNOWN BF SYMBOLS -+<>[],.
    MVI     A,2DH       ;-
    SUB     M
    CZ      DEC

    MVI     A,2BH   ;+
    SUB     M
    CZ      INR

    MVI     A,3CH   ;<
    SUB     M
    CZ      LEFT

    MVI     A,3EH   ;>
    SUB     M
    CZ      RIGHT

    MVI     A,5BH               ;[
    SUB     M
    CZ      LOOPSTART

    MVI     A,5DH               ;]
    SUB     M
    CZ      LOOPEND

    MVI     A,2EH               ;.
    SUB     M
    CZ      OUTPUT
    
    MVI     A,24H   ;$ - MARKS EOF
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
    MVI     M,35H   ;DCR M
    INX     H
    XCHG
    RET
INR:                            ;+
    XCHG
    MVI     M,34H               ;INR M
    INX     H
    XCHG
    RET
LEFT:                           ;<
    XCHG
    MVI     M,2BH               ;DCX H
    INX     H
    XCHG
    RET
RIGHT:                          ;>
    XCHG
    MVI     M,23H               ;INX H
    INX     H
    XCHG
    RET
LOOPSTART:
    XCHG
    MVI     M,0C3H              ;JMP
    INX     H
    MVI     M,0FFH              ;PLACEHOLDER. WE WILL COME BACK HERE LATER
    INX     H
    MVI     M,0FFH
    INX     H
    XCHG
    PUSH    H
    LHLD    LOOPSTACK
    MOV     M,D
    INX     H
    MOV     M,E
    INX     H
    SHLD    LOOPSTACK
    POP     H
    RET
LOOPEND:
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; XRA     A                   ;MAKE SURE A==0                                  ;;
    ;; ADD     M                   ;COPY CELL LOCATION TO A                         ;;
    ;; JNZ     LOOPLABEL           ;IF THE CELL ISN'T ZERO, JUMP BACK TO MATCHING [ ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    PUSH    H
    PUSH    D

    LHLD    LOOPSTACK
    DCX     H                   ;REDUCE LOOPSTACK TO LOOK AT PREVIOUS ENTRY
    DCX     H
    SHLD    LOOPSTACK
    MOV     D,M
    INX     H
    MOV     E,M
    XCHG                        ;SWITCH TO USING THE ADDRESS WE JUST LOADED

    POP     D
    DCX     H
    MOV     M,E
    DCX     H
    MOV     M,D
    XTHL
    POP     B
    INX     B
    INX     B  
    
    XCHG
    MVI     M,0AFH              ;XRA A
    INX     H
    MVI     M,086H              ;ADD M
    INX     H
    MVI     M,0C2H              ;JNZ
    INX     H
    MOV     M,B                 ;THE LOCATION WE JUST GOT FROM THE STACK
    INX     H
    MOV     M,C

    XCHG
    RET

OUTPUT:
    XCHG
    MVI     M,07EH              ;MVI A,M
    INX     H
    MVI     H,0D3H              ;OUT
    INX     H
    MVI     H,0H
    INX     H
    XCHG
    RET
    
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
DUMP:    DS 0FFH
    NOP
