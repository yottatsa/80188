#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "i8250.h"
#include "ports.h"

struct structusart i8250;

uint8_t in8250(uint16_t portnum) {
	switch (portnum & 0x7f) {
		case 5:
			return i8250.lsr;
	}
	return (0);
}

void out8250(uint16_t portnum, uint8_t value) {
	switch (portnum & 0x7f) {
		case 0:
			if (i8250.lcr & UART_LCR_DLAB) {
				i8250.dll = value;
			} else {
				printf("%c", value);
			}
			break;
		case 3:
			i8250.lcr = value;
	}
}

void init8250() {
	 memset((void *)&i8250, 0, sizeof(i8250));
	 i8250.lcr = 0;
	 i8250.lsr = UART_LSR_THREMPTY;
	 set_port_write_redirector(0x00, 0x80, &out8250);
	 set_port_read_redirector(0x00, 0x80, &in8250);
}
