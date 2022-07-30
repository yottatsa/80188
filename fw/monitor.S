CPU 186
USE16

%include "reset.sym"

segment .bss

segment .text		start=0xc0000	align=256
; 256k flash monitor entry point
_mon:
	jmp	_mon

_echo:
	call	0xf000:(_getch & 0xffff)
	mov	cx,ax
	call	0xf000:(_putch & 0xffff)
	jmp	_echo
