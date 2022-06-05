UMCS_256K_W3	equ	0xc03f
LMCS_128K_W3	equ	0x1fff

; base address will be be 0x0000
; pcs0 0x0000
; pcs1 0x0080
; pcs2 0x0100
; ...
; hex(int('0000' + bin(0x00000)[2:].zfill(20)[4:10] + '111' + bin(0x7)[2:], 2))

;PACS_0x00000_W3_TANDY equ	0x003e
PACS_0x00000_W3	equ	0x3f
;MPCS_TANDY	equ	0xc0be
MMCS_DEF	equ	0x21ff
MPCS_DEF	equ	0xc0bf

I8251_D		equ	0x0000
I8251_C		equ	0x0002
I8251_8n1_1x	equ	0x4d  ; 01 00 11 01	
I8251_8e2_1x	equ	0xfd

%macro  say_what 1
;; destroys AX, DX
		mov dx, 0x220
		mov ax, %1
		out dx, ax

%endmacro

%macro	_serial_init 1
;; serial init
;; destroys AX, DX
		mov dx,I8251_C
		mov al,0xff ; dummy
		out dx,al
		nop
		nop
		mov al,0x40 ; reset
		out dx,al
		nop
		nop

		mov al, %1; mode
		out dx,al
%endmacro

%macro	_serial_put_ch 1
;; blocking putch into serial
;; destroys AX, BX, DX
		mov	dx, I8251_C
		mov	al, 0x33	; transmit, RTS, ER, DTR??
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
