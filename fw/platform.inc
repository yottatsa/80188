; debug output
%macro  say_what 1
;; destroys AX, DX
		mov	dx, 0x220
		mov	ax, %1
		out	dx, ax
%endmacro


; serial
UART_BASE	equ	PCS0
%include "8250.inc"
BAUD_9600	equ	120	
