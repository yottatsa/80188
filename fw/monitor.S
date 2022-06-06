CPU 186
USE16

%include "amd80c188.inc"
%include "platform.inc"
%include "reset.sym"

segment .bss

segment .text		start=0xc0000	align=256
; 256k flash monitor entry point
_mon:

	say_what 0xc001
	say_what 0x5afe
	say_what 0xcafe

	;; and now just loop here
.nevermind:
	jmp .nevermind


