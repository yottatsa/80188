# 80188 single board modular computer

v.0.1.0

## References
* [Tandy 2000 BIOS](https://www.retrotronics.org/svn/t2kbios/)
* AMD 80C186/80C188 Preliminary
* Intel 80C186EA/80C188EA Microprocessor User's Manual

## Notes

### 0.1.0r1

* minor: SYSBUS socket is too close to the CPU socket and can'tbe used with the wide connector
* minor: 16V8 /OE and GND pin names were swapped
* minor: UART1 labels are wrong
* major: 74x573 OE should be /OE
* major: 16V8 /RESET can't be used as input
* unknown: 22V10 Verification failed at address 0x16C5: File=0x01, Device=0x00
