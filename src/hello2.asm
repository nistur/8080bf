	INCLUDE "layout.asm"

	ORG BFSTART
	
	DB 	'++++++++[>++++[>'
	DB	'++>+++>+++>+<<<<'
	DB	'-]>+>+>->>+[<]<-'
	DB	']>>.>---.+++++++'
	DB	'..+++.>>.<-.<.++'
	DB	'+.------.-------'
	DB	'-.>>+.>++.$'

BFEND:
SIZE 	EQU BFEND-BFSTART
	DS MAXSIZE-SIZE
	NOP
	