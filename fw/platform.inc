; debug output
%macro  say_what 1
;; destroys AX, DX
		mov	dx, 0x220
		mov	ax, %1
		out	dx, ax

%endmacro


; serial
UART_BASE	equ	PCS3
%include "8251.inc"


; timer 1
BAUD_76800	equ	26

%macro _baud_timer 1
;; baud timer init
;; destroys AX, DX
		mov	ax, %1
		mov	dx, TIMER0_MAXCNTA
		out	dx, ax
		mov	ax, 0xc001	; 1100000000000001
		mov	dx, TIMER0_CON
		out	dx, ax
%endmacro
