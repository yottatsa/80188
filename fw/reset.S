CPU 186
USE16

%include "80188.inc"
%include "platform.inc"

; uncomment for the full ram image
;	org 0x0


segment .bss

segment .text		start=0xc0000	align=256
; 256k flash monitor
mon:

	say_what 0xc001
	say_what 0x5afe
	say_what 0xcafe
	;; and now just loop here
.nevermind:
	jmp .nevermind



segment .data		start=0xffc00	align=256
; platform constants in BIOS space
; useful to read/change parameters
UMCS:	dw UMCS_256K_W3
LMCS:	dw LMCS_128K_W3
PACS:	dw PACS_0x00000_W3
MMCS:	dw MMCS_DEF
MPCS:	dw MPCS_DEF

segment .setup		start=0xffe00	progbits
; main setup code

setup:
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

;_set_sp:
;	mov ax, 0x0
;	mov ss, ax
;	mov sp, 0x1000

_test_serial:
	_serial_init I8251_8n1_1x
	nop
	nop

	_serial_put_ch 0xaa

        mov cx,0xff
_send_serial:
	_serial_put_ch cx
        loop _send_serial

_finish:
	say_what 0x7331

	jmp _test_serial
	;jmp 0xc000:mon


segment .restart	start=0xffff0	progbits
; 80188 entrypoint
; CS = 0xffff
; we have only 15 bytes here, so just
; setting the cs and doing a "long jump"
	cli
	jmp 0xffe0:0
	
; padding and version
	db 0x0,0x0
	db " V0.0.10"

