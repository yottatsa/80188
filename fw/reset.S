CPU 186
USE16

; uncomment for the full ram image
;	org 0x0



;;; MACRO

%macro  say_what 1
		;; destroys AX, DX
		mov dx, 0x220
		mov ax, %1
		out dx, ax

%endmacro



;;;;;;; CODE

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
  
  
  
  
.loop	jmp .loop



segment .data		start=0xffc00	align=256
; useful to change parameters
UMCS:	dw 0xc03f
LMCS:	dw 0x1fff

segment .setup		start=0xffe00	progbits
setup:
	;; entry point
	say_what 0xb007

	
	;; proper init
	
	;; Ensure relocation register upper bits clear

	mov    ax, 00ffh
	mov    dx, 0fffeh
	out    dx, ax
	
	say_what 0xb105

	;; Readback relocation register as a sanity test

	mov    ax, 00ffh
	mov    bx, ax
	not    ax
	mov    dx, 0fffeh
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
	mov dx,0xffa0
	mov ax,[ds:UMCS]
	out dx,ax
	mov dx,0xffa2
	mov ax,[ds:LMCS]
	out dx,ax
	
	say_what 0x1337

	jmp 0xc000:mon

segment .restart	start=0xffff0	progbits
; 80188 entrypoint
; CS = 0xffff
; we have only 15 bytes here, so just
; setting the cs and doing a "long jump"
	cli
	jmp 0xffe0:0
	
	db " V0.0.7"

