#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "x186.h"

struct structx186 x186;

extern void set_port_write_redirector_16(uint16_t startport, uint16_t endport, void *callback);
extern void set_port_read_redirector_16(uint16_t startport, uint16_t endport, void *callback);

uint16_t inx186(uint16_t portnum) {
	switch (portnum & 0xff) {
		   case 0xfe:
			return(x186.rel);
	}
	return (0);
}

void outx186(uint16_t portnum, uint16_t value) {
	switch (portnum & 0xff) {
		   case 0xfe:
			x186.rel = value;
	}
}

void debugx186(uint16_t portnum, uint16_t value) {
	printf("debug(0x%x);\n", value);
}

void initx186() {
	 memset((void *)&x186, 0, sizeof(x186));
	 set_port_write_redirector_16((uint16_t) 0xff00, (uint16_t) 0xffff, &outx186);
	 set_port_read_redirector_16((uint16_t) 0xff00, (uint16_t) 0xffff, &inx186);
	 set_port_write_redirector_16((uint16_t) 0x220, (uint16_t) 0x220, &debugx186);
}
