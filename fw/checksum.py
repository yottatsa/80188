#!/usr/bin/env python3

import struct
import sys
with open(sys.argv[1], "rb+") as f:
    f.seek(0x3fd00)
    checksum = 0
    i = 0
    while f.peek(2):
        i = i + 1
        checksum = (checksum + struct.unpack('<H', f.read(2))[0]) % 0x10000
    f.seek(0x3fc00)
    print(hex(i*2), "bytes,", hex(checksum))
    f.write(struct.pack('<H', checksum))
