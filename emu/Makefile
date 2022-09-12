CFLAGS=-O2 -DPATH_DATAFILES=\"$(DATAPATH)/\"
INCLUDE=-I.

all: fake86
	@ls -lh $^

fake86: main.c cpu.c ports.c i8253.c i8259.c timing.c parsecl.c stubs.c x186.c i8250.c cmos.c
	$(CC) $^ -o $@ $(CFLAGS) $(INCLUDE) $(LIBS)

run: fake86
	./$< -bios ../fw/fw.bin

debug: fake86
	./$< -bios ../fw/fw.bin -verbose

clean:
	rm -f fake86 cmos.bin *.o

format: main.h ports.h stubs.c x186.c x186.h i8250.c i8250.h cmos.c
	clang-format -i $^

.PHONY: all clean run debug format
