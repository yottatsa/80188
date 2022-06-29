all:
	make -C fw
	make -C gal

clean:
	make -C fw clean
	make -C gal clean

.PHONY: all clean
