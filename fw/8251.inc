; https://tams.informatik.uni-hamburg.de/applets/hades/webdemos/76-mips/18-uart/uart.c.txt
UART_DATA	equ	UART_BASE
UART_CMD	equ	(UART_BASE+2)

; mode register bits
UART_STOP_MASK	equ	0xc0
UART_2STOP	equ	0xc0
UART_15STOP	equ	0x80
UART_1STOP	equ	0x40
UART_0STOP	equ	0x00	; invalid

UART_PARITY_MASK	equ	0x30
UART_EVEN_PARITY	equ	0x20
UART_ODD_PARITY	equ	0x10
UART_NO_PARITY	equ	0x00

UART_BITS_MASK	equ	0x0c
UART_8BITS	equ	0x0c
UART_7BITS	equ	0x08
UART_6BITS	equ	0x04
UART_5BITS	equ	0x00

UART_PRESCALER	equ	0x03
UART_X64	equ	0x03
UART_X16	equ	0x02
UART_X1	equ	0x01
UART_SYNC_MODE	equ	0x00	; not implemented


; command register bits
UART_EH		equ	0x80	; enter hunt-mode: not implemented
UART_IR		equ	0x40	; internal reset
UART_RTS	equ	0x20	; 1: nRTS=0  0: nRTS=1
UART_ER		equ	0x10	; reset error flags in status register
UART_SBRK	equ	0x08	; send break, forces TXD low
UART_RXE	equ	0x04	; receiver enable bit
UART_DTR	equ	0x02	; 1: nDTR=0  1: nDTR=1
UART_TXE	equ	0x01	; transmitter enable bit

; status register bits
UART_DSR	equ	0x80
UART_SYNDET_BD	equ	0x40
UART_FE		equ	0x20
UART_OE		equ	0x10
UART_PE		equ	0x08
UART_TXEMPTY	equ	0x04
UART_RXRDY	equ	0x02
UART_TXRDY	equ	0x01


I8251_D		equ	UART_DATA
I8251_C		equ	UART_CMD

%macro	_serial_init 2
;; serial init
;; destroys AX, DX
		mov	dx, UART_CMD
		mov	al, 0xff	; dummy
		out	dx, al
		nop
		nop
		mov	al, UART_IR
		out	dx, al
		nop
		nop

		mov	al, %1		; mode
		out	dx, al
		mov	al, %2		; cmd
		out	dx, al
%endmacro

%macro	_serial_cmd 1
;; serial cmd
;; destroys AX, DX
		mov	dx, UART_CMD
		mov	al, %1
		out	dx, al
%endmacro

%macro	_serial_putch 1
;; blocking putch into serial
;; destroys AX, DX
		mov	dx, UART_CMD
%%wait_empty:	in	al, dx
		and	al, UART_TXEMPTY
		jz	%%wait_empty

		mov	dx, UART_DATA
		mov	ax, %1
		out	dx, al

		mov	dx, UART_CMD
%%wait_ready:	in	al, dx
		and	al, 0x01	; TXRDY
		jz	%%wait_ready
%endmacro

%macro	_serial_puts 1
		mov	bx, %1
%%loop:
		mov	al,[ds:bx]
		cmp	al, 0
		jz	%%end
		mov	cl, al
		_serial_putch	cx
		inc	bx
		jmp	%%loop
%%end:
%endmacro
