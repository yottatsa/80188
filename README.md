# 80188 single board modular computer

* testing and firmware development: r1
* hardware development: r2

To emulate

    make run

To program

    make fw gal
    minipro -p SST39SF020A@PLCC32 --write fw/fw.bin
    minipro -p ... --write gal/....pld

To connect

    picocom -q --baud 9600 --imap lfcrlf --omap crlf [serial device]

## Configuration

* 8MHz 8086-compatible CPU
* 128KB low SRAM
* 256KB EEPROM (27C020) or Flash (SST39SF020) with in-system programming and software programming capabilities
* PC/104-compatible with 8-bit ISA bus
  - 80188 Timer A is routed to OSC
* Dual channel 16550-compatible UART
  - FTDI USB-Serial/6-pin connector on port A
  - 5V 9pin connector on port B
* AT-compatible RTC

## Notes

### r1

* minor: SYSBUS socket is too close to the CPU socket and can'tbe used with the wide connector
* minor: 16V8 /OE and GND pin names were swapped
* minor: UART1 labels are wrong
* major: 74x573 OE should be /OE
* major: 16V8 /RESET can't be used as input
* major: PLCC sockets are unreliable
* unknown: 22V10 Verification failed at address 0x16C5: File=0x01, Device=0x00
* feature: added in-system programming
* major: 39x flash doesn't work as /PGM is floating

### r0
* major: PCB socket is unreliable
