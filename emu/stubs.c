#include <stdint.h>
#include "disk.h"
#include "blaster.h"

struct blaster_s blaster;
uint8_t doaudio = 0;
uint8_t port3da;

void tickaudio() {};
void tickssource() {};
void tickadlib() {};
void tickBlaster() {};


uint8_t keyboardwaitack;

uint32_t framedelay, textbase, usefullscreen;
uint8_t usessource, noscale, nosmooth, renderbenchmark, useconsole;
int32_t usesamplerate, latency;
uint8_t insertdisk (uint8_t drivenum, char *filename) {};
struct struct_drive disk[256];

uint8_t speakerenabled = 0;

uint8_t	vidmode = 9;
void vidinterrupt() {};
uint8_t readVGA (uint32_t addr32) {};
void diskhandler() {};
void readdisk (uint8_t drivenum, uint16_t dstseg, uint16_t dstoff, uint16_t cyl, uint16_t sect, uint16_t head, uint16_t sectcount) {};
uint8_t updatedscreen;
uint16_t	VGA_SC[0x100], VGA_CRTC[0x100], VGA_ATTR[0x100], VGA_GC[0x100];
void	writeVGA (uint32_t addr32, uint8_t value) {};
