CPU 186
USE16

%include "reset.inc"

segment .bss

_ES equ 0x0000
_SI equ 0x0002
_INPUTNUM equ 0x0004
_INPUTPOS equ 0x0006


segment .text		start=0xc0000	align=256
; 256k flash monitor entry point
_mon:
	putch	0x0a
	mov	ax, 0xf000
	mov 	ds, ax
	puts	(_version & 0xffff)
	mov	ax, 0xc000
	mov 	ds, ax
	puts	_monitor_name
	
_init:
	mov	ax, 0x0000
	mov	ds, ax
	mov	es, ax
	mov	[_ES], ax
	mov	[_SI], ax

_mainloop:
	
_status:
	putch	0x0a
	mov	ax, [_ES]
	putbyte	ah
	putbyte	al
	putch	":"
	mov	ax, [_SI]
	putbyte	ah
	putbyte	al
	putch	">"
	
_input_init:
	mov	ax, 0
	mov	[_INPUTPOS], al
	mov	[_INPUTNUM], ax
	
_read:
	getch
	
	mov	bx, [_INPUTPOS]
	cmp	bl, 3
	ja	_input_cmd
	jmp	_input_dec

_procnum:
	inc	byte [_INPUTPOS]
	
_echo:
	putch	al
	jmp	_read
	
_input_dec:
	cmp	al, '0'
	jb	_input_hex
	cmp	al, '9'
	ja	_input_hex
	jmp 	_procnum
	
_input_hex:
	cmp	al, 'A'
	jb	_input_hex2
	cmp	al, 'F'
	ja	_input_hex2
	jmp 	_procnum
	
_input_hex2:
	cmp	al, 'a'
	jb	_input_cmd
	cmp	al, 'f'
	ja	_input_cmd
	jmp 	_procnum

_input_cmd:
	cmp	al, 'n'
	je	_mainloop
	cmp	al, 'R'
	je	_mon
	cmp	al, 0xa
	je 	_do_last
	cmp	al, 0x20
	je 	_do_last

	; read keycode part
	;putch	'\'
	;putbyte	al
	;jmp	_mainloop
	
	jmp	_read
	
_do_last:
_do_peek:
	putch	0x0a
	;mov	ax, [_INPUTNUM]
	;mov	si, ax
	mov	si, [_SI]
	mov	ax, [es:si]
	putbyte	ah
	putbyte	al
	inc	word [_SI]
	inc	word [_SI]
	jmp 	_mainloop
	
_monitor_name:	db	" memory monitor",0x0
