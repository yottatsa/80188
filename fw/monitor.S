CPU 186
USE16

%include "reset.inc"


segment .bss


segment .text		start=0xc0000	align=256
; 256k flash monitor entry point
_mon:
	puts	(_version & 0xffff)
	putch	0x0a
	
_echo:
	getch
	putch	al
	jmp	_echo
