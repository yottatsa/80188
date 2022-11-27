CPU 186
USE16

%include "reset.inc"

section .text
org 0x100
	jmp real

section .real start=0x400
real:
	mov     ax, 0
	mov     ds, ax
	cli
	mov     word ds:[0x14 * 4], serial
	mov     word ds:[0x14 * 4 + 2], ax

	mov     word ds:[0x19 * 4], reboot
	mov     word ds:[0x19 * 4 + 2], ax
	sti

	mov	ah, 0x1
	mov	dx, 0

	mov	bx, _hello
.loop:
	mov	al, [ds:bx]
	cmp	al, 0
	jz	.end
	mov	cl, al
	int	0x14
	inc	bx
	jmp	.loop
.end:

	int	0x19

serial:
	putch	al	
	iret

reboot:
	warmreset
	iret

section .data
_hello: db "Hello, world!",0xa,0
