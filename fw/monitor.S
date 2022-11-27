CPU 186
USE16

%include "reset.inc"


segment .bss
; not a real bss, since it's compiled as flat
_ES equ 0x0000
_SI equ 0x0002
_INPUTNUM equ 0x0004
_INPUTPOS equ 0x0006


segment .at		start=0xf0000
_copyright:	db	"CC-BY-SA, Atsuko Ito <me@atsukoi.to>, 2022", 0


segment .text		start=0xf0100	align=256
; monitor entry point
_mon:
	putch	0x0a
	mov	ax, cs
	mov 	ds, ax
	puts	.name
	jmp	_init
.name:	db	"memory monitor", 0
	

_init:
	mov	ax, 0x0000
	mov	ds, ax
	mov	word [_ES], 0x0000
	mov	es, [_ES]
	mov	word [_SI], 0x0100
	mov	si, [_SI]

_mainloop:
	
_status:
; prints current segment and address, the cursor
	putch	0x0a
	mov	ax, [_ES]
	putbyte	ah
	putbyte	al
	putch	":"
	mov	ax, [_SI]
	putbyte	ah
	putbyte	al
	putch	">"
	
_input:
; Input format is
; ([0-9A-Fa-f]{0,4})([<cmd>]{0,1})([0-9A-Fa-f]{0,4}}
; where the first group is the address to set to the address cursor,
; second group is the command,
; and third group is the argument.
;
; All three are optional:
; absence of command repeat last command (peek-and-step by default),
; command without address uses current address from the cursor,
; arguments are only needed for certain commands.

.init:
	mov	ax, 0
	mov	[_INPUTPOS], al
	mov	[_INPUTNUM], ax
	
.read:
	getch
	
	mov	bx, [_INPUTPOS]
	cmp	bl, 3
	ja	.cmd
	jmp	.dec

.procnum:
	inc	byte [_INPUTPOS]
	
.echo:
	putch	al
	jmp	.read
	
.dec:
	cmp	al, "0"
	jb	.hex
	cmp	al, "9"
	ja	.hex
	jmp 	.procnum
	
.hex:
	cmp	al, "A"
	jb	.hex2
	cmp	al, "F"
	ja	.hex2
	jmp 	.procnum
	
.hex2:
	cmp	al, "a"
	jb	.cmd
	cmp	al, "f"
	ja	.cmd
	jmp 	.procnum

.cmd:
	cmp	al, "n"
	je	_mainloop
	cmp	al, "R"
	je	_mon
	cmp	al, "%"
	je	_do_jump
	cmp	al, 0xd
	je 	_do_last
	cmp	al, 0xa
	je 	_do_last
	cmp	al, 0x20
	je 	_do_last

;	; read keycode part
;	putch	"\\"
;	putbyte	al
;	jmp	_mainloop
	
	jmp	.read
	
_do_last:
; <ENTER> and <SPACE> repeats last command

_do_peek:
; '?' prints a word from the cursor and increment the cursor
; maybe optional argument for specifying how much to print?
	putch	0x0a
	;mov	ax, [_INPUTNUM]
	;mov	si, ax
	mov	si, [_SI]
	mov	ax, [es:si]
	putch	":"
	putbyte	ah
	putbyte	al
	inc	word [_SI]
	inc	word [_SI]
	jmp 	_mainloop

_do_poke:
; ':' writes a byte or word to the cursor and increment the cursor
; maybe write until <ENTER> or <SPACE>?
	
_do_addr:
; '&' returns absolute address

_do_seg:
; '#' sets segment from the argument
; e.g. '0#0<ENTER>' will set the cursor to 0000:0000

_do_jump:
; '%' long jump to the segment:address
	mov	ax, 0
	mov	ds, ax
	jmp	_ES:_SI

_do_print:
; '.' prints null-terminated string

; indirect operations
; dunno if needed, might be useful
_do_ipeek:
; '*' prints a word from the address that stored in the current address

_do_input:
; 'i'/'I' reads byte/word from the port

_do_output:
; 'o'/'O' writes byte/word from the port
