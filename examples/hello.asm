CPU 186
USE16

%include "reset.inc"

org 0x100
puts _hello
loop:
	jmp loop

_hello: db "Hello, world!",0x0a,0

