all: fw gal
	make -C emu

fw:
	make -C fw

gal:
	make -C gal

clean:
	make -C fw clean
	make -C gal clean
	make -C emu clean

run: fw
	make -C emu run

.PHONY: all fw gal clean run
