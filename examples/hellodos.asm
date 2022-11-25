CPU 186
USE16

section .text
org 0x100
	mov	ah, 0x9
	mov	dx, _hello
	int	0x21

	mov	ax, 0x4c00
	int	0x21

section .data
_hello: db "Hello, world!",13,10,'$'
