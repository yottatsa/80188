UART_THR	equ	UART_BASE	; W: Transmitter Holding Buffer
UART_RBR	equ	UART_BASE	; R: Receiver Buffer
UART_DLL	equ	UART_BASE	; DLAB1: Divisor Latch Low Byte
UART_IER	equ	(UART_BASE+1)	; Interrupt Enable Register
UART_DLH	equ	(UART_BASE+1)	; DLAB1: Divisor Latch High Byte
UART_IIR	equ	(UART_BASE+2)	; R: Interrupt Identification Register
UART_FCR	equ	(UART_BASE+2)	; W: FIFO Control Register
UART_LCR	equ	(UART_BASE+3)	; Line Control Register
UART_MCR	equ	(UART_BASE+4)	; Modem Control Register
UART_LSR	equ	(UART_BASE+5)	; R: Line Status Register
UART_MSR	equ	(UART_BASE+6)	; R: Modem Status Register
UART_EFR	equ	(UART_BASE+2)	; Enhanced Feature Register

UART_LCR_DLAB		equ	(1 << 7)
UART_LCR_EFR		equ	0xbf	; 16C752 only
UART_FCR_FIFOENABLE	equ	(1 << 0)
UART_FCR_RXRESET	equ	(1 << 1)
UART_FCR_TXRESET	equ	(1 << 2)
UART_FCR_FIFOSETUP	equ	(UART_FCR_FIFOENABLE | UART_FCR_RXRESET | UART_FCR_TXRESET)
UART_LSR_THREMPTY	equ	(1 << 5)
UART_EFR_AUTOCTS	equ	(1 << 7)
UART_EFR_AUTORTS	equ	(1 << 6)
UART_EFR_HWHANDSHAKE	equ	(UART_EFR_AUTOCTS | UART_EFR_AUTORTS)


; mode register bits
UART_2STOP	equ	0x04
UART_15STOP	equ	0x04
UART_1STOP	equ	0x00

UART_NO_PARITY	equ	0x00

UART_8BITS	equ	0x03
UART_7BITS	equ	0x02
UART_6BITS	equ	0x01
UART_5BITS	equ	0x00


_8250_init:
%macro _8250_init 4
; divisor, UART_EFR_HWHANDSHAKE, (wl, nst, pa, br), UART_FCR_FIFOSETUP

;; set_baud
; enable DLAB
		mov	dx, UART_LCR
		mov	al, (UART_LCR_DLAB | 0x1D) ; default value
		out	dx, al
;set DLL, DLH
		mov	dx, UART_DLL
		mov	al, (%1 & 0xff)
		out	dx, al

		mov	dx, UART_DLH
		mov	al, ((%1 >> 8) & 0xff)
		out	dx, al

;; configure EFR (16c752 only)
		mov	dx, UART_LCR
		mov	ax, UART_LCR_EFR
		out	dx, al

; Enhanced functions TODO
;  - MCR[6] registers 
;  - FIFO control (TCR/TLR, FCR[5:4])
;  - HW (IER[7:6])
;  - SW

		mov	dx, UART_EFR
		mov	ax, %2
		out	dx, al

;; disable DLAB/EFR and set LCR
		mov	dx, UART_LCR
		mov	al, %3
		out	dx, al

;; enable FIFO
		mov	dx, UART_FCR
		mov	al, %4
		out	dx, al
%endmacro


_serial_putch:
%macro	_serial_putch 1
;; blocking putch into serial
;; destroys AX, DX
		mov	dx, UART_LSR
%%wait_empty:	in	al, dx
		and	al, UART_LSR_THREMPTY
		jz	%%wait_empty

		mov	dx, UART_THR
		mov	ax, %1
		out	dx, al
%endmacro


_serial_puts:
%macro	_serial_puts 1
		mov	bx, %1
%%loop:
		mov	al, [ds:bx]
		cmp	al, 0
		jz	%%end
		mov	cl, al
		_serial_putch	cx
		inc	bx
		jmp	%%loop
%%end:
%endmacro
