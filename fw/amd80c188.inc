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

PIC_INT3	equ	0xff3e
PIC_INT2	equ	0xff3c
PIC_INT1	equ	0xff3a
PIC_INT0	equ	0xff38
PIC_DMA1	equ	0xff36
PIC_DMA0	equ	0xff34
PIC_TIMER	equ	0xff32
PIC_ISR		equ	0xff30
PIC_IRR		equ	0xff2e
PIC_INSERV	equ	0xff2c
PIC_PRIO	equ	0xff2a
PIC_MASK	equ	0xff28
PIC_POLLSTAT	equ	0xff26
PIC_POLL	equ	0xff24
PIC_EOI		equ	0xff22

PIC_INSERV_I3		equ	(1 << 7)
PIC_INSERV_I2		equ	(1 << 6)
PIC_INSERV_I1		equ	(1 << 5)
PIC_INSERV_I0		equ	(1 << 4)
PIC_INSERV_D1		equ	(1 << 3)
PIC_INSERV_D0		equ	(1 << 2)
PIC_INSERV_TIMER	equ	(1 << 0)
PIC_ISR_IRT0		equ	(1 << 0)
PIC_ISR_IRT1		equ	(1 << 1)
PIC_ISR_IRT2		equ	(1 << 2)

PIC_MASK_MASKED		equ	(1 << 3)
PIC_LTM_LEVEL		equ	(1 << 4)

PCS0		equ	0x0
PCS1		equ	0x80
PCS2		equ	0x100
PCS3		equ	0x0180
