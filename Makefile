_def: help
	@exit 1

help:
	@echo 'make [ help | run | all | emu | fw | gal | clean ]'
	@echo '     run: compile emulator and firmware, and run emulator'
	@echo '     run COM=examples/hello: makes examples/hello if not exists and loads to 0x100'
	@echo '     all: compile all artifacts for flashing'

run: fw
ifneq ($(COM),)
	$(MAKE) -C emu run COM=../$(COM)
else
	$(MAKE) -C emu run
endif

all: fw gal

emu:
	$(MAKE) -C emu

fw:
	$(MAKE) -C fw

gal:
	$(MAKE) -C gal

clean:
	$(MAKE) -C fw clean
	$(MAKE) -C gal clean
	$(MAKE) -C emu clean
	$(MAKE) -C examples clean

.PHONY: _def help run all emu fw gal clean
