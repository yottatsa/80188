; Provides interface to BIOS routines.

%ifdef NOSYM
GLOBAL UMCS, LMCS, PACS, MMCS, MPCS, MAXRAM, _restart, _putch, _puts, _getch, _putbyte, _putdec, _version

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
	mov 	bx, %1
	__callfar _puts
%endmacro

%macro	putch 1
	mov 	bl, %1
	__callfar _putch
%endmacro

%macro	getch 0
	__callfar _getch
%endmacro

%macro	putbyte	1
	mov 	bl, %1
	__callfar _putbyte
%endmacro

%macro	putdec	1
	mov 	bl, %1
	__callfar _putdec
%endmacro
