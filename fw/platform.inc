I8251_D		equ	0x0180
I8251_C		equ	0x0182
I8251_8n1_16x	equ	0x4e		; 01 00 11 10
I8251_8e1_16x	equ	0x7e		; 01 11 11 10

BAUD_76800	equ	26

%macro  say_what 1
;; destroys AX, DX
		mov	dx, 0x220
		mov	ax, %1
		out	dx, ax

%endmacro

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

%macro	_serial_init 1
;; serial init
;; destroys AX, DX
		mov	dx, I8251_C
		mov	al, 0xff	; dummy
		out	dx, al
		nop
		nop
		mov	al, 0x40	; reset
		out	dx, al
		nop
		nop

		mov	al, %1		; mode
		out	dx, al
%endmacro

%macro	_serial_put_ch 1
;; blocking putch into serial
;; destroys AX, DX
		mov	dx, I8251_C
		mov	al, 0x01	; transmit
		out	dx, al

.wait_ready:	in	al, dx
		and	al, 0x01	; TXRDY
		jz	.wait_ready

		mov	dx,I8251_D
		mov	ax, %1
		out	dx, al

;		mov	dx, I8251_C
;.wait_empty	in	al, dx
;		and	al, 0x04;	; TXEMPTY
;		jz	.wait_empty
%endmacro
