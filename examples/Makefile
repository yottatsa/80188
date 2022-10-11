FWSYM = ../fw
VPATH = $(FWSYM)

ASMFLAGS = -I$(FWSYM)

sources = hello.asm

all: $(sources:.asm=) 

clean:
	rm -f $(sources:.asm=.d) $(sources:.asm=)

%: %.asm
	nasm -f bin $(ASMFLAGS) $<

# deps
%.d: %.asm
	nasm $(ASMFLAGS) -M -MF $@ $<
include $(sources:.asm=.d)

.PHONY: all clean
