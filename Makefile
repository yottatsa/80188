all:
	make -C fw
	make -C gal
	make -C emu

clean:
	make -C fw clean
	make -C gal clean
	make -C emu clean

run:
	make -C fw
	make -C emu run

.PHONY: all clean run
