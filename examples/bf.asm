; Copyright Nina Kalinina 2021
; brainfuck, compiled with open watcom, disassembled,
; and ported for Nano-BIOS

CPU 186
USE16

%include "reset.inc"

org 0x100

mov ax, 0xFFFE
mov sp, ax

mov ax, 0
mov bx, 0
mov cx, 0
mov dx, 0
mov ss, ax
mov ds, ax
mov di, ax
mov si, ax

jmp main_



_getc:
	getch
	ret
	;;mov		ax,0
	;;int		16H
	;;ret
	
	
_putc:
	push		bp
	mov		bp,sp
	mov		al,byte [bp+4]
	putch	al
	;;int		29H
	pop		bp
	ret		2
	
	;;push		bp
	;;mov		bp,sp
	;;mov		al,byte [bp+4]
	;;int		29H
	;;pop		bp
	;;ret		2


__puts:
	push		si
	push		bp
	mov		bp,sp
	mov		si,word [bp+6]
L$1:
	mov		al,byte [si]
	test		al,al
	je		L$2
	xor		ah,ah
	push		ax
	call		near _putc
	inc		si
	jmp		L$1
L$2:
	pop		bp
	pop		si
	ret		2
interpret_:
	push		bx
	push		cx
	push		dx
	push		si
	push		di
	mov		di, _cmd
	xor		si,si
L$3:
	mov		bx,di
	add		bx,si
	mov		al,byte [bx]
	test		al,al
	je		L$9
	mov		dl,al
	cmp		al,3eH
	jne		L$4
	inc	  word [_ptr]
	jmp		near L$14
L$4:
	cmp		al,3cH
	jne		L$5
	dec		word [_ptr]
	jmp		near L$14
L$5:
	cmp		al,2bH
	jne		L$6
	mov		bx,word _ptr
	inc		byte [bx]
	jmp		near L$14
L$6:
	cmp		al,2dH
	jne		L$7
	mov		bx,word _ptr
	dec		byte [bx]
	jmp		L$14
L$7:
	cmp		al,2eH
	jne		L$8
	mov		bx,word _ptr
	mov		al,byte [bx]
	xor		ah,ah
	push		ax
	call		near _putc
	jmp		L$14
L$8:
	cmp		al,2cH
	jne		L$10
	call		near _getc
	mov		bx,word _ptr
	mov		byte [bx],al
	jmp		L$14
L$9:
	jmp		L$15
L$10:
	cmp		al,5bH
	je		L$14
	cmp		al,5dH
	jne		L$14
	mov		bx,word _ptr
	cmp		byte [bx],0
	je		L$14
	mov		ax,1
	jmp		L$13
L$11:
	cmp		dl,5dH
	jne		L$12
	inc		ax
L$12:
	test		ax,ax
	jle		L$14
L$13:
	dec		si
	mov		bx,di
	add		bx,si
	mov		dl,byte [bx]
	cmp		dl,5bH
	jne		L$11
	dec		ax
	jmp		L$12
L$14:
	inc		si
	jmp		near L$3
L$15:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	ret
main_:
	push		bx
	push		cx
	push		dx
	push		si
	xor		si,si
	mov		ax, L$18
	push		ax
	call		near __puts
L$16:
	call		near _getc
	mov		byte [si+_cmd],al
	xor		ah,ah
	push		ax
	call		near _putc
	cmp		byte [si+_cmd],0dH
	jne		L$17
	mov		byte [si+_cmd],0
	mov		ax, L$19
	push		ax
	call		near __puts
	call		near interpret_
	mov		ax, L$20
	push		ax
	call		near __puts
	xor		si,si
	jmp		L$16
L$17:
	inc		si
	jmp		L$16


L$18:
    DB	42H, 46H, 20H, 53H, 68H, 65H, 6cH, 6cH
    DB	0dH, 0aH, 3eH, 3eH, 20H, 0
L$19:
    DB	0dH, 0aH, 0
L$20:
    DB	0dH, 0aH, 3eH, 3eH, 20H, 0

;;; NOTE: following needs to be in RAM
_cmd:
    TIMES	3000 DB 0
    DB	0, 0, 0, 0, 0, 0, 0, 0

_tape:
    TIMES	3000 DB 0
    DB	0, 0, 0, 0, 0, 0, 0, 0
_ptr:
    DW _tape
