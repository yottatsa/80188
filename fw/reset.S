CPU 186
USE16

; for map generation only
GLOBAL UMCS, LMCS, PACS, MMCS, MPCS, MAXRAM, _restart, _putch, _getch, _version
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

; uncomment for the full ram image
;		org	0x0


segment .text		start=0xc0000	align=256
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
		;; entry point
		say_what 0xb007


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
		mov	ax,0xf000
		mov	ds,ax
		mov	dx,UMCS_REG
		mov	ax,[ds:UMCS]
		out	dx,ax
		mov	dx,LMCS_REG
		mov	ax,[ds:LMCS]
		out	dx,ax

_set_pcs:
		mov	dx,PACS_REG
		mov	ax,[ds:PACS]
		out	dx,ax
		mov	dx,MPCS_REG
		mov	ax,[ds:MPCS]
		out	dx,ax

;_set_sp:
;		;; ss = (((0x80 - 1) >> 6) << 12)
;		;; sp = (0x80 << 10) - 1
;		mov	ax, [ds:MAXRAM]
;		dec	ax
;		shr	ax, 6
;		shl	ax, 12
;		mov	ss, ax
;
;		mov	ax, [ds:MAXRAM]
;		shl	ax, 10
;		dec	ax
;		mov	sp, ax
;
;		say_what 0x1337


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
		mov	ax,[ds:SETUPSUM16]
		cmp	ax, bx
		jne	.rom_failure
		jmp	.end
.rom_failure:
		say_what 0x0bad
		jmp	.rom_failure
.end:
		say_what bx
		say_what 0x1337


_test_ram_words:
		mov	ax, 0x0
		mov	es, ax
		mov	si, 0x1234
		mov	cx, 0xabcd
		say_what si
		say_what cx
;; went past here
		mov	[es:si],cx
		mov	[es:si],cx
		mov	bx,0x0
		mov	bx,[es:si]
		cmp	bx, cx
		say_what bx
		jne	.ram_failure
		jmp	.end

.ram_failure:
.halt:
		say_what 0x2bad
		jmp	.halt
.end:
		say_what 0xcafe


_init_serial:
		_8250_init	BAUD_9600, UART_EFR_AUTOCTS, UART_8BITS, UART_FCR_FIFOSETUP
_print_version:
		mov		dx, UART_THR
		mov		bx, _version
.loop:
		mov		al,[ds:bx]
		cmp		al, 0
		jz		.end
		out		dx, al
		inc		bx
		jmp		.loop
.end
		mov		ax, 0x0a
		out		dx, al

_finish:
		_serial_puts	_ok
		jmp	0xc000:_mon

; text constants

_ok:		db	"OK",0x0a,0x0
;_bad:		db	"failed",0x0a,0x0


; BIOS functions
_putch:
;		push	ax
;		push	dx
;
;		_serial_putch cx
;
;		pop	dx
;		pop	ax
;		retf
;
_getch:
;		push	dx
;
;		mov	dx, I8251_C
;		mov	al, 0x34	; RTS, Reset Error Flag, RX
;		out	dx, al
;
;.wait_ready:	in	al, dx
;		and	al, 0x02	; RXRDY
;		jz	.wait_ready
;		mov	al, 0x10	; Reset Error Flag
;		out	dx, al
;
;		mov	dx,I8251_D
;		in	al, dx
;
;		xor	ah, ah
;		pop	dx
;		retf


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
