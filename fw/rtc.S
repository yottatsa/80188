RTC_SECONDS	equ	 RTC_BASE
RTC_MINUTES	equ	(RTC_BASE+2)
RTC_HOURS	equ	(RTC_BASE+4)
RTC_DATE	equ	(RTC_BASE+7)
RTC_MONTH	equ	(RTC_BASE+8)
RTC_YEAR	equ	(RTC_BASE+9)
RTC_CENTURY	equ	(RTC_BASE+0x32)

RTC_CA		equ	(RTC_BASE+0x0a)
RTC_CB		equ	(RTC_BASE+0x0b)
RTC_CC		equ	(RTC_BASE+0x0c)
RTC_CD		equ	(RTC_BASE+0x0d)

RTC_CB_SET	equ	(1 << 7)
RTC_CB_DM_BIN	equ	(1 << 2)
RTC_CB_24	equ	(1 << 1)
RTC_CB_DSE	equ	(1 << 0)

_rtc_reset:
%macro _rtc_reset 1
		mov	dx, RTC_CB
		mov	ax, (%1 | RTC_CB_SET)
		out	dx, al

		mov 	ax, 0x61
		mov	dx, RTC_CA
		out	dx, al

		mov	dx, RTC_CC
		in	al, dx

		mov	dx, RTC_SECONDS
		mov	ax, 0
		out	dx, al

		inc	dx ;01
		out	dx, al

		inc	dx ;02
		out	dx, al

		inc	dx ;03
		out	dx, al

		inc	dx ;04
		out	dx, al

		inc	dx ;05
		out	dx, al

		mov	ax, 1
		inc	dx ;06
		out	dx, al

		inc	dx ;07
		out	dx, al

		inc	dx ;08
		out	dx, al

		inc	dx ;09
		out	dx, al

%ifndef PRE
; this won't work on preprocessing
%if RTC_MODE & RTC_CB_DM_BIN
		mov 	ax, 20
%else
		mov 	ax, 0x20
%endif
		mov	dx, RTC_CENTURY
		out	dx, al
%endif

		mov 	ax, 0x21
		mov	dx, RTC_CA
		out	dx, al

		mov	dx, RTC_CB
		mov	ax, %1
		out	dx, al
%endmacro

%macro _putrtc 1
%ifndef PRE
; this won't work on preprocessing
%if RTC_MODE & RTC_CB_DM_BIN
		putdec	%1
%else
		putbyte	%1
%endif
%endif
%endmacro
