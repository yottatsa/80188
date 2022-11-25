; interrupt service routine

;; PC BIOS interrupt call API

; check PIC_INSERV
; 05h Array Bounds or Print Screen
; 08h and PIC_INSERV_TIMER and PIC_ISR_IRT0 or RTC int
; 09h Keyb int
; 0Ah/10 and PIC_INSERV_D0
; 0Bh/11 and PIC_INSERV_D1
; 0Ch/12 and PIC_INSERV_I0
; 0Dh/13 and PIC_INSERV_I1
; 0Eh/14 and PIC_INSERV_I2
; 0Fh/15 and PIC_INSERV_I3
; 10h/16 Video services (output)
; 	AH=0Eh Teletype output
; 11h/17 Equipment list
; 12h/18 and PIC_INSERV_TIMER and PIC_ISR_IRT1 or Memsize
; 13h/19 and PIC_INSERV_TIMER and PIC_ISR_IRT2 or Low Level Disk Services
; 14h Serial port services
; 15h Misc sys servies
; 16h Keyboard services
; 17h Printer services
; 1Ah RTC Services
; 1Bh CtrlBreak handler
; 1Ch Timer tick handler

;; DOS API
; 20h Terminate program
; 21h Main DOS API
; 	AH=00h Program terminate
; 	AH=01h Character input
; 	AH=02h Character output
; 	AH=03h Auxiliary input
; 	AH=04h Auxiliary output
; 	AH=05h Printer output
; 	AH=09h Display string
; 29h Fast console output

_pic_reset:
%macro _pic_reset 0
; mask all interrupts
	mov	ax, 0xfd
	mov	dx, PIC_MASK
	out	dx, ax	

	mov	ax, 1
	mov	dx, PIC_PRIO
	out	dx, ax
%endmacro
