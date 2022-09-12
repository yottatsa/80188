#include <stdint.h>

extern void set_port_write_redirector(uint16_t startport, uint16_t endport,
                                      void *callback);
extern void set_port_read_redirector(uint16_t startport, uint16_t endport,
                                     void *callback);
extern void set_port_write_redirector_16(uint16_t startport, uint16_t endport,
                                         void *callback);
extern void set_port_read_redirector_16(uint16_t startport, uint16_t endport,
                                        void *callback);
