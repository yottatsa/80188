CPU 186
USE16

; uncomment for the full ram image
;	org 0x0

segment .bss

segment .text		start=0xc0000	align=256
; 256k flash monitor
mon:
.loop	jmp .loop

segment .data		start=0xffc00	align=256
; useful to change parameters
UMCS:	dw 0xf800
LMCS:	dw 0x07f8

segment .setup		start=0xffe00	progbits
setup:
	mov ax,0xf
	mov ds,ax
	mov dx,0xffa0
	mov ax,[ds:UMCS]
	out dx,ax
	mov dx,0xffa2
	mov ax,[ds:LMCS]
	out dx,ax
	jmp 0xc:mon

segment .restart	start=0xffff0	progbits
; 80188 entrypoint
; we have only 15 bytes here, so just
; setting the cs and doing a "long jump"
	jmp 0xf:setup
