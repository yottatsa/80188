#define UART_LSR_THREMPTY	(1 << 5)
#define UART_LCR_DLAB 		(1 << 7)
struct structusart {
	uint8_t lcr; // Line Control Register
	uint8_t lsr; // Line Status Register
	uint8_t dll; // DLAB1: Divisor Latch Low Byte
};
