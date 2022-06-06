;; AMD 80C188
;; partially compatible with Intel 80188

RELREG_REG	equ	0xfffe
RELREG_DEF	equ	0x00ff

UMCS_REG	equ	0xffa0
LMCS_REG	equ	0xffa2
PACS_REG	equ	0xffa4
MMCS_REG	equ	0xffa6
MPCS_REG	equ	0xffa8

UMCS_256K_W3	equ	0xc03f
LMCS_128K_W3	equ	0x1fff

PACS_0x00000_W3	equ	0x3f
MMCS_DEF	equ	0x21ff
MPCS_DEF	equ	0xc0bf

TIMER0_MAXCNTA	equ	0xff52
TIMER0_CON	equ	0xff56

TIMER1_MAXCNTA	equ	0xff5a
TIMER1_CON	equ	0xff5e
