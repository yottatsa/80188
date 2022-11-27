; Nano-BIOS; initialises peripherals and provides minimal IO.

CPU 186
USE16

%define	NOSYM
%include "reset.inc"
%include "platform.inc"


segment .begin		start=0xc0000
; 256k flash

segment .at		start=0xf0000

segment .text		start=0xf0100	align=256
; monitor stub
; this startpoint is arbitrary
_mon:		jmp	_mon

segment .ibm		start=0xfe000
; IBM PC XT compatible 8KB BIOS starts here

segment .ibmid		start=0xfe00d
		db	"IBM"

segment .ibmcopy	start=0xfe020
_copyright:	db	"CC-BY-SA, Atsuko Ito <me@atsukoi.to>, 2022", 0


segment .ibmtext	start=0xfe05b	progbits
; IBM PC XT BIOS entrypoint
_warmreset:	jmp	0xffd0:0
_hwid:		db	"AMD 80C188/SC16C752B/DS12885T ", 0


;segment .text		start=0xfe06.....
; Nano-BIOS functions
_putch:
;; write the byte from BL on console
		push	ax
		push	dx
		_serial_putch bx
		pop	dx
		pop	ax
		retf

_puts:
;; write the null-terminated string from [ds:bx]
		push	ax
		push	cx
		push	dx
		__serial_puts
		pop	dx
		pop	cx
		pop	ax
		retf

_getch:
;; return the byte in AL
		push	dx
		_serial_getch al
		pop	dx
		retf

_putnibble:
;; print a nibble from BL
		and	bl, 0xf
		cmp	bl, 9
		jg	.hex
		add	bl, '0'
		jmp	.print
.hex:
		add	bl, 'a' - 10
.print:
		call	0xf000:_putch
		retf

_putbyte:
;; print a byte in hex from BL
		push 	ax
		mov	al, bl
		shr	bl, 4
		call	0xf000:_putnibble
		mov	bl, al
		call	0xf000:_putnibble
		pop	ax
		retf

_putdec:
;; print a two digits decimal number from BL
;; todo CL digits number with leading zeros
		cmp	bl, 9
		jng	.leadzero
.reduceprint:
		push	ax
		mov	bl, 10
		div	bl
		mov	bl, al
		call	0xf000:_putnibble
		mov	bl, ah
		pop	ax
.print:
		call	0xf000:_putnibble
		retf
.leadzero:
		push	ax
		push	dx
		_serial_putch '0'
		pop	dx
		pop	ax
		jmp	.print
		

; UMCS is configured for upper 1024B after RESET
; addresses below 0xffc00 are unavailable at first
segment .data		start=0xffc00	align=256
; platform constants in ROM space
; useful to read/change parameters
SETUPSUM16:	dw	0x0000		; updated during build	
UMCS:		dw	UMCS_256K_W3
LMCS:		dw	LMCS_128K_W3
PACS:		dw	PACS_0x00000_W3
MMCS:		dw	0x0000 		; not handled yet
MPCS:		dw	MPCS_DEF
MAXRAM:		dw	0x80		; in KB

GLOBAL UMCS, LMCS, PACS, MMCS, MPCS, MAXRAM

; unused yet space

segment .setup		start=0xffd00	progbits
; main setup code
_setup:
		cli
		say_what 0xb007		; jumped to the setup code

		mov	ax, 0xf000
		mov	ds, ax

_test_setup_rom:
		mov	si, 0xfd00
		mov	bx, 0x0
		mov	cx, (0x300 >> 1)
.loop:
		add	bx, [ds:si]
		inc	si
		inc	si
		loop	.loop
.check:
		mov	ax, [ds:SETUPSUM16]
		cmp	ax, bx
		jne	.rom_failure
		jmp	.end
.rom_failure:
		say_what 0x0bad		; rom check failed
		jmp	.rom_failure
.end:
		say_what bx		; checksum
		say_what 0xc0de		; rom check passed

_platform:
;; proper init
;; Ensure relocation register upper bits clear

		mov    ax, RELREG_DEF
		mov    dx, RELREG_REG
		out    dx, ax

;; Readback relocation register as a sanity test
		mov    ax, 00ffh
		mov    bx, ax
		not    ax
		mov    dx, RELREG_REG
		in     ax, dx
		xor    ax, bx
		and    ax, 0dfffh
		jz     .soc_passed

.soc_failure:
		say_what 0xdead		; wrong SOC
		jmp   .soc_failure

.soc_passed:
		say_what 0xb105		; x186 SOC registers enabled

_init_pic:
		_pic_reset

_set_mem:
		mov	dx, UMCS_REG
		mov	ax, [ds:UMCS]
		out	dx, ax
		mov	dx, LMCS_REG
		mov	ax, [ds:LMCS]
		out	dx, ax

_set_pcs:
		mov	dx, PACS_REG
		mov	ax, [ds:PACS]
		out	dx, ax
		mov	dx, MPCS_REG
		mov	ax, [ds:MPCS]
		out	dx, ax

		say_what 0xcafe		; x186 SOC is ready

_test_ram_words:
		mov	ax, 0x0
		mov	es, ax
		mov	si, 0x1234
		mov	cx, 0xabcd
		say_what si		; ram test address
		say_what cx		; ram test value to write
		mov	[es:si], cx
		mov	bx, 0x0
		mov	bx, [es:si]
		say_what bx		; ram test value readback
		cmp	bx, cx
		jne	.ram_failure
		jmp	.end

.ram_failure:
.halt:
		say_what 0x2bad		; memory test failed
		jmp	.halt
.end:
		say_what 0x07ea		; memory test passed

_set_sp:
		;; ss = (((0x80 - 1) >> 6) << 12)
		;; sp = (0x80 << 10) - 1
		mov	ax, [ds:MAXRAM]
		dec	ax
		shr	ax, 6
		shl	ax, 12
		mov	ss, ax
		say_what ss		; 0x1000

		mov	ax, [ds:MAXRAM]
		shl	ax, 10
		dec	ax
		mov	sp, ax
		say_what sp		; 0xffff

_init_serial:
		_8250_init BAUD_9600, UART_EFR_AUTOCTS, UART_8BITS, UART_FCR_FIFOSETUP
		puts	_hwid
		puts	_board_ok
		puts	_version
		puts	_crlf

		say_what 0x1337		; we have serial
		xor	ax, ax
		xor	bx, bx

; from this point it's safe to use the stack, BIOS API,
; and serial IO instead of `say_what`

_check_rtc:
		mov	dx, RTC_CD
		in	al, dx
		mov	bx, 0x80
		cmp	ax, bx
		jne	.bad_rtc

		mov	dx, RTC_CB
		in	al, dx
		mov	bx, RTC_MODE
		cmp	ax, bx
		jne	.bad_rtc

		mov	dx, RTC_CA
		in	al, dx
		mov	bx, 0x21
		cmp	ax, bx
		jne	.bad_rtc

.datetime:
		puts	_datetime

		mov	dx, RTC_CENTURY
		in	al, dx
		_putrtc	al

		mov	dx, RTC_YEAR
		in	al, dx
		_putrtc	al
		putch	"-"
		
		mov	dx, RTC_MONTH
		in	al, dx
		_putrtc	al
		putch	"-"
		
		mov	dx, RTC_DATE
		in	al, dx
		_putrtc	al
		putch	"_"

		mov	dx, RTC_HOURS
		in	al, dx
		_putrtc	al
		
		putch	":"
		mov	dx, RTC_MINUTES
		in	al, dx
		_putrtc	al
		
		putch	":"
		mov	dx, RTC_SECONDS
		in	al, dx
		_putrtc	al

		putch	0x0a
		jmp	.end

.bad_rtc:
		puts	_bad_rtc
		putbyte	al
		putbyte	dl
		putch	0x0a

.reset_rtc:
		_rtc_reset RTC_MODE
.end:

_finish:
		;sti
		jmp	0xf000:_mon

; text constants

_crlf:		db	0xd, 0xa, 0
_board_ok:	db	"Board OK ", 0
_datetime:	db	"Time: ", 0
_bad_rtc:	db	"Bad CMOS: ", 0



segment .restart	start=0xffff0	progbits
; 80188 entrypoint
; CS = 0xffff
; we have only 15 bytes here, so just
; setting the cs and doing a "long jump"
_restart:
		jmp	0xffd0:0


; version and padding
		db	0, 0
_version:	db	"r0.1v0.6", 0
