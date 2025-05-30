	;; Call CIO

	.export _ciov
	.include "atari.inc"

_ciov:
	LDX 	#$00
	JMP 	CIOV
	
