/*
  Fake86: A portable, open-source 8086 PC emulator.
  Copyright (C)2010-2013 Mike Chambers

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/* main.c: functions to initialize the different components of Fake86,
   load ROM binaries, and kickstart the CPU emulator. */

#include "config.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>

const uint8_t *build = BUILD_STRING;

extern uint8_t RAM[0x100000], readonly[0x100000];
extern uint8_t running, renderbenchmark;

extern void reset86();
extern void exec86 (uint32_t execloops);
extern uint8_t initscreen (uint8_t *ver);
extern void VideoThread();
extern doscrmodechange();
extern void handleinput();

#ifdef CPU_ADDR_MODE_CACHE
extern uint64_t cached_access_count, uncached_access_count;
#endif

extern uint8_t scrmodechange, doaudio;
extern uint64_t totalexec, totalframes;
uint64_t starttick, endtick, lasttick;

uint8_t *biosfile = NULL, verbose = 0, cgaonly = 0, useconsole = 0;
uint32_t speed = 0;


uint32_t loadbinary (uint32_t addr32, uint8_t *filename, uint8_t roflag) {
	FILE *binfile = NULL;
	uint32_t readsize;

	binfile = fopen (filename, "rb");
	if (binfile == NULL) {
			return (0);
		}

	fseek (binfile, 0, SEEK_END);
	readsize = ftell (binfile);
	fseek (binfile, 0, SEEK_SET);
	fread ( (void *) &RAM[addr32], 1, readsize, binfile);
	fclose (binfile);

	memset ( (void *) &readonly[addr32], roflag, readsize);
	return (readsize);
}

uint32_t loadrom (uint32_t addr32, uint8_t *filename, uint8_t failure_fatal) {
	uint32_t readsize;
	readsize = loadbinary (addr32, filename, 1);
	if (!readsize) {
			if (failure_fatal) printf("FATAL: ");
			else printf("WARNING: ");
			printf ("Unable to load %s\n", filename);
			return (0);
		}
	else {
			printf ("Loaded %s at 0x%05X (%lu KB)\n", filename, addr32, readsize >> 10);
			return (readsize);
		}
}

uint32_t loadbios (uint8_t *filename) {
	FILE *binfile = NULL;
	uint32_t readsize;

	binfile = fopen (filename, "rb");
	if (binfile == NULL) {
			return (0);
		}

	fseek (binfile, 0, SEEK_END);
	readsize = ftell (binfile);
	fseek (binfile, 0, SEEK_SET);
	fread ( (void *) &RAM[0x100000 - readsize], 1, readsize, binfile);
	fclose (binfile);

	memset ( (void *) &readonly[0x100000 - readsize], 1, readsize);
	return (readsize);
}

extern uint8_t insertdisk (uint8_t drivenum, char *filename);
extern void ejectdisk (uint8_t drivenum);
extern uint8_t bootdrive, ethif, net_enabled;
extern void doirq (uint8_t irqnum);
//extern void isa_ne2000_init(int baseport, uint8_t irq);
extern void parsecl (int argc, char *argv[]);
void timing();
void tickaudio();
void inittiming();
void initaudio();
void init8253();
void init8259();
void init8237();
extern void init8250();
extern void initx186();
extern void initVideoPorts();
extern void killaudio();
extern void initsermouse (uint16_t baseport, uint8_t irq);
extern void *port_write_callback[0x10000];
extern void *port_read_callback[0x10000];
extern void *port_write_callback16[0x10000];
extern void *port_read_callback16[0x10000];
extern void initadlib (uint16_t baseport);
extern void initsoundsource();
extern void isa_ne2000_init (uint16_t baseport, uint8_t irq);
extern void initBlaster (uint16_t baseport, uint8_t irq);

#ifdef NETWORKING_ENABLED
extern void initpcap();
extern void dispatch();
#endif

void printbinary (uint8_t value) {
	int8_t curbit;

	for (curbit=7; curbit>=0; curbit--) {
			if ( (value >> curbit) & 1) printf ("1");
			else printf ("0");
		}
}

uint8_t usessource = 0;
void inithardware() {
	printf ("Initializing emulated hardware:\n");
	memset (port_write_callback, 0, sizeof (port_write_callback) );
	memset (port_read_callback, 0, sizeof (port_read_callback) );
	memset (port_write_callback16, 0, sizeof (port_write_callback16) );
	memset (port_read_callback16, 0, sizeof (port_read_callback16) );
	printf ("  - x186 platform: ");
	initx186();
	printf ("OK\n");
	printf ("  - Intel 8250 USART: ");
	init8250();
	printf ("  - Intel 8253 timer: ");
	init8253();
	printf ("OK\n");
	printf ("  - Intel 8259 interrupt controller: ");
	init8259();
	printf ("OK\n");
	inittiming();
}

uint8_t dohardreset = 0;
uint8_t audiobufferfilled();

void *EmuThread (void *dummy) {
	while (running) {
			if (!speed) exec86 (10000);
			else {
				exec86(speed / 100);
				timing();
				usleep(10000);
			}
			if (dohardreset) {
				reset86();
				dohardreset = 0;
			}
		}
}

void *runconsole (void *dummy);

int main (int argc, char *argv[]) {
	uint32_t biossize;

	printf ("%s (c)2010-2013 Mike Chambers\n", build);
	printf ("[A portable, open-source 8086 PC emulator]\n\n");

	parsecl (argc, argv);

	memset (readonly, 0, 0x100000);
	biossize = loadbios (biosfile);
	if (!biossize) return (-1);
/*
#ifdef DISK_CONTROLLER_ATA
	if (!loadrom (0xD0000UL, PATH_DATAFILES "ide_xt.bin", 1) ) return (-1);
#endif
	if (biossize <= 8192) {
		loadrom (0xF6000UL, PATH_DATAFILES "rombasic.bin", 0);
		if (!loadrom (0xC0000UL, PATH_DATAFILES "videorom.bin", 1) ) return (-1);
	}
*/
	printf ("\nInitializing CPU... ");
	running = 1;
	reset86();
	printf ("OK!\n");

	inithardware();

	EmuThread(NULL);
	//exec86 (10000);

	return (0);
}
