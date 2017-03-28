                INCLUDE "layout.asm"

                ORG START
        
LOOPSTACKOFFSET EQU 0080H               ;OFFSET IN RAM OF THE JMP TARGET STACK
LOOPSTACKSIZE   EQU 0030H               ;SIZE OF THE JMP TARGET STACK
OUTPUTOFFSET    EQU LOOPSTACKOFFSET+LOOPSTACKSIZE ;OFFSET IN RAM OF THE COMPILED OUTPUT

OUTPUT          EQU RAM+OUTPUTOFFSET    ;LOCATION OF THE COMPILED OUTPUT
LOOPSTACK       EQU RAM+0000H           ;LOCATION OF TEMPORARY STACK FOR STORING JMP TARGETS
                                        ;[] LOOPS

RETARGET        EQU OUTPUT-BFSTART

        
COMPILECHECK    EQU BFSTART+MAXSIZE

RUN:    
        LXI     H,STACK
        SPHL
        XRA     A                       ;ZERO ACCUMULATOR THEN 
        LXI     H,BFSTART+COMPILECHECK  ;CHECK THAT THE LAST BYTE IN THE SECTION FOR  
        ADD     M                       ;BF CODE IS NON-NULL, MARKING IT AS ALREADY
        JNZ     RUNBF                   ;COMPILED, IN WHICH CASE, EXECUTE IT
        
COMPILE:        
        LXI     H,LOOPSTACK
        LXI     D,LOOPSTACK+2
        MOV     M,E
        INX     H
        MOV     M,D
        LXI     H,BFSTART
        LXI     D,OUTPUT

COMPILELOOP:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PARSE THE KNOWN SYMBOLS: - + < > [ ] , . $                                   ;;
;;                                                                              ;;
;; HL - LOCATION OF NEXT BF SYMBOL                                              ;;
;; DE - LOCATION OF NEXT OUTPUT                                                 ;;
;;                                                                              ;; 
;; GENERALLY THIS IS DONE AS FOLLOWS:                                           ;;
;; SET A TO VALUE WE'RE CHECKING                                                ;;
;; SUBTRACT CURRENT SYMBOL                                                      ;;
;; IF NOT ZERO, THE SYMBOL DOES NOT MATCH SO SKIP TO THE NEXT CHECK             ;;
;; OTHERWISE OUTPUT THE RELEVANT MACHINE CODE                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DEC:    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: -                               (2DH)                                ;;
;; ACTION: DECREMENT VALUE IN CURRENT CELL                                      ;;
;; OUTPUT: DCR M                           (35H)                                ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,2DH
        SUB     M
        JNZ     INC
        XCHG
        MVI     M,35H
        INX     H
        XCHG

INC:    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: +                               (2BH)                                ;;
;; ACTION: INCREMENT VALUE IN CURRENT CELL                                      ;;
;; OUTPUT: INR M                           (34H)                                ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,2BH
        SUB     M
        JNZ     LEFT
        XCHG
        MVI     M,34H
        INX     H
        XCHG

LEFT:   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: <                               (3CH)                                ;;
;; ACTION: MOVE LEFT TO PREVIOUS CELL                                           ;;
;; OUTPUT: DCX H                           (3BH)                                ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,3CH
        SUB     M
        JNZ     RIGHT
        XCHG
        MVI     M,2BH
        INX     H
        XCHG

RIGHT:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: >                               (3EH)                                ;;
;; ACTION: MOVE RIGHT TO NEXT CELL                                              ;;
;; OUTPUT: INX H                           (23H)                                ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,3EH               ;>
        SUB     M
        JNZ     OUT
        XCHG
        MVI     M,23H               ;INX H
        INX     H
        XCHG

OUT:    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: .                               (2EH)                                ;;
;; ACTION: OUTPUT CURRENT CELL                                                  ;;
;; OUTPUT: MOV A,M                         (7EH)                                ;;
;;         OUT 0                           (D3H 00H)                            ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,2EH
        SUB     M
        JNZ     IN
        XCHG
        MVI     M,07EH
        INX     H
        MVI     M,0D3H
        INX     H
        MVI     M,0H
        INX     H
        XCHG

IN:     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: ,                               (2CH)                                ;;
;; ACTION: READ INPUT TO CURRENT CELL                                           ;;
;; OUTPUT: IN 0                           (DBH 00H)                             ;; 
;;         MOV M,A                        (77H)                                 ;; 
;; NOTE: COMMENTED OUT AS IT'S UNUSED, TO SAVE SPACE (11 BYTES)                 ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,2CH
        SUB     M
        JNZ     LOOP
;;        XCHG
;;        MVI     M,0DBH
;;        INX     H
;;        MVI     M,0H
;;        INX     H
;;        MVI     M,077H
;;        INX     H
;;        XCHG


LOOP:   MVI     A,5BH               ;[
        SUB     M
        CZ      LOOPSTART

ENDLOOP:MVI     A,5DH               ;]
        SUB     M
        CZ      LOOPEND
        
        MVI     A,24H               ;$ - MARKS EOF
        SUB     M
        JZ      END
CONTINUE:
        INX     H
        JMP     COMPILELOOP

END:	XCHG
        MVI M,76H
        INX H
        XCHG
        
        LXI     H,OUTPUT
        LXI     D,BFSTART
        LXI     B,MAXSIZE

RELOCATE:
	MOV     A,M
        MVI     M,0H
        INX     H
        XCHG
        MOV     M,A
        INX     H
        XCHG
        DCX     B
        XRA     A
        ADD     B
        ADD     C
        JNZ     RELOCATE
                        ; the BF source     
RUNBF:  LXI     H,BFSTART+COMPILECHECK ; Flag this code as being compiled
        MVI     M,0FFH
        LXI     H,TAPE+TAPELENGTH;
        MVI     A,TAPELENGTH
CLEAR:  MVI     M,0H
        DCX     H
        DCR     A
        JNZ     CLEAR
        JMP     BFSTART
        
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
        SHLD    LOOPSTACK           ;Save LOOPSTACK with the previous entry
        MOV     D,M
        INX     H
        MOV     E,M

        XCHG                        ;SWITCH TO USING THE ADDRESS WE JUST LOADED

        POP     D
        
        
        ;; At this stage, we're all set, apart from that the address we have in DE
        ;; Is pointing to the location in the compilation space, so it needs to
        ;; be changed to be relative to the location it will be in future
        PUSH D                  ;We also need to store this as we'll need it again
        PUSH H
        PUSH PSW
        LXI H,RETARGET
        MOV A,E
        SUB L
        MOV E,A
        MOV A,D
        SBB H
        MOV D,A
        POP PSW
        POP H
        
        DCX     H
        MOV     M,D
        DCX     H
        MOV     M,E
        POP D                   ;get back the un-retargetted address, as we'll need it
        XTHL
        POP     B
        INX     B
        INX     B  
    
        XCHG
;;         ;;Similar to DE above, BC here needs to be retargetted to the final location
         PUSH H
         PUSH PSW
         LXI H,RETARGET
         MOV A,C
         SUB L
         MOV C,A
         MOV A,B
         SBB H
         MOV B,A
         POP PSW
         POP H
        
        MVI     M,0AFH              ;XRA A
        INX     H
        MVI     M,086H              ;ADD M
        INX     H
        MVI     M,0C2H              ;JNZ
        INX     H
        MOV     M,C                 ;THE LOCATION WE JUST GOT FROM THE STACK
        INX     H
        MOV     M,B
        INX     H
        
        XCHG
        RET
