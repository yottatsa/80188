MODE := amalgamation

ifeq ($(MODE), amalgamation)
COSMO = cosmopolitan.h \
	ape.lds \
	crt.o \
	ape.o \
	ape-no-modify-self.o \
	cosmopolitan.a \
	ape-copy-self.o
COSMODIST = cosmopolitan-amalgamation-2.0.1.zip

BLINKENLIGHTS = ../cosmopolitan/tool/build/blinkenlights.c \
	../cosmopolitan/tool/build/lib/machine.c \
	../cosmopolitan/tool/build/lib/pty.c \
	../cosmopolitan/tool/build/lib/throw.c \
	../cosmopolitan/tool/build/lib/fpu.c \
	../cosmopolitan/tool/build/lib/stack.c \
	../cosmopolitan/tool/build/lib/breakpoint.c \
	../cosmopolitan/tool/build/lib/memory.c \
	../cosmopolitan/tool/build/lib/modrm.c \
	../cosmopolitan/tool/build/lib/flags.c \
	../cosmopolitan/tool/build/lib/address.c \
	../cosmopolitan/tool/build/lib/breg.c \
	../cosmopolitan/tool/build/lib/memorymalloc.c \
	../cosmopolitan/tool/build/lib/reset.c \
	../cosmopolitan/tool/build/lib/ldbl.c \
	../cosmopolitan/tool/build/lib/divmul.c \
	../cosmopolitan/tool/build/lib/sse.c \
	../cosmopolitan/tool/build/lib/ssemov.c \
	../cosmopolitan/tool/build/lib/cvt.c \
	../cosmopolitan/tool/build/lib/ssefloat.c \
	../cosmopolitan/tool/build/lib/cpuid.c \
	../cosmopolitan/tool/build/lib/time.c \
	../cosmopolitan/tool/build/lib/syscall.c \
	../cosmopolitan/tool/build/lib/op101.c \
	../cosmopolitan/tool/build/lib/bcd.c \
	../cosmopolitan/tool/build/lib/alu.c \
	../cosmopolitan/tool/build/lib/signal.c \
	../cosmopolitan/tool/build/lib/xlat.c \
	../cosmopolitan/tool/build/lib/xlaterrno.c \
	errnos.o \
	../cosmopolitan/tool//build/lib/fds.c \
	../cosmopolitan/tool//build/lib/iovs.c \
	../cosmopolitan/tool//build/lib/string.c \
	../cosmopolitan/tool//build/lib/ioports.c \
	../cosmopolitan/tool//build/lib/clmul.c \
	../cosmopolitan/tool//build/lib/bitscan.c \
	../cosmopolitan/tool//build/lib/high.c \
	../cosmopolitan/tool//build/lib/dis.c \
	../cosmopolitan/tool//build/lib/diself.c \
	../cosmopolitan/tool//build/lib/disarg.c \
	../cosmopolitan/tool//build/lib/disinst.c \
	../cosmopolitan/tool//build/lib/disspec.c \
	../cosmopolitan/tool//build/lib/demangle.c \
	../cosmopolitan/tool//build/lib/buffer.c \
	../cosmopolitan/tool//build/lib/stats.c \
	../cosmopolitan/tool//build/lib/loader.c \
	../cosmopolitan/tool//build/lib/argv.c \
	../cosmopolitan/tool//build/lib/xmmtype.c \
	../cosmopolitan/tool//build/lib/message.c \
	../cosmopolitan/tool//build/lib/lines.c \
	../cosmopolitan/tool//build/lib/instruction.c \
	../cosmopolitan/tool//build/lib/pml4tfmt.c \
	../cosmopolitan/tool//build/lib/debug.c \
	../cosmopolitan/tool//build/lib/cga.c \
	../cosmopolitan/tool//build/lib/panel.c \
	../cosmopolitan/tool//build/lib/mda.c \
	../cosmopolitan/tool//build/lib/pml4t.c \
	../cosmopolitan//dsp/scale/cdecimate2xuint8x8.c
	

CC = x86_64-elf-gcc
GCC = x86_64-elf-gcc
OBJCOPY = x86_64-elf-objcopy
CFLAGS = -g -Os -static -nostdlib -nostdinc -fno-pie -no-pie -mno-red-zone \
 -fno-omit-frame-pointer -pg -mnop-mcount -mno-tls-direct-seg-refs -gdwarf-4
INCLUDES = -include cosmopolitan.h -include adaptor.h
LDFLAGS = -fuse-ld=bfd -Wl,-T,ape.lds -Wl,--gc-sections \
   crt.o ape-no-modify-self.o cosmopolitan.a

CFLAGS += -I. -Icosmopolitan -I../cosmopolitan

all: blinkenlights.com

errnos.o: ../cosmopolitan/tool/build/lib/errnos.S
	$(CC) --compile $(CFLAGS) $^

blinkenlights.com.dbg: $(COSMO) $(BLINKENLIGHTS)
	$(CC) -o $@ $(CFLAGS) $(BLINKENLIGHTS) $(INCLUDES) $(LDFLAGS) 

blinkenlights.com: blinkenlights.com.dbg
	$(OBJCOPY) -S -O binary $^ $@

$(COSMODIST):
	curl https://justine.lol/cosmopolitan/$@ > $@

$(COSMO): $(COSMODIST)
	unzip -o $^
	touch $(COSMO)
endif

ifeq ($(MODE), prebuilt)
blinkenlights.com:
	curl https://justine.lol/blinkenlights/blinkenlights-latest.com >$@
	chmod +x $@
endif

clean:
	rm -f blinkenlights.com errnos.o

.PHONY: all clean
