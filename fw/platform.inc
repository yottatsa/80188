%include "amd80c188.inc"

; serial (SC16C752B)
UART_BASE	equ	PCS0
%include "8250.S"
BAUD_9600	equ	120	

; AT-compatible RTC (DS12885T)
RTC_BASE	equ	PCS1
%include "rtc.inc"
