        ;; definitions for layout of 8080 brainfuck compiler and
        ;; code in memory

START           EQU 0000H       ; Start location of the compiler in memory
BFSTART         EQU 0100H       ; Start location of BF code in memory
RAM             EQU 0800H       ; Volatile memory location to be used as genral purpose RAM
STACK           EQU 1000H       ; Memory to be used as 8080's stack
NEGTAPE         EQU 0010H       ; How many cells prior to the start of the tape to initialise
TAPE            EQU RAM+NEGTAPE
MAXSIZE         EQU 00FFH       ; Maximum size of a BF program