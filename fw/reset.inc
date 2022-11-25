; Provides interface to Nano-BIOS routines.

%ifdef NOSYM
GLOBAL _warmreset, _putch, _puts, _getch, _putbyte, _putdec, _version

%ifndef NOMAP
[map all reset.map]
%endif

%else
%include "reset.sym"

%endif

%macro  say_what 1
;; destroys AX, DX
	mov	dx, 0x220
	mov	ax, %1
	out	dx, ax
%endmacro

%macro	__callfar 1
%ifdef NOSYM
	call	0xf000:%1
%else
	call	0xf000:(%1 & 0xffff)
%endif
%endmacro

%macro	puts 1
	push	bx
	mov 	bx, %1
	__callfar _puts
	pop	bx
%endmacro

%macro	putch 1
	push	bx
	mov 	bl, %1
	__callfar _putch
	pop	bx
%endmacro

%macro	getch 0
	__callfar _getch
%endmacro

%macro	putbyte	1
	push	bx
	mov 	bl, %1
	__callfar _putbyte
	pop	bx
%endmacro

%macro	putdec	1
	push	bx
	mov 	bl, %1
	__callfar _putdec
	pop	bx
%endmacro

%macro	warmreset 0
%ifdef NOSYM
	call	0xf000:_warmreset
%else
	call	0xf000:(_warmreset & 0xffff)
%endif
%endmacro
