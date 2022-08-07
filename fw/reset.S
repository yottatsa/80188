CPU 186
USE16

; for map generation only
GLOBAL UMCS, LMCS, PACS, MMCS, MPCS, MAXRAM, _restart, _putch, _puts, _getch, _version
%ifndef NOMAP
[map all reset.map]
%endif


; debug output
%macro  say_what 1
;; destroys AX, DX
		mov	dx, 0x220
		mov	ax, %1
		out	dx, ax
%endmacro


%include "amd80c188.inc"
%include "platform.inc"


segment .stub		start=0xc0000	align=256
; 256k flash monitor stub
_mon:
		jmp	_mon


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


segment .setup		start=0xffd00	progbits
; main setup code
_setup:
		say_what 0xb007		; jumped to the setup code


		;; proper init

		;; Ensure relocation register upper bits clear

		mov    ax, RELREG_DEF
		mov    dx, RELREG_REG
		out    dx, ax

		say_what 0xb105

		;; Readback relocation register as a sanity test

		mov    ax, 00ffh
		mov    bx, ax
		not    ax
		mov    dx, RELREG_REG
		in     ax, dx
		xor    ax, bx
		and    ax, 0dfffh
		jz     _soc_passed

_soc_failure:
		say_what 0xdead
		jmp    _soc_failure

_soc_passed:
		;; okay, time to set up memory
		say_what 0xc0de

_set_mem:
		mov	ax, 0xf000
		mov	ds, ax
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

_test_setup_rom:
		mov	si, 0xfd00
		mov	bx, 0x0
		mov	cx, 384
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
		say_what 0x0bad
		jmp	.rom_failure
.end:
		say_what bx		; checksum
		say_what 0x1337		; rom check passed


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
		say_what 0x2bad
		jmp	.halt
.end:
		say_what 0xcafe		; memory test passed


_init_serial:
		_8250_init BAUD_9600, UART_EFR_AUTOCTS, UART_8BITS, UART_FCR_FIFOSETUP
		mov	bx, _board_ok
		call	0xf000:_puts

_check_rtc:
		mov	dx, RTC_CD
		in	al, dx
		mov	bx, 0x80
		cmp	ax, bx
		jne	.bad_cmos

		mov	dx, RTC_CB
		in	al, dx
		mov	bx, 0x06
		cmp	ax, bx
		jne	.bad_cmos

		mov	dx, RTC_CA
		in	al, dx
		mov	bx, 0x21
		cmp	ax, bx
		jne	.bad_cmos

		mov	dx, RTC_MINUTES
		in	al, dx
		mov	bx, ax
		call	0xf000:_putch
		mov	bx, ":"
		call	0xf000:_putch
		mov	dx, RTC_SECONDS
		in	al, dx
		mov	bx, ax
		call	0xf000:_putch
		mov	bx, 0x0a
		call	0xf000:_putch
		jmp	.end
.bad_cmos:
		mov	bx, ax
                call    0xf000:_putch
		mov	bx, dx
                call    0xf000:_putch

		mov	bx, _bad_cmos
		call	0xf000:_puts

		mov	dx, RTC_CB
		mov	ax, 0xf6
		out	dx, al

		mov 	ax, 0x61
		mov	dx, RTC_CA
		out	dx, al

		mov	dx, RTC_CC
		in	al, dx

		mov	dx, RTC_SECONDS
		mov	ax, 0
		out	dx, al

		inc	dx
		mov	ax, 0xff
		out	dx, al

		inc	dx
		mov	ax, 0
		out	dx, al

		inc	dx
		mov	ax, 0xff
		out	dx, al

		inc	dx
		out	dx, al

		inc	dx
		out	dx, al

		mov	ax, 1
		inc	dx
		out	dx, al

		inc	dx
		out	dx, al

		inc	dx
		out	dx, al

		inc	dx
		out	dx, al

		mov 	ax, 0x21
		mov	dx, RTC_CA
		out	dx, al

		mov	dx, RTC_CB
		mov	ax, 0x6
		out	dx, al
		
.end:

_finish:
		;sti
		jmp	0xc000:_mon

; text constants

_board_ok:	db	"Board OK",0x0a,0x0
_bad_cmos:	db	"Bad CMOS",0x0a,0x0


segment .text		start=0xfff00	align=256
; BIOS functions
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
		push	dx
		_serial_getch al
		pop	dx
		retf


segment .restart	start=0xffff0	progbits
; 80188 entrypoint
; CS = 0xffff
; we have only 15 bytes here, so just
; setting the cs and doing a "long jump"
_restart:
		cli
		jmp	0xffd0:0


segment .version
; version and padding
_version:	db	"r0.1v0.2"
