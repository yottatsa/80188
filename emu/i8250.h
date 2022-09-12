#include <stdint.h>

#define UART_LSR 5 // R: Line Status Register
#define UART_LSR_THREMPTY (1 << 5)
#define UART_LSR_RBRDATA (1 << 0)
#define UART_LCR_DLAB (1 << 7)
struct structusart {
  uint8_t lcr; // Line Control Register
  uint8_t lsr; // Line Status Register
  uint8_t dll; // DLAB1: Divisor Latch Low Byte
};
extern uint8_t i8250enabled;
extern void inputhandler();
extern void init8250();
