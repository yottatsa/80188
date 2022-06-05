sources = reset.S

# final build
fw.bin: reset
	cp $< $@

# assembly
%: %.S
	nasm $< -o $@

clean:
	rm -f fw.bin reset $(sources:.S=.d)

# deps
%.d: %.S
	nasm -M $^ > $@
include $(sources:.S=.d)

.PHONY: clean
