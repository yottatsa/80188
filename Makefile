_def: help
	@exit 1

help:
	@echo 'make [ help | run | all | emu | fw | gal | clean ]'
	@echo '     run: compile emulator and firmware, and run emulator'
	@echo '     all: compile all artifacts for flashing'

run: fw
	make -C emu run

all: fw gal

emu:
	make -C emu

fw:
	make -C fw

gal:
	make -C gal

clean:
	make -C fw clean
	make -C gal clean
	make -C emu clean

.PHONY: _def help run all emu fw gal clean
