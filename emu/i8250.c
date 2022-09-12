#include "i8250.h"
#include "cpu.h"
#include "main.h"
#include "ports.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/poll.h>
#include <termios.h>
#include <unistd.h>

struct structusart i8250;
uint8_t i8250enabled = 0;
struct pollfd pfd = {.fd = 0, .events = POLLIN};
char buffer;

uint8_t in8250(uint16_t portnum) {
  switch (portnum & 0x7f) {
  case 0:
    i8250.lsr = UART_LSR_THREMPTY;
    return (uint8_t)buffer;
  case UART_LSR:
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

void set_term_quiet_input() {
  struct termios tc;
  tcgetattr(0, &tc);
  tc.c_lflag &= ~(ICANON | ECHO);
  tc.c_cc[VMIN] = 0;
  tc.c_cc[VTIME] = 0;
  tcsetattr(0, TCSANOW, &tc);
}

void inputhandler() {
  if (poll(&pfd, 1, 0) > 0) {
    char c = getchar();
    buffer = c;
    i8250.lsr = UART_LSR_THREMPTY | UART_LSR_RBRDATA;
    if (verbose)
      printf("keypress(); // = 0x%x \n", c);

    if (c == 0x18) // ^X
      running = 0;
    if (c == 0x2) // ^B
      dohardreset = 1;
  }
}

void init8250() {
  memset((void *)&i8250, 0, sizeof(i8250));
  i8250.lcr = 0;
  i8250.lsr = UART_LSR_THREMPTY;

  set_port_write_redirector(0x00, 0x80, &out8250);
  set_port_read_redirector(0x00, 0x80, &in8250);

  set_term_quiet_input();
  setvbuf(stdout, NULL, _IONBF, 0);

  i8250enabled = 1;
}
