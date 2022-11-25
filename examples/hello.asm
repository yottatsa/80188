CPU 186
USE16

%include "reset.inc"

section .text
org 0x100
	puts _hello
	warmreset

section .data
_hello: db "Hello, world!",0xa,0
