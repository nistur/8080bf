                INCLUDE "layout.asm"

                ORG START
        
LOOPSTACKOFFSET EQU 0080H                               ; Offset in RAM of the JMP target stack
LOOPSTACKSIZE   EQU 0030H                               ; Size of the JMP target stack
OUTPUTOFFSET    EQU LOOPSTACKOFFSET+LOOPSTACKSIZE       ; Offset in RAM of the compiled output

OUTPUT          EQU RAM+OUTPUTOFFSET ; Location of the compiled output
LOOPSTACK       EQU RAM+0000H        ; Location of temporary stack for storing JMP targets
                                     ; [] loops 

RETARGET        EQU OUTPUT-BFSTART

        
COMPILECHECK    EQU BFSTART+MAXSIZE

RUN:    
        LXI H,STACK
        SPHL
        XRA A
        LXI H,BFSTART+COMPILECHECK
        ADD M
        JNZ BFSTART
        
COMPILE:        
        LXI H,LOOPSTACK
        LXI D,LOOPSTACK+2
        MOV M,E
        INX H
        MOV M,D
        LXI H,BFSTART
        LXI D,OUTPUT
        CALL COMPILELOOP           ; Loop over the code until it's done compiling
        LXI H,OUTPUT
        LXI D,BFSTART
        LXI B,MAXSIZE

COPY:	MOV A,M
	MVI M,0H
        INX H
        XCHG
        MOV M,A
        INX H
        XCHG
        DCX B
	XRA A
	ADD B
	ADD C
        JNZ COPY
                        ; the BF source     
RUNBF:	LXI H,BFSTART+COMPILECHECK ; Flag this code as being compiled
        MVI M,0FFH
	LXI H,TAPE
        JMP BFSTART
        
COMPILELOOP:                    ;PARSE THE KNOWN BF SYMBOLS -+<>[],.
DEC:	MVI     A,2DH               ;-
        SUB     M
        JNZ   	INC
        XCHG
        MVI     M,35H   ;DCR M
        INX     H
        XCHG

INC:	MVI     A,2BH               ;+
        SUB     M
        JNZ     LEFT2
        XCHG
        MVI     M,34H               ;INR M
        INX     H
        XCHG

LEFT2:	MVI     A,3CH               ;<
        SUB     M
        JNZ     RIGHT2
        XCHG
        MVI     M,2BH               ;DCX H
        INX     H
        XCHG

RIGHT2:	MVI     A,3EH               ;>
        SUB     M
        JNZ     LOOP
        XCHG
        MVI     M,23H               ;INX H
        INX     H
        XCHG

LOOP:	MVI     A,5BH               ;[
	SUB     M
	CZ      LOOPSTART

ENDLOOP:MVI     A,5DH               ;]
	SUB     M
	CZ      LOOPEND

OUT2:	MVI     A,2EH               ;.
	SUB     M
	CZ      OUT

IN2:	MVI A,2CH
        SUB M
        CZ IN
        
        MVI     A,24H               ;$ - MARKS EOF
        SUB     M
        JNZ	CONTINUE
	XCHG
	MVI M,76H
	INX H
	XCHG
	RET
        
CONTINUE:
        INX     H
        JMP     COMPILELOOP

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
	PUSH D			;We also need to store this as we'll need it again
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
	POP D 			;get back the un-retargetted address, as we'll need it
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
	INX 	H
	
        XCHG
        RET

OUT:
        XCHG
        MVI     M,07EH              ;MVI A,M
        INX     H
        MVI     M,0D3H              ;OUT
        INX     H
        MVI     M,0H
        INX     H
        XCHG
        RET


IN:
;;         XCHG
;;         MVI M,0DBH              ; IN
;;         INX H
;;         MVI M,0H
;;         INX H
;; 	MVI M,077H              ; MOV M,A
;;         INX H
;;         XCHG
        RET