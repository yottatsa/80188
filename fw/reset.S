CPU 186
USE16
GLOBAL _restart, _putch, _version

%ifndef NOMAP
[map all reset.map]
%endif

%include "amd80c188.inc"
%include "platform.inc"

; uncomment for the full ram image
;	org 0x0


segment .text		start=0xc0000	align=256
; 256k flash monitor stub
_mon:		jmp _mon
		

segment .data		start=0xffc00	align=256
; platform constants in ROM space
; useful to read/change parameters
UMCS:	dw UMCS_256K_W3
LMCS:	dw LMCS_128K_W3
PACS:	dw PACS_0x00000_W3
MMCS:	dw 0x0000 	; not handled yet
MPCS:	dw MPCS_DEF


segment .setup		start=0xffe00	progbits
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
	mov ax,0xf000
	mov ds,ax
	mov dx,UMCS_REG
	mov ax,[ds:UMCS]
	out dx,ax
	mov dx,LMCS_REG
	mov ax,[ds:LMCS]
	out dx,ax

	say_what 0x1337

_set_pcs:
	mov dx,PACS_REG
	mov ax,[ds:PACS]
	out dx,ax
	mov dx,MPCS_REG
	mov ax,[ds:MPCS]
	out dx,ax

_set_sp:
	mov ax, 0x0
	mov ss, ax
	mov sp, LMCS_STACK

_init_serial:
	_baud_timer BAUD_9600_16x
	_serial_init I8251_8n1_16x
	nop
	nop

_test_serial:
		_serial_put_ch 0x10

		mov bx,_version
.loop
		mov	ax,[ds:bx]
		jz	.end
		mov	cx,ax
		call	0xf000:_putch
		inc	bx
		jmp	.loop
.end
		mov	cx, 0x10
		call	0xf000:_putch

_finish:
	say_what 0x7331

	jmp 0xc000:_mon


;; BIOS functions
_putch:
		push	ax
		push	dx

		_serial_put_ch cx

		pop	dx
		pop	ax	
		retf


segment .restart	start=0xffff0	progbits
; 80188 entrypoint
; CS = 0xffff
; we have only 15 bytes here, so just
; setting the cs and doing a "long jump"
_restart:	cli
		jmp	0xffe0:0
	
segment .version
; padding and version
_version:	db	"V0.0.12",0x0
