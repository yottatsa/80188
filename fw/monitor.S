CPU 186
USE16

%include "reset.sym"

segment .bss

segment .text		start=0xc0000	align=256
; 256k flash monitor entry point
_mon:

        mov cx,0xff
_send_serial:
	call 0xf000:_putch
        loop _send_serial
	jmp _mon

	;; and now just loop here
.nevermind:
	jmp .nevermind


