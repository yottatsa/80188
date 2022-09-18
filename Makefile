all: fw gal
	make -C emu

fw:
	make -C fw

gal:
	make -C gal

blinkenlights:
	make -C fw/blinkenlights

clean:
	make -C fw clean
	make -C gal clean
	make -C emu clean
	make -C fw/blinkenlights clean

run: fw
	make -C emu run

step: fw blinkenlights
	bash -c 'cd fw/blinkenlights; ./blinkenlights.com -rt ../fw.bin'
	

.PHONY: all fw gal blinkenlights clean run
