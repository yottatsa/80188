#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "i8250.h"

struct structusart i8250;

extern void set_port_write_redirector(uint16_t startport, uint16_t endport, void *callback);
extern void set_port_read_redirector(uint16_t startport, uint16_t endport, void *callback);

uint8_t in8250(uint16_t portnum) {
	switch (portnum & 0x7f) {
		case 5:
			return UART_LSR_THREMPTY;
	}
	return (0);
}

void out8250(uint16_t portnum, uint8_t value) {
	switch (portnum & 0x7f) {
		case 0:
			printf("%c", value);
	}
}

void init8250() {
	 memset((void *)&i8250, 0, sizeof(i8250));
	 set_port_write_redirector(0x00, 0x80, &out8250);
	 set_port_read_redirector(0x00, 0x80, &in8250);
}
