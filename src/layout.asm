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
 
        ;; DEFINITIONS FOR LAYOUT OF 8080 BRAINFUCK COMPILER AND
        ;; CODE IN MEMORY

START           EQU 0000H       ;START LOCATION OF THE COMPILER IN MEMORY
BFSTART         EQU 0100H       ;START LOCATION OF BF CODE IN MEMORY
RAM             EQU 0800H       ;VOLATILE MEMORY LOCATION TO BE USED AS GENRAL PURPOSE RAM
STACK           EQU 1000H       ;MEMORY TO BE USED AS 8080'S STACK
NEGTAPE         EQU 0010H       ;HOW MANY CELLS PRIOR TO THE START OF THE TAPE TO INITIALISE
TAPE            EQU RAM+NEGTAPE
TAPELENGTH      EQU 00FFH       ;LENGTH OF TAPE - FOR NOW NEEDS TO BE 256
MAXSIZE         EQU 00FFH       ;MAXIMUM SIZE OF A BF PROGRAM