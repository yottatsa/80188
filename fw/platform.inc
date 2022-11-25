%include "amd80c188.inc"

%include "pic.S"

; serial (SC16C752B)
UART_BASE	equ	PCS0
BAUD_9600	equ	120	
; serial interrupt
UART_PIC_INT	equ	PIC_INT0
UART_PIC_INSERV equ	PIC_INSERV_I0
%include "8250.S"

; AT-compatible RTC (DS12885T)
RTC_BASE	equ	PCS1
RTC_MODE	equ	(RTC_CB_24 | RTC_CB_DM_BIN)

%include "rtc.S"

SYSTMR_TIMER	equ	PIC_TIMER
SYSTMR_	equ	PIC_TIMER
%include "timer.S"

