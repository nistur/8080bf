;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (c) 2017 Philipp Geyer                   					;;
;;											;;
;;	This software is provided 'as-is', without any express or implied		;;
;;	warranty. In no event will the authors be held liable for any damages		;;
;;	arising from the use of this software.						;;
;;											;;
;;	Permission is granted to anyone to use this software for any purpose,		;;
;;	including commercial applications, and to alter it and redistribute it		;;
;;	freely, subject to the following restrictions:					;;
;;											;;
;;	1. The origin of this software must not be misrepresented ; you must not	;;
;;	   claim that you wrote the original software. If you use this software		;;
;;	   in a product, an acknowledgment in the product documentation would be	;;
;;	   appreciated but is not required.						;;
;;	2. Altered source versions must be plainly marked as such, and must not be	;;
;;	   misrepresented as being the original software.				;;
;;	3. This notice may not be removed or altered from any source distribution.	;;
;;											;;
;;      Philipp Geyer                                                                   ;;
;;      nistur@gmail.com                                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;  ;;;;;;;  ;;;;;;;  ;;;;;;;  ;;;;;    ;;;;;      ;;;;;;;;    ;;;;;;;;;;;;;    ;;;;;
;;;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;;;;;;;;;;;  ;;;;;;;;;;;;;;;;;  ;;;;;
;;;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;;;;;;;;;;;  ;;;;;;;;;;;;;;;;;  ;;;;;
;;;;;;;  ;;;;;  ;;  ;;;;;  ;;;;;  ;;  ;;;    ;;;;;    ;;;;;;;;;;  ;;;;;;;;;;;;;;;;;  ;;;;;
;;;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;;;;;;;;;;;  ;;;;;;;;;;;;;;;;;  ;;;;;
;;;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;  ;;;  ;;;;;;;  ;;;  ;;;;;  ;;;  ;;;;;  ;;;;;
;;;;;;;  ;;;;;;;  ;;;;;;;  ;;;;;;;  ;;;;;    ;;;;;  ;;;;;;;  ;;;    ;;;  ;;;  ;;;    ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;; ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
        MVI     A,3EH
        SUB     M
        JNZ     OUT
        XCHG
        MVI     M,23H
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
;; OUTPUT: IN  0                           (DBH 00H)                            ;; 
;;         MOV M,A                         (77H)                                ;; 
;; NOTE: COMMENTED OUT AS IT'S UNUSED, TO SAVE SPACE (11 BYTES)                 ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,2CH
        SUB     M
        JNZ     LOOPSTART
;;        XCHG
;;        MVI     M,0DBH
;;        INX     H
;;        MVI     M,0H
;;        INX     H
;;        MVI     M,077H
;;        INX     H
;;        XCHG

LOOPSTART:      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: [                               (5BH)                                ;;
;; ACTION: LOOP TO MATCHING ]                                                   ;;
;; OUTPUT: JMP LOOPTEST                    (C3H FFH FFH)                        ;; 
;; NOTE: [] ARE EQUIVALENT TO A WHILE LOOP, SO THE TEST NEEDS TO GO FIRST. THE  ;; 
;;   BEST WAY TO DO THIS IS TO JMP TO THE TEST THEN JNZ BACK TO AFTER THIS JMP  ;; 
;;   TO PERFORM THE BODY OF THE LOOP. WHAT THIS MEANS IS THAT WE DON'T KNOW     ;; 
;;   WHERE THIS IS GOING TO JMP TO UNTIL WE FIND THE MATCHING ]. SO WE THEN HAVE;; 
;;   TO STORE THIS LOCATION SO WE CAN COME BACK AND TIE UP THE JMPS             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,5BH
        SUB     M
        JNZ     LOOPEND
        XCHG
        MVI     M,0C3H
        INX     H
        MVI     M,0FFH                 ;PLACEHOLDER. WE WILL COME BACK HERE LATER
        INX     H
        MVI     M,0FFH
        INX     H
        XCHG
        PUSH    H
        
        LHLD    LOOPSTACK              ;STORE THE LOCATION OF THE ADDRESS IN A 
        MOV     M,D                    ;STACK SO THAT WE CAN COME BACK LATER TO
        INX     H                      ;HOOK IT UP AGAIN
        MOV     M,E
        INX     H
        SHLD    LOOPSTACK
        POP     H

LOOPEND:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: ]                               (5DH)                                ;;
;; ACTION: LOOP BACK TO MATCHING [                                              ;;
;; OUTPUT: XRA A                           (AFH)                                ;; 
;;         ADD M                           (86H)                                ;; 
;;         JNZ STARTLOOP                   (C3H FFH FFH)                        ;; 
;; NOTE: AS MENTIONED PREVIOUSLY, THIS NEEDS TO SKIP BACK AND REWRITE THE       ;; 
;;   ADDRESS IN THE MATCHING [. THE ACTUAL TEST IS, INITIALISE A WITH 0, THEN   ;; 
;;   ADD THE CONTENTS OF THE CELL, IF IT'S ZERO THEN WE BREAK OUT OF THE LOOP.  ;; 
;;   ANOTHER THING TO NOTE IS, NOW THAT WE HAVE THE ADDRESSES, WE CAN APPLY AN  ;; 
;;   OFFSET TO BOTH OF THEM. THE REASON FOR THIS IS THAT THE CODE WILL BE COPIED;;
;;   TO A NEW LOCATION. THEREFORE THE JMPS WILL HAVE TO BE RETARGETTED          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,5DH
        SUB     M
        JNZ     EOF

        PUSH    H
        PUSH    D

        LHLD    LOOPSTACK
        DCX     H                   ;REDUCE LOOPSTACK TO LOOK AT PREVIOUS ENTRY
        DCX     H
        SHLD    LOOPSTACK           ;SAVE LOOPSTACK WITH THE PREVIOUS ENTRY
        MOV     D,M
        INX     H
        MOV     E,M

        XCHG                        ;SWITCH TO USING THE ADDRESS WE JUST LOADED

        POP     D                   ;LOAD OUTPUT ADDRESS BACK
        
        
        ;;AT THIS STAGE, WE'RE ALL SET, APART FROM THAT THE ADDRESS WE HAVE IN DE
        ;;IS POINTING TO THE LOCATION IN THE COMPILATION SPACE, SO IT NEEDS TO
        ;;BE CHANGED TO BE RELATIVE TO THE LOCATION IT WILL BE IN FUTURE
        PUSH    D                   ;WE ALSO NEED TO STORE THIS AS WE'LL NEED IT AGAIN

        PUSH    H
        PUSH    PSW
        LXI     H,RETARGET
        MOV     A,E
        SUB     L
        MOV     E,A
        MOV     A,D
        SBB     H
        MOV     D,A
        POP     PSW
        POP     H

	;;HL - LOCATION OF THE PLACEHOLDER JMP ADDRESS FOR THE ORIGINAL [
	;;DE - RETARGETTED LOCATION FOR JMP 
	
        DCX     H
        MOV     M,D
        DCX     H
        MOV     M,E
        POP     D                   ;GET BACK THE UN-RETARGETTED ADDRESS, AS WE'LL NEED IT
        XTHL
        POP     B
        INX     B
        INX     B  
    
        XCHG

	;;SIMILAR TO DE ABOVE, BC HERE NEEDS TO BE RETARGETTED TO THE FINAL LOCATION
        PUSH    H
        PUSH    PSW
        LXI     H,RETARGET
        MOV     A,C
        SUB     L
        MOV     C,A
        MOV     A,B
        SBB     H
        MOV     B,A
        POP     PSW
        POP     H
        
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

EOF:    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYMBOL: $                               (24H)                                ;;
;; ACTION: EOF MARKER. NO MORE BF CODE FOLLOWS                                  ;;
;; OUTPUT:                                                                      ;; 
;; NOTE: THIS ISN'T A STANDARD BF SYMBOL, HOWEVER IT APPEARS TO BE STANDARD IN  ;;
;;    SOME WAY TO THE 8080 OR POSSIBLY CP/M TO MARK THE END OF A STRING SO IN   ;; 
;;    KEEPING MORE WITH THE 8080, I'VE USED THIS RATHER THAN NULL TERMINATING   ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MVI     A,24H
        SUB     M
        JZ      END

CONTINUE:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; END OF LOOP                                                                  ;; 
;; MOVE ONTO NEXT SYMBOL AND REPEAT                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        INX     H
        JMP     COMPILELOOP

END:	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; END OF BF CODE PARSING HAS BEEN REACHED.                                     ;;
;; ALL THAT IS LEFT IS TO PUT A HLT AT THE END AND RELOCATE THE CODE TO IT'S    ;;
;; FINAL RESTING PLACE.                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        XCHG
        MVI     M,76H
        INX     H
        XCHG
        
        LXI     H,OUTPUT 		;PREPARE OUTPUT FOR THE RELOCATE
        LXI     D,BFSTART		;LOAD DESTINATION FOR THE RELOCATE
        LXI     B,MAXSIZE		;RATHER THAN CALCULATE THE ACTUAL SIZE
					;JUST USE THE MAX SIZE

RELOCATE:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MOVE ALL THE COMPILED CODE FROM HL TO DE WITH SIZE BC                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        MOV     A,M
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

RUNBF:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PREPARE THE ENVIRONMENT FOR THE COMPILED BF CODE TO BE EXECUTED             ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LXI     H,BFSTART+COMPILECHECK 	;FLAG THIS CODE AS BEING COMPILED
        MVI     M,0FFH
	
        LXI     H,TAPE+TAPELENGTH	;POINT TO THE END OF THE TAPE
        MVI     A,TAPELENGTH		;RIGHT NOW WE ONLY SUPPORT TAPE UP TO 255

CLEARTAPE:	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CLEAR THE BF TAPE TO ENSURE EVERYTHING STARTS AT ZERO EVERY TIME             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MVI     M,0H
        DCX     H
        DCR     A
        JNZ     CLEARTAPE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RUN THE CODE                                                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        JMP     BFSTART
 