CFLAGS=-O2 -DPATH_DATAFILES=\"$(DATAPATH)/\"
INCLUDE=-I.

all: fake86

fake86: main.c cpu.c ports.c i8253.c i8259.c timing.c parsecl.c stubs.c
	$(CC) $^ -o $@ $(CFLAGS) $(INCLUDE) $(LIBS)
