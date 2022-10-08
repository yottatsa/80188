// from
// https://github.com/bit-hack/fake86/raw/1b34ba42803e0bc594910f85f557873a1e646dec/src/fake86/cmos.c
/*
  Fake86: A portable, open-source 8086 PC emulator.
  Copyright (C)2010-2013 Mike Chambers
               2019      Aidan Dodds

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
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
  USA.
*/

// http://bochs.sourceforge.net/techspec/CMOS-reference.txt

#include "main.h"
#include "ports.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

// static bool _enable_nmi;
static uint8_t _cmos_addr;
static uint8_t cmos_ram[128];

#define CMOS_FILE "cmos.bin"

void load_cmos(void) {
  FILE *binfile = NULL;
  uint32_t readsize;

  binfile = fopen(CMOS_FILE, "rb");
  if (binfile == NULL) {
    memset((void *)&cmos_ram, 0, sizeof(cmos_ram));
    return;
  }

  fseek(binfile, 0, SEEK_SET);
  fread((void *)&cmos_ram, 1, sizeof(cmos_ram), binfile);
  fclose(binfile);
}

void save_cmos(void) {
  FILE *binfile = NULL;
  uint32_t readsize;

  binfile = fopen(CMOS_FILE, "wb");
  fseek(binfile, 0, SEEK_SET);
  fwrite((void *)&cmos_ram, 1, sizeof(cmos_ram), binfile);
  fclose(binfile);
}

uint32_t dec2bcd_r(uint16_t dec) {
  if (cmos_ram[0x0b] & (1 << 2))
    return (dec);
  else
    return (dec) ? ((dec2bcd_r(dec / 10) << 4) + (dec % 10)) : 0;
}

static uint8_t _cmos_rtc_read(uint16_t port) {
  time_t t = time(NULL);
  struct tm *tm = localtime(&t);

  switch (port & 0x7f) {
  case 0x00: // seconds
    return dec2bcd_r(tm->tm_sec);
  case 0x01: // second alarm
  case 0x02: // minuites
    return dec2bcd_r(tm->tm_min);
  case 0x03: // minuite alarm
  case 0x04: // hours
    return dec2bcd_r(tm->tm_hour);
  case 0x05: // hour alarm
  case 0x06: // day of week
    return dec2bcd_r(tm->tm_wday + 1);
  case 0x07: // date of month
    return dec2bcd_r(tm->tm_mday);
  case 0x08: // month
    return dec2bcd_r(tm->tm_mon + 1);
  case 0x09: // year
    return dec2bcd_r(tm->tm_year % 100);
  // case 0x0b: // status register C r/w
  //   return 0x06;
  case 0x0D: // status register D r/w
    return 0x80;
  default:
    return cmos_ram[(uint8_t)(port & 0x7f)];
  }
}

static uint8_t _cmos_read(uint16_t port) {
  switch (port) {
  case 0x70:
    return _cmos_addr;
  case 0x71:
    if (_cmos_addr >= 0x00 && _cmos_addr <= 0x0E) {
      return _cmos_rtc_read(port);
    } else {
      return cmos_ram[_cmos_addr];
    }
  default:
    return 0;
  }
}

static void _cmos_write(uint16_t port, uint8_t value) {
  switch (port) {
  case 0x70:
    _cmos_addr = value & 0x7F;
    //_enable_nmi = value & 0x80 ? false : true;
    break;
  case 0x71:
    cmos_ram[_cmos_addr] = value;
    break;
  }
}

static void _cmos_rtc_write(uint16_t port, uint8_t value) {
  if (verbose)
    printf("cmos_write(%x, %x);\n", (uint8_t)(port & 0x7f), value);
  cmos_ram[(uint8_t)(port & 0x7f)] = value;
  save_cmos();
}

void initcmos() {
  load_cmos();

  // register as a directly connected device
  set_port_read_redirector(0x80, 0xff, _cmos_rtc_read);
  set_port_write_redirector(0x80, 0xff, _cmos_rtc_write);
}

// bool cmos_nmi_enabled(void) {
//   return _enable_nmi;
// }
